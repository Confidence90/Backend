import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/design_tokens.dart';

class SecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double? height;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.height,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 80), reverseDuration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) { if (!disabled) { HapticFeedback.lightImpact(); _ctrl.forward(); } },
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: disabled ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: BLMotion.fast,
          height: widget.height ?? BLSize.buttonH,
          width: widget.fullWidth ? double.infinity : null,
          padding: widget.fullWidth ? null : const EdgeInsets.symmetric(horizontal: BLSpace.lg),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BLRadius.def,
            border: Border.all(
              color: disabled ? BLColor.outlineVariant : BLColor.primary,
              width: 1.5,
            ),
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(isDark ? BLColor.primaryFixedDim : BLColor.primary)))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: disabled ? BLColor.outline : BLColor.primary, size: 20),
                        const SizedBox(width: BLSpace.sm),
                      ],
                      Text(widget.label, style: BLTypo.button.copyWith(color: disabled ? BLColor.outline : (isDark ? BLColor.primaryFixedDim : BLColor.primary))),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
