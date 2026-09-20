import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/movie.dart';
import 'package:uuid/uuid.dart';

class MovieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  CollectionReference get _movies => _firestore.collection('movies');

  // ─── READ ───────────────────────────────────────────────────────────────────

  Stream<List<Movie>> watchAllMovies() {
    return _movies
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Movie.fromFirestore(d)).toList());
  }

  Stream<List<Movie>> watchFeaturedMovies() {
    return _movies
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Movie.fromFirestore(d)).toList());
  }

  Stream<List<Movie>> watchMoviesByGenre(String genre) {
    return _movies
        .where('genre', isEqualTo: genre)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Movie.fromFirestore(d)).toList());
  }

  Future<List<Movie>> searchMovies(String query) async {
    final lower = query.toLowerCase();
    final all = await _movies.get();
    return all.docs
        .map((d) => Movie.fromFirestore(d))
        .where((m) =>
            m.title.toLowerCase().contains(lower) ||
            m.genre.toLowerCase().contains(lower) ||
            m.description.toLowerCase().contains(lower) ||
            m.cast.any((c) => c.toLowerCase().contains(lower)))
        .toList();
  }

  Future<Movie?> getMovie(String id) async {
    final doc = await _movies.doc(id).get();
    if (doc.exists) return Movie.fromFirestore(doc);
    return null;
  }

  Future<List<String>> getDistinctGenres() async {
    final snap = await _movies.get();
    final genres = snap.docs
        .map((d) => (d.data() as Map<String, dynamic>)['genre'] as String? ?? '')
        .where((g) => g.isNotEmpty)
        .toSet()
        .toList();
    genres.sort();
    return genres;
  }

  // ─── CREATE ─────────────────────────────────────────────────────────────────

  Future<String> addMovie(Movie movie) async {
    final doc = await _movies.add(movie.toFirestore());
    return doc.id;
  }

  // ─── UPDATE ─────────────────────────────────────────────────────────────────

  Future<void> updateMovie(Movie movie) async {
    await _movies.doc(movie.id).update(movie.toFirestore());
  }

  Future<void> incrementViewCount(String movieId) async {
    await _movies.doc(movieId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  // ─── DELETE ─────────────────────────────────────────────────────────────────

  Future<void> deleteMovie(String movieId) async {
    await _movies.doc(movieId).delete();
  }

  // ─── FIREBASE STORAGE UPLOAD ─────────────────────────────────────────────────

  Future<String> uploadVideo(File videoFile, void Function(double) onProgress) async {
    final fileName = '${_uuid.v4()}.mp4';
    final ref = _storage.ref().child('videos/$fileName');
    final task = ref.putFile(videoFile);

    task.snapshotEvents.listen((snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      onProgress(progress);
    });

    await task;
    return await ref.getDownloadURL();
  }

  Future<String> uploadThumbnail(File imageFile) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('thumbnails/$fileName');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<void> deleteStorageFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {
      // File may not exist in storage (e.g., Google Photos links)
    }
  }

  // ─── SEED DEMO DATA ─────────────────────────────────────────────────────────

  Future<void> seedDemoMovies() async {
    final existing = await _movies.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final demos = [
      Movie(
        id: '',
        title: 'The Dark Knight',
        description: 'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
        genre: 'Action',
        thumbnailUrl: 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
        videoUrl: '',
        year: 2008,
        rating: 9.0,
        duration: '2h 32m',
        cast: ['Christian Bale', 'Heath Ledger', 'Aaron Eckhart'],
        tags: ['Superhero', 'Crime', 'Thriller'],
        isFeatured: true,
        createdAt: DateTime.now(),
      ),
      Movie(
        id: '',
        title: 'Inception',
        description: 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.',
        genre: 'Sci-Fi',
        thumbnailUrl: 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
        videoUrl: '',
        year: 2010,
        rating: 8.8,
        duration: '2h 28m',
        cast: ['Leonardo DiCaprio', 'Joseph Gordon-Levitt', 'Elliot Page'],
        tags: ['Mind-Bending', 'Thriller', 'Action'],
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      Movie(
        id: '',
        title: 'Interstellar',
        description: 'A team of explorers travel through a wormhole in space in an attempt to ensure humanity\'s survival.',
        genre: 'Sci-Fi',
        thumbnailUrl: 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
        videoUrl: '',
        year: 2014,
        rating: 8.6,
        duration: '2h 49m',
        cast: ['Matthew McConaughey', 'Anne Hathaway', 'Jessica Chastain'],
        tags: ['Space', 'Drama', 'Adventure'],
        isFeatured: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      Movie(
        id: '',
        title: 'The Godfather',
        description: 'The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.',
        genre: 'Drama',
        thumbnailUrl: 'https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsLLeHOJZ4FaI.jpg',
        videoUrl: '',
        year: 1972,
        rating: 9.2,
        duration: '2h 55m',
        cast: ['Marlon Brando', 'Al Pacino', 'James Caan'],
        tags: ['Crime', 'Classic', 'Drama'],
        isFeatured: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      Movie(
        id: '',
        title: 'Avengers: Endgame',
        description: 'After the devastating events of Infinity War, the Avengers assemble once more in order to reverse Thanos\'s actions and restore balance to the universe.',
        genre: 'Action',
        thumbnailUrl: 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
        videoUrl: '',
        year: 2019,
        rating: 8.4,
        duration: '3h 1m',
        cast: ['Robert Downey Jr.', 'Chris Evans', 'Mark Ruffalo'],
        tags: ['Superhero', 'Action', 'Adventure'],
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      Movie(
        id: '',
        title: 'Parasite',
        description: 'Greed and class discrimination threaten the newly formed symbiotic relationship between the wealthy Park family and the destitute Kim clan.',
        genre: 'Thriller',
        thumbnailUrl: 'https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg',
        videoUrl: '',
        year: 2019,
        rating: 8.5,
        duration: '2h 12m',
        cast: ['Song Kang-ho', 'Lee Sun-kyun', 'Cho Yeo-jeong'],
        tags: ['Korean', 'Drama', 'Thriller'],
        isFeatured: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];

    for (final m in demos) {
      await _movies.add(m.toFirestore());
    }
  }
}
