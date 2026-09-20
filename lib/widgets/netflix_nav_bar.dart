import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Peeled/curved glassmorphism bottom navigation bar
class PeeledNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PeeledNavItem> items;

  const PeeledNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<PeeledNavBar> createState() => _PeeledNavBarState();
}

class _PeeledNavBarState extends State<PeeledNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(PeeledNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _slideController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Stack(
        children: [
          // Glass background with custom curved painter
          Positioned.fill(
            child: CustomPaint(
              painter: _PeeledNavBarPainter(
                selectedIndex: widget.currentIndex,
                itemCount: widget.items.length,
              ),
              child: ClipPath(
                clipper: _PeeledNavBarClipper(
                  selectedIndex: widget.currentIndex,
                  itemCount: widget.items.length,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF1C1C1C).withOpacity(0.95),
                          const Color(0xFF0D0D0D).withOpacity(0.98),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Top glossy sheen
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            height: 1.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Nav items
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(widget.items.length, (i) {
                final isSelected = i == widget.currentIndex;
                return _NavItemWidget(
                  item: widget.items[i],
                  isSelected: isSelected,
                  onTap: () => widget.onTap(i),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemWidget extends StatelessWidget {
  final PeeledNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isSelected ? 52 : 44,
              height: isSelected ? 52 : 44,
              decoration: isSelected
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE50914), Color(0xFFB20710)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.netflixRed.withOpacity(0.5),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    )
                  : null,
              child: Center(
                child: AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF808080),
                    size: isSelected ? 24 : 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: isSelected ? AppTheme.netflixRed : const Color(0xFF606060),
                fontSize: isSelected ? 11 : 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: 0.3,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class PeeledNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const PeeledNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// Custom painter for the peeled/curved top edge
class _PeeledNavBarPainter extends CustomPainter {
  final int selectedIndex;
  final int itemCount;

  _PeeledNavBarPainter({required this.selectedIndex, required this.itemCount});

  @override
  void paint(Canvas canvas, Size size) {
    final itemWidth = size.width / itemCount;
    final selectedCenter = itemWidth * selectedIndex + itemWidth / 2;

    // Border glow at the top peeled bump
    final glowPaint = Paint()
      ..color = AppTheme.netflixRed.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6);

    final path = _buildPath(size, selectedCenter);
    canvas.drawPath(path, glowPaint);
  }

  Path _buildPath(Size size, double selectedCenter) {
    const pumpHeight = 18.0;
    const pumpWidth = 60.0;

    final path = Path();
    path.moveTo(0, pumpHeight + 4);

    // Left flat region
    path.lineTo(selectedCenter - pumpWidth / 2, pumpHeight + 4);

    // Peeled bump
    path.cubicTo(
      selectedCenter - pumpWidth / 4,
      pumpHeight + 4,
      selectedCenter - pumpWidth / 4,
      0,
      selectedCenter,
      0,
    );
    path.cubicTo(
      selectedCenter + pumpWidth / 4,
      0,
      selectedCenter + pumpWidth / 4,
      pumpHeight + 4,
      selectedCenter + pumpWidth / 2,
      pumpHeight + 4,
    );

    // Right flat region
    path.lineTo(size.width, pumpHeight + 4);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(_PeeledNavBarPainter old) =>
      old.selectedIndex != selectedIndex;
}

class _PeeledNavBarClipper extends CustomClipper<Path> {
  final int selectedIndex;
  final int itemCount;

  _PeeledNavBarClipper({required this.selectedIndex, required this.itemCount});

  @override
  Path getClip(Size size) {
    final itemWidth = size.width / itemCount;
    final selectedCenter = itemWidth * selectedIndex + itemWidth / 2;
    const pumpHeight = 18.0;
    const pumpWidth = 60.0;

    final path = Path();
    path.moveTo(0, pumpHeight + 4);
    path.lineTo(selectedCenter - pumpWidth / 2, pumpHeight + 4);
    path.cubicTo(
      selectedCenter - pumpWidth / 4,
      pumpHeight + 4,
      selectedCenter - pumpWidth / 4,
      0,
      selectedCenter,
      0,
    );
    path.cubicTo(
      selectedCenter + pumpWidth / 4,
      0,
      selectedCenter + pumpWidth / 4,
      pumpHeight + 4,
      selectedCenter + pumpWidth / 2,
      pumpHeight + 4,
    );
    path.lineTo(size.width, pumpHeight + 4);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_PeeledNavBarClipper old) =>
      old.selectedIndex != selectedIndex;
}
