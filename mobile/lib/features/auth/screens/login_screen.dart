import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/app_buttons.dart';
import '../../../core/widgets/inputs/app_inputs.dart';
import '../../../core/widgets/layout/app_shared_widgets.dart';
import '../../../shared/navigation/app_routes.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _usePhone = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < AppConstants.phoneMinLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro de téléphone invalide')),
      );
      return;
    }
    
    final success = await ref.read(authProvider.notifier).requestOtp(
          '${AppConstants.phonePrefix}$phone',
        );
        
    if (success && mounted) {
      context.push(
        '${AppRoutes.otp}?phone=${AppConstants.phonePrefix}$phone',
      );
    }
  }

  Future<void> _loginWithEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await ref.read(authProvider.notifier).loginWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      // Le router redirigera automatiquement grâce au redirect guard
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final error = authState is AuthError ? authState.message : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // Back
                GestureDetector(
                  onTap: () => context.canPop() ? context.pop() : context.go(AppRoutes.onboarding),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back_rounded,
                          color: AppColors.onSurfaceVariant, size: 20),
                      const SizedBox(width: 4),
                      Text('Retour',
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Header
                Text('Connexion', style: AppTypography.h1),
                const SizedBox(height: 6),
                Text(
                  'Accède à toutes les opportunités BaaraLink',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Tab switcher
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: AppRadius.radiusMd,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    children: [
                      _LoginTab(
                        label: 'Téléphone / OTP',
                        icon: Icons.phone_android_rounded,
                        selected: _usePhone,
                        onTap: () {
                          ref.read(authProvider.notifier).clearError();
                          setState(() => _usePhone = true);
                        },
                      ),
                      _LoginTab(
                        label: 'Email',
                        icon: Icons.email_outlined,
                        selected: !_usePhone,
                        onTap: () {
                          ref.read(authProvider.notifier).clearError();
                          setState(() => _usePhone = false);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Error banner
                if (error != null) ...[
                  _ErrorBanner(message: error),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Phone flow
                if (_usePhone) ...[
                  Text('Numéro de téléphone',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(
                              color: AppColors.outlineVariant, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Text('🇲🇱', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 6),
                            Text(
                              AppConstants.phonePrefix,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (_) => ref.read(authProvider.notifier).clearError(),
                          style: AppTypography.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'XX XX XX XX',
                            hintStyle: AppTypography.bodyMedium.copyWith(
                              color:
                                  AppColors.onSurfaceVariant.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.compact),
                  Container(
                    padding: AppSpacing.cardPadding,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 16, color: AppColors.tertiary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Un code SMS te sera envoyé. Valable 10 minutes.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: 'Recevoir le code SMS',
                    onPressed: _requestOtp,
                    isLoading: isLoading,
                    icon: const Icon(Icons.sms_rounded,
                        color: Colors.white, size: 18),
                  ),
                ]
                else ...[
                  AppTextField(
                    label: 'Email',
                    hint: 'ton@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    onChanged: (_) => ref.read(authProvider.notifier).clearError(),
                    validator: (v) =>
                        v?.contains('@') == true ? null : 'Email invalide',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Mot de passe',
                    hint: '••••••••',
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onChanged: (_) => ref.read(authProvider.notifier).clearError(),
                    validator: (v) => (v?.length ?? 0) >=
                            AppConstants.minPasswordLength
                        ? null
                        : 'Minimum ${AppConstants.minPasswordLength} caractères',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text('Mot de passe oublié ?',
                          style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Se connecter',
                    onPressed: _loginWithEmail,
                    isLoading: isLoading,
                    icon: const Icon(Icons.login_rounded,
                        color: Colors.white, size: 18),
                  ),
                ],

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        child: Text('ou',
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.onSurfaceVariant)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                ),

                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Pas encore de compte ? ',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.onSurfaceVariant),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => context.push(AppRoutes.roleSelect),
                            child: Text('Créer un compte',
                                style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginTab extends StatelessWidget {
  const _LoginTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: AppRadius.radiusSm,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      selected ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: AppRadius.radiusMd,
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}
