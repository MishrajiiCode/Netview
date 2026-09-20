import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String title;
  final String description;
  final String genre;
  final String thumbnailUrl;
  final String videoUrl;       // Google Photos share link or Firebase Storage URL
  final String videoType;      // 'google_photos' | 'firebase_storage' | 'direct'
  final int year;
  final double rating;
  final String duration;
  final List<String> cast;
  final List<String> tags;
  final bool isFeatured;
  final DateTime createdAt;
  final int viewCount;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.genre,
    required this.thumbnailUrl,
    required this.videoUrl,
    this.videoType = 'direct',
    required this.year,
    required this.rating,
    this.duration = '',
    this.cast = const [],
    this.tags = const [],
    this.isFeatured = false,
    required this.createdAt,
    this.viewCount = 0,
  });

  factory Movie.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Movie(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      genre: data['genre'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      videoType: data['videoType'] ?? 'direct',
      year: data['year'] ?? DateTime.now().year,
      rating: (data['rating'] ?? 0.0).toDouble(),
      duration: data['duration'] ?? '',
      cast: List<String>.from(data['cast'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      isFeatured: data['isFeatured'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      viewCount: data['viewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'genre': genre,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'videoType': videoType,
      'year': year,
      'rating': rating,
      'duration': duration,
      'cast': cast,
      'tags': tags,
      'isFeatured': isFeatured,
      'createdAt': Timestamp.fromDate(createdAt),
      'viewCount': viewCount,
    };
  }

  Movie copyWith({
    String? id,
    String? title,
    String? description,
    String? genre,
    String? thumbnailUrl,
    String? videoUrl,
    String? videoType,
    int? year,
    double? rating,
    String? duration,
    List<String>? cast,
    List<String>? tags,
    bool? isFeatured,
    DateTime? createdAt,
    int? viewCount,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      genre: genre ?? this.genre,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      videoType: videoType ?? this.videoType,
      year: year ?? this.year,
      rating: rating ?? this.rating,
      duration: duration ?? this.duration,
      cast: cast ?? this.cast,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}
