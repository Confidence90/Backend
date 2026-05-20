import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/navigation/app_routes.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushMissions = true;
  bool _pushMessages = true;
  bool _pushPayments = true;
  bool _pushMarketing = false;
  bool _locationEnabled = true;
  bool _biometric = false;
  String _language = 'Français';

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
          color: AppColors.onSurface,
        ),
        title: Text('Paramètres', style: AppTypography.h3),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
      ),
      body: ListView(
        children: [
          // ── Appearance ────────────────────────────────────────────────
          _SectionHeader('Apparence'),
          _ToggleTile(
            icon: Icons.dark_mode_rounded,
            iconColor: const Color(0xFF7C4DFF),
            iconBg: const Color(0xFFEDE7F6),
            title: 'Mode sombre',
            subtitle: 'Interface en thème sombre',
            value: isDark,
            onChanged: (v) => ref.read(isDarkModeProvider.notifier).state = v,
          ),
          _NavTile(
            icon: Icons.language_rounded,
            iconColor: AppColors.tertiary,
            iconBg: AppColors.secondaryContainer,
            title: 'Langue',
            subtitle: _language,
            onTap: () => _showLanguagePicker(context),
          ),

          // ── Notifications ─────────────────────────────────────────────
          _SectionHeader('Notifications'),
          _ToggleTile(
            icon: Icons.task_alt_rounded,
            iconColor: AppColors.primary,
            iconBg: AppColors.surfaceContainer,
            title: 'Nouvelles missions',
            subtitle: 'Alertes quand une mission correspond à votre profil',
            value: _pushMissions,
            onChanged: (v) => setState(() => _pushMissions = v),
          ),
          _ToggleTile(
            icon: Icons.chat_bubble_rounded,
            iconColor: AppColors.tertiary,
            iconBg: AppColors.secondaryContainer,
            title: 'Messages',
            subtitle: 'Notifications de nouveaux messages',
            value: _pushMessages,
            onChanged: (v) => setState(() => _pushMessages = v),
          ),
          _ToggleTile(
            icon: Icons.payments_rounded,
            iconColor: AppColors.success,
            iconBg: AppColors.successContainer,
            title: 'Paiements',
            subtitle: 'Confirmations et alertes de transaction',
            value: _pushPayments,
            onChanged: (v) => setState(() => _pushPayments = v),
          ),
          _ToggleTile(
            icon: Icons.campaign_rounded,
            iconColor: AppColors.onSurfaceVariant,
            iconBg: AppColors.surfaceContainerHighest,
            title: 'Offres & actualités',
            subtitle: 'Promotions et nouveautés BaaraLink',
            value: _pushMarketing,
            onChanged: (v) => setState(() => _pushMarketing = v),
          ),

          // ── Privacy & Security ────────────────────────────────────────
          _SectionHeader('Confidentialité & Sécurité'),
          _ToggleTile(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.error,
            iconBg: AppColors.errorContainer,
            title: 'Géolocalisation',
            subtitle: 'Permettre la recherche de prestataires proches',
            value: _locationEnabled,
            onChanged: (v) => setState(() => _locationEnabled = v),
          ),
          _ToggleTile(
            icon: Icons.fingerprint_rounded,
            iconColor: AppColors.primary,
            iconBg: AppColors.surfaceContainer,
            title: 'Connexion biométrique',
            subtitle: 'Utiliser l\'empreinte ou Face ID',
            value: _biometric,
            onChanged: (v) => setState(() => _biometric = v),
          ),
          _NavTile(
            icon: Icons.lock_reset_rounded,
            iconColor: AppColors.warning,
            iconBg: AppColors.warningContainer,
            title: 'Changer le mot de passe',
            onTap: () {},
          ),
          _NavTile(
            icon: Icons.privacy_tip_rounded,
            iconColor: AppColors.tertiary,
            iconBg: AppColors.secondaryContainer,
            title: 'Politique de confidentialité',
            onTap: () {},
          ),

          // ── Account ───────────────────────────────────────────────────
          _SectionHeader('Compte'),
          _NavTile(
            icon: Icons.verified_rounded,
            iconColor: AppColors.tertiary,
            iconBg: AppColors.secondaryContainer,
            title: 'Vérification d\'identité',
            subtitle: 'Obtenir le badge Vérifié',
            onTap: () => context.push(AppRoutes.idVerification),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.successContainer,
                borderRadius: AppRadius.radiusFull,
              ),
              child: Text('Complété', style: AppTypography.caption.copyWith(
                  color: AppColors.success, letterSpacing: 0)),
            ),
          ),
          _NavTile(
            icon: Icons.download_rounded,
            iconColor: AppColors.primary,
            iconBg: AppColors.surfaceContainer,
            title: 'Télécharger mes données',
            onTap: () {},
          ),
          _NavTile(
            icon: Icons.delete_outline_rounded,
            iconColor: AppColors.error,
            iconBg: AppColors.errorContainer,
            title: 'Supprimer le compte',
            titleColor: AppColors.error,
            onTap: () => _showDeleteDialog(context),
          ),

          // ── App info ──────────────────────────────────────────────────
          _SectionHeader('À propos'),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile, vertical: AppSpacing.compact),
            child: Row(children: [
              Text('Version', style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant)),
              const Spacer(),
              Text('1.0.0 (build 1)', style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant)),
            ]),
          ),
          const SizedBox(height: AppSpacing.generous),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Langue', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            ...['Français', 'Bambara (bientôt)', 'English (bientôt)'].map((lang) {
              final isSelected = _language == lang;
              final isDisabled = lang.contains('bientôt');
              return ListTile(
                title: Text(lang, style: AppTypography.bodyMedium.copyWith(
                    color: isDisabled ? AppColors.onSurfaceVariant : AppColors.onSurface)),
                trailing: isSelected
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: isDisabled ? null : () {
                  setState(() => _language = lang);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Supprimer le compte ?', style: AppTypography.h3),
        content: Text(
          'Cette action est irréversible. Toutes vos données, missions et historique seront définitivement supprimés.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Supprimer', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile, AppSpacing.md, AppSpacing.marginMobile, 4),
      child: Text(title, style: AppTypography.labelCaps.copyWith(
          color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon, required this.iconColor, required this.iconBg,
    required this.title, this.subtitle, required this.value, required this.onChanged,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile, vertical: 2),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: AppRadius.radiusSm),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.compact),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium),
                if (subtitle != null)
                  Text(subtitle!, style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon, required this.iconColor, required this.iconBg,
    required this.title, this.subtitle, this.titleColor,
    this.onTap, this.trailing,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: iconBg, borderRadius: AppRadius.radiusSm),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(title, style: AppTypography.bodyMedium.copyWith(color: titleColor)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant))
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded,
          color: AppColors.onSurfaceVariant, size: 20),
      onTap: onTap,
    );
  }
}
