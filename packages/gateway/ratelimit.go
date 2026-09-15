package gateway

import (
	"fmt"
	"math"
	"net/http"
	"strconv"
	"sync"
	"time"
)

type RateLimitConfig struct {
	RequestsPerSecond float64       `json:"requests_per_second"`
	BurstSize         int           `json:"burst_size"`
	CleanupInterval   time.Duration `json:"cleanup_interval"`
}

func DefaultRateLimitConfig() RateLimitConfig {
	return RateLimitConfig{
		RequestsPerSecond: 100,
		BurstSize:         200,
		CleanupInterval:   5 * time.Minute,
	}
}

type tokenBucket struct {
	tokens     float64
	maxTokens  float64
	refillRate float64
	lastRefill time.Time
	mu         sync.Mutex
}

func newTokenBucket(rate float64, burst int) *tokenBucket {
	return &tokenBucket{
		tokens:     float64(burst),
		maxTokens:  float64(burst),
		refillRate: rate,
		lastRefill: time.Now(),
	}
}

func (b *tokenBucket) allow() bool {
	b.mu.Lock()
	defer b.mu.Unlock()

	now := time.Now()
	elapsed := now.Sub(b.lastRefill).Seconds()
	b.tokens = math.Min(b.maxTokens, b.tokens+elapsed*b.refillRate)
	b.lastRefill = now

	if b.tokens < 1 {
		return false
	}
	b.tokens--
	return true
}

func (b *tokenBucket) remaining() int {
	b.mu.Lock()
	defer b.mu.Unlock()
	return int(b.tokens)
}

func (b *tokenBucket) resetTime() time.Time {
	b.mu.Lock()
	defer b.mu.Unlock()
	if b.tokens >= b.maxTokens {
		return time.Now()
	}
	deficit := b.maxTokens - b.tokens
	return time.Now().Add(time.Duration(deficit/b.refillRate) * time.Second)
}

type RateLimiter struct {
	config  RateLimitConfig
	buckets map[string]*tokenBucket
	mu      sync.RWMutex
	done    chan struct{}

	endpointLimits map[string]RateLimitConfig
}

func NewRateLimiter(cfg RateLimitConfig) *RateLimiter {
	rl := &RateLimiter{
		config:         cfg,
		buckets:        make(map[string]*tokenBucket),
		done:           make(chan struct{}),
		endpointLimits: make(map[string]RateLimitConfig),
	}

	go rl.cleanup()
	return rl
}

func (rl *RateLimiter) SetEndpointLimit(path string, cfg RateLimitConfig) {
	rl.mu.Lock()
	rl.endpointLimits[path] = cfg
	rl.mu.Unlock()
}

func (rl *RateLimiter) Middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ip := extractIP(r)
		tenantID := r.Header.Get("X-Tenant-ID")

		key := rl.buildKey(ip, tenantID, r.URL.Path)
		cfg := rl.configForPath(r.URL.Path)

		bucket := rl.getBucket(key, cfg)

		w.Header().Set("X-RateLimit-Limit", strconv.Itoa(int(cfg.RequestsPerSecond)))
		w.Header().Set("X-RateLimit-Remaining", strconv.Itoa(bucket.remaining()))
		w.Header().Set("X-RateLimit-Reset", strconv.FormatInt(bucket.resetTime().Unix(), 10))

		if !bucket.allow() {
			w.Header().Set("Retry-After", "1")
			http.Error(w, `{"error":"rate_limit_exceeded"}`, http.StatusTooManyRequests)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func (rl *RateLimiter) Allow(key string) bool {
	bucket := rl.getBucket(key, rl.config)
	return bucket.allow()
}

func (rl *RateLimiter) Close() {
	close(rl.done)
}

func (rl *RateLimiter) buildKey(ip, tenantID, path string) string {
	if tenantID != "" {
		return fmt.Sprintf("tenant:%s:%s", tenantID, path)
	}
	return fmt.Sprintf("ip:%s:%s", ip, path)
}

func (rl *RateLimiter) configForPath(path string) RateLimitConfig {
	rl.mu.RLock()
	defer rl.mu.RUnlock()
	if cfg, ok := rl.endpointLimits[path]; ok {
		return cfg
	}
	return rl.config
}

func (rl *RateLimiter) getBucket(key string, cfg RateLimitConfig) *tokenBucket {
	rl.mu.RLock()
	bucket, ok := rl.buckets[key]
	rl.mu.RUnlock()
	if ok {
		return bucket
	}

	rl.mu.Lock()
	defer rl.mu.Unlock()
	if bucket, ok = rl.buckets[key]; ok {
		return bucket
	}
	bucket = newTokenBucket(cfg.RequestsPerSecond, cfg.BurstSize)
	rl.buckets[key] = bucket
	return bucket
}

func (rl *RateLimiter) cleanup() {
	ticker := time.NewTicker(rl.config.CleanupInterval)
	defer ticker.Stop()

	for {
		select {
		case <-rl.done:
			return
		case <-ticker.C:
			rl.mu.Lock()
			now := time.Now()
			for key, bucket := range rl.buckets {
				bucket.mu.Lock()
				idle := now.Sub(bucket.lastRefill)
				bucket.mu.Unlock()
				if idle > rl.config.CleanupInterval {
					delete(rl.buckets, key)
				}
			}
			rl.mu.Unlock()
		}
	}
}
