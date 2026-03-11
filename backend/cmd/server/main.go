package main

import (
	"context"
	"crypto/tls"
	"errors"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/handler"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/middleware"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/repository/postgres"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/router"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/service"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/storage"
)

func main() {
	_ = godotenv.Load()

	databaseURL := mustEnv("DATABASE_URL")
	supabaseURL := mustEnv("SUPABASE_URL")
	supabaseKey := mustEnv("SUPABASE_SERVICE_ROLE_KEY")
	jwksURL := mustEnv("SUPABASE_JWKS_URL")
	port := getEnv("PORT", "8080")

	expectedIssuer := mustEnv("SUPABASE_JWT_ISSUER")
	expectedAudience := getEnv("SUPABASE_JWT_AUDIENCE", "authenticated")

	// JWKS から EC 公開鍵を取得
	keys, err := middleware.FetchECPublicKeys(jwksURL)
	if err != nil {
		log.Fatalf("failed to fetch JWKS: %v", err)
	}

	// DB 接続（Supabase のプーラーは TLS 必須）
	dbConfig, err := pgxpool.ParseConfig(databaseURL)
	if err != nil {
		log.Fatalf("failed to parse DATABASE_URL: %v", err)
	}
	if dbConfig.ConnConfig.Database == "" {
		dbConfig.ConnConfig.Database = "postgres"
	}
	if dbConfig.ConnConfig.TLSConfig == nil {
		dbConfig.ConnConfig.TLSConfig = &tls.Config{MinVersion: tls.VersionTLS12}
	}
	// pgBouncer(Transaction mode)は prepared statement 非対応
	dbConfig.ConnConfig.DefaultQueryExecMode = pgx.QueryExecModeSimpleProtocol

	db, err := pgxpool.NewWithConfig(context.Background(), dbConfig)
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}
	defer db.Close()

	// 起動時に DB への疎通確認
	pingCtx, pingCancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer pingCancel()
	if err := db.Ping(pingCtx); err != nil {
		log.Fatalf("database ping failed: %v", err)
	}

	// Repository
	userRepo := postgres.NewUserRepository(db)
	sessionRepo := postgres.NewSessionRepository(db)
	videoRepo := postgres.NewVideoRepository(db)
	postRepo := postgres.NewPostRepository(db)
	commentRepo := postgres.NewCommentRepository(db)
	friendRepo := postgres.NewFriendRepository(db)

	// Storage
	supabaseStorage := storage.NewSupabaseStorage(supabaseURL, supabaseKey, "videos")

	// Service
	userSvc := service.NewUserService(userRepo)
	sessionSvc := service.NewSessionService(sessionRepo)
	videoSvc := service.NewVideoService(videoRepo, supabaseStorage)
	postSvc := service.NewPostService(postRepo, videoRepo, friendRepo)
	commentSvc := service.NewCommentService(commentRepo, postRepo)
	friendSvc := service.NewFriendService(friendRepo)

	// Handler
	handlers := router.Handlers{
		Auth:    handler.NewAuthHandler(userSvc),
		User:    handler.NewUserHandler(userSvc),
		Session: handler.NewSessionHandler(sessionSvc),
		Video:   handler.NewVideoHandler(videoSvc),
		Post:    handler.NewPostHandler(postSvc),
		Comment: handler.NewCommentHandler(commentSvc),
		Friend:  handler.NewFriendHandler(friendSvc),
	}

	r := router.NewRouter(handlers, keys, expectedIssuer, expectedAudience)

	srv := &http.Server{
		Addr:              ":" + port,
		Handler:           r,
		ReadHeaderTimeout: 10 * time.Second,
		ReadTimeout:       30 * time.Second,
		WriteTimeout:      60 * time.Second,
		IdleTimeout:       120 * time.Second,
	}

	// サーバーをゴルーチンで起動
	go func() {
		log.Printf("server starting on :%s", port)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatalf("server error: %v", err)
		}
	}()

	// SIGINT / SIGTERM でグレースフルシャットダウン
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("shutting down server...")
	shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer shutdownCancel()
	if err := srv.Shutdown(shutdownCtx); err != nil {
		log.Printf("server shutdown error: %v", err)
	}
}

func mustEnv(key string) string {
	v := os.Getenv(key)
	if v == "" {
		log.Fatalf("environment variable %s is required", key)
	}
	return v
}

func getEnv(key, defaultVal string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultVal
}
