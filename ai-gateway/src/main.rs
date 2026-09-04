//! AI Gateway — gRPC server entry point.
//!
//! Loads configuration, initializes all Rust AI/ML engines, and starts the
//! tonic gRPC server that Go microservices call for inference.

use std::path::Path;
use std::time::Duration;

use tonic::transport::Server;
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

    // Start the gRPC server.
    Server::builder()
        .timeout(timeout)
        .concurrency_limit_per_connection(config.server.max_concurrent_requests)
        .add_service(AiGatewayServiceServer::new(ai_service))
        .serve(addr)
        .await?;

    Ok(())
}
