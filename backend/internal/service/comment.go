package service

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/repository"
)

type CommentService struct {
	repo     repository.CommentRepository
	postRepo repository.PostRepository
}

func NewCommentService(repo repository.CommentRepository, postRepo repository.PostRepository) *CommentService {
	return &CommentService{repo: repo, postRepo: postRepo}
}

type CreateCommentInput struct {
	PostID  uuid.UUID
	UserID  uuid.UUID
	Content string
}

func (s *CommentService) Create(ctx context.Context, input CreateCommentInput) (*model.Comment, error) {
	if _, err := s.postRepo.FindByID(ctx, input.PostID); err != nil {
		return nil, fmt.Errorf("post not found")
	}

	comment := &model.Comment{
		ID:        uuid.New(),
		PostID:    input.PostID,
		UserID:    input.UserID,
		Content:   input.Content,
		CreatedAt: time.Now(),
	}
	if err := s.repo.Create(ctx, comment); err != nil {
		return nil, err
	}
	return comment, nil
}

func (s *CommentService) List(ctx context.Context, postID uuid.UUID) ([]*model.Comment, error) {
	return s.repo.ListByPostID(ctx, postID)
}

func (s *CommentService) Delete(ctx context.Context, userID, commentID uuid.UUID) error {
	comment, err := s.repo.FindByID(ctx, commentID)
	if err != nil {
		return fmt.Errorf("comment not found")
	}
	if comment.UserID != userID {
		return fmt.Errorf("forbidden: comment does not belong to you")
	}
	return s.repo.Delete(ctx, commentID)
}
