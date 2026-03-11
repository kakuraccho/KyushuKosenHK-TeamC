package service

import (
	"context"
	"errors"
	"fmt"
	"io"
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/repository"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/storage"
)

type VideoService struct {
	repo    repository.VideoRepository
	storage *storage.SupabaseStorage
}

func NewVideoService(repo repository.VideoRepository, storage *storage.SupabaseStorage) *VideoService {
	return &VideoService{repo: repo, storage: storage}
}

func (s *VideoService) Upload(ctx context.Context, userID uuid.UUID, contentType string, r io.Reader, size int64) (*model.Video, error) {
	// ユーザー入力ファイル名は使わず UUID をファイル名として使用（パストラバーサル対策）
	fileName := fmt.Sprintf("%s/%s.mp4", userID.String(), uuid.New().String())

	storageURL, err := s.storage.UploadVideo(ctx, fileName, contentType, r, size)
	if err != nil {
		return nil, err
	}

	video := &model.Video{
		ID:         uuid.New(),
		UserID:     userID,
		StorageURL: storageURL,
		CreatedAt:  time.Now(),
	}
	if err := s.repo.Create(ctx, video); err != nil {
		// 補償削除: DBへの保存に失敗した場合、ストレージの孤立オブジェクトを削除する
		if delErr := s.storage.DeleteVideo(context.Background(), fileName); delErr != nil {
			log.Printf("failed to delete orphaned storage object %s: %v", fileName, delErr)
		}
		return nil, err
	}
	return video, nil
}

func (s *VideoService) List(ctx context.Context, userID uuid.UUID) ([]*model.Video, error) {
	return s.repo.ListByUserID(ctx, userID)
}

func (s *VideoService) Get(ctx context.Context, id, callerID uuid.UUID) (*model.Video, error) {
	v, err := s.repo.FindByID(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrVideoNotFound
		}
		return nil, err
	}
	if v.UserID != callerID {
		return nil, ErrVideoForbidden
	}
	return v, nil
}
