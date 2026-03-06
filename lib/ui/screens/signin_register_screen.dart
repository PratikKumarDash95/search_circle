import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../services/auth_service.dart';

/// Screen 5 — Sign In / Register
///
/// Phone number authentication screen with country code picker,
/// Send OTP button, social sign-in options (Google / Apple),
/// and "Create Account" link at bottom.
class SignInRegisterScreen extends StatefulWidget {
  const SignInRegisterScreen({super.key});

  @override
  State<SignInRegisterScreen> createState() => _SignInRegisterScreenState();
}

class _SignInRegisterScreenState extends State<SignInRegisterScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  String _selectedCountryCode = '+1';
  bool _isLoading = false;

  late final AnimationController _fadeController;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _iconScale;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _formOpacity;
  late final Animation<double> _socialOpacity;
  late final Animation<double> _bottomOpacity;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.15, 0.4, curve: Curves.easeOut),
      ),
    );

    _formOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    _socialOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    _bottomOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFF),
              Color(0xFFFCFCFF),
              Color(0xFFF8FAFF),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeController,
            builder: (context, _) {
              return Column(
                children: [
                  // ── Top bar ───────────────────────────────────────────
                  _buildTopBar(),

                  // ── Scrollable content ────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.xl),

                          // ── Search icon ───────────────────────────────
                          _buildSearchIcon(),

                          const SizedBox(height: AppSpacing.xl),

                          // ── Title + Subtitle ──────────────────────────
                          _buildTitleSection(),

                          const SizedBox(height: AppSpacing.xxl),

                          // ── Phone input ───────────────────────────────
                          _buildPhoneInput(),

                          const SizedBox(height: AppSpacing.base),

                          // ── Send OTP Button ───────────────────────────
                          _buildSendOtpButton(),

                          const SizedBox(height: AppSpacing.xxl),

                          // ── Or sign in with ───────────────────────────
                          _buildDivider(),

                          const SizedBox(height: AppSpacing.xl),

                          // ── Social buttons ────────────────────────────
                          _buildSocialButtons(),
                        ],
                      ),
                    ),
                  ),

                  // ── Bottom section ────────────────────────────────────
                  _buildBottomSection(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // WIDGETS
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchIcon() {
    return Opacity(
      opacity: _iconOpacity.value,
      child: Transform.scale(
        scale: _iconScale.value,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
            size: 44,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Opacity(
      opacity: _titleOpacity.value,
      child: Column(
        children: [
          Text(
            'Welcome Back',
            style: AppTextStyles.displayLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enter your phone number to sign in to\nSearchCircle.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Opacity(
      opacity: _formOpacity.value,
      child: Row(
        children: [
          // ── Country code picker ──────────────────────────────────────
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: _showCountryCodePicker,
              child: Container(
                height: AppSpacing.buttonHeightLg,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.language_rounded,
                      size: 20,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _selectedCountryCode,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // ── Phone number field ──────────────────────────────────────
          Expanded(
            flex: 7,
            child: Container(
              height: AppSpacing.buttonHeightLg,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '555-0123',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: Icon(
                    Icons.smartphone_rounded,
                    size: 20,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendOtpButton() {
    return Opacity(
      opacity: _formOpacity.value,
      child: Container(
        width: double.infinity,
        height: AppSpacing.buttonHeightLg + 4,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.primary,
              Color(0xFF4B8AFF),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: InkWell(
            onTap: _isLoading ? null : _sendOtp,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Send OTP',
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Opacity(
      opacity: _socialOpacity.value,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.divider,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Text(
              'Or sign in with',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.divider,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Opacity(
      opacity: _socialOpacity.value,
      child: Row(
        children: [
          // ── Google button ──────────────────────────────────────────────
          Expanded(
            child: _SocialLoginButton(
              label: 'Google',
              icon: _buildGoogleIcon(),
              onTap: _signInWithGoogle,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // ── Apple button ──────────────────────────────────────────────
          Expanded(
            child: _SocialLoginButton(
              label: 'Apple',
              icon: Icon(
                Icons.apple_rounded,
                size: 22,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
              ),
              onTap: _signInWithApple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [
                  Color(0xFF4285F4),
                  Color(0xFFDB4437),
                  Color(0xFFF4B400),
                  Color(0xFF0F9D58),
                ],
              ).createShader(const Rect.fromLTWH(0, 0, 22, 22)),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Opacity(
      opacity: _bottomOpacity.value,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.base,
        ),
        child: Column(
          children: [
            // ── New user? Create Account ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'New user? ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: _createAccount,
                  child: Text(
                    'Create Account',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Terms + Privacy ──────────────────────────────────────────
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
                children: [
                  const TextSpan(text: 'By signing in, you agree to our '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' and\n'),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // ACTIONS — wired to real backend
  // ═════════════════════════════════════════════════════════════════════════

  void _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.sendOtp(
      phone: phone,
      countryCode: _selectedCountryCode,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        Navigator.of(context).pushNamed('/otp', arguments: {
          'phone': phone,
          'country_code': _selectedCountryCode,
          'full_phone': result['phone'] ?? '$_selectedCountryCode$phone',
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to send OTP')),
        );
      }
    }
  }

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (context) => _CountryCodeSheet(
        onSelect: (code) {
          setState(() => _selectedCountryCode = code);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _signInWithGoogle() {
    // Social sign-in — future implementation
  }

  void _signInWithApple() {
    // Social sign-in — future implementation
  }

  void _createAccount() {
    _sendOtp(); // Same flow — server auto-creates account on first OTP verify
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUPPORTING WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

/// Social login button (Google / Apple)
class _SocialLoginButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onTap;

  const _SocialLoginButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.buttonHeightLg,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Country code picker bottom sheet.
class _CountryCodeSheet extends StatelessWidget {
  final ValueChanged<String> onSelect;

  const _CountryCodeSheet({required this.onSelect});

  static const _codes = [
    ('+1', 'United States', '🇺🇸'),
    ('+44', 'United Kingdom', '🇬🇧'),
    ('+91', 'India', '🇮🇳'),
    ('+61', 'Australia', '🇦🇺'),
    ('+81', 'Japan', '🇯🇵'),
    ('+49', 'Germany', '🇩🇪'),
    ('+33', 'France', '🇫🇷'),
    ('+55', 'Brazil', '🇧🇷'),
    ('+86', 'China', '🇨🇳'),
    ('+82', 'South Korea', '🇰🇷'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: AppSpacing.base),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ────────────────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Select Country',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _codes.length,
              itemBuilder: (context, index) {
                final code = _codes[index];
                return ListTile(
                  leading: Text(
                    code.$3,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    code.$2,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: Text(
                    code.$1,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => onSelect(code.$1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
