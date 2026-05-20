import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/app_buttons.dart';
import '../../../core/widgets/inputs/app_inputs.dart';
import '../../../shared/navigation/app_routes.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});
  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  String _otp = '';
  int _resendSeconds = AppConstants.otpResendSeconds;
  Timer? _timer;
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(tween: Tween(begin: Offset.zero, end: const Offset(0.05, 0)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(0.05, 0), end: const Offset(-0.05, 0)), weight: 2),
      TweenSequenceItem(tween: Tween(begin: const Offset(-0.05, 0), end: Offset.zero), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = AppConstants.otpResendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otp.length < AppConstants.otpLength) return;
    final success = await ref.read(authProvider.notifier).verifyOtp(widget.phone, _otp);
    if (!mounted) return;
    if (success) {
      context.go(AppRoutes.roleSelect);
    } else {
      _shakeController.forward(from: 0);
    }
  }

  Future<void> _resend() async {
    if (_resendSeconds > 0) return;
    await ref.read(authProvider.notifier).requestOtp(widget.phone);
    _startTimer();
  }

  String get _formattedPhone {
    final p = widget.phone.replaceAll(AppConstants.phonePrefix, '');
    if (p.length == 8) {
      return '${AppConstants.phonePrefix} ${p.substring(0, 2)} ${p.substring(2, 4)} ${p.substring(4, 6)} ${p.substring(6)}';
    }
    return widget.phone;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final hasError = authState is AuthError;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),

              // Back
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.onSurfaceVariant, size: 24),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Icon header
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.sms_rounded,
                      size: 38, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                'Vérifie ton numéro',
                style: AppTypography.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Code envoyé au\n',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.onSurfaceVariant),
                  children: [
                    TextSpan(
                      text: _formattedPhone,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // OTP input
              SlideTransition(
                position: _shakeAnimation,
                child: OTPInputField(
                  length: AppConstants.otpLength,
                  onCompleted: (otp) {
                    setState(() => _otp = otp);
                    _verify();
                  },
                  onChanged: (otp) => setState(() => _otp = otp),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Success/Error indicator
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: hasError
                    ? _StatusBanner(
                        icon: Icons.error_outline_rounded,
                        message: (authState as AuthError).message,
                        color: AppColors.error,
                        backgroundColor: AppColors.errorContainer,
                      )
                    : _otp.length == AppConstants.otpLength
                        ? _StatusBanner(
                            icon: Icons.check_circle_rounded,
                            message: 'Code complet — vérification en cours…',
                            color: AppColors.success,
                            backgroundColor: AppColors.successContainer,
                          )
                        : _StatusBanner(
                            icon: Icons.info_outline_rounded,
                            message:
                                '${_otp.length}/${AppConstants.otpLength} chiffres saisis',
                            color: AppColors.tertiary,
                            backgroundColor: AppColors.secondaryContainer,
                          ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Verify button
              PrimaryButton(
                label: 'Valider le code',
                onPressed: _otp.length == AppConstants.otpLength ? _verify : null,
                isLoading: isLoading,
                enabled: _otp.length == AppConstants.otpLength,
              ),
              const SizedBox(height: AppSpacing.md),

              // Resend
              Center(
                child: GestureDetector(
                  onTap: _resendSeconds == 0 ? _resend : null,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: AppTypography.bodySmall.copyWith(
                      color: _resendSeconds == 0
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    child: _resendSeconds > 0
                        ? Text('Renvoyer dans 0:${_resendSeconds.toString().padLeft(2, '0')}')
                        : const Text('Renvoyer le code'),
                  ),
                ),
              ),

              const Spacer(),

              // Security note
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded,
                        size: 16, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Ce code est à usage unique et expire dans ${AppConstants.otpExpiryMinutes} minutes.',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.message,
    required this.color,
    required this.backgroundColor,
  });
  final IconData icon;
  final String message;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(backgroundColor),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.radiusMd,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message,
                style: AppTypography.bodySmall.copyWith(
                    color: color, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
