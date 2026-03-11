package postgres_test

import (
	"context"
	"crypto/tls"
	"fmt"
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
		fmt.Fprintln(os.Stderr, "DATABASE_URL is required to run repository tests")
		os.Exit(1)
	}

	config, err := pgxpool.ParseConfig(dbURL)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to parse DATABASE_URL: %v\n", err)
		os.Exit(1)
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
		fmt.Fprintf(os.Stderr, "failed to connect to database: %v\n", err)
		os.Exit(1)
	}

	code := m.Run()
	testDB.Close()
	os.Exit(code)
}
