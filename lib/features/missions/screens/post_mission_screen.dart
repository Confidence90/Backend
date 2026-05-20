import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/widgets/buttons/app_buttons.dart';
import '../../../core/widgets/inputs/app_inputs.dart';
import '../../../core/widgets/layout/app_shared_widgets.dart';
import '../../../shared/navigation/app_routes.dart';

class PostMissionScreen extends ConsumerStatefulWidget {
  const PostMissionScreen({super.key});

  @override
  ConsumerState<PostMissionScreen> createState() => _PostMissionScreenState();
}

class _PostMissionScreenState extends ConsumerState<PostMissionScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Form data
  String _category = 'Plomberie';
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController(text: 'ACI 2000, Bamako');
  final _budgetController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _usePack = false;

  static const _categories = [
    (Icons.plumbing_rounded, 'Plomberie'),
    (Icons.bolt_rounded, 'Électricité'),
    (Icons.cleaning_services_rounded, 'Ménage'),
    (Icons.construction_rounded, 'Maçonnerie'),
    (Icons.format_paint_rounded, 'Peinture'),
    (Icons.carpenter_rounded, 'Menuiserie'),
    (Icons.yard_rounded, 'Jardinage'),
    (Icons.child_care_rounded, 'Garde enfant'),
  ];

  static const _steps = ['Détails', 'Lieu & Date', 'Budget'];

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: AppAnimations.standard,
        curve: Curves.easeInOut,
      );
    } else {
      await _submit();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: AppAnimations.standard,
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _showSuccessSheet();
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _SuccessSheet(
        onDone: () {
          Navigator.pop(context);
          context.go(AppRoutes.clientDashboard);
        },
        onViewPacks: () {
          Navigator.pop(context);
          context.go(AppRoutes.packs);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _back,
          color: AppColors.onSurface,
        ),
        title: Text('Publier une mission', style: AppTypography.h3),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _StepIndicator(steps: _steps, current: _currentStep),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _Step1Details(
            category: _category,
            categories: _categories,
            titleController: _titleController,
            descController: _descController,
            onCategoryChanged: (c) => setState(() => _category = c),
          ),
          _Step2LocationDate(
            addressController: _addressController,
            selectedDate: _selectedDate,
            selectedTime: _selectedTime,
            onDateChanged: (d) => setState(() => _selectedDate = d),
            onTimeChanged: (t) => setState(() => _selectedTime = t),
          ),
          _Step3Budget(
            budgetController: _budgetController,
            usePack: _usePack,
            onPackChanged: (v) => setState(() => _usePack = v),
            onViewPacks: () => context.push(AppRoutes.packs),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        step: _currentStep,
        totalSteps: _steps.length,
        isSubmitting: _isSubmitting,
        onNext: _next,
      ),
    );
  }
}

