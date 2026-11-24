import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/bike_rider_visual.dart';

/// Screen 2: Onboarding / How It Works Screen
/// 3-step visual overview of digital rider registration, safety compliance,
/// and transparent levy payments across Freetown stations.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'step': '01',
      'title': 'Digital Rider & Motorcycle Registry',
      'subtitle': 'Zero Duplicate Identities & Full Verification',
      'description':
          'Replace handwritten station registers with a centralized, searchable registry linking riders (R001), driving licences, and bike plates (BKE-101) across Lumley, Kissy, Wellington, and all Freetown terminals.',
      'icon': Icons.badge_rounded,
      'color': AppTheme.primaryGreen,
      'sdg': 'SDG 11: Sustainable Urban Transport Systems',
    },
    {
      'step': '02',
      'title': 'Safety & Roadworthiness Compliance',
      'subtitle': 'No Blind Passing • Real Inspections',
      'description':
          'Motorcycles undergo verified safety checks covering brakes, lighting, tyre tread depth, and dual certified helmets for rider and passenger. Track inspection status (PASSED, PENDING, FLAGGED) in real time.',
      'icon': Icons.security_rounded,
      'color': AppTheme.goldenAmber,
      'sdg': 'SDG 11.2: Safe, Affordable & Accessible Road Safety',
    },
    {
      'step': '03',
      'title': 'Direct Payments & Immutable Ledger',
      'subtitle': 'Zero Cash Leakage • Time-Stamped Digital Receipts',
      'description':
          'Pay Daily Levies (Le 25,000), Safety Fines (Le 15,000), or Annual Permits (Le 100,000) directly. Every transaction generates an immutable PostgreSQL log, an instant receipt, and live executive auditability.',
      'icon': Icons.receipt_long_rounded,
      'color': AppTheme.accentBlue,
      'sdg': 'SDG 8: Decent Work & Formalized Economic Growth',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            child: const Text(
              'Skip to Home',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Hero Vector Artwork
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: BikeRiderVisual(height: 180, compact: true),
            ),

            const SizedBox(height: 16),

            // Page View with the 3 steps
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (idx) {
                  setState(() {
                    _currentPage = idx;
                  });
                },
                itemBuilder: (context, idx) {
                  final step = _steps[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step number & icon badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (step['color'] as Color).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: (step['color'] as Color).withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                'STEP ${step['step']}',
                                style: TextStyle(
                                  color: step['color'] as Color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (step['color'] as Color).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                step['icon'] as IconData,
                                color: step['color'] as Color,
                                size: 24,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Title
                        Text(
                          step['title'] as String,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          step['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: step['color'] as Color,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Description
                        Text(
                          step['description'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          ),
                        ),

                        const Spacer(),

                        // SDG Alignment footer pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.workspace_premium_rounded,
                                size: 16,
                                color: AppTheme.goldenAmber,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  step['sdg'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Indicator Dots & Navigation Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      _steps.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primaryGreen
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next / Get Started Action Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _steps.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      _currentPage == _steps.length - 1 ? 'Get Started' : 'Next →',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
