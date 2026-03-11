package middleware

import (
	"context"
	"crypto/ecdsa"
	"crypto/elliptic"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"math/big"
	"net/http"
	"time"
)

type jwk struct {
	Kid string `json:"kid"`
	Kty string `json:"kty"`
	Crv string `json:"crv"`
	X   string `json:"x"`
	Y   string `json:"y"`
}

type jwksResponse struct {
	Keys []jwk `json:"keys"`
}

// FetchECPublicKeys は JWKS エンドポイントから EC P-256 公開鍵を kid をキーとした map で返す。
func FetchECPublicKeys(jwksURL string) (map[string]*ecdsa.PublicKey, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, jwksURL, nil) //nolint:gosec
	if err != nil {
		return nil, fmt.Errorf("create jwks request: %w", err)
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("fetch jwks: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("fetch jwks: unexpected status %d", resp.StatusCode)
	}

	var keys jwksResponse
	if err := json.NewDecoder(resp.Body).Decode(&keys); err != nil {
		return nil, fmt.Errorf("decode jwks: %w", err)
	}

	result := make(map[string]*ecdsa.PublicKey)
	for _, k := range keys.Keys {
		if k.Kty != "EC" || k.Crv != "P-256" {
			continue
		}
		xBytes, err := base64.RawURLEncoding.DecodeString(k.X)
		if err != nil {
			return nil, fmt.Errorf("decode x for kid %q: %w", k.Kid, err)
		}
		yBytes, err := base64.RawURLEncoding.DecodeString(k.Y)
		if err != nil {
			return nil, fmt.Errorf("decode y for kid %q: %w", k.Kid, err)
		}
		result[k.Kid] = &ecdsa.PublicKey{
			Curve: elliptic.P256(),
			X:     new(big.Int).SetBytes(xBytes),
			Y:     new(big.Int).SetBytes(yBytes),
		}
	}

	if len(result) == 0 {
		return nil, fmt.Errorf("no EC P-256 key found in jwks")
	}
	return result, nil
}
