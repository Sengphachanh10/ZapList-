# ZapList To-Do List

A cross-platform to-do list application built with Flutter (frontend) and Go (backend).

## Features

- User authentication (register, login, logout)
- Add, edit, delete, and mark todos as complete
- Profile management
- Responsive UI

## Project Structure

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Go](https://go.dev/doc/install)
- [Git](https://git-scm.com/)

### Clone the Repository

```sh
git clone https://github.com/Sengphachanh10/ZapList-to-do-list.git
cd ZapList-to-do-list/todo_project
```

---

## Backend Setup (Go)

1. Navigate to the backend directory:
   ```sh
   cd backend
   ```
2. Install dependencies:
   ```sh
   go mod tidy
   ```
3. Run the server:
   ```sh
   go run main.go
   ```
   The backend will start on the default port (e.g., `localhost:8080`).

---

## Frontend Setup (Flutter)

1. Navigate to the frontend directory:
   ```sh
   cd frontend
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the app:
   ```sh
   flutter run
   ```
   You can run on Android, iOS, web, or desktop.

---

## API Endpoints

- `POST /register` – Register a new user
- `POST /login` – Login
- `GET /todos` – Get all todos
- `POST /todos` – Add a new todo
- `PUT /todos/:id` – Update a todo
- `DELETE /todos/:id` – Delete a todo

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a pull request

---

## License

This project is licensed under the MIT License.

---

## Contact

For questions or support, open an issue on [GitHub](https://github.com/Sengphachanh10/ZapList-to-do-list/issues).
