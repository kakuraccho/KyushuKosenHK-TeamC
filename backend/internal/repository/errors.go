package repository

import "errors"

// ErrNotFound is returned by repository methods when the requested record does not exist.
var ErrNotFound = errors.New("not found")
