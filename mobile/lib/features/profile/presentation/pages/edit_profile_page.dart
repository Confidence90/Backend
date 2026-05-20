import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});
  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey  = GlobalKey<FormState>();
  final _bioCtrl  = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _distCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _minCtrl  = TextEditingController();
  String _experience = 'beginner';
  List<String> _selectedCategories = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final profile = ref.read(myProfileProvider).profile;
      if (profile != null) {
        _bioCtrl.text  = profile['bio']        as String? ?? '';
        _cityCtrl.text = profile['city']       as String? ?? 'Bamako';
        _distCtrl.text = profile['district']   as String? ?? '';
        _rateCtrl.text = (profile['hourly_rate'] as int?)?.toString() ?? '';
        _minCtrl.text  = (profile['min_rate']    as int?)?.toString() ?? '';
        _experience    = profile['experience_level'] as String? ?? 'beginner';
        _selectedCategories = ((profile['categories'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map((c) => c['id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toList());
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _bioCtrl.dispose(); _cityCtrl.dispose(); _distCtrl.dispose();
    _rateCtrl.dispose(); _minCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(myProfileProvider.notifier).update({
      'bio':               _bioCtrl.text.trim(),
      'city':              _cityCtrl.text.trim(),
      'district':          _distCtrl.text.trim(),
      'experience_level':  _experience,
      if (_rateCtrl.text.isNotEmpty) 'hourly_rate': int.parse(_rateCtrl.text.trim()),
      if (_minCtrl.text.isNotEmpty)  'min_rate':    int.parse(_minCtrl.text.trim()),
      if (_selectedCategories.isNotEmpty) 'category_ids': _selectedCategories,
    });
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profil mis à jour !'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state      = ref.watch(myProfileProvider);
    final categories = state.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: state.isSaving ? null : _save,
            child: state.isSaving
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : const Text('Enregistrer', style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                    color: AppColors.primary, fontSize: 15)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Success/error banners
            if (state.successMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.successSurface, borderRadius: AppRadius.md),
                child: Text(state.successMessage!, style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 13, color: AppColors.success)),
              ).animate().fade(),
            if (state.error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.errorSurface, borderRadius: AppRadius.md),
                child: Text(state.error!, style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 13, color: AppColors.error)),
              ).animate().shake(),

            // ── Avatar section ──
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primarySurface,
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    child: const Icon(Icons.person_rounded, size: 48, color: AppColors.primary),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 30, height: 30,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Bio ──
            _FieldLabel('Biographie'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bioCtrl,
              maxLines: 4,
              maxLength: 500,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Parlez de votre expérience, vos compétences, ce qui vous distingue…',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // ── Location ──
            _FieldLabel('Localisation'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextFormField(
                controller: _cityCtrl,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                decoration: const InputDecoration(hintText: 'Ville'),
                validator: (v) => v!.trim().isEmpty ? 'Requis' : null,
              )),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(
                controller: _distCtrl,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                decoration: const InputDecoration(hintText: 'Quartier'),
              )),
            ]),
            const SizedBox(height: 20),

            // ── Experience ──
            _FieldLabel('Niveau d\'expérience'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _experience,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textPrimary),
              decoration: const InputDecoration(),
              items: const [
                DropdownMenuItem(value: 'beginner',     child: Text('Débutant (< 1 an)')),
                DropdownMenuItem(value: 'intermediate', child: Text('Intermédiaire (1–3 ans)')),
                DropdownMenuItem(value: 'experienced',  child: Text('Expérimenté (3–5 ans)')),
                DropdownMenuItem(value: 'expert',       child: Text('Expert (5+ ans)')),
              ],
              onChanged: (v) => setState(() => _experience = v!),
            ),
            const SizedBox(height: 20),

            // ── Rates ──
            _FieldLabel('Tarifs (FCFA)'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextFormField(
                controller: _rateCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                decoration: const InputDecoration(hintText: 'Tarif horaire'),
              )),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(
                controller: _minCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                decoration: const InputDecoration(hintText: 'Tarif minimum'),
              )),
            ]),
            const SizedBox(height: 20),

            // ── Categories ──
            if (categories.isNotEmpty) ...[
              _FieldLabel('Mes spécialités'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: categories.map((cat) {
                  final id = cat['id']?.toString() ?? '';
                  final selected = _selectedCategories.contains(id);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected) _selectedCategories.remove(id);
                      else _selectedCategories.add(id);
                    }),
                    child: AnimatedContainer(
                      duration: 180.ms,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primarySurface : AppColors.surface,
                        borderRadius: AppRadius.full,
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        '${cat['icon'] ?? '🔧'} ${cat['name']}',
                        style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500,
                          color: selected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],

            AppButton(label: 'Enregistrer les modifications', isLoading: state.isSaving, onPressed: _save),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(
    fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  ));
}
