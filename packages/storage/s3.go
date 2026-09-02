package storage

import (
	"context"
	"fmt"
	"io"
	"net/url"
	"os"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

// Client wraps an S3-compatible object store (AWS S3 or MinIO).
type Client struct {
	s3     *s3.Client
	bucket string
}

// Config holds settings for connecting to S3/MinIO.
type Config struct {
	Endpoint        string // e.g. "http://minio:9000" (empty = real AWS)
	Region          string
	Bucket          string
	AccessKeyID     string
	SecretAccessKey string
	ForcePathStyle  bool // true for MinIO
}

// ConfigFromEnv reads storage configuration from environment variables.
func ConfigFromEnv() Config {
	return Config{
		Endpoint:        os.Getenv("S3_ENDPOINT"),
		Region:          envOr("S3_REGION", "us-east-1"),
		Bucket:          envOr("S3_BUCKET", "yieldpoint"),
		AccessKeyID:     os.Getenv("S3_ACCESS_KEY_ID"),
		SecretAccessKey: os.Getenv("S3_SECRET_ACCESS_KEY"),
		ForcePathStyle:  os.Getenv("S3_FORCE_PATH_STYLE") == "true",
	}
}

// NewClient creates an S3/MinIO storage client.
func NewClient(ctx context.Context, cfg Config) (*Client, error) {
	var opts []func(*config.LoadOptions) error
	opts = append(opts, config.WithRegion(cfg.Region))

	if cfg.AccessKeyID != "" && cfg.SecretAccessKey != "" {
		opts = append(opts, config.WithCredentialsProvider(
			credentials.NewStaticCredentialsProvider(cfg.AccessKeyID, cfg.SecretAccessKey, ""),
		))
	}

	awsCfg, err := config.LoadDefaultConfig(ctx, opts...)
	if err != nil {
		return nil, fmt.Errorf("storage: load aws config: %w", err)
	}

	var s3Opts []func(*s3.Options)
	if cfg.Endpoint != "" {
		s3Opts = append(s3Opts, func(o *s3.Options) {
			o.BaseEndpoint = aws.String(cfg.Endpoint)
			o.UsePathStyle = cfg.ForcePathStyle
		})
	}

	client := s3.NewFromConfig(awsCfg, s3Opts...)
	return &Client{s3: client, bucket: cfg.Bucket}, nil
}

// Upload stores an object at the given key.
func (c *Client) Upload(ctx context.Context, key, contentType string, body io.Reader) error {
	_, err := c.s3.PutObject(ctx, &s3.PutObjectInput{
		Bucket:      aws.String(c.bucket),
		Key:         aws.String(key),
		Body:        body,
		ContentType: aws.String(contentType),
	})
	if err != nil {
		return fmt.Errorf("storage: upload %s: %w", key, err)
	}
	return nil
}

// Download retrieves an object by key.
func (c *Client) Download(ctx context.Context, key string) (io.ReadCloser, error) {
	out, err := c.s3.GetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(c.bucket),
		Key:    aws.String(key),
	})
	if err != nil {
		return nil, fmt.Errorf("storage: download %s: %w", key, err)
	}
	return out.Body, nil
}

// Delete removes an object by key.
func (c *Client) Delete(ctx context.Context, key string) error {
	_, err := c.s3.DeleteObject(ctx, &s3.DeleteObjectInput{
		Bucket: aws.String(c.bucket),
		Key:    aws.String(key),
	})
	if err != nil {
		return fmt.Errorf("storage: delete %s: %w", key, err)
	}
	return nil
}

// PresignedURL generates a time-limited URL for downloading an object.
func (c *Client) PresignedURL(ctx context.Context, key string, ttl time.Duration) (*url.URL, error) {
	presigner := s3.NewPresignClient(c.s3)
	req, err := presigner.PresignGetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(c.bucket),
		Key:    aws.String(key),
	}, s3.WithPresignExpires(ttl))
	if err != nil {
		return nil, fmt.Errorf("storage: presign %s: %w", key, err)
	}
	u, err := url.Parse(req.URL)
	if err != nil {
		return nil, fmt.Errorf("storage: parse presigned url: %w", err)
	}
	return u, nil
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
