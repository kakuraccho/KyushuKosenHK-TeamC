package service

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/repository"
)

type FriendService struct {
	repo repository.FriendRepository
}

func NewFriendService(repo repository.FriendRepository) *FriendService {
	return &FriendService{repo: repo}
}

func (s *FriendService) SendRequest(ctx context.Context, followerID, followingID uuid.UUID) (*model.Friendship, error) {
	f := &model.Friendship{
		ID:          uuid.New(),
		FollowerID:  followerID,
		FollowingID: followingID,
		Status:      model.FriendshipPending,
		CreatedAt:   time.Now(),
	}
	if err := s.repo.CreateRequest(ctx, f); err != nil {
		return nil, err
	}
	return f, nil
}

func (s *FriendService) ListPendingRequests(ctx context.Context, userID uuid.UUID) ([]*model.Friendship, error) {
	return s.repo.ListPendingRequests(ctx, userID)
}

func (s *FriendService) RespondToRequest(ctx context.Context, requestID uuid.UUID, userID uuid.UUID, accept bool) error {
	f, err := s.repo.FindByID(ctx, requestID)
	if err != nil {
		return err
	}
	if f.FollowingID != userID {
		return fmt.Errorf("unauthorized")
	}
	status := model.FriendshipAccepted
	if !accept {
		status = model.FriendshipBlocked
	}
	return s.repo.UpdateStatus(ctx, requestID, status)
}

func (s *FriendService) ListFriends(ctx context.Context, userID uuid.UUID) ([]*model.Friendship, error) {
	return s.repo.ListFriends(ctx, userID)
}
