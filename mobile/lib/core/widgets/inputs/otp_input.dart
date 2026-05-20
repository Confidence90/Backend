import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/design_tokens.dart';

class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool hasError;

  const OtpInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.hasError = false,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes  = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onChanged(String val, int idx) {
    if (val.length > 1) {
      // Handle paste
      final digits = val.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < widget.length && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final filled = digits.length >= widget.length;
      if (filled) {
        _focusNodes.last.unfocus();
        widget.onCompleted(_controllers.map((c) => c.text).join());
      } else if (digits.length < widget.length) {
        _focusNodes[digits.length].requestFocus();
      }
      return;
    }
    if (val.isNotEmpty) {
      if (idx < widget.length - 1) _focusNodes[idx + 1].requestFocus();
    }
    final code = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      _focusNodes.last.unfocus();
      widget.onCompleted(code);
    }
  }

  void _onBackspace(int idx) {
    if (_controllers[idx].text.isEmpty && idx > 0) {
      _controllers[idx - 1].clear();
      _focusNodes[idx - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (i) {
        return _OtpCell(
          controller: _controllers[i],
          focusNode: _focusNodes[i],
          hasError: widget.hasError,
          isDark: isDark,
          onChanged: (v) => _onChanged(v, i),
          onBackspace: () => _onBackspace(i),
          onTap: () => _focusNodes[i].requestFocus(),
        );
      }),
    );
  }
}

class _OtpCell extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;
  final VoidCallback onTap;

  const _OtpCell({
    required this.controller, required this.focusNode, required this.hasError,
    required this.isDark, required this.onChanged, required this.onBackspace, required this.onTap,
  });

  @override
  State<_OtpCell> createState() => _OtpCellState();
}

class _OtpCellState extends State<_OtpCell> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() => setState(() => _focused = widget.focusNode.hasFocus));
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.hasError
        ? BLColor.error
        : _focused ? BLColor.primary : BLColor.outlineVariant;
    final bgColor = widget.hasError
        ? BLColor.errorContainer.withOpacity(0.3)
        : _focused
            ? (widget.isDark ? BLColor.surfaceContainerDark : BLColor.surfaceContainerLow)
            : (widget.isDark ? BLColor.surfaceContainerDark : BLColor.surfaceContainerLowest);

    return AnimatedContainer(
      duration: BLMotion.fast,
      width: BLSize.otpCell,
      height: BLSize.otpCell,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BLRadius.lg,
        border: Border.all(color: borderColor, width: _focused ? 2 : 1),
        boxShadow: _focused ? [BoxShadow(color: borderColor.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))] : null,
      ),
      child: Center(
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (event) {
            if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
              widget.onBackspace();
            }
          },
          child: EditableText(
            controller: widget.controller,
            focusNode: widget.focusNode,
            onChanged: widget.onChanged,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(1)],
            style: BLTypo.h2.copyWith(
              color: widget.hasError ? BLColor.error : (widget.isDark ? BLColor.onSurfaceDark : BLColor.onSurface),
            ),
            cursorColor: BLColor.primary,
            backgroundCursorColor: Colors.transparent,
            autofocus: false,
            showCursor: _focused,
          ),
        ),
      ),
    );
  }
}
