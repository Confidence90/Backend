import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/widgets/buttons/app_buttons.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  int _step = 0; // 0=intro, 1=phone, 2=id_card, 3=selfie, 4=complete
  bool _isProcessing = false;

  final _steps = [
    _VerifStep(
      icon: Icons.verified_user_rounded,
      color: AppColors.tertiary,
      title: 'Vérification en 3 étapes',
      subtitle: 'Obtenez le badge Vérifié BaaraLink en moins de 5 minutes. Cela augmente votre Trust Score et vos missions.',
      actionLabel: 'Commencer',
    ),
    _VerifStep(
      icon: Icons.phone_android_rounded,
      color: AppColors.success,
      title: 'Numéro vérifié ✓',
      subtitle: 'Votre numéro de téléphone a déjà été vérifié par SMS lors de votre inscription.',
      actionLabel: 'Continuer',
    ),
    _VerifStep(
      icon: Icons.badge_rounded,
      color: AppColors.primary,
      title: 'Pièce d\'identité',
      subtitle: 'Prenez en photo votre CNI ou passeport malien (recto et verso).',
      actionLabel: 'Prendre une photo',
    ),
    _VerifStep(
      icon: Icons.face_rounded,
      color: AppColors.warning,
      title: 'Selfie de confirmation',
      subtitle: 'Prenez un selfie pour confirmer que vous êtes bien le titulaire de la pièce d\'identité.',
      actionLabel: 'Prendre un selfie',
    ),
    _VerifStep(
      icon: Icons.check_circle_rounded,
      color: AppColors.success,
      title: 'Vérification en cours !',
      subtitle: 'Votre dossier est en cours d\'examen par notre équipe. Vous recevrez une notification sous 24h.',
      actionLabel: 'Retourner au profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentStep = _steps[_step];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => _step > 0 && _step < 4
              ? setState(() => _step--)
              : context.pop(),
          color: AppColors.onSurface,
        ),
        title: Text('Vérification d\'identité', style: AppTypography.h3),
        bottom: _step > 0 && _step < 4
            ? PreferredSize(
                preferredSize: const Size.fromHeight(5),
                child: ClipRRect(
                  child: LinearProgressIndicator(
                    value: _step / 3,
                    backgroundColor: AppColors.outlineVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 3,
                  ),
                ),
              )
            : null,
      ),
      body: AnimatedSwitcher(
        duration: AppAnimations.standard,
        child: _step == 4
            ? _SuccessView(onDone: () => context.pop())
            : _buildStepContent(context, currentStep),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, _VerifStep step) {
    return SingleChildScrollView(
      key: ValueKey(_step),
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: step.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(step.icon, size: 48, color: step.color),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(step.title, style: AppTypography.h2, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(step.subtitle,
              style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant, height: 1.6),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),

          // Upload area for steps 2 and 3
          if (_step == 2) ...[
            _UploadCard(
              icon: Icons.credit_card_rounded,
              label: 'Recto de la pièce d\'identité',
              isUploaded: false,
            ),
            const SizedBox(height: AppSpacing.compact),
            _UploadCard(
              icon: Icons.credit_card_rounded,
              label: 'Verso de la pièce d\'identité',
              isUploaded: false,
            ),
            const SizedBox(height: AppSpacing.lg),
          ] else if (_step == 3) ...[
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_rounded, size: 48, color: AppColors.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text('Appuyez pour activer la caméra',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Tips card
          if (_step > 0 && _step < 4)
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: AppRadius.radiusMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('Conseils', style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ]),
                  const SizedBox(height: 8),
                  ..._getTips(_step).map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('• ', style: TextStyle(color: AppColors.primary)),
                      Expanded(child: Text(tip, style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant))),
                    ]),
                  )),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: step.actionLabel,
            onPressed: _advance,
            isLoading: _isProcessing,
            icon: Icon(
              _step == 0 ? Icons.arrow_forward_rounded : Icons.check_rounded,
              color: Colors.white, size: 18,
            ),
          ),
          const SizedBox(height: AppSpacing.generous),
        ],
      ),
    );
  }

  List<String> _getTips(int step) {
    return switch (step) {
      2 => [
        'Document officiel malien en cours de validité',
        'Photo nette, sans reflet ni ombre',
        'Tous les coins du document visibles',
      ],
      3 => [
        'Visage bien éclairé, de face',
        'Pas de lunettes de soleil ni chapeau',
        'Arrière-plan neutre de préférence',
      ],
      _ => ['Document sécurisé par chiffrement AES-256', 'Données jamais partagées avec des tiers'],
    };
  }

  Future<void> _advance() async {
    if (_step == 2 || _step == 3) {
      setState(() => _isProcessing = true);
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _isProcessing = false);
    }
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      context.pop();
    }
  }
}

class _VerifStep {
  const _VerifStep({required this.icon, required this.color, required this.title,
      required this.subtitle, required this.actionLabel});
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String actionLabel;
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({required this.icon, required this.label, required this.isUploaded});
  final IconData icon;
  final String label;
  final bool isUploaded;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.successContainer : AppColors.surfaceContainerHighest,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(
            color: isUploaded ? AppColors.success : AppColors.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(children: [
          Icon(isUploaded ? Icons.check_circle_rounded : icon,
              size: 28,
              color: isUploaded ? AppColors.success : AppColors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.compact),
          Expanded(child: Text(label, style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: isUploaded ? AppColors.success : AppColors.onSurface))),
          Icon(isUploaded ? Icons.edit_rounded : Icons.upload_rounded,
              size: 18, color: AppColors.onSurfaceVariant),
        ]),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: const BoxDecoration(color: AppColors.successContainer, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, size: 52, color: AppColors.success),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Dossier envoyé !', style: AppTypography.h2, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Notre équipe examine votre dossier. Vous recevrez le badge Vérifié sous 24h.',
            style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(label: 'Retourner au profil', onPressed: onDone),
        ],
      ),
    );
  }
}
