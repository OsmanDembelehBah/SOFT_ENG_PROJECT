import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Rich Vector Bike Rider Visual for TransitFlow SL
/// Renders an authentic commercial Okada rider with helmet, safety gear,
/// motorcycle front cockpit, and Sierra Leone backdrop.
/// Guaranteed 100% offline, resolution-independent and visually rich.
class BikeRiderVisual extends StatelessWidget {
  final double height;
  final bool compact;

  const BikeRiderVisual({
    super.key,
    this.height = 190,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F2B1D), // Dark Forest Green
            Color(0xFF133E2B),
            Color(0xFF0E2238), // Deep Sierra Leone Blue
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Custom vector painter drawing Freetown topography, road and motorcycle rider
            Positioned.fill(
              child: CustomPaint(
                painter: _OkadaRiderPainter(compact: compact),
              ),
            ),

            // Top badge: SDG 11 & SDG 8 alignment
            Positioned(
              top: 12,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.goldenAmber.withOpacity(0.6),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      size: 14,
                      color: AppTheme.goldenAmber,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      compact
                          ? 'SDG 11.2 • SDG 8'
                          : 'SDG 11.2 Safe Urban Transit • SDG 8 Decent Work',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom overlay caption
            Positioned(
              bottom: 12,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'OKADA FLEET • FREETOWN SL',
                            style: TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      if (!compact)
                        const Text(
                          'Verified Helmets • Digital Dues • Real-Time Safety',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.accentBlue.withOpacity(0.5),
                      ),
                    ),
                    child: const Text(
                      'TRANSITFLOW SL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OkadaRiderPainter extends CustomPainter {
  final bool compact;

  _OkadaRiderPainter({this.compact = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw Freetown mountain rolling contours in background
    final hillPaint = Paint()
      ..color = const Color(0xFF1B4D36).withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final hillPath = Path()
      ..moveTo(0, h * 0.65)
      ..quadraticBezierTo(w * 0.25, h * 0.40, w * 0.55, h * 0.55)
      ..quadraticBezierTo(w * 0.80, h * 0.42, w, h * 0.52)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hillPath, hillPaint);

    // 2. Draw curved road ribbon
    final roadPaint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final roadPath = Path()
      ..moveTo(w * 0.15, h)
      ..quadraticBezierTo(w * 0.45, h * 0.65, w * 0.70, h * 0.55)
      ..lineTo(w * 0.85, h * 0.55)
      ..quadraticBezierTo(w * 0.60, h * 0.70, w * 0.45, h)
      ..close();
    canvas.drawPath(roadPath, roadPaint);

    // Road dashed line
    final linePaint = Paint()
      ..color = AppTheme.goldenAmber.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final roadLine = Path()
      ..moveTo(w * 0.30, h)
      ..quadraticBezierTo(w * 0.52, h * 0.68, w * 0.78, h * 0.55);
    canvas.drawPath(roadLine, linePaint);

    // 3. Draw Stylized Commercial Motorcycle Rider in centre-right
    final riderCenterX = w * 0.74;
    final riderCenterY = h * 0.52;

    // Glowing headlight cone
    final headlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF9C4).withOpacity(0.4),
          const Color(0xFFFFEB3B).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(riderCenterX - 50, riderCenterY + 25), radius: 65));
    canvas.drawCircle(Offset(riderCenterX - 50, riderCenterY + 25), 65, headlightPaint);

    // Motorcycle Front Wheel & Mudguard
    final bikeMetalPaint = Paint()..color = const Color(0xFF475569);
    canvas.drawCircle(Offset(riderCenterX - 45, riderCenterY + 45), 18, bikeMetalPaint);
    final tyrePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(riderCenterX - 45, riderCenterY + 45), 18, tyrePaint);

    // Motorcycle Body (Red Bajaj/TVS chassis)
    final bikeBodyPaint = Paint()..color = const Color(0xFFDC2626);
    final bikeBodyPath = Path()
      ..moveTo(riderCenterX - 40, riderCenterY + 25)
      ..lineTo(riderCenterX - 15, riderCenterY + 25)
      ..lineTo(riderCenterX - 5, riderCenterY + 38)
      ..lineTo(riderCenterX - 35, riderCenterY + 38)
      ..close();
    canvas.drawPath(bikeBodyPath, bikeBodyPaint);

    // Headlight lens
    final lightLensPaint = Paint()..color = const Color(0xFFFFF59D);
    canvas.drawCircle(Offset(riderCenterX - 44, riderCenterY + 25), 6, lightLensPaint);

    // Handlebars
    final barPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(riderCenterX - 32, riderCenterY + 16),
      Offset(riderCenterX - 18, riderCenterY + 12),
      barPaint,
    );
    // Mirror
    canvas.drawCircle(Offset(riderCenterX - 34, riderCenterY + 11), 3.5, barPaint);

    // Rider Jacket / High-Vis Safety Vest (Golden Amber / Green)
    final vestPaint = Paint()..color = const Color(0xFF16A34A); // Green Union Vest
    final vestPath = Path()
      ..moveTo(riderCenterX - 15, riderCenterY + 14)
      ..lineTo(riderCenterX + 10, riderCenterY + 18)
      ..lineTo(riderCenterX + 14, riderCenterY + 40)
      ..lineTo(riderCenterX - 10, riderCenterY + 36)
      ..close();
    canvas.drawPath(vestPath, vestPaint);

    // Reflective stripe on vest
    final stripePaint = Paint()
      ..color = const Color(0xFFFDE047)
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(riderCenterX - 12, riderCenterY + 26),
      Offset(riderCenterX + 12, riderCenterY + 29),
      stripePaint,
    );

    // Safety Helmet (Mandatory under SDG 11.2 safety compliance)
    final helmetPaint = Paint()..color = const Color(0xFFF59E0B); // Amber Yellow Helmet
    canvas.drawCircle(Offset(riderCenterX - 2, riderCenterY - 2), 16, helmetPaint);

    // Helmet Visor / Protective Shield (Dark tinted glass with highlight)
    final visorPaint = Paint()..color = const Color(0xFF0F172A);
    final visorPath = Path()
      ..moveTo(riderCenterX - 15, riderCenterY - 2)
      ..quadraticBezierTo(riderCenterX - 14, riderCenterY + 6, riderCenterX - 4, riderCenterY + 7)
      ..lineTo(riderCenterX - 1, riderCenterY)
      ..close();
    canvas.drawPath(visorPath, visorPaint);

    // Visor reflection streak
    final reflectionPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(riderCenterX - 13, riderCenterY + 1),
      Offset(riderCenterX - 8, riderCenterY + 5),
      reflectionPaint,
    );

    // Sierra Leone Flag Emblem (Green, White, Light Blue)
    final flagGreen = Paint()..color = const Color(0xFF1EB53A);
    final flagWhite = Paint()..color = Colors.white;
    final flagBlue = Paint()..color = const Color(0xFF0072C6);

    final flagRect = Rect.fromLTWH(w * 0.08, h * 0.45, 24, 15);
    canvas.drawRect(Rect.fromLTWH(flagRect.left, flagRect.top, 24, 5), flagGreen);
    canvas.drawRect(Rect.fromLTWH(flagRect.left, flagRect.top + 5, 24, 5), flagWhite);
    canvas.drawRect(Rect.fromLTWH(flagRect.left, flagRect.top + 10, 24, 5), flagBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
