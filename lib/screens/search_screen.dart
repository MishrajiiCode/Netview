import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';
import '../screens/movie_detail_screen.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.netflixDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: AppTheme.netflixRed,
                        decoration: const InputDecoration(
                          hintText: 'Search movies, genres, cast...',
                          hintStyle: TextStyle(color: Colors.white38),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        onChanged: (q) =>
                            context.read<MovieProvider>().search(q),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      _controller.clear();
                      context.read<MovieProvider>().clearSearch();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                          color: AppTheme.netflixRed,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Results
            Expanded(
              child: Consumer<MovieProvider>(
                builder: (_, provider, __) {
                  if (provider.isSearching) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.netflixRed),
                    );
                  }

                  if (_controller.text.isEmpty) {
                    return _BrowseByGenre(provider: provider);
                  }

                  if (provider.searchResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded,
                              color: Colors.white24, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'No results for "${_controller.text}"',
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: provider.searchResults.length,
                    itemBuilder: (_, i) {
                      final movie = provider.searchResults[i];
                      return MovieCard(
                        movie: movie,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MovieDetailScreen(movie: movie),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrowseByGenre extends StatelessWidget {
  final MovieProvider provider;
  const _BrowseByGenre({required this.provider});

  @override
  Widget build(BuildContext context) {
    final genres = provider.genres.where((g) => g != 'All').toList();
    final colors = [
      const Color(0xFF1A4A2E),
      const Color(0xFF2E1A1A),
      const Color(0xFF1A2E2E),
      const Color(0xFF2E2A1A),
      const Color(0xFF1A1A2E),
      const Color(0xFF2A1A2E),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Browse by Genre',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: genres.length,
            itemBuilder: (_, i) {
              final genre = genres[i];
              final color = colors[i % colors.length];
              final movies = provider.moviesByGenre[genre] ?? [];
              return GestureDetector(
                onTap: () {
                  provider.selectGenre(genre);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Transform.rotate(
                          angle: 0.3,
                          child: Icon(
                            _genreIcon(genre),
                            color: Colors.white.withOpacity(0.15),
                            size: 60,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              genre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${movies.length} title${movies.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _genreIcon(String genre) {
    switch (genre.toLowerCase()) {
      case 'action':
        return Icons.local_fire_department_rounded;
      case 'drama':
        return Icons.theater_comedy_rounded;
      case 'sci-fi':
        return Icons.rocket_launch_rounded;
      case 'thriller':
        return Icons.remove_red_eye_rounded;
      case 'comedy':
        return Icons.sentiment_very_satisfied_rounded;
      case 'horror':
        return Icons.dark_mode_rounded;
      case 'romance':
        return Icons.favorite_rounded;
      case 'animation':
        return Icons.animation_rounded;
      default:
        return Icons.movie_rounded;
    }
  }
}
