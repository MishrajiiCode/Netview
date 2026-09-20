import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/featured_movie.dart';
import '../widgets/movie_row.dart';
import '../screens/admin/admin_login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 50;
      if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().seedDemoData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.netflixDark,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: _isScrolled
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.95),
                        Colors.black.withOpacity(0.0),
                      ],
                    )
                  : null,
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              titleSpacing: 16,
              title: _NetflixLogo(onAdminTap: () => _checkAdminTap(context)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                  onPressed: () {},
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.netflixRed,
                    child: const Text(
                      'U',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Consumer<MovieProvider>(
          builder: (_, provider, __) {
            final featured = provider.featuredMovies;
            final all = provider.allMovies;
            final byGenre = provider.moviesByGenre;

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Featured Banner
                SliverToBoxAdapter(
                  child: FeaturedMovieBanner(movies: featured),
                ),

                // Genre Filter Chips
                SliverToBoxAdapter(
                  child: _GenreFilter(provider: provider),
                ),

                // "All Movies" or filtered row
                if (provider.selectedGenre != 'All')
                  SliverToBoxAdapter(
                    child: MovieRow(
                      title: provider.selectedGenre,
                      movies: provider.filteredMovies,
                      isLarge: true,
                    ),
                  )
                else ...[
                  // New Releases
                  SliverToBoxAdapter(
                    child: MovieRow(
                      title: '🔥 New Releases',
                      movies: all.take(8).toList(),
                      isLarge: true,
                    ),
                  ),

                  // By Genre rows
                  ...byGenre.entries.map(
                    (e) => SliverToBoxAdapter(
                      child: MovieRow(
                        title: e.key,
                        movies: e.value,
                      ),
                    ),
                  ),

                  // Top Rated
                  SliverToBoxAdapter(
                    child: MovieRow(
                      title: '⭐ Top Rated',
                      movies: List.from(all)
                        ..sort((a, b) => b.rating.compareTo(a.rating)),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _checkAdminTap(BuildContext context) {
    final shouldOpen = context.read<MovieProvider>().handleLogoTap();
    if (shouldOpen) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      );
    }
  }
}

class _NetflixLogo extends StatelessWidget {
  final VoidCallback onAdminTap;
  const _NetflixLogo({required this.onAdminTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdminTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 48,
            child: CustomPaint(painter: _MiniNetflixN()),
          ),
          const SizedBox(width: 8),
          const Text(
            'MOVI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniNetflixN extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sw = w * 0.28;

    final paint = Paint()
      ..color = AppTheme.netflixRed
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, sw, h), paint);
    canvas.drawRect(Rect.fromLTWH(w - sw, 0, sw, h), paint);

    final diag = Path()
      ..moveTo(0, 0)
      ..lineTo(sw, 0)
      ..lineTo(w, h)
      ..lineTo(w - sw, h)
      ..close();
    canvas.drawPath(diag, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GenreFilter extends StatelessWidget {
  final MovieProvider provider;
  const _GenreFilter({required this.provider});

  @override
  Widget build(BuildContext context) {
    final genres = provider.genres;
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: genres.length,
        itemBuilder: (_, i) {
          final genre = genres[i];
          final isSelected = provider.selectedGenre == genre;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => provider.selectGenre(genre),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFE50914), Color(0xFFB20710)],
                        )
                      : null,
                  color: isSelected ? null : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.netflixRed
                        : Colors.white.withOpacity(0.1),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.netflixRed.withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  genre,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
