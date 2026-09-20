import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../providers/movie_provider.dart';
import '../../services/movie_service.dart';
import '../../theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.netflixDark,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.netflixRed,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Dashboard',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await context.read<MovieProvider>().adminLogout();
              if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
            },
            icon: const Icon(Icons.logout_rounded,
                color: Colors.white54, size: 18),
            label: const Text('Logout',
                style: TextStyle(color: Colors.white54, fontSize: 14)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.netflixRed,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(text: 'All Movies'),
            Tab(text: 'Add Movie'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MovieListTab(
            onEdit: (movie) {
              _tabController.animateTo(1);
              // Will be handled by AddMovieTab's edit mode
            },
          ),
          _AddMovieTab(),
        ],
      ),
    );
  }
}

// ─── MOVIE LIST TAB ─────────────────────────────────────────────────────────

class _MovieListTab extends StatelessWidget {
  final void Function(Movie) onEdit;
  const _MovieListTab({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (_, provider, __) {
        final movies = provider.allMovies;

        if (movies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.movie_filter_outlined,
                    color: Colors.white24, size: 64),
                const SizedBox(height: 16),
                const Text('No movies yet',
                    style: TextStyle(color: Colors.white60, fontSize: 16)),
                const SizedBox(height: 8),
                const Text('Add your first movie using the "Add Movie" tab',
                    style:
                        TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: movies.length,
          itemBuilder: (_, i) {
            final movie = movies[i];
            return _AdminMovieTile(
              movie: movie,
              onDelete: () => _confirmDelete(context, provider, movie),
              onEdit: () => onEdit(movie),
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: i * 60))
                .slideX(begin: 0.1);
          },
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, MovieProvider provider, Movie movie) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Movie',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete "${movie.title}"? This cannot be undone.',
          style: const TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.netflixRed),
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteMovie(movie.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🗑️ "${movie.title}" deleted'),
                    backgroundColor: const Color(0xFF2A2A2A),
                  ),
                );
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _AdminMovieTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _AdminMovieTile({
    required this.movie,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: movie.thumbnailUrl.isNotEmpty
                ? Image.network(
                    movie.thumbnailUrl,
                    width: 80,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _placeholder(),
                  )
                : _placeholder(),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.netflixRed.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          movie.genre,
                          style: const TextStyle(
                              color: AppTheme.netflixRed,
                              fontSize: 10,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('${movie.year}',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: AppTheme.netflixGold, size: 13),
                      const SizedBox(width: 3),
                      Text(
                        movie.rating.toStringAsFixed(1),
                        style: TextStyle(
                            color: AppTheme.netflixGold, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        movie.videoUrl.isNotEmpty
                            ? Icons.check_circle_rounded
                            : Icons.warning_rounded,
                        color: movie.videoUrl.isNotEmpty
                            ? Colors.green
                            : Colors.orange,
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        movie.videoUrl.isNotEmpty
                            ? 'Video Set'
                            : 'No Video',
                        style: TextStyle(
                          color: movie.videoUrl.isNotEmpty
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (movie.isFeatured)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.netflixGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '⭐ Featured',
                        style: TextStyle(
                            color: AppTheme.netflixGold,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Actions
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded,
                    color: Colors.white54, size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded,
                    color: AppTheme.netflixRed, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 80,
      height: 110,
      color: const Color(0xFF2A2A2A),
      child: const Icon(Icons.movie_rounded,
          color: AppTheme.netflixRed, size: 28),
    );
  }
}

// ─── ADD MOVIE TAB ──────────────────────────────────────────────────────────

class _AddMovieTab extends StatefulWidget {
  const _AddMovieTab();

  @override
  State<_AddMovieTab> createState() => _AddMovieTabState();
}

class _AddMovieTabState extends State<_AddMovieTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _thumbCtrl = TextEditingController();
  final _videoUrlCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _castCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(text: '2024');

  String _selectedGenre = 'Action';
  double _rating = 7.0;
  bool _isFeatured = false;
  String _videoType = 'google_photos';
  bool _isLoading = false;
  double _uploadProgress = 0;
  File? _pickedVideo;
  final _movieService = MovieService();

  final _genres = [
    'Action', 'Drama', 'Sci-Fi', 'Thriller', 'Comedy',
    'Horror', 'Romance', 'Animation', 'Documentary', 'Other'
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _thumbCtrl.dispose();
    _videoUrlCtrl.dispose();
    _durationCtrl.dispose();
    _castCtrl.dispose();
    _tagsCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedVideo = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _uploadProgress = 0;
    });

    try {
      String videoUrl = _videoUrlCtrl.text.trim();

      // If a video file was picked, upload it
      if (_pickedVideo != null && _videoType == 'firebase_storage') {
        videoUrl = await _movieService.uploadVideo(
          _pickedVideo!,
          (p) => setState(() => _uploadProgress = p),
        );
      }

      final movie = Movie(
        id: '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        genre: _selectedGenre,
        thumbnailUrl: _thumbCtrl.text.trim(),
        videoUrl: videoUrl,
        videoType: _videoType,
        year: int.tryParse(_yearCtrl.text) ?? 2024,
        rating: _rating,
        duration: _durationCtrl.text.trim(),
        cast: _castCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        tags: _tagsCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        isFeatured: _isFeatured,
        createdAt: DateTime.now(),
      );

      await context.read<MovieProvider>().addMovie(movie);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "${movie.title}" added successfully!'),
            backgroundColor: const Color(0xFF1A3A1A),
          ),
        );
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppTheme.netflixRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _titleCtrl.clear();
    _descCtrl.clear();
    _thumbCtrl.clear();
    _videoUrlCtrl.clear();
    _durationCtrl.clear();
    _castCtrl.clear();
    _tagsCtrl.clear();
    _yearCtrl.text = '2024';
    setState(() {
      _selectedGenre = 'Action';
      _rating = 7.0;
      _isFeatured = false;
      _videoType = 'google_photos';
      _pickedVideo = null;
      _uploadProgress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Basic Info'),
            _field(_titleCtrl, 'Movie Title *',
                Icons.movie_rounded, required: true),
            _field(_descCtrl, 'Description *',
                Icons.description_outlined,
                maxLines: 4, required: true),
            _field(_yearCtrl, 'Release Year',
                Icons.calendar_today_outlined),
            _field(_durationCtrl, 'Duration (e.g. 2h 15m)',
                Icons.access_time_rounded),

            const SizedBox(height: 16),
            _sectionTitle('Genre & Rating'),

            // Genre dropdown
            DropdownButtonFormField<String>(
              value: _selectedGenre,
              dropdownColor: const Color(0xFF2A2A2A),
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Genre', Icons.category_outlined),
              items: _genres
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedGenre = v!),
            ),
            const SizedBox(height: 16),

            // Rating slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rating: ${_rating.toStringAsFixed(1)}/10',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14),
                ),
                Slider(
                  value: _rating,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  activeColor: AppTheme.netflixRed,
                  inactiveColor: const Color(0xFF333333),
                  onChanged: (v) => setState(() => _rating = v),
                ),
              ],
            ),