// ─── Step Indicator ──────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.steps, required this.current});
  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile, 0, AppSpacing.marginMobile, AppSpacing.sm),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            return Expanded(
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                height: 2,
                color: stepIndex < current
                    ? AppColors.primary
                    : AppColors.outlineVariant,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final isCompleted = stepIndex < current;
          final isActive = stepIndex == current;
          return Row(
            children: [
              AnimatedContainer(
                duration: AppAnimations.fast,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.primary
                      : isActive
                          ? AppColors.primary
                          : AppColors.surfaceContainerHighest,
                  border: Border.all(
                    color: isActive || isCompleted
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                      : Text(
                          '${stepIndex + 1}',
                          style: AppTypography.caption.copyWith(
                            color: isActive ? Colors.white : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 6),
              if (isActive || isCompleted)
                Text(steps[stepIndex],
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    )),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Step 1: Details ─────────────────────────────────────────────────────────
class _Step1Details extends StatelessWidget {
  const _Step1Details({
    required this.category, required this.categories,
    required this.titleController, required this.descController,
    required this.onCategoryChanged,
  });
  final String category;
  final List<(IconData, String)> categories;
  final TextEditingController titleController;
  final TextEditingController descController;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type de service', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.compact),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
            children: categories.map((c) {
              final isSelected = category == c.$2;
              return GestureDetector(
                onTap: () => onCategoryChanged(c.$2),
                child: AnimatedContainer(
                  duration: AppAnimations.fast,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.surfaceContainerHighest,
                    borderRadius: AppRadius.radiusMd,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(c.$1, size: 24,
                          color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant),
                      const SizedBox(height: 4),
                      Text(c.$2,
                          style: AppTypography.overline.copyWith(
                            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                            letterSpacing: 0,
                            fontSize: 9,
                          ),
                          textAlign: TextAlign.center, maxLines: 2),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Titre de la mission *',
            hint: 'Ex: Réparer une fuite sous l\'évier',
            controller: titleController,
            textInputAction: TextInputAction.next,
            maxLength: 100,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Description détaillée',
            hint: 'Décris le problème avec le plus de détails possibles…',
            controller: descController,
            maxLines: 4,
            textInputAction: TextInputAction.done,
            maxLength: 500,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─── Step 2: Location & Date ──────────────────────────────────────────────────
class _Step2LocationDate extends StatelessWidget {
  const _Step2LocationDate({
    required this.addressController, required this.selectedDate,
    required this.selectedTime, required this.onDateChanged,
    required this.onTimeChanged,
  });
  final TextEditingController addressController;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adresse d\'intervention', style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: addressController,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Saisir l\'adresse…',
              prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
              suffixIcon: const Icon(Icons.my_location_rounded, color: AppColors.tertiary, size: 18),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Date picker
          Text('Date souhaitée', style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primary),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) onDateChanged(picked);
            },
            child: _DateTimePicker(
              icon: Icons.calendar_today_rounded,
              label: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Time picker
          Text('Heure souhaitée', style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final picked = await showTimePicker(
                context: context, initialTime: selectedTime,
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primary),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) onTimeChanged(picked);
            },
            child: _DateTimePicker(
              icon: Icons.access_time_rounded,
              label: selectedTime.format(context),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Quick time chips
          Text('Ou choisir rapidement', style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            children: ['Ce matin', 'Cet après-midi', 'Demain matin', 'Ce week-end']
                .map((t) => AppFilterChip(label: t, selected: false, onSelected: (_) {}))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  const _DateTimePicker({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.outlineVariant, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTypography.bodyMedium),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant, size: 18),
        ],
      ),
    );
  }
}

// ─── Step 3: Budget ──────────────────────────────────────────────────────────
class _Step3Budget extends StatelessWidget {
  const _Step3Budget({
    required this.budgetController, required this.usePack,
    required this.onPackChanged, required this.onViewPacks,
  });
  final TextEditingController budgetController;
  final bool usePack;
  final ValueChanged<bool> onPackChanged;
  final VoidCallback onViewPacks;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Budget estimé (FCFA)',
            hint: '25 000',
            controller: budgetController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Le prestataire peut proposer son propre tarif. Ton budget est indicatif.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Pack upsell
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.06), AppColors.primary.withOpacity(0.02)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.radiusLg,
              border: Border.all(
                color: usePack ? AppColors.primary : AppColors.outlineVariant,
                width: usePack ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Activer le Pack Premium',
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Switch(
                      value: usePack,
                      onChanged: onPackChanged,
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'BaaraLink sélectionne automatiquement les meilleurs prestataires pour toi. Plus besoin de chercher.',
                  style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant, height: 1.5),
                ),
                if (usePack) ...[
                  const SizedBox(height: AppSpacing.compact),
                  const Divider(),
                  const SizedBox(height: AppSpacing.compact),
                  Row(
                    children: [
                      Expanded(
                        child: _PackOption(
                          name: 'Basic',
                          price: '4 950 FCFA',
                          profiles: 4,
                          selected: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PackOption(
                          name: 'Premium',
                          price: '6 950 FCFA',
                          profiles: 9,
                          selected: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Payment info
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: AppRadius.radiusMd,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_rounded, size: 18, color: AppColors.tertiary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Le paiement sera sécurisé en escrow. L\'argent est libéré uniquement après validation du service.',
                    style: AppTypography.bodySmall.copyWith(
                        color: AppColors.tertiary, fontWeight: FontWeight.w500, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackOption extends StatelessWidget {
  const _PackOption({required this.name, required this.price, required this.profiles, required this.selected});
  final String name;
  final String price;
  final int profiles;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.compact),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withOpacity(0.08) : AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: selected ? AppColors.primary : AppColors.outlineVariant,
            width: selected ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700,
              color: selected ? AppColors.primary : AppColors.onSurface)),
          Text(price, style: AppTypography.caption.copyWith(color: AppColors.primary,
              fontWeight: FontWeight.w700, letterSpacing: 0)),
          Text('$profiles profils', style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant, letterSpacing: 0)),
        ],
      ),
    );
  }
}

// ─── Bottom Bar ───────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.step, required this.totalSteps,
    required this.isSubmitting, required this.onNext,
  });
  final int step;
  final int totalSteps;
  final bool isSubmitting;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile, AppSpacing.compact, AppSpacing.marginMobile, AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: PrimaryButton(
          label: step == totalSteps - 1 ? 'Publier la mission' : 'Continuer',
          onPressed: onNext,
          isLoading: isSubmitting,
          icon: Icon(
            step == totalSteps - 1 ? Icons.publish_rounded : Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// ─── Success Bottom Sheet ──────────────────────────────────────────────────────
class _SuccessSheet extends StatelessWidget {
  const _SuccessSheet({required this.onDone, required this.onViewPacks});
  final VoidCallback onDone;
  final VoidCallback onViewPacks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.bottomSheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.successContainer, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, size: 44, color: AppColors.success),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Mission publiée ! 🎉', style: AppTypography.h2, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            '3 prestataires dans ta zone ont été notifiés. Tu recevras des propositions très prochainement.',
            style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(label: 'Voir mes missions', onPressed: onDone),
          const SizedBox(height: AppSpacing.compact),
          SecondaryButton(label: 'Activer Pack Premium', onPressed: onViewPacks),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
