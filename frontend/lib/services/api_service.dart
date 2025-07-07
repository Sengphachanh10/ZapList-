// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/todo.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class ApiService {
  static const String baseUrl = Constants.baseUrl;

  static Future<Map<String, String>> _getHeaders(
      {bool withAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (withAuth) {
      final token = await StorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    try {
      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          data: fromJson != null ? fromJson(data) : data as T,
          message: data['message'],
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          error: data['error'] ?? 'Unknown error occurred',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        error: 'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }

  // Auth APIs
  static Future<ApiResponse<AuthResponse>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: await _getHeaders(),
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      return _handleResponse<AuthResponse>(
        response,
        (data) => AuthResponse.fromJson(data),
      );
    } catch (e) {
      return ApiResponse.error(error: 'Network error: $e');
    }
  }

  static Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: await _getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      return _handleResponse<AuthResponse>(
        response,
        (data) => AuthResponse.fromJson(data),
      );
    } catch (e) {
      return ApiResponse.error(error: 'Network error: $e');
    }
  }

  static Future<ApiResponse<User>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: await _getHeaders(withAuth: true),
      );

      return _handleResponse<User>(
        response,
        (data) => User.fromJson(data['user']),
      );
    } catch (e) {
      return ApiResponse.error(error: 'Network error: $e');
    }
  }

  // Todo APIs
  static Future<ApiResponse<List<Todo>>> getTodos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/todos'),
        headers: await _getHeaders(withAuth: true),
      );

      return _handleResponse<List<Todo>>(
        response,
        (data) =>
            (data['todos'] as List).map((todo) => Todo.fromJson(todo)).toList(),
      );
    } catch (e) {
      return ApiResponse.error(error: 'Network error: $e');
    }
  }

  static Future<ApiResponse<Todo>> createTodo(CreateTodoRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/todos'),
        headers: await _getHeaders(withAuth: true),
        body: json.encode(request.toJson()),
      );

      return _handleResponse<Todo>(
        response,
        (data) => Todo.fromJson(data['todo']),
      );
    } catch (e) {
      return ApiResponse.error(error: 'Network error: $e');
    }
  }

  static Future<ApiResponse<String>> updateTodo(
    String todoId,
    UpdateTodoRequest request,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/todos/$todoId'),
        headers: await _getHeaders(withAuth: true),
        body: json.encode(request.toJson()),
      );

      return _handleResponse<String>(
        response,
        (data) => data['message'] ?? 'Todo updated successfully',
      );
    } catch (e) {
      return ApiResponse.error(error: 'Network error: $e');
    }
  }

  static Future<ApiResponse<String>> deleteTodo(String todoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/todos/$todoId'),
        headers: await _getHeaders(withAuth: true),
      );

      return _handleResponse<String>(
        response,
        (data) => data['message'] ?? 'Todo deleted successfully',
      );
    } catch (e) {
      return ApiResponse.error(error: 'Network error: $e');
    }
  }

  static Future<ApiResponse<String>> updatePassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/reset-password'),
        headers: await _getHeaders(),
        body: json.encode({
          'email': email,
          'new_password': newPassword,
        }),
      );
      // Try to parse as JSON, but if it fails, return a generic error
      try {
        return _handleResponse<String>(
          response,
          (data) => data['message'] ?? 'Password updated successfully',
        );
      } catch (e) {
        return ApiResponse.error(
          error: 'Unexpected response from server: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(error: 'Network error: $e');
    }
  }
}
