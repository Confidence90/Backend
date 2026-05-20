import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../providers/auth_provider.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String phone;
  final String purpose;
  final String? firstName;
  final String? lastName;
  final String? role;

  const OtpPage({
    super.key,
    required this.phone,
    required this.purpose,
    this.firstName,
    this.lastName,
    this.role,
  });

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final _pinCtrl = TextEditingController();
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown == 0) {
        t.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  Future<void> _resend() async {
    final notif = ref.read(authProvider.notifier);
    if (widget.purpose == 'login') {
      await notif.requestLoginOtp(widget.phone);
    } else {
      await notif.requestRegisterOtp(
        phone: widget.phone,
        firstName: widget.firstName ?? '',
        lastName: widget.lastName ?? '',
        role: widget.role ?? 'client',
      );
    }
    setState(() => _resendCountdown = 60);
    _startTimer();
  }

  Future<void> _verify(String code) async {
    if (code.length < 6) return;
    final notif = ref.read(authProvider.notifier);
    bool ok;
    if (widget.purpose == 'register') {
      ok = await notif.verifyRegister(widget.phone, code);
    } else {
      ok = await notif.verifyLogin(widget.phone, code);
    }
    if (ok && mounted) context.go(AppRoutes.home);
  }

  @override
  void dispose() { _pinCtrl.dispose(); _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final defaultTheme = PinTheme(
      width: 56, height: 60,
      textStyle: const TextStyle(
        fontFamily: 'Poppins', fontSize: 24,
        fontWeight: FontWeight.w700, color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.lg,
        border: Border.all(color: Colors.transparent, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppRadius.lg,
                ),
                child: const Center(child: Text('📱', style: TextStyle(fontSize: 32))),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

              const SizedBox(height: 24),

              Text('Vérification', style: Theme.of(context).textTheme.displaySmall)
                .animate(delay: 100.ms).slideY(begin: 0.2).fade(),

              const SizedBox(height: 8),

              RichText(
                text: TextSpan(
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, height: 1.5),
                  children: [
                    const TextSpan(text: 'Code envoyé au\n', style: TextStyle(color: AppColors.textSecondary)),
                    TextSpan(
                      text: widget.phone,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ).animate(delay: 150.ms).slideY(begin: 0.2).fade(),

              const SizedBox(height: 48),

              // PIN input
              Center(
                child: Pinput(
                  controller: _pinCtrl,
                  length: 6,
                  autofocus: true,
                  defaultPinTheme: defaultTheme,
                  focusedPinTheme: defaultTheme.copyWith(
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: AppRadius.lg,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                  ),
                  submittedPinTheme: defaultTheme.copyWith(
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: AppRadius.lg,
                      border: Border.all(color: AppColors.success, width: 2),
                    ),
                  ),
                  errorPinTheme: defaultTheme.copyWith(
                    decoration: BoxDecoration(
                      color: AppColors.errorSurface,
                      borderRadius: AppRadius.lg,
                      border: Border.all(color: AppColors.error, width: 2),
                    ),
                  ),
                  onCompleted: _verify,
                ),
              ).animate(delay: 200.ms).slideY(begin: 0.3).fade(),

              const SizedBox(height: 32),

              // Error
              if (state.error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorSurface,
                    borderRadius: AppRadius.md,
                  ),
                  child: Text(
                    state.error!,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ).animate().shake().fade(),

              if (state.isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.primary)),

              const Spacer(),

              // Resend
              Center(
                child: _resendCountdown > 0
                    ? Text(
                        'Renvoi disponible dans ${_resendCountdown}s',
                        style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: const Text('Renvoyer le code', style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 14,
                          fontWeight: FontWeight.w600, color: AppColors.primary,
                        )),
                      ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
