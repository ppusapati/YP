package grpcdial

import (
	"crypto/tls"
	"os"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/credentials/insecure"
)

// TransportCredentials returns TLS credentials by default. Set the
// environment variable GRPC_PLAINTEXT=1 to use plaintext (dev/sidecar only).
func TransportCredentials() grpc.DialOption {
	if os.Getenv("GRPC_PLAINTEXT") == "1" {
		return grpc.WithTransportCredentials(insecure.NewCredentials())
	}
	return grpc.WithTransportCredentials(credentials.NewTLS(&tls.Config{
		MinVersion: tls.VersionTLS12,
	}))
}
