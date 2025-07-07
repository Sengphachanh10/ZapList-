// models/todo.dart
class Todo {
  final String? id;
  final String userId;
  final String title;
  final String description;
  final bool completed;
  final String priority;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Todo({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.completed = false,
    this.priority = 'medium',
    this.createdAt,
    this.updatedAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      completed: json['completed'] ?? false,
      priority: json['priority'] ?? 'medium',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'completed': completed,
      'priority': priority,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Todo copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    bool? completed,
    String? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CreateTodoRequest {
  final String title;
  final String description;
  final String priority;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CreateTodoRequest({
    required this.title,
    required this.description,
    required this.priority,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

class UpdateTodoRequest {
  final String title;
  final String description;
  final String priority;
  final bool completed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UpdateTodoRequest({
    required this.title,
    required this.description,
    required this.priority,
    required this.completed,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'completed': completed,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
