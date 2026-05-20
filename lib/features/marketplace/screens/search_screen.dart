import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/widgets/inputs/app_inputs.dart';
import '../../../core/widgets/layout/app_shared_widgets.dart';
import '../../../core/widgets/states/ux_states.dart';
import '../../../core/widgets/buttons/app_buttons.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/navigation/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────
final _searchQueryProvider = StateProvider<String>((ref) => '');
final _selectedCategoryProvider = StateProvider<String?>((ref) => null);
final _selectedFiltersProvider = StateProvider<Set<String>>((ref) => {'Tous'});
final _searchLoadingProvider = StateProvider<bool>((ref) => false);

final _filteredArtisansProvider = Provider<List<User>>((ref) {
  final query = ref.watch(_searchQueryProvider).toLowerCase();
  final category = ref.watch(_selectedCategoryProvider);
  final filters = ref.watch(_selectedFiltersProvider);

  var list = MockData.topArtisans;

  if (query.isNotEmpty) {
    list = list
        .where((a) =>
            a.name.toLowerCase().contains(query) ||
            (a.specialty?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  if (category != null) {
    list = list
        .where((a) =>
            a.specialty?.toLowerCase().contains(category.toLowerCase()) ?? false)
        .toList();
  }

  if (filters.contains('Note 4.5+')) {
    list = list.where((a) => a.rating >= 4.5).toList();
  }
  if (filters.contains('Certifiés')) {
    list = list.where((a) => a.isCertified).toList();
  }

  return list;
});

// ─────────────────────────────────────────────────────────────────────────────
// SearchScreen
// ─────────────────────────────────────────────────────────────────────────────
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery, this.category});
  final String? initialQuery;
  final String? category;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;
  final _scrollController = ScrollController();
  bool _isSticky = false;

  static const _filterChips = [
    'Tous', 'Disponible', 'Près de moi', 'Note 4.5+', 'Certifiés', 'Prix ↑', 'Prix ↓',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');

    if (widget.initialQuery != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(_searchQueryProvider.notifier).state = widget.initialQuery!;
      });
    }
    if (widget.category != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(_selectedCategoryProvider.notifier).state = widget.category;
      });
    }

    _scrollController.addListener(() {
      final sticky = _scrollController.offset > 20;
      if (sticky != _isSticky) setState(() => _isSticky = sticky);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String q) async {
    ref.read(_searchQueryProvider.notifier).state = q;
    ref.read(_searchLoadingProvider.notifier).state = true;
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) ref.read(_searchLoadingProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final artisans = ref.watch(_filteredArtisansProvider);
    final isLoading = ref.watch(_searchLoadingProvider);
    final selectedFilters = ref.watch(_selectedFiltersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Sticky Header ──────────────────────────────────────────────
            AnimatedContainer(
              duration: AppAnimations.fast,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border(
                  bottom: BorderSide(
                    color: _isSticky ? AppColors.outlineVariant : Colors.transparent,
                  ),
                ),
                boxShadow: _isSticky
                    ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]
                    : null,
              ),
              child: Column(
                children: [
                  // Search bar row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.sm, AppSpacing.compact, AppSpacing.marginMobile, AppSpacing.compact),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: AppColors.onSurfaceVariant,
                          onPressed: () => context.pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        ),
                        Expanded(
                          child: SearchField(
                            controller: _searchController,
                            autofocus: widget.initialQuery == null,
                            onChanged: _onSearch,
                            onSubmitted: _onSearch,
                            onFilterTap: () => _showFilterSheet(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter chips
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(
                          left: AppSpacing.marginMobile, right: AppSpacing.marginMobile, bottom: 8),
                      itemCount: _filterChips.length,
                      itemBuilder: (_, i) {
                        final chip = _filterChips[i];
                        final selected = selectedFilters.contains(chip);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: AppFilterChip(
                            label: chip,
                            selected: selected,
                            onSelected: (v) {
                              final filters = {...selectedFilters};
                              if (chip == 'Tous') {
                                filters.clear();
                                filters.add('Tous');
                              } else {
                                filters.remove('Tous');
                                if (v) filters.add(chip); else filters.remove(chip);
                                if (filters.isEmpty) filters.add('Tous');
                              }
                              ref.read(_selectedFiltersProvider.notifier).state = filters;
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Result count bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: AppAnimations.fast,
                      child: Text(
                        key: ValueKey(artisans.length),
                        isLoading ? 'Recherche en cours…' : '${artisans.length} artisan${artisans.length > 1 ? 's' : ''} trouvé${artisans.length > 1 ? 's' : ''} • Bamako',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showSortSheet(context),
                    child: Row(
                      children: [
                        const Icon(Icons.sort_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('Trier', style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w600,
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Results ───────────────────────────────────────────────────
            Expanded(
              child: isLoading
                  ? _SearchShimmer()
                  : artisans.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.search_off_rounded,
                          title: 'Aucun résultat',
                          subtitle: 'Essaie un autre service ou élargis ta zone de recherche.',
                          actionLabel: 'Effacer les filtres',
                          onAction: () {
                            _searchController.clear();
                            ref.read(_searchQueryProvider.notifier).state = '';
                            ref.read(_selectedFiltersProvider.notifier).state = {'Tous'};
                            ref.read(_selectedCategoryProvider.notifier).state = null;
                          },
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(
                              left: AppSpacing.marginMobile,
                              right: AppSpacing.marginMobile,
                              bottom: AppSpacing.generous),
                          itemCount: artisans.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _ArtisanSearchCard(
                              artisan: artisans[i],
                              index: i,
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterBottomSheet(),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Artisan Search Card — premium layout matching Stitch design
// ─────────────────────────────────────────────────────────────────────────────
class _ArtisanSearchCard extends StatefulWidget {
  const _ArtisanSearchCard({required this.artisan, required this.index});
  final User artisan;
  final int index;

  @override
  State<_ArtisanSearchCard> createState() => _ArtisanSearchCardState();
}

class _ArtisanSearchCardState extends State<_ArtisanSearchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.98)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.artisan;
    // Stagger animation based on index
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + widget.index * 60),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - v)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: _ctrl.reverse,
        onTap: () => context.push('/artisan/${a.id}'),
        child: AnimatedBuilder(
          animation: _scale,
          builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with online dot
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AppAvatar(
                          initials: _initials(a.name),
                          size: AppSpacing.avatarLg,
                          showVerified: a.isVerified,
                        ),
                        Positioned(
                          bottom: 2,
                          left: 2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.surfaceContainerLowest, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.compact),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(a.name,
                                    style: AppTypography.bodyLarge
                                        .copyWith(fontWeight: FontWeight.w700),
                                    overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 6),
                              if (a.isPremium) const PremiumBadge(label: 'Top', small: true)
                              else if (a.isVerified) const VerifiedBadge(small: true),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(a.specialty ?? '',
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 6),
                          Row(children: [
                            StarRating(
                                rating: a.rating, size: 12, showValue: true,
                                showCount: true, count: a.reviewCount),
                            const SizedBox(width: 8),
                            const Icon(Icons.location_on_outlined,
                                size: 12, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 2),
                            Text('${(widget.index * 0.8 + 0.5).toStringAsFixed(1)} km',
                                style: AppTypography.caption.copyWith(
                                    color: AppColors.onSurfaceVariant, letterSpacing: 0)),
                            const SizedBox(width: 8),
                            const Icon(Icons.task_alt_rounded,
                                size: 12, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 2),
                            Text('${a.completedMissions} missions',
                                style: AppTypography.caption.copyWith(
                                    color: AppColors.onSurfaceVariant, letterSpacing: 0)),
                          ]),
                        ],
                      ),
                    ),
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(3500 + widget.index * 1500)} FCFA',
                          style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                        Text('/ heure',
                            style: AppTypography.caption.copyWith(
                                color: AppColors.onSurfaceVariant, letterSpacing: 0)),
                      ],
                    ),
                  ],
                ),

                // Skills tags
                if (a.skills != null && a.skills!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 26,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: a.skills!.length.clamp(0, 4),
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: AppRadius.radiusFull,
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Text(a.skills![i],
                              style: AppTypography.caption.copyWith(
                                  color: AppColors.onSurfaceVariant, letterSpacing: 0)),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.compact),
                // Action row
                Row(children: [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () => context.push('/artisan/${a.id}'),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: AppRadius.radiusFull,
                        ),
                        child: Center(
                          child: Text('Contacter',
                              style: AppTypography.bodySmall
                                  .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _isFavorited = !_isFavorited),
                    child: AnimatedContainer(
                      duration: AppAnimations.fast,
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _isFavorited
                            ? AppColors.errorContainer
                            : AppColors.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Icon(
                        _isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 18,
                        color: _isFavorited ? AppColors.error : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.push('/chat/conv-${a.id}'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: const Icon(Icons.chat_bubble_outline_rounded,
                          size: 18, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.substring(0, 2).toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  double _minRating = 0;
  RangeValues _priceRange = const RangeValues(0, 50000);
  bool _verifiedOnly = false;
  bool _availableNow = true;
  String _sortBy = 'rating';
  double _maxDistance = 10;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.bottomSheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: AppRadius.radiusFull,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
            child: Row(
              children: [
                Text('Filtres', style: AppTypography.h3),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _minRating = 0;
                      _priceRange = const RangeValues(0, 50000);
                      _verifiedOnly = false;
                      _availableNow = true;
                      _sortBy = 'rating';
                      _maxDistance = 10;
                    });
                  },
                  child: Text('Réinitialiser',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.error, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Note minimale
                  Text('Note minimale', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [0.0, 3.0, 4.0, 4.5, 5.0].map((v) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _minRating = v),
                        child: AnimatedContainer(
                          duration: AppAnimations.fast,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _minRating == v ? AppColors.primary : AppColors.surfaceContainerHighest,
                            borderRadius: AppRadius.radiusFull,
                            border: Border.all(
                              color: _minRating == v ? AppColors.primary : AppColors.outlineVariant,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (v > 0) ...[
                                Icon(Icons.star_rounded, size: 14,
                                    color: _minRating == v ? Colors.white : AppColors.primaryContainer),
                                const SizedBox(width: 3),
                              ],
                              Text(v == 0 ? 'Tous' : v.toString(),
                                  style: AppTypography.bodySmall.copyWith(
                                      color: _minRating == v ? Colors.white : AppColors.onSurface,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Distance
                  Row(children: [
                    Text('Distance max', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('${_maxDistance.toInt()} km',
                        style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ]),
                  Slider(
                    value: _maxDistance,
                    min: 1,
                    max: 30,
                    divisions: 29,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.outlineVariant,
                    onChanged: (v) => setState(() => _maxDistance = v),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Toggles
                  _FilterToggle(
                    label: 'Disponible maintenant',
                    value: _availableNow,
                    onChanged: (v) => setState(() => _availableNow = v),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _FilterToggle(
                    label: 'Prestataires vérifiés uniquement',
                    value: _verifiedOnly,
                    onChanged: (v) => setState(() => _verifiedOnly = v),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Tarif range
                  Row(children: [
                    Text('Tarif horaire', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('${_priceRange.start.toInt()} – ${_priceRange.end.toInt()} FCFA',
                        style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ]),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 50000,
                    divisions: 50,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.outlineVariant,
                    onChanged: (v) => setState(() => _priceRange = v),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // Apply button
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile, 0, AppSpacing.marginMobile, AppSpacing.lg),
            child: PrimaryButton(
              label: 'Appliquer les filtres',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterToggle extends StatelessWidget {
  const _FilterToggle({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTypography.bodyMedium)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _SortSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final options = [
      (Icons.star_rounded, 'Meilleure note', 'rating'),
      (Icons.location_on_rounded, 'Plus proche', 'distance'),
      (Icons.arrow_upward_rounded, 'Prix croissant', 'price_asc'),
      (Icons.arrow_downward_rounded, 'Prix décroissant', 'price_desc'),
      (Icons.task_alt_rounded, 'Plus de missions', 'missions'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.bottomSheet,
      ),
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Center(
            child: Container(
              width: 32, height: 4,
              decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: AppRadius.radiusFull),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Trier par', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          ...options.map((o) => ListTile(
                leading: Icon(o.$1, color: AppColors.primary),
                title: Text(o.$2, style: AppTypography.bodyMedium),
                onTap: () => Navigator.pop(context),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
              )),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _SearchShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      itemCount: 5,
      itemBuilder: (_, i) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.sm),
        child: ArtisanCardShimmer(),
      ),
    );
  }
}
