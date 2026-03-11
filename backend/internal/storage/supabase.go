package storage

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"
)

const uploadTimeout = 5 * time.Minute

type SupabaseStorage struct {
	baseURL        string
	serviceRoleKey string
	bucketName     string
	httpClient     *http.Client
}

func NewSupabaseStorage(baseURL, serviceRoleKey, bucketName string) *SupabaseStorage {
	return &SupabaseStorage{
		baseURL:        baseURL,
		serviceRoleKey: serviceRoleKey,
		bucketName:     bucketName,
		httpClient:     &http.Client{Timeout: uploadTimeout},
	}
}

// escapePath はスラッシュを区切りとして各パスセグメントを percent-encode する。
func escapePath(path string) string {
	segments := strings.Split(path, "/")
	for i, seg := range segments {
		segments[i] = url.PathEscape(seg)
	}
	return strings.Join(segments, "/")
}

func (s *SupabaseStorage) UploadVideo(ctx context.Context, fileName string, contentType string, r io.Reader, size int64) (string, error) {
	escapedBucket := url.PathEscape(s.bucketName)
	escapedFile := escapePath(fileName)

	uploadURL := fmt.Sprintf("%s/storage/v1/object/%s/%s", s.baseURL, escapedBucket, escapedFile)

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, uploadURL, r)
	if err != nil {
		return "", fmt.Errorf("create request: %w", err)
	}
	req.ContentLength = size
	req.Header.Set("Authorization", "Bearer "+s.serviceRoleKey)
	req.Header.Set("Content-Type", contentType)

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("upload request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		body, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("upload failed: status=%d body=%s", resp.StatusCode, body)
	}

	publicURL := fmt.Sprintf("%s/storage/v1/object/public/%s/%s", s.baseURL, escapedBucket, escapedFile)
	return publicURL, nil
}

func (s *SupabaseStorage) DeleteVideo(ctx context.Context, fileName string) error {
	escapedBucket := url.PathEscape(s.bucketName)
	escapedFile := escapePath(fileName)

	deleteURL := fmt.Sprintf("%s/storage/v1/object/%s/%s", s.baseURL, escapedBucket, escapedFile)

	req, err := http.NewRequestWithContext(ctx, http.MethodDelete, deleteURL, nil)
	if err != nil {
		return fmt.Errorf("create delete request: %w", err)
	}
	req.Header.Set("Authorization", "Bearer "+s.serviceRoleKey)

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("delete request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("delete failed: status=%d body=%s", resp.StatusCode, body)
	}
	return nil
}
