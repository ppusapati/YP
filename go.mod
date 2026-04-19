module p9e.in/samavaya/agriculture

go 1.25.4

require (
	connectrpc.com/connect v1.17.0
	p9e.in/samavaya/packages v0.0.0
	github.com/jackc/pgx/v5 v5.7.6
	github.com/stretchr/testify v1.10.0
	google.golang.org/protobuf v1.36.7
	google.golang.org/grpc v1.71.0
	github.com/oklog/ulid/v2 v2.1.1
	github.com/IBM/sarama v1.45.1
	github.com/sqlc-dev/pqtype v0.3.0
	go.uber.org/zap v1.27.0
)

replace p9e.in/samavaya/packages => ./packages
