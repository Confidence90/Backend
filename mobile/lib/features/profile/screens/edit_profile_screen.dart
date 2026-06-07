import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/app_buttons.dart';
import '../../../core/widgets/inputs/app_inputs.dart';
import '../../../core/widgets/layout/app_shared_widgets.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _specialtyCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  bool _isSaving = false;

  final _skills = <String>['Fuite d\'eau', 'Installation', 'Chauffe-eau', 'WC'];
  final _newSkillCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider) ?? MockData.currentProvider;
    _nameCtrl = TextEditingController(text: user.name);
    _specialtyCtrl = TextEditingController(text: user.specialty ?? '');
    _bioCtrl = TextEditingController(
      text: 'Plombier professionnel avec 8 ans d\'expérience à Bamako. Spécialiste des fuites et installations sanitaires.',
    );
    _locationCtrl = TextEditingController(text: user.location ?? 'ACI 2000, Bamako');
    _phoneCtrl = TextEditingController(text: '+223 76 54 32 10');
    _emailCtrl = TextEditingController(text: user.email ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _specialtyCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _newSkillCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès !')),
      );
      context.pop();
    }
  }

  void _addSkill(String skill) {
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _newSkillCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
          color: AppColors.onSurface,
        ),
        title: Text('Modifier le profil', style: AppTypography.h3),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : Text('Sauvegarder',
                      style: AppTypography.button.copyWith(
                          color: AppColors.primary, fontSize: 14)),
            ),
          ),
        ],
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Avatar editor ─────────────────────────────────────────────
            Center(
              child: Stack(
                children: [
                  AppAvatar(initials: 'MD', size: 88, showVerified: true),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text('Changer la photo',
                    style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Personal info ─────────────────────────────────────────────
            _SectionTitle('Informations personnelles'),
            const SizedBox(height: AppSpacing.compact),
            AppTextField(label: 'Nom complet *', controller: _nameCtrl, textInputAction: TextInputAction.next),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Spécialité', controller: _specialtyCtrl,
                hint: 'Ex: Plombier Expert', textInputAction: TextInputAction.next),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Bio / Description', controller: _bioCtrl,
                maxLines: 4, maxLength: 500, textInputAction: TextInputAction.done),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Localisation', controller: _locationCtrl,
                prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                textInputAction: TextInputAction.next),
            const SizedBox(height: AppSpacing.lg),

            // ── Contact ───────────────────────────────────────────────────
            _SectionTitle('Contact'),
            const SizedBox(height: AppSpacing.compact),
            AppTextField(
              label: 'Téléphone',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              enabled: false,
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successContainer,
                  borderRadius: AppRadius.radiusFull,
                ),
                child: Text('Vérifié', style: AppTypography.caption.copyWith(
                    color: AppColors.success, letterSpacing: 0)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Email (optionnel)',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Skills ────────────────────────────────────────────────────
            _SectionTitle('Compétences'),
            const SizedBox(height: AppSpacing.compact),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._skills.map((s) => Chip(
                  label: Text(s, style: AppTypography.bodySmall),
                  deleteIcon: const Icon(Icons.close_rounded, size: 14),
                  onDeleted: () => setState(() => _skills.remove(s)),
                  backgroundColor: AppColors.surfaceContainerHighest,
                  side: const BorderSide(color: AppColors.outlineVariant),
                )),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _newSkillCtrl,
                  style: AppTypography.bodySmall,
                  decoration: const InputDecoration(
                    hintText: 'Ajouter une compétence…',
                    isDense: true,
                  ),
                  onSubmitted: _addSkill,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _addSkill(_newSkillCtrl.text),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                ),
              ),
            ]),
            const SizedBox(height: AppSpacing.xl),

            PrimaryButton(
              label: 'Sauvegarder les modifications',
              onPressed: _save,
              isLoading: _isSaving,
              icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(height: AppSpacing.generous),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(title,
      style: AppTypography.labelCaps.copyWith(
          color: AppColors.onSurfaceVariant, letterSpacing: 0.8));
}
