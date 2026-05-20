import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/design_tokens.dart';

enum FieldState { idle, focused, success, error }

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool autofocus;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefix;
  final Widget? suffix;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool showSuccess;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.autofocus = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.inputFormatters,
    this.showSuccess = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focus;
  late AnimationController _borderCtrl;
  late Animation<double> _borderAnim;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
    _borderCtrl = AnimationController(vsync: this, duration: BLMotion.normal);
    _borderAnim = CurvedAnimation(parent: _borderCtrl, curve: BLMotion.easeOut);
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focus.hasFocus);
    if (_focus.hasFocus) _borderCtrl.forward();
    else _borderCtrl.reverse();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    _borderCtrl.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (widget.errorText != null) return BLColor.error;
    if (widget.showSuccess) return BLColor.success;
    if (_isFocused) return BLColor.primary;
    return BLColor.outlineVariant;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: BLTypo.bodySm.copyWith(
            fontWeight: FontWeight.w600,
            color: widget.errorText != null
                ? BLColor.error
                : _isFocused
                    ? BLColor.primary
                    : isDark ? BLColor.onSurfaceVariantDark : BLColor.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: BLSpace.sm),
        AnimatedBuilder(
          animation: _borderAnim,
          builder: (_, child) => Container(
            decoration: BoxDecoration(
              borderRadius: BLRadius.lg,
              border: Border.all(color: _borderColor, width: _isFocused ? 2 : 1),
              color: isDark ? BLColor.surfaceContainerDark : BLColor.surfaceContainerLow,
              boxShadow: _isFocused ? [BoxShadow(color: _borderColor.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 2))] : null,
            ),
            child: child,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focus,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: widget.obscureText,
            autofocus: widget.autofocus,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            onSubmitted: widget.onSubmitted,
            style: BLTypo.bodyMd.copyWith(
              color: isDark ? BLColor.onSurfaceDark : BLColor.onSurface,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: BLTypo.bodyMd.copyWith(color: BLColor.outline),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              contentPadding: BLSpace.inputPadding,
              prefixIcon: widget.prefix ?? (widget.prefixIcon != null
                  ? Padding(padding: const EdgeInsets.only(left: BLSpace.md, right: BLSpace.sm),
                      child: Icon(widget.prefixIcon, size: BLSize.iconMd, color: _isFocused ? BLColor.primary : BLColor.outline))
                  : null),
              prefixIconConstraints: const BoxConstraints(minWidth: 48),
              suffixIcon: _buildSuffix(),
              suffixIconConstraints: const BoxConstraints(minWidth: 48),
              counterText: '',
            ),
          ),
        ),
        if (widget.errorText != null || widget.helperText != null) ...[
          const SizedBox(height: BLSpace.xs),
          Row(children: [
            Icon(
              widget.errorText != null ? Icons.error_outline_rounded : Icons.info_outline_rounded,
              size: 14,
              color: widget.errorText != null ? BLColor.error : BLColor.outline,
            ),
            const SizedBox(width: 4),
            Text(
              widget.errorText ?? widget.helperText ?? '',
              style: BLTypo.bodySm.copyWith(
                color: widget.errorText != null ? BLColor.error : BLColor.outline,
              ),
            ),
          ]),
        ],
      ],
    );
  }

  Widget? _buildSuffix() {
    if (widget.showSuccess) return const Padding(padding: EdgeInsets.only(right: BLSpace.md), child: Icon(Icons.check_circle_rounded, color: BLColor.success, size: 20));
    if (widget.errorText != null) return const Padding(padding: EdgeInsets.only(right: BLSpace.md), child: Icon(Icons.cancel_rounded, color: BLColor.error, size: 20));
    if (widget.suffix != null) return widget.suffix;
    if (widget.suffixIcon != null) return GestureDetector(
      onTap: widget.onSuffixTap,
      child: Padding(padding: const EdgeInsets.only(right: BLSpace.md), child: Icon(widget.suffixIcon, size: BLSize.iconMd, color: BLColor.outline)),
    );
    return null;
  }
}
