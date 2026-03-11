package storage

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net/http"
)

type SupabaseStorage struct {
	baseURL        string
	serviceRoleKey string
	bucketName     string
}

func NewSupabaseStorage(baseURL, serviceRoleKey, bucketName string) *SupabaseStorage {
	return &SupabaseStorage{
		baseURL:        baseURL,
		serviceRoleKey: serviceRoleKey,
		bucketName:     bucketName,
	}
}

func (s *SupabaseStorage) UploadVideo(ctx context.Context, fileName string, contentType string, data []byte) (string, error) {
	url := fmt.Sprintf("%s/storage/v1/object/%s/%s", s.baseURL, s.bucketName, fileName)

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(data))
	if err != nil {
		return "", fmt.Errorf("create request: %w", err)
	}
	req.Header.Set("Authorization", "Bearer "+s.serviceRoleKey)
	req.Header.Set("Content-Type", contentType)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("upload request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		body, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("upload failed: status=%d body=%s", resp.StatusCode, body)
	}

	publicURL := fmt.Sprintf("%s/storage/v1/object/public/%s/%s", s.baseURL, s.bucketName, fileName)
	return publicURL, nil
}
