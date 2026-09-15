# Offline development

The platform talks to four external providers: Open-Meteo (forecast and
archive), OpenWeather One Call, PlantNet, and Google Cloud Vision. Each one is
a reason a developer cannot work on a train, a reason CI needs a secret, and a
reason a test fails for something other than the code under test.

`cmd/mockserver` replaces all four. It serves them on one port, at the paths
the real clients use, with responses those clients actually parse.

```bash
make mockserver          # or: go run ./cmd/mockserver -v
docker compose --profile offline up mockserver
```

## Pointing services at it

Weather comes from environment variables:

```bash
OPEN_METEO_FORECAST_URL=http://localhost:8199/v1/forecast
OPEN_METEO_ARCHIVE_URL=http://localhost:8199/v1/archive
OPENWEATHER_BASE_URL=http://localhost:8199/data/3.0/onecall
OPENWEATHER_API_KEY=mock
```

Under compose, substitute `mockserver` for `localhost`. `.env.example` carries
these commented out; left unset, the adapters call the real public APIs.

Vision is configured in TOML rather than the environment, because that is how
the ai-gateway reads it. `ai-gateway/config.offline.toml` is ready to use:

```bash
AI_GATEWAY_CONFIG=ai-gateway/config.offline.toml cargo run -p ai-gateway
```

Note the gateway only calls an external provider when no local ONNX model is
configured for the task. The offline config clears the model paths so that the
external path is the one taken; if you want to exercise local inference
instead, point them at real model directories.

## What it serves

| Method | Path | Provider |
|--------|------|----------|
| GET | `/v1/forecast` | Open-Meteo forecast |
| GET | `/v1/archive` | Open-Meteo archive |
| GET | `/data/3.0/onecall` | OpenWeather One Call 3.0 |
| POST | `/v2/identify/all` | PlantNet |
| POST | `/v1/images:annotate` | Google Cloud Vision |
| POST | `/analyze` | the gateway's own "custom" provider |
| GET | `/__mock/health` | liveness |
| GET | `/__mock/routes` | this table, as JSON |
| * | `/__mock/faults` | fault injection |

A 404 returns the same list, because a wrong path in a base URL is the usual
cause.

## Determinism

Every response is a pure function of its inputs. The same coordinates and date
always give the same weather; the same image bytes always give the same
diagnosis. That is what makes the mock usable in a test rather than only in a
demo — a fixture image can be checked in and asserted against.

`-now 2026-03-15T10:00:00Z` freezes the clock, so that forecast windows, which
are relative to today, stay fixed across runs too.

The numbers are also meant to be plausible, which is a separate property and
just as deliberate. Weather follows an annual cycle by latitude, a diurnal
cycle by hour, humidity that moves against temperature, and rainfall
concentrated in the monsoon; dew point is derived from temperature and humidity
rather than drawn independently, so it cannot exceed the air temperature. A mock
that returned 500 °C, or a dew point above the temperature, would let through
exactly the unit and bounds bugs that real data catches.

The vision catalogue is real crops and real diseases with real treatment advice
for the same reason: "Lorem Ipsum Blight" at 99% confidence never reveals that
a label overflows its container or that a four-item treatment list renders
badly.

## Fault injection

The happy path is the easy half. Retry, backoff and timeout handling can only
be rehearsed against an upstream that misbehaves on demand:

```bash
# the next two Open-Meteo calls fail, the third succeeds
curl -X POST 'localhost:8199/__mock/faults?provider=openmeteo' \
     -d '{"status":503,"remaining":2}'

# PlantNet answers, but takes five seconds about it
curl -X POST 'localhost:8199/__mock/faults?provider=plantnet' \
     -d '{"delay_ms":5000}'

# one provider down while the others stay healthy, until cleared
curl -X POST 'localhost:8199/__mock/faults?provider=openweather' -d '{"status":500}'

curl -s localhost:8199/__mock/faults          # what is configured
curl -X DELETE localhost:8199/__mock/faults   # clear everything
```

`remaining` is the field that matters: a counted fault expresses "fail twice,
then succeed", which is the shape that proves a retry loop actually retries. A
probabilistic fault cannot.

Provider names are `openmeteo`, `openweather`, `plantnet`, `vision`, `custom`,
and `all` for anything without a more specific entry.

## Using it from a Go test

The handlers are a package, so a test can stand an upstream up in-process and
skip the binary:

```go
srv := httptest.NewServer(mockapi.New(mockapi.Options{
    Now: func() time.Time { return frozen },
}).Handler())
defer srv.Close()

p := providers.NewOpenMeteo(srv.Client(), srv.URL+"/v1/forecast", srv.URL+"/v1/archive")
```

`weather-service/internal/adapters/outbound/providers/mockapi_compat_test.go`
does exactly this, and is the reason the mock can be trusted: it drives the
real adapters against the mock's output, so a field name that drifts out of
step with a struct tag fails the build rather than surfacing in production.

`Options.OmitET0` makes Open-Meteo return zero for reference
evapotranspiration, as the real API does outside its supported range, which is
what sends weather-service down its local recomputation path. It is an option
rather than a query parameter because the adapter appends its own query string
to the configured base URL.

## Known gaps

- **Uploaded image URLs cannot be mocked.** `plant-diagnosis-service` fetches
  images by URL through an SSRF guard (`packages/urlsafe`) that refuses
  anything but https to a non-private address, so a local mock image host is
  unreachable by construction. Submit images as inline bytes when working
  offline.
- **OIDC issuers are hardcoded** in `NewGoogleProvider` and
  `NewMicrosoftProvider`, so SSO cannot be pointed at a local issuer without a
  code change. Nothing currently constructs those providers, so this is latent
  rather than blocking.
- **S3 is already covered** by MinIO in `docker-compose.yml`; the mock does not
  duplicate it.
