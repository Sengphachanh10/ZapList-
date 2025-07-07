// main.go
package main

import (
	"log"
	"os"

	"todo-backend/database"
	"todo-backend/handlers"
	"todo-backend/middleware"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Fatal("Error loading .env file")
	}

	// Connect to database
	database.ConnectDB()

	// Create Fiber app
	app := fiber.New()

	// Middleware
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowMethods: "GET,POST,PUT,DELETE",
		AllowHeaders: "Origin, Content-Type, Accept, Authorization",
	}))

	// Routes
	api := app.Group("/api")

	// Auth routes
	auth := api.Group("/auth")
	auth.Post("/register", handlers.Register)
	auth.Post("/login", handlers.Login)
	auth.Post("/reset-password", handlers.ResetPassword)
	auth.Get("/profile", middleware.AuthMiddleware, handlers.GetProfile)

	// Todo routes
	todos := api.Group("/todos")
	todos.Use(middleware.AuthMiddleware)
	todos.Post("/", handlers.CreateTodo)
	todos.Get("/", handlers.GetTodos)
	todos.Put("/:id", handlers.UpdateTodo)
	todos.Delete("/:id", handlers.DeleteTodo)

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	log.Fatal(app.Listen(":" + port))
}
