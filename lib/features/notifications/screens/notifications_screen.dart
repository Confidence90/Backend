import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/widgets/states/ux_states.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/providers/app_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    // Group by date bucket
    final today = notifications.where((n) => _isToday(n.createdAt)).toList();
    final yesterday = notifications.where((n) => _isYesterday(n.createdAt)).toList();
    final older = notifications.where((n) => !_isToday(n.createdAt) && !_isYesterday(n.createdAt)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
          color: AppColors.onSurface,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications', style: AppTypography.h3),
            if (unreadCount > 0)
              Text('$unreadCount non lu${unreadCount > 1 ? 's' : ''}',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.primary, letterSpacing: 0)),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
              child: Text('Tout lire',
                  style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: notifications.isEmpty
          ? EmptyStateWidget(
              icon: Icons.notifications_none_rounded,
              title: 'Aucune notification',
              subtitle: 'Vos notifications apparaîtront ici.',
            )
          : ListView(
              children: [
                if (today.isNotEmpty) ...[
                  _GroupHeader(label: 'Aujourd\'hui'),
                  ...today.map((n) => _NotificationTile(
                        notification: n,
                        onRead: () => ref.read(notificationsProvider.notifier).markRead(n.id),
                        onDismiss: () => ref.read(notificationsProvider.notifier).dismiss(n.id),
                      )),
                ],
                if (yesterday.isNotEmpty) ...[
                  _GroupHeader(label: 'Hier'),
                  ...yesterday.map((n) => _NotificationTile(
                        notification: n,
                        onRead: () => ref.read(notificationsProvider.notifier).markRead(n.id),
                        onDismiss: () => ref.read(notificationsProvider.notifier).dismiss(n.id),
                      )),
                ],
                if (older.isNotEmpty) ...[
                  _GroupHeader(label: 'Plus tôt'),
                  ...older.map((n) => _NotificationTile(
                        notification: n,
                        onRead: () => ref.read(notificationsProvider.notifier).markRead(n.id),
                        onDismiss: () => ref.read(notificationsProvider.notifier).dismiss(n.id),
                      )),
                ],
                const SizedBox(height: AppSpacing.generous),
              ],
            ),
    );
  }

  bool _isToday(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    } catch (_) {
      return false;
    }
  }

  bool _isYesterday(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      return dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day;
    } catch (_) {
      return false;
    }
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile, AppSpacing.md, AppSpacing.marginMobile, 4),
      child: Text(label,
          style: AppTypography.labelCaps.copyWith(
              color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onRead,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onRead;
  final VoidCallback onDismiss;

  static const _categoryConfig = <NotificationCategory, (IconData, Color, Color)>{
    NotificationCategory.payment: (Icons.payments_rounded, AppColors.success, AppColors.successContainer),
    NotificationCategory.mission: (Icons.task_alt_rounded, AppColors.tertiary, AppColors.secondaryContainer),
    NotificationCategory.review: (Icons.star_rounded, AppColors.primaryContainer, Color(0xFFFFF3E0)),
    NotificationCategory.message: (Icons.chat_bubble_rounded, AppColors.primary, AppColors.surfaceContainer),
    NotificationCategory.system: (Icons.info_rounded, AppColors.onSurfaceVariant, AppColors.surfaceContainerHighest),
  };

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor, iconBg) =
        _categoryConfig[notification.category] ?? _categoryConfig[NotificationCategory.system]!;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => onDismiss(),
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) onRead();
          if (notification.actionRoute != null) {
            context.push(notification.actionRoute!);
          }
        },
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          color: notification.isRead
              ? Colors.transparent
              : AppColors.surfaceContainerLow,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginMobile, vertical: AppSpacing.compact),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.compact),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(notification.title,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                color: AppColors.onSurface,
                              )),
                        ),
                        const SizedBox(width: 8),
                        Text(_formatTime(notification.createdAt),
                            style: AppTypography.caption.copyWith(
                              color: notification.isRead
                                  ? AppColors.onSurfaceVariant
                                  : AppColors.primary,
                              letterSpacing: 0,
                            )),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(notification.body,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Unread dot
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
      if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
      if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }
}
