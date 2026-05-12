import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/network/api_service.dart';

class JobCreatePage extends ConsumerStatefulWidget {
  const JobCreatePage({super.key});
  @override
  ConsumerState<JobCreatePage> createState() => _JobCreatePageState();
}

class _JobCreatePageState extends ConsumerState<JobCreatePage> {
  final _formKey    = GlobalKey<FormState>();
  final _titleCtrl  = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _cityCtrl   = TextEditingController(text: 'Bamako');
  final _distCtrl   = TextEditingController();
  final _budMinCtrl = TextEditingController();
  final _budMaxCtrl = TextEditingController();

  String  _jobType   = 'mission';
  String  _urgency   = 'low';
  String? _categoryId;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading    = false;
  bool _isSaving     = false;
  String? _error;

  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getCategories();
      setState(() {
        _categories = data.cast<Map<String, dynamic>>();
        _isLoading  = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose(); _cityCtrl.dispose();
    _distCtrl.dispose();  _budMinCtrl.dispose(); _budMaxCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSaving = true; _error = null; });
    try {
      final job = await _api.createJob({
        'title':       _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'job_type':    _jobType,
        'urgency':     _urgency,
        'city':        _cityCtrl.text.trim(),
        'district':    _distCtrl.text.trim(),
        if (_budMinCtrl.text.isNotEmpty) 'budget_min': int.parse(_budMinCtrl.text.trim()),
        if (_budMaxCtrl.text.isNotEmpty) 'budget_max': int.parse(_budMaxCtrl.text.trim()),
        if (_categoryId != null) 'category_id': _categoryId,
      });
      if (mounted) {
        context.pop();
        context.push('/jobs/${job['id']}');
      }
    } catch (e) {
      setState(() { _isSaving = false; _error = 'Erreur lors de la création. Réessayez.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Publier une mission'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : const Text('Publier', style: TextStyle(fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 15)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // Error banner
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.errorSurface, borderRadius: AppRadius.md),
                child: Text(_error!, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.error)),
              ).animate().shake(),

            // ── Title ──
            _Label('Titre de la mission *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(hintText: 'Ex: Plombier pour réparation robinet urgent'),
              validator: (v) => v!.trim().length < 5 ? 'Titre trop court (min 5 caractères)' : null,
            ),

            const SizedBox(height: 20),

            // ── Category ──
            _Label('Catégorie'),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                : Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _categoryId == cat['id']?.toString();
                      return GestureDetector(
                        onTap: () => setState(() => _categoryId = isSelected ? null : cat['id']?.toString()),
                        child: AnimatedContainer(
                          duration: 180.ms,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primarySurface : AppColors.surface,
                            borderRadius: AppRadius.full,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            '${cat['icon'] ?? '🔧'} ${cat['name']}',
                            style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 20),

            // ── Job Type ──
            _Label('Type de mission *'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _jobType,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textPrimary),
              decoration: const InputDecoration(),
              items: const [
                DropdownMenuItem(value: 'mission',    child: Text('Mission ponctuelle')),
                DropdownMenuItem(value: 'full_time',  child: Text('CDI (plein temps)')),
                DropdownMenuItem(value: 'part_time',  child: Text('Temps partiel')),
                DropdownMenuItem(value: 'contract',   child: Text('CDD / Contrat')),
                DropdownMenuItem(value: 'freelance',  child: Text('Freelance')),
                DropdownMenuItem(value: 'internship', child: Text('Stage')),
              ],
              onChanged: (v) => setState(() => _jobType = v!),
            ),

            const SizedBox(height: 20),

            // ── Urgency ──
            _Label('Urgence *'),
            const SizedBox(height: 8),
            Row(
              children: [
                _UrgencyChip(label: '🟢 Flexible',  value: 'low',    selected: _urgency == 'low',    onTap: () => setState(() => _urgency = 'low')),
                const SizedBox(width: 8),
                _UrgencyChip(label: '🟡 Sous 48h',  value: 'medium', selected: _urgency == 'medium', onTap: () => setState(() => _urgency = 'medium')),
                const SizedBox(width: 8),
                _UrgencyChip(label: '🔴 Urgent',    value: 'high',   selected: _urgency == 'high',   onTap: () => setState(() => _urgency = 'high')),
              ],
            ),

            const SizedBox(height: 20),

            // ── Description ──
            _Label('Description *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              maxLines: 5,
              maxLength: 2000,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Décrivez votre besoin en détail : contexte, attentes, matériaux fournis…',
                alignLabelWithHint: true,
              ),
              validator: (v) => v!.trim().length < 20 ? 'Description trop courte (min 20 caractères)' : null,
            ),

            const SizedBox(height: 20),

            // ── Location ──
            _Label('Localisation *'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityCtrl,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    decoration: const InputDecoration(hintText: 'Ville'),
                    validator: (v) => v!.trim().isEmpty ? 'Requis' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _distCtrl,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    decoration: const InputDecoration(hintText: 'Quartier (optionnel)'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Budget ──
            _Label('Budget (FCFA)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _budMinCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    decoration: const InputDecoration(hintText: 'Min (ex: 5000)'),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('–', style: TextStyle(fontSize: 20, color: AppColors.textTertiary))),
                Expanded(
                  child: TextFormField(
                    controller: _budMaxCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    decoration: const InputDecoration(hintText: 'Max (ex: 25000)'),
                    validator: (v) {
                      final min = int.tryParse(_budMinCtrl.text);
                      final max = int.tryParse(v ?? '');
                      if (min != null && max != null && max < min) return 'Max < Min';
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            AppButton(label: 'Publier la mission', isLoading: _isSaving, onPressed: _submit),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(
    fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  ));
}

class _UrgencyChip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  const _UrgencyChip({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 180.ms,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: AppRadius.md,
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(
          fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600,
          color: selected ? AppColors.primary : AppColors.textSecondary,
        )),
      ),
    ),
  );
}
