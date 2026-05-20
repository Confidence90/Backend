import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/design_tokens.dart';

/// Multi-state button: idle → loading → success/error
class LoadingButton extends StatefulWidget {
  final String label;
  final Future<bool> Function()? onPressed; // returns true=success, false=error
  final IconData? icon;
  final bool fullWidth;
  final double? height;

  const LoadingButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.height,
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

enum _BtnState { idle, loading, success, error }

class _LoadingButtonState extends State<LoadingButton> with SingleTickerProviderStateMixin {
  _BtnState _state = _BtnState.idle;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 80), reverseDuration: const Duration(milliseconds: 120));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _scaleCtrl.dispose(); super.dispose(); }

  Future<void> _handleTap() async {
    if (_state != _BtnState.idle || widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    _scaleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 80));
    _scaleCtrl.reverse();
    setState(() => _state = _BtnState.loading);
    final success = await widget.onPressed!();
    setState(() => _state = success ? _BtnState.success : _BtnState.error);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) setState(() => _state = _BtnState.idle);
  }

  Color get _bgColor => switch (_state) {
    _BtnState.success => BLColor.success,
    _BtnState.error   => BLColor.error,
    _BtnState.loading => BLColor.primary.withOpacity(0.85),
    _BtnState.idle    => BLColor.primary,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { if (_state == _BtnState.idle) _scaleCtrl.forward(); },
      onTapUp: (_) => _scaleCtrl.reverse(),
      onTapCancel: () => _scaleCtrl.reverse(),
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: BLMotion.normal,
          curve: BLMotion.easeOut,
          height: widget.height ?? BLSize.buttonH,
          width: widget.fullWidth ? double.infinity : null,
          padding: widget.fullWidth ? null : const EdgeInsets.symmetric(horizontal: BLSpace.lg),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BLRadius.def,
            boxShadow: _state == _BtnState.idle ? BLShadow.orange : BLShadow.none,
          ),
          child: Center(child: _buildContent()),
        ),
      ),
    );
  }

  Widget _buildContent() => AnimatedSwitcher(
    duration: BLMotion.fast,
    child: switch (_state) {
      _BtnState.loading => const SizedBox(key: ValueKey('load'), width: 22, height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white))),
      _BtnState.success => const Row(key: ValueKey('ok'), mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
          SizedBox(width: BLSpace.sm),
          Text('Succès', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ]),
      _BtnState.error   => const Row(key: ValueKey('err'), mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
          SizedBox(width: BLSpace.sm),
          Text('Erreur', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ]),
      _BtnState.idle    => Row(key: const ValueKey('idle'), mainAxisSize: MainAxisSize.min, children: [
          if (widget.icon != null) ...[Icon(widget.icon, color: Colors.white, size: 20), const SizedBox(width: BLSpace.sm)],
          Text(widget.label, style: BLTypo.button.copyWith(color: Colors.white)),
        ]),
    },
  );
}
