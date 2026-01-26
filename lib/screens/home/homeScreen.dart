import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../widgets/twinkling_stars_painter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🌌 Night sky – stars only
        const Positioned.fill(child: TwinklingStars()),

        // Foreground UI (unchanged)
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👋 Greeting (fade + slide)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final t = Curves.easeOut.transform(_controller.value);

                    return Opacity(
                      opacity: t.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, (1 - t) * 30),
                        child: child,
                      ),
                    );
                  },
                  child: const Text(
                    "Hello, Alex 👋",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: Color.fromARGB(200, 200, 200, 200),
                    ),
                  ),
                ),

                const SizedBox(height: 6),
                Text(
                  "Welcome back, your storage looks good today",
                  style: TextStyle(fontSize: 14, color: kTextSecondary),
                ),

                const SizedBox(height: 28),

                // 💾 Storage Card
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final scale = Curves.easeOutBack.transform(
                      _controller.value.clamp(0.0, 1.0),
                    );

                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: kPrimaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Storage Usage",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "2.3 GB / 10 GB",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 16),

                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: (0.23 * _controller.value).clamp(
                                  0.0,
                                  1.0,
                                ),
                                minHeight: 8,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              elevation: 0,
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
                              "Upgrade Plan",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ⚡ Quick Actions
                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 200, 200, 200),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _animatedAction(0, Icons.cloud_upload_rounded, "Upload"),
                    _animatedAction(1, Icons.folder_open_rounded, "Files"),
                    _animatedAction(2, Icons.star_rounded, "Rewards"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🔥 Staggered action animation (SAFE)
  Widget _animatedAction(int index, IconData icon, String label) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final delay = index * 0.2;
        final raw = ((_controller.value - delay) / 0.6).clamp(0.0, 1.0);

        final scale = Curves.easeOutBack.transform(raw);

        return Transform.scale(
          scale: scale,
          child: Opacity(opacity: raw, child: child),
        );
      },
      child: _buildActionItem(icon, label),
    );
  }

  Widget _buildActionItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) => kPrimaryGradient.createShader(bounds),
              child: Icon(icon, size: 26, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: kTextSecondary,
          ),
        ),
      ],
    );
  }
}
