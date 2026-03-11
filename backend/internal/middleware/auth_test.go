package middleware_test

import (
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/middleware"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	testIssuer   = "https://example.supabase.co/auth/v1"
	testAudience = "authenticated"
	testKid      = "test-key-id"
)

func init() {
	gin.SetMode(gin.TestMode)
}

func newTestKeyPair(t *testing.T) (*ecdsa.PrivateKey, *ecdsa.PublicKey) {
	t.Helper()
	priv, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	require.NoError(t, err)
	return priv, &priv.PublicKey
}

func makeKeys(pub *ecdsa.PublicKey) map[string]*ecdsa.PublicKey {
	return map[string]*ecdsa.PublicKey{testKid: pub}
}

func makeToken(t *testing.T, priv *ecdsa.PrivateKey, sub string, exp time.Time) string {
	t.Helper()
	token := jwt.NewWithClaims(jwt.SigningMethodES256, jwt.MapClaims{
		"sub": sub,
		"exp": exp.Unix(),
		"iss": testIssuer,
		"aud": testAudience,
	})
	token.Header["kid"] = testKid
	tokenStr, err := token.SignedString(priv)
	require.NoError(t, err)
	return tokenStr
}

func setupRouter(keys map[string]*ecdsa.PublicKey) *gin.Engine {
	r := gin.New()
	r.Use(middleware.AuthMiddleware(keys, testIssuer, testAudience))
	r.GET("/protected", func(c *gin.Context) {
		userID := c.MustGet("user_id").(uuid.UUID)
		c.JSON(http.StatusOK, gin.H{"user_id": userID.String()})
	})
	return r
}

// TestAuthMiddleware_ValidToken は有効な JWT で 200 が返ることを確認する。
func TestAuthMiddleware_ValidToken(t *testing.T) {
	priv, pub := newTestKeyPair(t)
	userID := uuid.New()
	token := makeToken(t, priv, userID.String(), time.Now().Add(time.Hour))

	r := setupRouter(makeKeys(pub))
	req := httptest.NewRequest(http.MethodGet, "/protected", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	assert.Contains(t, w.Body.String(), userID.String())
}

// TestAuthMiddleware_NoHeader は Authorization ヘッダーなしで 401 が返ることを確認する。
func TestAuthMiddleware_NoHeader(t *testing.T) {
	_, pub := newTestKeyPair(t)
	r := setupRouter(makeKeys(pub))

	req := httptest.NewRequest(http.MethodGet, "/protected", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusUnauthorized, w.Code)
}

// TestAuthMiddleware_ExpiredToken は期限切れトークンで 401 が返ることを確認する。
func TestAuthMiddleware_ExpiredToken(t *testing.T) {
	priv, pub := newTestKeyPair(t)
	token := makeToken(t, priv, uuid.New().String(), time.Now().Add(-time.Hour))

	r := setupRouter(makeKeys(pub))
	req := httptest.NewRequest(http.MethodGet, "/protected", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusUnauthorized, w.Code)
}

// TestAuthMiddleware_WrongKey は異なる鍵で署名されたトークンで 401 が返ることを確認する。
func TestAuthMiddleware_WrongKey(t *testing.T) {
	priv, _ := newTestKeyPair(t)
	_, otherPub := newTestKeyPair(t)
	token := makeToken(t, priv, uuid.New().String(), time.Now().Add(time.Hour))

	// same kid, but mapped to a different public key
	r := setupRouter(makeKeys(otherPub))
	req := httptest.NewRequest(http.MethodGet, "/protected", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusUnauthorized, w.Code)
}

// TestAuthMiddleware_InvalidFormat は "Bearer" プレフィックスなしで 401 が返ることを確認する。
func TestAuthMiddleware_InvalidFormat(t *testing.T) {
	_, pub := newTestKeyPair(t)
	r := setupRouter(makeKeys(pub))

	req := httptest.NewRequest(http.MethodGet, "/protected", nil)
	req.Header.Set("Authorization", "invalidtoken")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusUnauthorized, w.Code)
}
