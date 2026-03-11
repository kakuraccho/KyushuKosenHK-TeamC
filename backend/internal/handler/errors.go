package handler

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgconn"
)

// handleServiceError は service/repository 層のエラーを適切な HTTP レスポンスに変換する。
func handleServiceError(c *gin.Context, err error) {
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) {
		switch pgErr.Code {
		case "23505": // unique_violation
			c.JSON(http.StatusConflict, gin.H{"error": "already exists"})
		case "23503": // foreign_key_violation
			c.JSON(http.StatusBadRequest, gin.H{"error": "referenced resource not found"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		}
		return
	}
	c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
}
