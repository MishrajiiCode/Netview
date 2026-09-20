import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../theme/app_theme.dart';
import 'movie_card.dart';
import '../screens/movie_detail_screen.dart';

class MovieRow extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final bool isLarge;

  const MovieRow({
    super.key,
    required this.title,
    required this.movies,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'See all',
                    style: TextStyle(
                      color: AppTheme.netflixRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppTheme.netflixRed, size: 18),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: isLarge ? 285 : 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: movies.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: MovieCard(
                movie: movies[i],
                isLarge: isLarge,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MovieDetailScreen(movie: movies[i]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
