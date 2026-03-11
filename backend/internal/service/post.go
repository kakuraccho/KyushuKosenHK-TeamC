package service

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/repository"
)

type PostService struct {
	repo       repository.PostRepository
	videoRepo  repository.VideoRepository
	friendRepo repository.FriendRepository
}

func NewPostService(repo repository.PostRepository, videoRepo repository.VideoRepository, friendRepo repository.FriendRepository) *PostService {
	return &PostService{repo: repo, videoRepo: videoRepo, friendRepo: friendRepo}
}

type CreatePostInput struct {
	UserID     uuid.UUID
	VideoID    uuid.UUID
	Content    *string
	Visibility model.VisibilityType
}

func (s *PostService) Create(ctx context.Context, input CreatePostInput) (*model.Post, error) {
	// 動画のオーナーシップ確認
	video, err := s.videoRepo.FindByID(ctx, input.VideoID)
	if err != nil {
		return nil, ErrVideoNotFound
	}
	if video.UserID != input.UserID {
		return nil, ErrVideoForbidden
	}

	post := &model.Post{
		ID:         uuid.New(),
		UserID:     input.UserID,
		VideoID:    input.VideoID,
		Content:    input.Content,
		Visibility: input.Visibility,
		CreatedAt:  time.Now(),
	}
	if err := s.repo.Create(ctx, post); err != nil {
		return nil, err
	}
	return post, nil
}

func (s *PostService) Feed(ctx context.Context, userID uuid.UUID) ([]*model.Post, error) {
	return s.repo.ListFeed(ctx, userID)
}

func (s *PostService) Get(ctx context.Context, id, requesterID uuid.UUID) (*model.Post, error) {
	post, err := s.repo.FindByID(ctx, id)
	if err != nil {
		return nil, ErrPostNotFound
	}

	switch post.Visibility {
	case model.VisibilityPrivate:
		if post.UserID != requesterID {
			return nil, ErrPostForbidden
		}
	case model.VisibilityFriends:
		if post.UserID != requesterID {
			ok, err := s.friendRepo.AreFriends(ctx, requesterID, post.UserID)
			if err != nil || !ok {
				return nil, ErrPostForbidden
			}
		}
	}

	return post, nil
}

func (s *PostService) Delete(ctx context.Context, userID, postID uuid.UUID) error {
	post, err := s.repo.FindByID(ctx, postID)
	if err != nil {
		return ErrPostNotFound
	}
	if post.UserID != userID {
		return ErrPostForbidden
	}
	return s.repo.Delete(ctx, postID)
}
