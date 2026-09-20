import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../services/auth_service.dart';

class MovieProvider extends ChangeNotifier {
  final MovieService _movieService = MovieService();
  final AuthService _authService = AuthService();

  List<Movie> _allMovies = [];
  List<Movie> _featuredMovies = [];
  List<Movie> _searchResults = [];
  List<String> _genres = [];
  String _selectedGenre = 'All';
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  bool _isAdmin = false;
  int _logoTapCount = 0;

  // ─── GETTERS ────────────────────────────────────────────────────────────────

  List<Movie> get allMovies => _allMovies;
  List<Movie> get featuredMovies => _featuredMovies;
  List<Movie> get searchResults => _searchResults;
  List<String> get genres => ['All', ..._genres];
  String get selectedGenre => _selectedGenre;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  bool get isAdmin => _isAdmin;

  List<Movie> get filteredMovies {
    if (_selectedGenre == 'All') return _allMovies;
    return _allMovies.where((m) => m.genre == _selectedGenre).toList();
  }

  Map<String, List<Movie>> get moviesByGenre {
    final Map<String, List<Movie>> result = {};
    for (final genre in _genres) {
      final movies = _allMovies.where((m) => m.genre == genre).toList();
      if (movies.isNotEmpty) result[genre] = movies;
    }
    return result;
  }

  // ─── INIT ────────────────────────────────────────────────────────────────────

  void init() {
    _isAdmin = _authService.isAdmin;
    _loadMovies();
    _loadGenres();
    _authService.authStateChanges.listen((user) {
      _isAdmin = user != null;
      notifyListeners();
    });
  }

  void _loadMovies() {
    _movieService.watchAllMovies().listen((movies) {
      _allMovies = movies;
      _featuredMovies = movies.where((m) => m.isFeatured).toList();
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      notifyListeners();
    });
  }

  Future<void> _loadGenres() async {
    _genres = await _movieService.getDistinctGenres();
    notifyListeners();
  }

  // ─── SEARCH ─────────────────────────────────────────────────────────────────

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();
    _searchResults = await _movieService.searchMovies(query);
    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  // ─── GENRE FILTER ────────────────────────────────────────────────────────────

  void selectGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  // ─── ADMIN ACTIONS ──────────────────────────────────────────────────────────

  Future<void> addMovie(Movie movie) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _movieService.addMovie(movie);
      await _loadGenres();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMovie(Movie movie) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _movieService.updateMovie(movie);
      await _loadGenres();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMovie(String movieId) async {
    await _movieService.deleteMovie(movieId);
    await _loadGenres();
  }

  Future<void> incrementViewCount(String movieId) async {
    await _movieService.incrementViewCount(movieId);
  }

  // ─── HIDDEN ADMIN ENTRY ──────────────────────────────────────────────────────

  bool handleLogoTap() {
    _logoTapCount++;
    if (_logoTapCount >= 5) {
      _logoTapCount = 0;
      return true; // Signal to open admin login
    }
    return false;
  }

  // ─── AUTH ────────────────────────────────────────────────────────────────────

  Future<void> adminLogin(String email, String password) async {
    await _authService.signIn(email, password);
    _isAdmin = true;
    notifyListeners();
  }

  Future<void> adminLogout() async {
    await _authService.signOut();
    _isAdmin = false;
    notifyListeners();
  }

  // ─── SEED ────────────────────────────────────────────────────────────────────

  Future<void> seedDemoData() async {
    await _movieService.seedDemoMovies();
    await _loadGenres();
  }
}
