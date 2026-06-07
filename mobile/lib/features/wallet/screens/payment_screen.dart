import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/widgets/buttons/app_buttons.dart';
import '../../../shared/navigation/app_routes.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.amount, this.missionTitle});
  final int amount;
  final String? missionTitle;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedMethod = 'orange';
  bool _isProcessing = false;
  bool _paymentSuccess = false;
  final _fcfa = NumberFormat('#,###', 'fr_FR');

  final _effectiveAmount = 25000;
  final _commission = 1875;

  static const _methods = [
    _PaymentMethod(
      id: 'orange',
      name: 'Orange Money',
      logo: '🟠',
      balance: 87500,
      color: Color(0xFFFF6600),
      textColor: Colors.white,
      sublabel: 'Orange Mali',
    ),
    _PaymentMethod(
      id: 'wave',
      name: 'Wave',
      logo: 'W',
      balance: 12000,
      color: Color(0xFF1F9EF7),
      textColor: Colors.white,
      sublabel: 'Wave Mobile Money',
    ),
    _PaymentMethod(
      id: 'moov',
      name: 'Moov Money',
      logo: 'M',
      balance: 0,
      color: Color(0xFF0A3D7E),
      textColor: Colors.white,
      sublabel: 'Moov Africa Mali',
    ),
  ];

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _paymentSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_paymentSuccess) return _SuccessScreen(amount: _effectiveAmount, fcfa: _fcfa);

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
        title: Text('Paiement Sécurisé', style: AppTypography.h3),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Mission details card ─────────────────────────────────────
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DÉTAILS DE LA MISSION',
                      style: AppTypography.labelCaps.copyWith(
                          color: AppColors.onSurfaceVariant, letterSpacing: 1.0)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.missionTitle ?? 'Réparation fuite robinet cuisine',
                    style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text('Artisan : Moussa Diarra',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: AppRadius.radiusFull),
                    child: Text('Paiement escrow — libéré après validation',
                        style: AppTypography.caption.copyWith(
                            color: AppColors.secondary,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w600)),
                  ),
                  const Divider(height: AppSpacing.lg),
                  _PriceLine(label: 'Coût de la mission', value: '${_fcfa.format(_effectiveAmount)} FCFA'),
                  const SizedBox(height: 6),
                  _PriceLine(label: 'Commission BaaraLink (7.5%)', value: '${_fcfa.format(_commission)} FCFA'),
                  const Divider(height: AppSpacing.md),
                  Row(
                    children: [
                      Text('Total à payer',
                          style: AppTypography.h3),
                      const Spacer(),
                      Text('${_fcfa.format(_effectiveAmount + _commission)} FCFA',
                          style: AppTypography.h2.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Payment method selection ──────────────────────────────────
            Text('Moyen de paiement', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.compact),

            ..._methods.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _PaymentMethodCard(
                    method: m,
                    selected: _selectedMethod == m.id,
                    fcfa: _fcfa,
                    onTap: () => setState(() => _selectedMethod = m.id),
                  ),
                )),
            const SizedBox(height: AppSpacing.md),

            // ── Security note ─────────────────────────────────────────────
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.successContainer,
                borderRadius: AppRadius.radiusMd,
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded, color: AppColors.success, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Paiement sécurisé. L\'argent est retenu en escrow et libéré uniquement après validation du service.',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.success, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Pay button ────────────────────────────────────────────────
            PrimaryButton(
              label: 'Payer ${_fcfa.format(_effectiveAmount + _commission)} FCFA',
              onPressed: _processPayment,
              isLoading: _isProcessing,
              icon: const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant))),
        Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _PaymentMethod {
  const _PaymentMethod({
    required this.id, required this.name, required this.logo,
    required this.balance, required this.color, required this.textColor,
    required this.sublabel,
  });
  final String id;
  final String name;
  final String logo;
  final int balance;
  final Color color;
  final Color textColor;
  final String sublabel;
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method, required this.selected,
    required this.fcfa, required this.onTap,
  });
  final _PaymentMethod method;
  final bool selected;
  final NumberFormat fcfa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasBalance = method.balance > 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.03)
              : AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: method.color,
                borderRadius: AppRadius.radiusMd,
              ),
              child: Center(
                child: method.logo.length == 1 && method.logo != '🟠'
                    ? Text(method.logo,
                        style: AppTypography.h3.copyWith(
                            color: method.textColor, fontWeight: FontWeight.w800))
                    : Text(method.logo, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: AppSpacing.compact),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.name,
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                  Text(
                    hasBalance
                        ? 'Solde : ${fcfa.format(method.balance)} FCFA'
                        : 'Connecter le compte',
                    style: AppTypography.bodySmall.copyWith(
                        color: hasBalance
                            ? AppColors.onSurfaceVariant
                            : AppColors.error),
                  ),
                ],
              ),
            ),

            // Selection circle
            AnimatedContainer(
              duration: AppAnimations.fast,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Success Screen
// ─────────────────────────────────────────────────────────────────────────────
class _SuccessScreen extends StatefulWidget {
  const _SuccessScreen({required this.amount, required this.fcfa});
  final int amount;
  final NumberFormat fcfa;

  @override
  State<_SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<_SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated checkmark
              AnimatedBuilder(
                animation: _scale,
                builder: (_, __) => Transform.scale(
                  scale: _scale.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.successContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.success.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(Icons.check_rounded, size: 52, color: AppColors.success),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Paiement effectué !', style: AppTypography.h2, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                '${widget.fcfa.format(widget.amount)} FCFA\nenvoyés avec succès',
                style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              // Receipt info
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  children: [
                    _ReceiptRow('Montant', '${widget.fcfa.format(widget.amount)} FCFA'),
                    const Divider(height: AppSpacing.md),
                    _ReceiptRow('Statut', 'En escrow — en attente de validation'),
                    const Divider(height: AppSpacing.md),
                    _ReceiptRow('Référence', 'BRL-2025-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
                    const Divider(height: AppSpacing.md),
                    _ReceiptRow('Date', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Voir la mission',
                onPressed: () => context.go('/mission/mis-001'),
                icon: const Icon(Icons.task_alt_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(height: AppSpacing.compact),
              SecondaryButton(
                label: 'Télécharger le reçu',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
        const Spacer(),
        Flexible(
          child: Text(value,
              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
