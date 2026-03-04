package main

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"fmt"
)

func main() {
	r := gin.Default()
	r.GET("/api", func(ctx *gin.Context) {
		ctx.JSON(http.StatusOK, "hello world!")
	})
	fmt.Println("hello world!")
	r.Run()
}
