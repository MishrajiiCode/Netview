import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/movie.dart';
import '../theme/app_theme.dart';
import '../screens/movie_detail_screen.dart';

class FeaturedMovieBanner extends StatefulWidget {
  final List<Movie> movies;

  const FeaturedMovieBanner({super.key, required this.movies});

  @override
  State<FeaturedMovieBanner> createState() => _FeaturedMovieBannerState();
}

class _FeaturedMovieBannerState extends State<FeaturedMovieBanner> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      if (widget.movies.isEmpty) return;
      final nextPage = (_currentPage + 1) % widget.movies.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return const SizedBox(height: 500, child: Center(
        child: CircularProgressIndicator(color: AppTheme.netflixRed),
      ));
    }

    return SizedBox(
      height: 520,
      child: Stack(
        children: [
          // Page view
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: widget.movies.length,
            itemBuilder: (_, i) => _FeaturedPage(movie: widget.movies[i]),
          ),

          // Dot indicators
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.movies.length, (i) {
                final isActive = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.netflixRed
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedPage extends StatelessWidget {
  final Movie movie;
  const _FeaturedPage({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          movie.thumbnailUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: movie.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: const Color(0xFF1A1A1A),
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.netflixRed),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFF1A1A1A),
                    child: const Icon(Icons.movie_rounded,
                        color: AppTheme.netflixRed, size: 64),
                  ),
                )
              : Container(
                  color: const Color(0xFF1A1A1A),
                  child: const Icon(Icons.movie_rounded,
                      color: AppTheme.netflixRed, size: 64),
                ),

          // Gradient overlay
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppTheme.heroGradient),
          ),

          // Side gradient for depth
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Content
          Positioned(
            bottom: 80,
            left: 20,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Genre pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.netflixRed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    movie.genre.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 10),

                // Title
                Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                const SizedBox(height: 8),

                // Meta row
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        color: AppTheme.netflixGold, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      movie.rating.toStringAsFixed(1),
                      style: TextStyle(
                        color: AppTheme.netflixGold,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${movie.year}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                    if (movie.duration.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Text(
                        movie.duration,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ],
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 12),

                // Description
                Text(
                  movie.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ).animate().fadeIn(delay: 450.ms),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    // Play button
                    _GlossyButton(
                      icon: Icons.play_arrow_rounded,
                      label: 'Play',
                      isPrimary: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailScreen(movie: movie),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // More Info
                    _GlossyButton(
                      icon: Icons.info_outline_rounded,
                      label: 'More Info',
                      isPrimary: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailScreen(movie: movie),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlossyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _GlossyButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: isPrimary
                  ? const LinearGradient(
                      colors: [Color(0xFFE50914), Color(0xFFB20710)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isPrimary ? null : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPrimary
                    ? Colors.transparent
                    : Colors.white.withOpacity(0.3),
              ),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: AppTheme.netflixRed.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
