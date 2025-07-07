// handlers/todo.go
package handlers

import (
	"context"
	"time"

	"todo-backend/database"
	"todo-backend/models"

	"github.com/gofiber/fiber/v2"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func CreateTodo(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(string)

	var req models.CreateTodoRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	objID, err := primitive.ObjectIDFromHex(userID)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{
			"error": "Invalid user ID",
		})
	}

	todo := models.Todo{
		UserID:      objID,
		Title:       req.Title,
		Description: req.Description,
		Priority:    req.Priority,
		Completed:   false,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	result, err := database.DB.Collection("todos").InsertOne(context.Background(), todo)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"error": "Failed to create todo",
		})
	}

	todo.ID = result.InsertedID.(primitive.ObjectID)
	return c.Status(201).JSON(fiber.Map{
		"message": "Todo created successfully",
		"todo":    todo,
	})
}

func GetTodos(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(string)

	objID, err := primitive.ObjectIDFromHex(userID)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{
			"error": "Invalid user ID",
		})
	}

	cursor, err := database.DB.Collection("todos").Find(context.Background(), bson.M{"user_id": objID})
	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"error": "Failed to fetch todos",
		})
	}
	defer cursor.Close(context.Background())

	var todos []models.Todo
	if err = cursor.All(context.Background(), &todos); err != nil {
		return c.Status(500).JSON(fiber.Map{
			"error": "Failed to parse todos",
		})
	}
	if todos == nil {
		todos = []models.Todo{}
	}
	return c.JSON(fiber.Map{
		"todos": todos,
	})
}

func UpdateTodo(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(string)
	todoID := c.Params("id")

	var req models.UpdateTodoRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	userObjID, err := primitive.ObjectIDFromHex(userID)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{
			"error": "Invalid user ID",
		})
	}

	todoObjID, err := primitive.ObjectIDFromHex(todoID)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{
			"error": "Invalid todo ID",
		})
	}

	update := bson.M{
		"$set": bson.M{
			"title":       req.Title,
			"description": req.Description,
			"priority":    req.Priority,
			"completed":   req.Completed,
			"updated_at":  time.Now(),
		},
	}

	_, err = database.DB.Collection("todos").UpdateOne(
		context.Background(),
		bson.M{"_id": todoObjID, "user_id": userObjID},
		update,
	)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"error": "Failed to update todo",
		})
	}

	return c.JSON(fiber.Map{
		"message": "Todo updated successfully",
	})
}

func DeleteTodo(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(string)
	todoID := c.Params("id")

	userObjID, err := primitive.ObjectIDFromHex(userID)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{
			"error": "Invalid user ID",
		})
	}

	todoObjID, err := primitive.ObjectIDFromHex(todoID)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{
			"error": "Invalid todo ID",
		})
	}

	_, err = database.DB.Collection("todos").DeleteOne(
		context.Background(),
		bson.M{"_id": todoObjID, "user_id": userObjID},
	)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"error": "Failed to delete todo",
		})
	}

	return c.JSON(fiber.Map{
		"message": "Todo deleted successfully",
	})
}