            // Featured toggle
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: SwitchListTile(
                title: const Text('Featured Movie',
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text('Show in hero banner',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
                value: _isFeatured,
                activeColor: AppTheme.netflixRed,
                onChanged: (v) => setState(() => _isFeatured = v),
              ),
            ),

            const SizedBox(height: 20),
            _sectionTitle('Media'),

            _field(_thumbCtrl, 'Thumbnail URL *',
                Icons.image_outlined, required: true),

            // Video source selector
            const SizedBox(height: 12),
            const Text('Video Source',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                _VideoTypeChip(
                  label: '📸 Google Photos',
                  value: 'google_photos',
                  selected: _videoType == 'google_photos',
                  onTap: () => setState(() => _videoType = 'google_photos'),
                ),
                const SizedBox(width: 8),
                _VideoTypeChip(
                  label: '☁️ Firebase Upload',
                  value: 'firebase_storage',
                  selected: _videoType == 'firebase_storage',
                  onTap: () =>
                      setState(() => _videoType = 'firebase_storage'),
                ),
                const SizedBox(width: 8),
                _VideoTypeChip(
                  label: '🔗 Direct URL',
                  value: 'direct',
                  selected: _videoType == 'direct',
                  onTap: () => setState(() => _videoType = 'direct'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_videoType == 'google_photos') ...[
              _field(_videoUrlCtrl, 'Google Photos Share Link',
                  Icons.link_rounded),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2A1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Text(
                  '📱 In Google Photos: Open video → Share → "Anyone with link" → Copy link → Paste above',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
            ] else if (_videoType == 'firebase_storage') ...[
              // File picker for video
              GestureDetector(
                onTap: _pickVideo,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _pickedVideo != null
                          ? Colors.green.withOpacity(0.5)
                          : Colors.white12,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _pickedVideo != null
                            ? Icons.check_circle_rounded
                            : Icons.upload_file_rounded,
                        color: _pickedVideo != null
                            ? Colors.green
                            : Colors.white38,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _pickedVideo != null
                              ? _pickedVideo!.path.split('/').last
                              : 'Tap to pick video from gallery',
                          style: TextStyle(
                            color: _pickedVideo != null
                                ? Colors.white
                                : Colors.white38,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading && _uploadProgress > 0) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: const Color(0xFF333333),
                  valueColor: const AlwaysStoppedAnimation(
                      AppTheme.netflixRed),
                ),
                const SizedBox(height: 4),
                Text(
                  'Uploading... ${(_uploadProgress * 100).toInt()}%',
                  style:
                      const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ] else ...[
              _field(_videoUrlCtrl, 'Direct Video URL',
                  Icons.link_rounded),
            ],

            const SizedBox(height: 20),
            _sectionTitle('Additional Info'),
            _field(_castCtrl, 'Cast (comma separated)',
                Icons.people_outlined),
            _field(_tagsCtrl, 'Tags (comma separated)',
                Icons.label_outline_rounded),

            const SizedBox(height: 28),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.netflixRed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 8,
                  shadowColor: AppTheme.netflixRed.withOpacity(0.4),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.add_circle_outline_rounded,
                        color: Colors.white),
                label: Text(
                  _isLoading ? 'Adding Movie...' : 'Add Movie',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                onPressed: _isLoading ? null : _submit,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppTheme.netflixRed,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label, icon),
        validator: required
            ? (v) => v?.trim().isEmpty == true ? '$label is required' : null
            : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white38, size: 20),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.netflixRed, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Colors.white54),
    );
  }
}

class _VideoTypeChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _VideoTypeChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.netflixRed.withOpacity(0.2)
              : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.netflixRed : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.netflixRed : Colors.white54,
            fontSize: 11,
            fontWeight:
                selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
