//! AI Gateway — gRPC server entry point.
//!
//! Loads configuration, initializes all Rust AI/ML engines, and starts the
//! tonic gRPC server that Go microservices call for inference. The standard
//! gRPC health service reports the gateway as SERVING and each local vision
//! model as SERVING / NOT_SERVING so orchestration can tell real inference
//! from demo/external fallback.

use std::path::Path;
use std::time::Duration;

use tonic::transport::Server;
use tower::limit::GlobalConcurrencyLimitLayer;
use tower::load_shed::LoadShedLayer;
use tower::ServiceBuilder;
use tonic_health::server::health_reporter;
use tonic_health::ServingStatus;
use tracing_subscriber::{fmt, EnvFilter};

use ai_gateway::config::Config;
use ai_gateway::proto::ai_gateway_service_server::AiGatewayServiceServer;
use ai_gateway::service::AiGatewayServiceImpl;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize tracing / logging.
    fmt()
        .with_env_filter(
            EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| EnvFilter::new("ai_gateway=info,tower_http=debug")),
        )
        .init();

    // Load configuration.
    let config_path = std::env::args()
        .nth(1)
        .or_else(|| std::env::var("AI_GATEWAY_CONFIG").ok())
        .unwrap_or_else(|| "config.toml".to_string());

    let config = if Path::new(&config_path).exists() {
        tracing::info!(path = %config_path, "Loading configuration from file");
        Config::from_file(Path::new(&config_path))?
    } else {
        tracing::warn!(
            path = %config_path,
            "Config file not found, using defaults"
        );
        Config::default()
    };

    let addr = config.server.address.parse()?;
    let timeout = Duration::from_secs(config.server.request_timeout_secs);

    tracing::info!(
        address = %config.server.address,
        max_concurrent = config.server.max_concurrent_requests,
        timeout_secs = config.server.request_timeout_secs,
        "Starting AI Gateway gRPC server"
    );

    // Build the service with all engine modules.
    let ai_service = AiGatewayServiceImpl::new(&config)
        .map_err(|e| anyhow::anyhow!("failed to initialize AI engines: {e}"))?;

    // gRPC health: the gateway itself plus one entry per local vision model.
    let (mut reporter, health_service) = health_reporter();
    reporter
        .set_serving::<AiGatewayServiceServer<AiGatewayServiceImpl>>()
        .await;
    for status in ai_service.vision_model_status() {
        let name = format!("ai_gateway.vision.{}", status.task.name());
        let serving = if status.loaded {
            ServingStatus::Serving
        } else {
            ServingStatus::NotServing
        };
        reporter.set_service_status(&name, serving).await;
        if status.shared {
            tracing::info!(
                task = status.task.name(),
                version = %status.version,
                "task served by the shared multi-task model"
            );
        }
    }

    // Start the gRPC server.
    //
    // Two limits, because they bound different things.
    //
    // `concurrency_limit_per_connection` is tonic's, and it is per connection
    // by definition: nine services dial this gateway, seventy pods at their
    // autoscaler ceilings, so that number multiplies by the number of callers
    // rather than capping the total. It is kept because a single misbehaving
    // connection should still be bounded on its own.
    //
    // The global layer is the one that bounds the process. Inference here is
    // CPU- and memory-bound against a fixed replica count, so past some
    // concurrency the work does not go faster — it queues, and a queued request
    // is one whose caller is still holding a slot waiting for it.
    //
    // LoadShed sits outside the limit so that reaching it returns an error
    // immediately rather than exerting backpressure. Backpressure on an HTTP/2
    // connection stops the whole connection being read, which head-of-line
    // blocks every other stream a caller had in flight on it; shedding one
    // request lets its caller's adaptive limiter see the refusal and narrow,
    // which is the signal the whole arrangement runs on.
    let layers = ServiceBuilder::new()
        .layer(LoadShedLayer::new())
        .layer(GlobalConcurrencyLimitLayer::new(
            config.server.max_global_concurrent_requests,
        ))
        .into_inner();

    Server::builder()
        .timeout(timeout)
        .concurrency_limit_per_connection(config.server.max_concurrent_requests)
        .layer(layers)
        .add_service(health_service)
        .add_service(AiGatewayServiceServer::new(ai_service))
        .serve(addr)
        .await?;

    Ok(())
}
