import 'package:flutter/material.dart';
import '../../tokens/design_tokens.dart';

class AppSearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller;

  const AppSearchField({
    super.key,
    this.hint = 'Rechercher un artisan, service…',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.controller,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() { _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: BLMotion.fast,
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? BLColor.surfaceContainerDark : BLColor.surfaceContainerLowest,
        borderRadius: BLRadius.full,
        border: Border.all(
          color: _focused ? BLColor.primary : BLColor.outlineVariant,
          width: _focused ? 2 : 1,
        ),
        boxShadow: _focused ? BLShadow.card : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        style: BLTypo.bodyMd.copyWith(color: isDark ? BLColor.onSurfaceDark : BLColor.onSurface),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: BLTypo.bodyMd.copyWith(color: BLColor.outline),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 10),
            child: Icon(Icons.search_rounded, color: _focused ? BLColor.primary : BLColor.outline, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 52),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
