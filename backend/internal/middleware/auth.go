package middleware

import (
	"crypto/ecdsa"
	"fmt"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

// AuthMiddleware は Supabase が発行した ES256 JWT を検証する。
func AuthMiddleware(keys map[string]*ecdsa.PublicKey, expectedIssuer, expectedAudience string) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Authorization header required"})
			return
		}

		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid authorization format"})
			return
		}

		token, err := jwt.Parse(parts[1], func(t *jwt.Token) (interface{}, error) {
			if t.Method.Alg() != jwt.SigningMethodES256.Alg() {
				return nil, jwt.ErrSignatureInvalid
			}
			kid, ok := t.Header["kid"].(string)
			if !ok || kid == "" {
				return nil, fmt.Errorf("missing kid in token header")
			}
			key, found := keys[kid]
			if !found {
				return nil, fmt.Errorf("unknown kid: %s", kid)
			}
			return key, nil
		},
			jwt.WithIssuer(expectedIssuer),
			jwt.WithAudience(expectedAudience),
		)
		if err != nil || !token.Valid {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
			return
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid token claims"})
			return
		}

		sub, ok := claims["sub"].(string)
		if !ok {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Missing sub claim"})
			return
		}

		userID, err := uuid.Parse(sub)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid user ID"})
			return
		}

		c.Set("user_id", userID)
		c.Next()
	}
}
