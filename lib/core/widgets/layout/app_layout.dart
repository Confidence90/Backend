import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_animations.dart';
import '../../constants/app_constants.dart';
import '../layout/app_shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppScaffold — base scaffold with consistent chrome
// ─────────────────────────────────────────────────────────────────────────────
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.topBar,
    this.bottomNav,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
  });

  final Widget body;
  final PreferredSizeWidget? topBar;
  final Widget? bottomNav;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: topBar,
      body: body,
      bottomNavigationBar: bottomNav,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTopBar — standard top app bar
// ─────────────────────────────────────────────────────────────────────────────
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBack = true,
    this.centerTitle = false,
    this.actions,
    this.backgroundColor,
    this.onBack,
    this.elevation = 0,
  });

  final String? title;
  final Widget? titleWidget;
  final bool showBack;
  final bool centerTitle;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final VoidCallback? onBack;
  final double elevation;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.topBarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest),
      elevation: elevation,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.outlineVariant.withOpacity(0.4),
      surfaceTintColor: Colors.transparent,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: colorScheme.onSurface,
              onPressed: onBack ?? () => context.pop(),
              tooltip: 'Retour',
            )
          : null,
      automaticallyImplyLeading: showBack,
      centerTitle: centerTitle,
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: AppTypography.h3.copyWith(color: colorScheme.onSurface),
                )
              : null),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: isDark ? AppColors.darkOutline : AppColors.outlineVariant,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BaaraLinkAppBar — branded top bar with logo + avatar
// ─────────────────────────────────────────────────────────────────────────────
class BaaraLinkAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BaaraLinkAppBar({
    super.key,
    required this.userInitials,
    this.onNotificationTap,
    this.onAvatarTap,
    this.notificationCount = 0,
    this.showMenuIcon = true,
  });

  final String userInitials;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final int notificationCount;
  final bool showMenuIcon;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.topBarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkOutline : AppColors.outlineVariant,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
          child: Row(
            children: [
              // Menu or BaaraLink logo
              if (showMenuIcon) ...[
                IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  color: AppColors.primary,
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: AppSpacing.compact),
              ],
              Text(
                AppConstants.appName,
                style: AppTypography.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              // Notification bell
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    color: colorScheme.onSurfaceVariant,
                    onPressed: onNotificationTap,
                    iconSize: 22,
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 6),
              // Avatar
              GestureDetector(
                onTap: onAvatarTap,
                child: AppAvatar(
                  initials: userInitials,
                  size: 36,
                  borderColor: AppColors.primaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ProviderBottomNav — 5-tab nav for provider flow
// ─────────────────────────────────────────────────────────────────────────────
class ProviderBottomNav extends StatelessWidget {
  const ProviderBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Accueil'),
    _NavItem(icon: Icons.task_alt_outlined, activeIcon: Icons.task_alt_rounded, label: 'Missions'),
    _NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Messages'),
    _NavItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded, label: 'Wallet'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) => _BaaraBottomNav(
    items: _items,
    currentIndex: currentIndex,
    onTap: onTap,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ClientBottomNav — 5-tab nav for client flow
// ─────────────────────────────────────────────────────────────────────────────
class ClientBottomNav extends StatelessWidget {
  const ClientBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Accueil'),
    _NavItem(icon: Icons.search_outlined, activeIcon: Icons.search_rounded, label: 'Recherche'),
    _NavItem(icon: Icons.add_circle_outline_rounded, activeIcon: Icons.add_circle_rounded, label: 'Mission'),
    _NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Messages'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) => _BaaraBottomNav(
    items: _items,
    currentIndex: currentIndex,
    onTap: onTap,
    addButtonIndex: 2,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// _BaaraBottomNav — internal implementation
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem {
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _BaaraBottomNav extends StatelessWidget {
  const _BaaraBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.addButtonIndex,
  });

  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int? addButtonIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: isDark ? AppColors.darkOutline : AppColors.outlineVariant),
        ),
        boxShadow: AppShadows.bottomNavShadow,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = i == currentIndex;
              final isAdd = i == addButtonIndex;

              if (isAdd) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedContainer(
                        duration: AppAnimations.fast,
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                );
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: AppAnimations.fast,
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          key: ValueKey(isActive),
                          color: isActive
                              ? AppColors.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: AppTypography.overline.copyWith(
                          color: isActive
                              ? AppColors.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
