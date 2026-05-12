import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();
  bool _isLogin    = true; // toggle login / register

  @override
  void dispose() { _phoneCtrl.dispose(); super.dispose(); }

  String get _formattedPhone {
    var v = _phoneCtrl.text.trim().replaceAll(' ', '');
    if (!v.startsWith('+')) v = '${AppConstants.maliPrefix}$v';
    return v;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = _formattedPhone;
    final notif = ref.read(authProvider.notifier);

    if (_isLogin) {
      final ok = await notif.requestLoginOtp(phone);
      if (ok && mounted) {
        context.push('${AppRoutes.otpVerify}?phone=${Uri.encodeComponent(phone)}&purpose=login');
      }
    } else {
      context.push(AppRoutes.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Logo
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: AppRadius.lg,
                  ),
                  child: const Center(
                    child: Text('BL', style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 22,
                      fontWeight: FontWeight.w800, color: AppColors.primary,
                    )),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

                const SizedBox(height: 32),

                Text(
                  _isLogin ? 'Bon retour 👋' : 'Rejoindre BaaraLink',
                  style: Theme.of(context).textTheme.displaySmall,
                ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms).fade(),

                const SizedBox(height: 8),

                Text(
                  _isLogin
                      ? 'Entrez votre numéro pour recevoir un code de vérification.'
                      : 'Créez votre compte en quelques secondes.',
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 14,
                    color: AppColors.textSecondary, height: 1.5,
                  ),
                ).animate(delay: 100.ms).slideY(begin: 0.2, end: 0, duration: 400.ms).fade(),

                const SizedBox(height: 40),

                // Phone field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Numéro de téléphone', style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 13,
                      fontWeight: FontWeight.w500, color: AppColors.textPrimary,
                    )),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d+ ]'))],
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: '70 00 00 00',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.sm,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🇲🇱', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 4),
                              Text('+223', style: TextStyle(
                                fontFamily: 'Poppins', fontSize: 13,
                                fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                              )),
                            ],
                          ),
                        ),
                      ),
                      validator: (v) {
                        final val = v?.trim().replaceAll(' ', '') ?? '';
                        if (val.isEmpty) return 'Entrez votre numéro';
                        if (val.length < 8) return 'Numéro trop court';
                        return null;
                      },
                    ),
                  ],
                ).animate(delay: 200.ms).slideY(begin: 0.2, end: 0, duration: 400.ms).fade(),

                const SizedBox(height: 32),

                // Error
                if (state.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.errorSurface,
                      borderRadius: AppRadius.md,
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(state.error!, style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 13, color: AppColors.error,
                      ))),
                    ]),
                  ).animate().shake(),

                // Submit button
                AppButton(
                  label: _isLogin ? 'Recevoir le code' : 'Créer un compte',
                  isLoading: state.isLoading,
                  onPressed: _submit,
                ).animate(delay: 300.ms).slideY(begin: 0.2, end: 0, duration: 400.ms).fade(),

                const SizedBox(height: 24),

                // Toggle
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_isLogin) {
                        context.push(AppRoutes.register);
                      } else {
                        setState(() => _isLogin = true);
                      }
                    },
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                        children: [
                          TextSpan(
                            text: _isLogin ? 'Pas encore de compte ? ' : 'Déjà un compte ? ',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          TextSpan(
                            text: _isLogin ? 'S\'inscrire' : 'Se connecter',
                            style: const TextStyle(
                              color: AppColors.primary, fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Social proof
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16, runSpacing: 8,
                    children: const [
                      _TrustBadge('✅ Profils vérifiés'),
                      _TrustBadge('💳 Orange Money'),
                      _TrustBadge('⭐ Notes réelles'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final String label;
  const _TrustBadge(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: AppRadius.full,
      border: Border.all(color: AppColors.border),
    ),
    child: Text(label, style: const TextStyle(
      fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary,
    )),
  );
}
