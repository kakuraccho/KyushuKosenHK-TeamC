package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/service"
)

type CommentHandler struct {
	commentSvc *service.CommentService
}

func NewCommentHandler(commentSvc *service.CommentService) *CommentHandler {
	return &CommentHandler{commentSvc: commentSvc}
}

type createCommentRequest struct {
	Content string `json:"content" binding:"required,max=10000"`
}

func (h *CommentHandler) Create(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	postID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid post id"})
		return
	}

	var req createCommentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	comment, err := h.commentSvc.Create(c.Request.Context(), service.CreateCommentInput{
		PostID:  postID,
		UserID:  userID,
		Content: req.Content,
	})
	if err != nil {
		if err.Error() == "post not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			return
		}
		handleServiceError(c, err)
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": comment})
}

func (h *CommentHandler) List(c *gin.Context) {
	postID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid post id"})
		return
	}

	comments, err := h.commentSvc.List(c.Request.Context(), postID)
	if err != nil {
		handleServiceError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": comments})
}

func (h *CommentHandler) Delete(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	commentID, err := uuid.Parse(c.Param("comment_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid comment id"})
		return
	}

	if err := h.commentSvc.Delete(c.Request.Context(), userID, commentID); err != nil {
		switch err.Error() {
		case "comment not found":
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		case "forbidden: comment does not belong to you":
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
		default:
			handleServiceError(c, err)
		}
		return
	}

	c.Status(http.StatusNoContent)
}
