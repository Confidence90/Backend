import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/review_card.dart';

class ProfileViewPage extends ConsumerWidget {
  final String profileId;
  const ProfileViewPage({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(providerProfileProvider(profileId));

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (state.profile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.surface),
        body: NetworkErrorWidget(
          onRetry: () => ref.read(providerProfileProvider(profileId).notifier).load(),
        ),
      );
    }

    final profile = state.profile!;
    final portfolio = (profile['portfolio'] as List? ?? []).cast<Map<String, dynamic>>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: DefaultTabController(
        length: portfolio.isNotEmpty ? 3 : 2,
        child: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            SliverAppBar(
              backgroundColor: AppColors.surface,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
              ],
              bottom: TabBar(
                tabs: [
                  const Tab(text: 'Profil'),
                  const Tab(text: 'Avis'),
                  if (portfolio.isNotEmpty) const Tab(text: 'Portfolio'),
                ],
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              // ── Tab 1: Profile ──
              SingleChildScrollView(
                child: Column(
                  children: [
                    ProfileHeader(
                      profile: profile,
                      isOwnProfile: false,
                      onContactTap: () {
                        // Navigate to chat with this provider
                        context.push('/chat/${profile['user']}');
                      },
                    ),
                    ProfileStatsCard(profile: profile),

                    // Categories & available jobs
                    if ((profile['categories'] as List? ?? []).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: Container(
                          width: double.infinity,
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
                              const Text('Disponibilité & tarif', style: TextStyle(
                                fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600,
                              )),
                              const SizedBox(height: 12),
                              Row(children: [
                                const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(_availabilityLabel(profile['availability'] as String? ?? 'available'),
                                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                                const Spacer(),
                                if (profile['hourly_rate'] != null)
                                  Text('${profile['hourly_rate']} FCFA/h', style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary,
                                  )),
                              ]),
                              if (profile['min_rate'] != null) ...[
                                const SizedBox(height: 6),
                                Text('Tarif minimum : ${profile['min_rate']} FCFA', style: const TextStyle(
                                  fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary,
                                )),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Tab 2: Reviews ──
              state.reviews.isEmpty
                  ? const EmptyState(emoji: '⭐', title: 'Aucun avis', subtitle: 'Ce prestataire n\'a pas encore reçu d\'avis.')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.reviews.length,
                      itemBuilder: (_, i) => ReviewCard(review: state.reviews[i])
                          .animate(delay: (i * 60).ms).slideY(begin: 0.1).fade(),
                    ),

              // ── Tab 3: Portfolio (if any) ──
              if (portfolio.isNotEmpty)
                GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1,
                  ),
                  itemCount: portfolio.length,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () {},
                    child: ClipRRect(
                      borderRadius: AppRadius.lg,
                      child: portfolio[i]['image'] != null
                          ? Image.network(portfolio[i]['image'] as String, fit: BoxFit.cover)
                          : Container(color: AppColors.surfaceVariant,
                              child: const Icon(Icons.image_outlined, size: 40, color: AppColors.textTertiary)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _availabilityLabel(String s) {
    switch (s) {
      case 'available': return 'Disponible maintenant';
      case 'busy':      return 'Occupé en ce moment';
      default:          return 'Indisponible';
    }
  }
}
