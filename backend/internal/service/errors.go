package service

import "errors"

var (
	ErrVideoNotFound  = errors.New("video not found")
	ErrVideoForbidden = errors.New("video does not belong to you")
	ErrPostNotFound   = errors.New("post not found")
	ErrPostForbidden  = errors.New("post does not belong to you")
)
