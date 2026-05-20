import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/review_card.dart';

class MyProfilePage extends ConsumerWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myProfileProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (state.profile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: NetworkErrorWidget(onRetry: () => ref.read(myProfileProvider.notifier).load()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            SliverAppBar(
              backgroundColor: AppColors.surface,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => _showSettingsMenu(context, ref),
                ),
              ],
              title: const Text('Mon Profil'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Profil'),
                  Tab(text: 'Avis'),
                  Tab(text: 'Portfolio'),
                ],
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
                unselectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              // Tab 1: Profile info
              _ProfileTab(profile: state.profile!, ref: ref),

              // Tab 2: Reviews
              _ReviewsTab(reviews: state.reviews),

              // Tab 3: Portfolio
              _PortfolioTab(profile: state.profile!),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: AppRadius.full),
            ),
            const SizedBox(height: 20),
            _SettingsTile(
              icon: Icons.edit_outlined, label: 'Modifier le profil',
              onTap: () { Navigator.pop(context); context.push('/profile/edit'); },
            ),
            _SettingsTile(
              icon: Icons.notifications_outlined, label: 'Notifications',
              onTap: () { Navigator.pop(context); context.push(AppRoutes.notifications); },
            ),
            _SettingsTile(
              icon: Icons.help_outline_rounded, label: 'Aide & Support',
              onTap: () {},
            ),
            const Divider(),
            _SettingsTile(
              icon: Icons.logout_rounded, label: 'Se déconnecter',
              color: AppColors.error,
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.login);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final Map<String, dynamic> profile;
  final WidgetRef ref;
  const _ProfileTab({required this.profile, required this.ref});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(
      children: [
        ProfileHeader(
          profile: profile,
          isOwnProfile: true,
          onEditTap: () => context.push('/profile/edit'),
        ),
        ProfileStatsCard(profile: profile),

        // Availability quick toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.lg,
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.subtle,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Disponibilité', style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: 12),
                Row(
                  children: ['available', 'busy', 'unavailable'].map((s) {
                    final current = profile['availability'] as String? ?? 'available';
                    final isSelected = current == s;
                    final label  = s == 'available' ? 'Disponible' : s == 'busy' ? 'Occupé' : 'Indisponible';
                    final color  = s == 'available' ? AppColors.success : s == 'busy' ? AppColors.warning : AppColors.textTertiary;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => ref.read(myProfileProvider.notifier).updateAvailability(s),
                        child: AnimatedContainer(
                          duration: 200.ms,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withOpacity(0.12) : AppColors.surfaceVariant,
                            borderRadius: AppRadius.md,
                            border: Border.all(
                              color: isSelected ? color : AppColors.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? color : AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _ReviewsTab extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;
  const _ReviewsTab({required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const EmptyState(
        emoji: '⭐',
        title: 'Aucun avis pour l\'instant',
        subtitle: 'Vos avis apparaîtront ici après la fin de vos missions.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (_, i) => ReviewCard(review: reviews[i])
          .animate(delay: (i * 60).ms).slideY(begin: 0.1).fade(),
    );
  }
}

class _PortfolioTab extends StatelessWidget {
  final Map<String, dynamic> profile;
  const _PortfolioTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final items = (profile['portfolio'] as List? ?? []).cast<Map<String, dynamic>>();
    if (items.isEmpty) {
      return EmptyState(
        emoji: '🖼️',
        title: 'Portfolio vide',
        subtitle: 'Ajoutez des photos de vos réalisations pour attirer plus de clients.',
        buttonLabel: 'Ajouter une photo',
        onAction: () {},
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => ClipRRect(
        borderRadius: AppRadius.lg,
        child: items[i]['image'] != null
            ? Image.network(items[i]['image'] as String, fit: BoxFit.cover)
            : Container(
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.image_outlined, size: 40, color: AppColors.textTertiary),
              ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _SettingsTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
    title: Text(label, style: TextStyle(
      fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w500,
      color: color ?? AppColors.textPrimary,
    )),
    trailing: color == null
        ? const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary)
        : null,
    onTap: onTap,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
  );
}
