import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/jobs_provider.dart';

class JobDetailPage extends ConsumerWidget {
  final String jobId;
  const JobDetailPage({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(jobDetailProvider(jobId));
    final currentUser = ref.watch(currentUserProvider);

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.surface),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (state.error != null || state.job == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.surface),
        body: NetworkErrorWidget(
          onRetry: () => ref.read(jobDetailProvider(jobId).notifier).fetchJob(),
        ),
      );
    }

    final job       = state.job!;
    final isClient  = currentUser?['role'] == 'client';
    final isProvider = currentUser?['role'] == 'provider';
    final isOwner   = job['client']?.toString() == currentUser?['id']?.toString();
    final jobStatus = job['status'] as String? ?? 'open';
    final hasApplied = job['user_application'] != null;
    final userApp   = job['user_application'] as Map<String, dynamic>?;
    final assigned  = job['assigned_to'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ──
          SliverAppBar(
            backgroundColor: AppColors.surface,
            expandedHeight: 0,
            floating: true,
            snap: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Hero card ──
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + urgency row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: AppRadius.full,
                            ),
                            child: Text(
                              job['category']?['name'] as String? ?? 'Général',
                              style: const TextStyle(
                                fontFamily: 'Poppins', fontSize: 12,
                                fontWeight: FontWeight.w600, color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge.urgency(job['urgency'] as String? ?? 'low'),
                          const Spacer(),
                          StatusBadge.jobStatus(jobStatus),
                        ],
                      ).animate().fade(duration: 300.ms),

                      const SizedBox(height: 16),

                      Text(
                        job['title'] as String? ?? '',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ).animate(delay: 60.ms).slideY(begin: 0.1).fade(),

                      const SizedBox(height: 12),

                      // Client info
                      Row(
                        children: [
                          UserAvatar(
                            name: job['client_name'] as String? ?? '?',
                            size: 36,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job['client_name'] as String? ?? '',
                                style: const TextStyle(
                                  fontFamily: 'Poppins', fontSize: 13,
                                  fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                _timeAgo(job['created_at'] as String?),
                                style: const TextStyle(
                                  fontFamily: 'Poppins', fontSize: 11, color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ).animate(delay: 100.ms).fade(),

                      const SizedBox(height: 20),

                      // Stats row
                      _StatsRow(job: job),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Description ──
                _Section(
                  title: 'Description',
                  child: Text(
                    job['description'] as String? ?? '',
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 14,
                      color: AppColors.textSecondary, height: 1.7,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Details ──
                _Section(
                  title: 'Détails',
                  child: Column(
                    children: [
                      _DetailRow(icon: Icons.location_on_outlined, label: 'Localisation',
                        value: _buildLocation(job)),
                      _DetailRow(icon: Icons.calendar_today_outlined, label: 'Date de début',
                        value: job['start_date'] as String? ?? 'À définir'),
                      if (job['duration_hours'] != null)
                        _DetailRow(icon: Icons.timer_outlined, label: 'Durée estimée',
                          value: '${job['duration_hours']}h'),
                      _DetailRow(icon: Icons.work_outline_rounded, label: 'Type',
                        value: _jobTypeLabel(job['job_type'] as String?)),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Budget ──
                if (job['budget_min'] != null || job['budget_max'] != null)
                  _Section(
                    title: 'Budget',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: AppRadius.lg,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.payments_outlined, color: AppColors.primary, size: 24),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _buildBudgetText(job['budget_min'] as int?, job['budget_max'] as int?),
                                style: const TextStyle(
                                  fontFamily: 'Poppins', fontSize: 18,
                                  fontWeight: FontWeight.w700, color: AppColors.primary,
                                ),
                              ),
                              const Text('FCFA', style: TextStyle(
                                fontFamily: 'Poppins', fontSize: 12, color: AppColors.primaryDark,
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // ── Applications (owner view) ──
                if (isOwner && (job['applications'] as List? ?? []).isNotEmpty)
                  _Section(
                    title: 'Candidatures (${(job['applications'] as List).length})',
                    child: Column(
                      children: (job['applications'] as List)
                          .cast<Map<String, dynamic>>()
                          .map((app) => _ApplicationTile(
                                app: app,
                                jobId: jobId,
                                jobStatus: jobStatus,
                                ref: ref,
                              ))
                          .toList(),
                    ),
                  ),

                // ── User's own application status ──
                if (hasApplied && !isOwner)
                  _Section(
                    title: 'Votre candidature',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _appStatusColor(userApp?['status'] as String?).withOpacity(0.1),
                        borderRadius: AppRadius.lg,
                        border: Border.all(
                          color: _appStatusColor(userApp?['status'] as String?).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(_appStatusIcon(userApp?['status'] as String?),
                            color: _appStatusColor(userApp?['status'] as String?), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _appStatusLabel(userApp?['status'] as String?),
                              style: TextStyle(
                                fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600,
                                color: _appStatusColor(userApp?['status'] as String?),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 120), // Bottom padding for sticky button
              ],
            ),
          ),
        ],
      ),

      // ── Sticky bottom button ──
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: AppShadows.elevated,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: _buildBottomAction(
          context: context,
          ref: ref,
          state: state,
          isOwner: isOwner,
          isProvider: isProvider,
          hasApplied: hasApplied,
          jobStatus: jobStatus,
          job: job,
        ),
      ),
    );
  }

  Widget _buildBottomAction({
    required BuildContext context,
    required WidgetRef ref,
    required JobDetailState state,
    required bool isOwner,
    required bool isProvider,
    required bool hasApplied,
    required String jobStatus,
    required Map<String, dynamic> job,
  }) {
    // Owner: complete button
    if (isOwner && jobStatus == 'in_progress') {
      return AppButton(
        label: 'Marquer comme terminée',
        isLoading: state.isCompleting,
        onPressed: () async {
          final ok = await ref.read(jobDetailProvider(jobId).notifier).complete();
          if (ok && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Mission terminée !'),
              backgroundColor: AppColors.success,
            ));
          }
        },
      );
    }

    // Owner: job open, no actions
    if (isOwner) {
      return OutlinedButton(
        onPressed: () {},
        child: Text('${job['applications_count'] ?? 0} candidature(s) reçue(s)'),
      );
    }

    // Provider already applied
    if (hasApplied) {
      return AppButton(
        label: 'Candidature envoyée',
        isOutlined: true,
        icon: Icons.check_circle_outline_rounded,
        onPressed: null,
        color: AppColors.success,
      );
    }

    // Provider can apply
    if (isProvider && jobStatus == 'open') {
      return AppButton(
        label: 'Postuler à cette mission',
        isLoading: state.isApplying,
        onPressed: () => _showApplyModal(context, ref),
      );
    }

    return const SizedBox.shrink();
  }

  void _showApplyModal(BuildContext context, WidgetRef ref) {
    final coverCtrl  = TextEditingController();
    final priceCtrl  = TextEditingController();
    final formKey    = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: AppRadius.full),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Postuler à cette mission', style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700,
                )),
                const SizedBox(height: 20),

                // Proposed price
                const Text('Votre tarif proposé (FCFA)', style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500,
                )),
                const SizedBox(height: 8),
                TextFormField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 15),
                  decoration: const InputDecoration(hintText: 'Ex: 25000'),
                ),

                const SizedBox(height: 16),

                // Cover letter
                const Text('Lettre de motivation (optionnel)', style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500,
                )),
                const SizedBox(height: 8),
                TextFormField(
                  controller: coverCtrl,
                  maxLines: 4,
                  maxLength: 500,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Décrivez brièvement pourquoi vous êtes le meilleur candidat…',
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 20),

                Consumer(builder: (ctx, ref, _) {
                  final s = ref.watch(jobDetailProvider(jobId));
                  return AppButton(
                    label: 'Envoyer ma candidature',
                    isLoading: s.isApplying,
                    onPressed: () async {
                      final price = int.tryParse(priceCtrl.text.trim());
                      final ok = await ref.read(jobDetailProvider(jobId).notifier).apply(
                        coverLetter: coverCtrl.text.trim(),
                        proposedPrice: price,
                      );
                      if (ok && ctx.mounted) {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Candidature envoyée ! 🎉'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return timeago.format(dt, locale: 'fr');
    } catch (_) {
      return '';
    }
  }

  String _buildLocation(Map<String, dynamic> job) {
    final district = job['district'] as String?;
    final city     = job['city']     as String? ?? 'Bamako';
    return district != null ? '$district, $city' : city;
  }

  String _buildBudgetText(int? min, int? max) {
    if (min != null && max != null) return '$min – $max';
    if (min != null) return 'À partir de $min';
    if (max != null) return 'Max $max';
    return 'À négocier';
  }

  String _jobTypeLabel(String? type) {
    const labels = {
      'mission': 'Mission ponctuelle',
      'full_time': 'CDI',
      'part_time': 'Temps partiel',
      'contract': 'CDD',
      'freelance': 'Freelance',
      'internship': 'Stage',
    };
    return labels[type] ?? 'Mission';
  }

  Color _appStatusColor(String? status) {
    switch (status) {
      case 'accepted':  return AppColors.success;
      case 'rejected':  return AppColors.error;
      case 'withdrawn': return AppColors.textTertiary;
      default:          return AppColors.warning;
    }
  }

  IconData _appStatusIcon(String? status) {
    switch (status) {
      case 'accepted':  return Icons.check_circle_rounded;
      case 'rejected':  return Icons.cancel_rounded;
      case 'withdrawn': return Icons.remove_circle_outline_rounded;
      default:          return Icons.hourglass_bottom_rounded;
    }
  }

  String _appStatusLabel(String? status) {
    switch (status) {
      case 'accepted':  return 'Votre candidature a été acceptée ! 🎉';
      case 'rejected':  return 'Candidature non retenue cette fois.';
      case 'withdrawn': return 'Candidature retirée.';
      default:          return 'Candidature en attente de réponse…';
    }
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surface,
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

class _StatsRow extends StatelessWidget {
  final Map<String, dynamic> job;
  const _StatsRow({required this.job});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _Stat(icon: Icons.location_on_outlined, label: job['city'] as String? ?? 'Bamako'),
      const SizedBox(width: 16),
      _Stat(icon: Icons.group_outlined,       label: '${job['applications_count'] ?? 0} candidat(s)'),
      const SizedBox(width: 16),
      _Stat(icon: Icons.access_time_rounded,  label: job['job_type'] == 'mission' ? 'Ponctuel' : 'Emploi'),
    ],
  );
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: AppColors.textTertiary),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(
        fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary,
      )),
    ],
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: AppRadius.sm),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textTertiary)),
            Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    ),
  );
}

class _ApplicationTile extends StatelessWidget {
  final Map<String, dynamic> app;
  final String jobId, jobStatus;
  final WidgetRef ref;
  const _ApplicationTile({required this.app, required this.jobId, required this.jobStatus, required this.ref});

  @override
  Widget build(BuildContext context) {
    final status = app['status'] as String? ?? 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          UserAvatar(name: app['applicant_name'] as String? ?? '?', size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app['applicant_name'] as String? ?? '',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600)),
                if (app['proposed_price'] != null)
                  Text('Tarif proposé : ${app['proposed_price']} FCFA',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                if ((app['cover_letter'] as String? ?? '').isNotEmpty)
                  Text(app['cover_letter'] as String, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Accept button if job still open
          if (status == 'pending' && jobStatus == 'open')
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: const Size(72, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
              ),
              child: const Text('Accepter'),
            )
          else
            StatusBadge.jobStatus(status),
        ],
      ),
    );
  }
}
