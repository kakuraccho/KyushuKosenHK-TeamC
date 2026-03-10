package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/service"
)

type FriendHandler struct {
	friendSvc *service.FriendService
}

func NewFriendHandler(friendSvc *service.FriendService) *FriendHandler {
	return &FriendHandler{friendSvc: friendSvc}
}

type sendRequestBody struct {
	FollowingID string `json:"following_id" binding:"required"`
}

func (h *FriendHandler) SendRequest(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	var req sendRequestBody
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	followingID, err := uuid.Parse(req.FollowingID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid following_id"})
		return
	}

	f, err := h.friendSvc.SendRequest(c.Request.Context(), userID, followingID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": f})
}

func (h *FriendHandler) ListPendingRequests(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	requests, err := h.friendSvc.ListPendingRequests(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": requests})
}

type respondRequestBody struct {
	Accept bool `json:"accept"`
}

func (h *FriendHandler) RespondToRequest(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}

	var req respondRequestBody
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.friendSvc.RespondToRequest(c.Request.Context(), id, userID, req.Accept); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": "ok"})
}

func (h *FriendHandler) ListFriends(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	friends, err := h.friendSvc.ListFriends(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": friends})
}
