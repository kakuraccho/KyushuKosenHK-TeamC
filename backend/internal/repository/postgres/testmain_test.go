package postgres_test

import (
	"context"
	"crypto/tls"
	"os"
	"testing"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)

var testDB *pgxpool.Pool

func TestMain(m *testing.M) {
	_ = godotenv.Load("../../../.env")

	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		os.Exit(m.Run())
	}

	config, err := pgxpool.ParseConfig(dbURL)
	if err != nil {
		// URL パース失敗はスキップ
		os.Exit(m.Run())
	}

	// データベース名が空の場合は "postgres" をデフォルトに
	if config.ConnConfig.Database == "" {
		config.ConnConfig.Database = "postgres"
	}
	// Supabase のプーラーは TLS 必須
	if config.ConnConfig.TLSConfig == nil {
		config.ConnConfig.TLSConfig = &tls.Config{MinVersion: tls.VersionTLS12}
	}
	// pgBouncer(Transaction mode)は prepared statement 非対応
	config.ConnConfig.DefaultQueryExecMode = pgx.QueryExecModeSimpleProtocol

	testDB, err = pgxpool.NewWithConfig(context.Background(), config)
	if err != nil {
		testDB = nil
		os.Exit(m.Run())
	}
	defer testDB.Close()

	os.Exit(m.Run())
}
