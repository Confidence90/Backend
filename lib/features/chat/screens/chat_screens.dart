import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/widgets/layout/app_shared_widgets.dart';
import '../../../core/widgets/states/ux_states.dart';
import '../../../shared/models/app_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock Conversations
// ─────────────────────────────────────────────────────────────────────────────
final _mockConversations = [
  (
    'conv-001',
    'AC',
    'Aminata Coulibaly',
    'D\'accord pour demain 9h, merci !',
    '14:32',
    2,
    true,
    'Réparation fuite robinet',
  ),
  (
    'conv-002',
    'MT',
    'Modibo Traoré',
    'Super travail encore une fois 👍',
    'Hier',
    0,
    false,
    'Installation électrique',
  ),
  (
    'conv-003',
    'BL',
    'BaaraLink',
    'Nouvelle mission dans ta zone !',
    'Lun',
    1,
    false,
    null,
  ),
  (
    'conv-004',
    'SK',
    'Seydou Kouyaté',
    'À quelle heure pouvez-vous venir ?',
    'Dim',
    0,
    true,
    'Chauffe-eau solaire',
  ),
  (
    'conv-005',
    'FK',
    'Fatoumata Koné',
    'Merci beaucoup, très satisfaite !',
    '12/05',
    0,
    false,
    'Ménage appartement',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// ChatListScreen
// ─────────────────────────────────────────────────────────────────────────────
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalUnread = _mockConversations.fold<int>(0, (sum, c) => sum + c.$6);

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
            Text('Messages', style: AppTypography.h3),
            if (totalUnread > 0)
              Text('$totalUnread non lu${totalUnread > 1 ? 's' : ''}',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.primary, letterSpacing: 0)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            color: AppColors.onSurfaceVariant,
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: const Divider(height: 1),
        ),
      ),
      body: _mockConversations.isEmpty
          ? EmptyStateWidget(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Aucun message',
              subtitle: 'Vos conversations avec les artisans apparaîtront ici.',
            )
          : ListView.separated(
              itemCount: _mockConversations.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
              itemBuilder: (_, i) {
                final conv = _mockConversations[i];
                return _ConversationTile(conversation: conv, index: i);
              },
            ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.index});
  final dynamic conversation;
  final int index;

  @override
  Widget build(BuildContext context) {
    final (
      id,
      initials,
      name,
      lastMsg,
      time,
      unread,
      isOfficialOrOnline,
      missionTitle
    ) = (
      conversation.$1,
      conversation.$2,
      conversation.$3,
      conversation.$4,
      conversation.$5,
      conversation.$6,
      conversation.$7,
      conversation.$8
    );
    final isOfficial = name == 'BaaraLink';
    final hasUnread = (unread as int) > 0;

    return InkWell(
      onTap: () => context.push('/chat/$id'),
      child: Container(
        color: hasUnread ? AppColors.surfaceContainerLow : Colors.transparent,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.marginMobile, vertical: AppSpacing.compact),
        child: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                AppAvatar(
                  initials: initials as String,
                  size: AppSpacing.avatarMd,
                  backgroundColor: isOfficial
                      ? AppColors.primaryContainer.withOpacity(0.2)
                      : AppColors.surfaceContainer,
                  foregroundColor: isOfficial
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
                if (isOfficialOrOnline as bool && !isOfficial)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.background, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.compact),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(name as String,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: hasUnread
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: AppColors.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            if (isOfficial) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: AppRadius.radiusFull,
                                ),
                                child: Text('Officiel',
                                    style: AppTypography.overline.copyWith(
                                        color: Colors.white,
                                        fontSize: 8,
                                        letterSpacing: 0.3)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(time as String,
                          style: AppTypography.caption.copyWith(
                            color: hasUnread
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                            letterSpacing: 0,
                          )),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (missionTitle != null)
                    Text('Mission: $missionTitle',
                        style: AppTypography.caption.copyWith(
                            color: AppColors.tertiary,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      Expanded(
                        child: Text(lastMsg as String,
                            style: AppTypography.bodySmall.copyWith(
                              color: hasUnread
                                  ? AppColors.onSurface
                                  : AppColors.onSurfaceVariant,
                              fontWeight:
                                  hasUnread ? FontWeight.w500 : FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                      ),
                      if ((unread as int) > 0)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                          child: Center(
                            child: Text(unread.toString(),
                                style: AppTypography.overline.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                    letterSpacing: 0)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ChatRoomScreen
// ─────────────────────────────────────────────────────────────────────────────
final _chatMessagesProvider = StateProvider<List<_ChatMsg>>((ref) => [
      _ChatMsg(
          text:
              'Bonjour Moussa, j\'ai un robinet qui fuit dans ma cuisine. Vous pouvez venir aujourd\'hui ?',
          isMe: false,
          time: '09:14',
          isRead: true),
      _ChatMsg(
          text:
              'Bonjour ! Oui je suis disponible cet après-midi. Dans quel quartier êtes-vous ?',
          isMe: true,
          time: '09:16',
          isRead: true),
      _ChatMsg(
          text:
              'Je suis à ACI 2000. Quel est votre tarif pour ce type de réparation ?',
          isMe: false,
          time: '09:18',
          isRead: true),
      _ChatMsg(
          text:
              'Pour ACI 2000 : déplacement + réparation standard = 25 000 FCFA. Je peux être là vers 14h30.',
          isMe: true,
          time: '09:22',
          isRead: true),
      _ChatMsg(
          text: 'D\'accord pour demain 9h, merci beaucoup !',
          isMe: false,
          time: '14:32',
          isRead: false),
    ]);

class _ChatMsg {
  const _ChatMsg(
      {required this.text,
      required this.isMe,
      required this.time,
      this.isRead = false});
  final String text;
  final bool isMe;
  final String time;
  final bool isRead;
}

class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({super.key, required this.chatId});
  final String chatId;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;
  bool _otherTyping = false;

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final msgs = ref.read(_chatMessagesProvider);
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    ref.read(_chatMessagesProvider.notifier).state = [
      ...msgs,
      _ChatMsg(text: text, isMe: true, time: time),
    ];
    _msgController.clear();
    setState(() => _isTyping = false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppAnimations.standard,
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate typing indicator then reply
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _otherTyping = true);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _otherTyping = false);
        final updatedMsgs = ref.read(_chatMessagesProvider);
        ref.read(_chatMessagesProvider.notifier).state = [
          ...updatedMsgs,
          _ChatMsg(
              text: 'Parfait, je confirme ! À demain 👍',
              isMe: false,
              time: time),
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(_chatMessagesProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: _ChatAppBar(chatId: widget.chatId),
      body: Column(
        children: [
          // Mission context pill
          GestureDetector(
            onTap: () => context.push('/mission/mis-001'),
            child: Container(
              color: AppColors.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.task_alt_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('Mission : Réparation fuite robinet',
                        style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600)),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 16, color: AppColors.onSurfaceVariant),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile, vertical: AppSpacing.md),
              itemCount: messages.length + (_otherTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_otherTyping && i == messages.length) {
                  return _TypingIndicator();
                }
                return _MessageBubble(message: messages[i]);
              },
            ),
          ),

          // Input bar
          _ChatInputBar(
            controller: _msgController,
            onChanged: (v) => setState(() => _isTyping = v.isNotEmpty),
            onSend: _sendMessage,
            hasText: _isTyping,
          ),
        ],
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({required this.chatId});
  final String chatId;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.topBarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.onSurface,
                onPressed: () => context.pop(),
              ),
              AppAvatar(initials: 'AC', size: 40, showOnline: true),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Aminata Coulibaly',
                        style: AppTypography.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                    Row(children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text('En ligne',
                          style: AppTypography.caption.copyWith(
                              color: AppColors.success, letterSpacing: 0)),
                    ]),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.call_rounded),
                color: AppColors.onSurfaceVariant,
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                color: AppColors.onSurfaceVariant,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final _ChatMsg message;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            AppAvatar(initials: 'AC', size: 28),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isMe ? AppColors.primary : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border:
                    isMe ? null : Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text,
                    style: AppTypography.bodySmall.copyWith(
                      color: isMe ? Colors.white : AppColors.onSurface,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(message.time,
                          style: AppTypography.overline.copyWith(
                            color: isMe
                                ? Colors.white60
                                : AppColors.onSurfaceVariant,
                            fontSize: 10,
                            letterSpacing: 0,
                          )),
                      if (isMe) ...[
                        const SizedBox(width: 3),
                        Icon(
                          message.isRead
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 13,
                          color: message.isRead
                              ? Colors.lightBlueAccent
                              : Colors.white60,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
        3,
        (i) => AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 400),
            ));
    _anims = _controllers
        .map((c) => Tween<double>(begin: 0, end: -6)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();

    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AppAvatar(initials: 'AC', size: 28),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                  3,
                  (i) => AnimatedBuilder(
                        animation: _anims[i],
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, _anims[i].value),
                          child: Container(
                            width: 6,
                            height: 6,
                            margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                            decoration: const BoxDecoration(
                                color: AppColors.onSurfaceVariant,
                                shape: BoxShape.circle),
                          ),
                        ),
                      )),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.onChanged,
    required this.onSend,
    required this.hasText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final bool hasText;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLowest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.compact, vertical: AppSpacing.sm),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file_rounded),
                color: AppColors.onSurfaceVariant,
                onPressed: () {},
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: AppRadius.radiusFull,
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    style: AppTypography.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Message…',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              AnimatedContainer(
                duration: AppAnimations.fast,
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hasText
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    hasText ? Icons.send_rounded : Icons.mic_rounded,
                    color: hasText ? Colors.white : AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: hasText ? onSend : () {},
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
