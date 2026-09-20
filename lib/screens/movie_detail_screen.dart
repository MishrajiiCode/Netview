import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../theme/app_theme.dart';
import 'player_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorited = false;

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppTheme.netflixDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => setState(() => _isFavorited = !_isFavorited),
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _isFavorited
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(_isFavorited),
                  color: _isFavorited ? AppTheme.netflixRed : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero thumbnail
            SizedBox(
              height: size.height * 0.45,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  movie.thumbnailUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: movie.thumbnailUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(color: const Color(0xFF1A1A1A)),

                  // Gradient
                  const DecoratedBox(
                    decoration:
                        BoxDecoration(gradient: AppTheme.heroGradient),
                  ),

                  // Play button overlay
                  Center(
                    child: GestureDetector(
                      onTap: () => _playMovie(context, movie),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 40),
                      ),
                    ).animate().scale(delay: 200.ms),
                  ),
                ],
              ),
            ),

            // Details section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Genre + Year row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.netflixRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          movie.genre.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${movie.year}',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 14)),
                      if (movie.duration.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.access_time_rounded,
                            color: Colors.white38, size: 14),
                        const SizedBox(width: 4),
                        Text(movie.duration,
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 14)),
                      ],
                    ],
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ).animate().fadeIn(delay: 150.ms),
                  const SizedBox(height: 12),

                  // Rating
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: movie.rating / 2,
                        itemBuilder: (_, __) => const Icon(
                            Icons.star_rounded,
                            color: AppTheme.netflixGold),
                        itemCount: 5,
                        itemSize: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${movie.rating}/10',
                        style: TextStyle(
                          color: AppTheme.netflixGold,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${movie.viewCount} views)',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 20),

                  // Play & Download buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded,
                              size: 22),
                          label: const Text(
                            'Play',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () => _playMovie(context, movie),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _IconActionButton(
                        icon: Icons.add_rounded,
                        label: 'My List',
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _IconActionButton(
                        icon: Icons.thumb_up_outlined,
                        label: 'Rate',
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _IconActionButton(
                        icon: Icons.share_rounded,
                        label: 'Share',
                        onTap: () {},
                      ),
                    ],
                  ).animate().fadeIn(delay: 250.ms),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Synopsis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 24),

                  // Cast
                  if (movie.cast.isNotEmpty) ...[
                    const Text(
                      'Cast',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: movie.cast
                          .map((actor) => _CastChip(name: actor))
                          .toList(),
                    ).animate().fadeIn(delay: 350.ms),
                    const SizedBox(height: 24),
                  ],

                  // Tags
                  if (movie.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: movie.tags
                          .map((tag) => _TagChip(tag: tag))
                          .toList(),
                    ).animate().fadeIn(delay: 400.ms),
                  ],

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playMovie(BuildContext context, Movie movie) {
    if (movie.videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '⚠️ No video URL set. Admin needs to add a video link.'),
          backgroundColor: Color(0xFF2A2A2A),
        ),
      );
      return;
    }
    context.read<MovieProvider>().incrementViewCount(movie.id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerScreen(movie: movie)),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }
}

class _CastChip extends StatelessWidget {
  final String name;
  const _CastChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(name,
          style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.netflixRed.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.netflixRed.withOpacity(0.3)),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(
            color: AppTheme.netflixRed.withOpacity(0.8), fontSize: 12),
      ),
    );
  }
}
