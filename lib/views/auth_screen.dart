import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../widgets/bike_rider_visual.dart';

/// Screen 3: Login Modal / Authentication Screen
/// Features Bike Rider Visual, "Continue with Google", "Sign In with Credentials" (supporting Username,
/// Rider ID e.g. R001, or Bike Plate e.g. BKE-101), quick test role selector, and register/reset tabs.
class AuthScreen extends StatefulWidget {
  final bool isModal;
  const AuthScreen({super.key, this.isModal = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _queryController = TextEditingController(text: 'R001');
  final TextEditingController _passwordController = TextEditingController(text: 'password123');

  // Register form controllers
  final TextEditingController _regRiderCodeController = TextEditingController();
  final TextEditingController _regFullNameController = TextEditingController();
  final TextEditingController _regPhoneController = TextEditingController();
  final TextEditingController _regLicenseController = TextEditingController();
  final TextEditingController _regPlateController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();

  // Reset password controller
  final TextEditingController _resetQueryController = TextEditingController();

  bool _obscurePassword = true;
  String? _feedbackMessage;
  bool _isSuccessFeedback = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _queryController.dispose();
    _passwordController.dispose();
    _regRiderCodeController.dispose();
    _regFullNameController.dispose();
    _regPhoneController.dispose();
    _regLicenseController.dispose();
    _regPlateController.dispose();
    _regPasswordController.dispose();
    _resetQueryController.dispose();
    super.dispose();
  }

  void _handleSignIn(AuthController auth) async {
    setState(() {
      _feedbackMessage = null;
    });

    final success = await auth.signInWithCredentials(
      query: _queryController.text,
      password: _passwordController.text,
    );

    if (success) {
      if (mounted) {
        if (widget.isModal) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } else {
      setState(() {
        _feedbackMessage = auth.errorMessage ?? 'Invalid credentials. Please try again.';
        _isSuccessFeedback = false;
      });
    }
  }

  void _handleGoogleSignIn(AuthController auth) async {
    setState(() {
      _feedbackMessage = null;
    });

    final success = await auth.signInWithGoogle();
    if (success) {
      if (mounted) {
        if (widget.isModal) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    }
  }

  void _handleDemoQuickLogin(AuthController auth, String role, String query) {
    _queryController.text = query;
    _passwordController.text = 'password123';
    auth.switchRole(role);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${role.toUpperCase()} profile ($query)'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
    if (widget.isModal) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthController>();

    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Prominent Rich Bike Rider Visual Artwork
          const BikeRiderVisual(height: 185),

          const SizedBox(height: 16),

          // Tab Navigation Header (Sign In, Register Rider, Reset Password)
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'Sign In'),
                Tab(text: 'Register'),
                Tab(text: 'Reset'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (_feedbackMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isSuccessFeedback
                    ? AppTheme.primaryGreen.withOpacity(0.12)
                    : AppTheme.statusFlagged.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isSuccessFeedback ? AppTheme.primaryGreen : AppTheme.statusFlagged,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSuccessFeedback ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                    color: _isSuccessFeedback ? AppTheme.primaryGreen : AppTheme.statusFlagged,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _feedbackMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: _isSuccessFeedback ? AppTheme.primaryGreen : AppTheme.statusFlagged,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Tab View Content
          SizedBox(
            height: 390,
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: SIGN IN FORM
                _buildSignInTab(auth, isDark),

                // TAB 2: REGISTER QUICK FORM
                _buildRegisterTab(auth, isDark),

                // TAB 3: RESET PASSWORD TAB
                _buildResetTab(isDark),
              ],
            ),
          ),

          const Divider(height: 28),

          // Demo Quick Roles for easy evaluation
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.touch_app_rounded, size: 16, color: AppTheme.goldenAmber),
                  const SizedBox(width: 6),
                  Text(
                    'Instant Demo Sign-In (Tap to switch role):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildRoleChip(
                      label: 'Rider (R001)',
                      role: 'rider',
                      query: 'R001',
                      icon: Icons.two_wheeler_rounded,
                      color: AppTheme.primaryGreen,
                      onTap: () => _handleDemoQuickLogin(auth, 'rider', 'R001'),
                    ),
                    const SizedBox(width: 8),
                    _buildRoleChip(
                      label: 'Plate (BKE-101)',
                      role: 'rider',
                      query: 'BKE-101',
                      icon: Icons.confirmation_number_rounded,
                      color: AppTheme.primaryGreen,
                      onTap: () => _handleDemoQuickLogin(auth, 'rider', 'BKE-101'),
                    ),
                    const SizedBox(width: 8),
                    _buildRoleChip(
                      label: 'Inspector Alpha',
                      role: 'inspector',
                      query: 'inspector_alpha',
                      icon: Icons.security_rounded,
                      color: AppTheme.statusPending,
                      onTap: () => _handleDemoQuickLogin(auth, 'inspector', 'inspector_alpha'),
                    ),
                    const SizedBox(width: 8),
                    _buildRoleChip(
                      label: 'Admin Osman',
                      role: 'admin',
                      query: 'admin_usman',
                      icon: Icons.admin_panel_settings_rounded,
                      color: AppTheme.accentBlue,
                      onTap: () => _handleDemoQuickLogin(auth, 'admin', 'admin_usman'),
                    ),
                    const SizedBox(width: 8),
                    _buildRoleChip(
                      label: 'Executive Mansaray',
                      role: 'executive',
                      query: 'exec_mohamed',
                      icon: Icons.account_balance_rounded,
                      color: const Color(0xFF9C27B0),
                      onTap: () => _handleDemoQuickLogin(auth, 'executive', 'exec_mohamed'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );

    if (widget.isModal) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              height: 4,
              width: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(child: content),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('TransitFlow SL Authentication'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(child: content),
    );
  }

  Widget _buildSignInTab(AuthController auth, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Continue with Google Button
        OutlinedButton.icon(
          onPressed: auth.isLoading ? null : () => _handleGoogleSignIn(auth),
          icon: Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
            height: 18,
            width: 18,
            errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata_rounded, size: 24, color: Colors.red),
          ),
          label: const Text(
            'Continue with Google',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 13),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(child: Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'OR SIGN IN WITH CREDENTIALS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              ),
            ),
            Expanded(child: Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
          ],
        ),

        const SizedBox(height: 14),

        // Username / Rider ID / Bike Plate Field
        TextField(
          controller: _queryController,
          decoration: const InputDecoration(
            labelText: 'Username, Rider ID, or Plate',
            hintText: 'e.g. R001, BKE-101, or admin_usman',
            prefixIcon: Icon(Icons.person_pin_rounded),
          ),
        ),

        const SizedBox(height: 12),

        // Password Field
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Sign In Button
        ElevatedButton(
          onPressed: auth.isLoading ? null : () => _handleSignIn(auth),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: auth.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  'Sign In to TransitFlow SL',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
        ),
      ],
    );
  }

  Widget _buildRegisterTab(AuthController auth, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: _regRiderCodeController,
            decoration: const InputDecoration(
              labelText: 'Proposed Rider ID (e.g. R007)',
              prefixIcon: Icon(Icons.badge_rounded),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _regFullNameController,
            decoration: const InputDecoration(
              labelText: 'Rider Full Name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _regPlateController,
            decoration: const InputDecoration(
              labelText: 'Motorcycle Plate (e.g. BKE-707)',
              prefixIcon: Icon(Icons.two_wheeler_rounded),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              // Directs to the full registration screen
              Navigator.pushNamed(context, '/register-rider');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Open Full Rider Registration Form →'),
          ),
        ],
      ),
    );
  }

  Widget _buildResetTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Enter your registered Rider ID, Phone Number, or Username to receive credentials verification assistance from your station coordinator.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _resetQueryController,
          decoration: const InputDecoration(
            labelText: 'Rider ID or Phone Number',
            hintText: 'e.g. R001 or +232 76 123456',
            prefixIcon: Icon(Icons.phonelink_lock_rounded),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _feedbackMessage =
                  'Password reset token generated and dispatched to station coordinator.';
              _isSuccessFeedback = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.goldenAmber,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            'Request Union Credential Reset',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleChip({
    required String label,
    required String role,
    required String query,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 14, color: color),
      label: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
      backgroundColor: color.withOpacity(0.12),
      side: BorderSide(color: color.withOpacity(0.3)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: onTap,
    );
  }
}
