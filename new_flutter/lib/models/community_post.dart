import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Comment {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime timestamp;
  final String postId;
  final DateTime? updatedAt;

  Comment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.timestamp,
    required this.postId,
    this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    DateTime timestamp;
    final timestampValue = json['timestamp'];

    if (timestampValue is Timestamp) {
      timestamp = timestampValue.toDate();
    } else if (timestampValue is String) {
      try {
        timestamp = DateTime.parse(timestampValue);
      } catch (e) {
        debugPrint('Error parsing timestamp string: $timestampValue');
        timestamp = DateTime.now();
      }
    } else if (timestampValue == null) {
      // Handle null timestamp (can happen with FieldValue.serverTimestamp())
      debugPrint('Warning: Comment has null timestamp, using current time');
      timestamp = DateTime.now();
    } else {
      debugPrint('Warning: Unknown timestamp type: ${timestampValue.runtimeType}');
      timestamp = DateTime.now();
    }

    // Handle updatedAt timestamp
    DateTime? updatedAt;
    final updatedAtValue = json['updatedAt'];
    if (updatedAtValue is Timestamp) {
      updatedAt = updatedAtValue.toDate();
    } else if (updatedAtValue is String) {
      try {
        updatedAt = DateTime.parse(updatedAtValue);
      } catch (e) {
        debugPrint('Error parsing updatedAt string: $updatedAtValue');
      }
    }

    return Comment(
      id: json['id'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? 'Anonymous',
      content: json['content'] ?? '',
      timestamp: timestamp,
      postId: json['postId'] ?? '',
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'postId': postId,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final List<String> tags;
  final String? category;
  final String? location;
  final String? date;
  final String? time;
  final String? contactMethod;

  CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.tags = const [],
    this.category,
    this.location,
    this.date,
    this.time,
    this.contactMethod,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    DateTime timestamp;
    if (json['timestamp'] is Timestamp) {
      timestamp = (json['timestamp'] as Timestamp).toDate();
    } else if (json['timestamp'] is String) {
      timestamp = DateTime.parse(json['timestamp']);
    } else {
      timestamp = DateTime.now();
    }

    return CommunityPost(
      id: json['id'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? 'Anonymous',
      content: json['content'] ?? '',
      timestamp: timestamp,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'],
      location: json['location'],
      date: json['date'],
      time: json['time'],
      contactMethod: json['contactMethod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'tags': tags,
      'category': category,
      'location': location,
      'date': date,
      'time': time,
      'contactMethod': contactMethod,
    };
  }

  CommunityPost copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? content,
    DateTime? timestamp,
    int? likes,
    int? comments,
    List<String>? tags,
    String? category,
    String? location,
    String? date,
    String? time,
    String? contactMethod,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      location: location ?? this.location,
      date: date ?? this.date,
      time: time ?? this.time,
      contactMethod: contactMethod ?? this.contactMethod,
    );
  }

  @override
  String toString() {
    return 'CommunityPost(id: $id, authorName: $authorName, content: $content, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommunityPost && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
