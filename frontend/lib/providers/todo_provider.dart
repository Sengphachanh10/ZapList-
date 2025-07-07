// providers/todo_provider.dart
import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/api_service.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Todo> get completedTodos =>
      _todos.where((todo) => todo.completed).toList();
  List<Todo> get pendingTodos =>
      _todos.where((todo) => !todo.completed).toList();

  Future<void> fetchTodos() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.getTodos();

      if (response.success && response.data != null) {
        _todos = response.data!;
      } else {
        _error = response.error ?? 'Failed to fetch todos';
      }
    } catch (e) {
      _error = 'Failed to fetch todos: $e';
    }

    _setLoading(false);
  }

  Future<bool> createTodo(CreateTodoRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.createTodo(request);

      if (response.success && response.data != null) {
        _todos.add(response.data!);
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to create todo';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to create todo: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTodo(String todoId, UpdateTodoRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.updateTodo(todoId, request);

      if (response.success) {
        final index = _todos.indexWhere((todo) => todo.id == todoId);
        if (index != -1) {
          _todos[index] = _todos[index].copyWith(
            title: request.title,
            description: request.description,
            priority: request.priority,
            completed: request.completed,
            updatedAt: DateTime.now(),
          );
        }
        notifyListeners();
        _setLoading(false);
        return true;
      } else {
        _error = response.error ?? 'Failed to update todo';
        notifyListeners();
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Failed to update todo: $e';
      notifyListeners();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteTodo(String todoId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.deleteTodo(todoId);

      if (response.success) {
        _todos.removeWhere((todo) => todo.id == todoId);
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to delete todo';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to delete todo: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleTodoStatus(String todoId) async {
    final todo = _todos.firstWhere((t) => t.id == todoId);
    final request = UpdateTodoRequest(
      title: todo.title,
      description: todo.description,
      priority: todo.priority,
      completed: !todo.completed,
    );

    return await updateTodo(todoId, request);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
