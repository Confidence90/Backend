import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey   = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _role     = 'client';

  @override
  void dispose() {
    _firstCtrl.dispose(); _lastCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    var phone = _phoneCtrl.text.trim().replaceAll(' ', '');
    if (!phone.startsWith('+')) phone = '${AppConstants.maliPrefix}$phone';

    final ok = await ref.read(authProvider.notifier).requestRegisterOtp(
      phone: phone,
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      role: _role,
    );
    if (ok && mounted) {
      context.push(
        '${AppRoutes.otpVerify}?phone=${Uri.encodeComponent(phone)}&purpose=register'
        '&first_name=${Uri.encodeComponent(_firstCtrl.text.trim())}'
        '&last_name=${Uri.encodeComponent(_lastCtrl.text.trim())}'
        '&role=$_role',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Créer un compte', style: Theme.of(context).textTheme.displaySmall)
                  .animate().slideY(begin: 0.2).fade(),
                const SizedBox(height: 8),
                const Text('Rejoignez des milliers de Maliens sur BaaraLink.',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ).animate(delay: 80.ms).slideY(begin: 0.2).fade(),

                const SizedBox(height: 32),

                // Role selector
                const Text('Je suis...', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _RoleCard(
                      icon: '🤝', label: 'Un client', sublabel: 'Je cherche des prestataires',
                      isSelected: _role == 'client',
                      onTap: () => setState(() => _role = 'client'),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _RoleCard(
                      icon: '🔧', label: 'Un prestataire', sublabel: 'Je propose mes services',
                      isSelected: _role == 'provider',
                      onTap: () => setState(() => _role = 'provider'),
                    )),
                  ],
                ).animate(delay: 100.ms).slideY(begin: 0.2).fade(),

                const SizedBox(height: 24),

                // Name row
                Row(
                  children: [
                    Expanded(child: _Field(controller: _firstCtrl, label: 'Prénom', hint: 'Moussa',
                      validator: (v) => v!.trim().isEmpty ? 'Requis' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: _Field(controller: _lastCtrl, label: 'Nom', hint: 'Traoré',
                      validator: (v) => v!.trim().isEmpty ? 'Requis' : null)),
                  ],
                ).animate(delay: 150.ms).slideY(begin: 0.2).fade(),

                const SizedBox(height: 16),

                // Phone
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Téléphone', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d+ ]'))],
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: '70 00 00 00',
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.sm, border: Border.all(color: AppColors.border)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('🇲🇱', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 4),
                          Text('+223', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                    validator: (v) {
                      final val = v?.trim().replaceAll(' ', '') ?? '';
                      if (val.isEmpty) return 'Entrez votre numéro';
                      if (val.length < 8) return 'Numéro trop court';
                      return null;
                    },
                  ),
                ]).animate(delay: 200.ms).slideY(begin: 0.2).fade(),

                const SizedBox(height: 32),

                if (state.error != null)
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: AppColors.errorSurface, borderRadius: AppRadius.md),
                    child: Text(state.error!, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.error)),
                  ).animate().shake(),

                AppButton(label: 'Créer mon compte', isLoading: state.isLoading, onPressed: _submit)
                  .animate(delay: 250.ms).slideY(begin: 0.2).fade(),

                const SizedBox(height: 16),
                const Center(child: Text('En créant un compte, vous acceptez nos Conditions d\'utilisation.',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textTertiary), textAlign: TextAlign.center)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String icon, label, sublabel;
  final bool isSelected;
  final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.label, required this.sublabel, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primarySurface : AppColors.surfaceVariant,
        borderRadius: AppRadius.lg,
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.primary : AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(sublabel, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary)),
      ]),
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final String? Function(String?)? validator;
  const _Field({required this.controller, required this.label, required this.hint, this.validator});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 15),
      decoration: InputDecoration(hintText: hint),
      validator: validator,
    ),
  ]);
}
