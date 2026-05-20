// Manual model classes — identical API to the @freezed versions
// Used for development without running build_runner
// Replace with generated .freezed.dart files for production

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────
enum UserRole { provider, client, admin }
enum MissionStatusType { pending, inProgress, inEscrow, completed, cancelled, disputed }
enum TransactionType { credit, debit, escrow, refund }
enum MessageType { text, image, file, location }
enum NotificationCategory { payment, mission, review, message, system }

// ─────────────────────────────────────────────────────────────────────────────
// User
// ─────────────────────────────────────────────────────────────────────────────
class User {
  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.role = UserRole.client,
    this.isVerified = false,
    this.isPhoneVerified = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.completedMissions = 0,
    this.trustScore = 0.0,
    this.bio,
    this.location,
    this.specialty,
    this.skills,
    this.isPremium = false,
    this.isCertified = false,
    this.certificationBadge,
    this.createdAt,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final UserRole role;
  final bool isVerified;
  final bool isPhoneVerified;
  final double rating;
  final int reviewCount;
  final int completedMissions;
  final double trustScore;
  final String? bio;
  final String? location;
  final String? specialty;
  final List<String>? skills;
  final bool isPremium;
  final bool isCertified;
  final String? certificationBadge;
  final String? createdAt;

  User copyWith({
    String? id, String? name, String? phone, String? email, String? avatarUrl,
    UserRole? role, bool? isVerified, bool? isPhoneVerified, double? rating,
    int? reviewCount, int? completedMissions, double? trustScore, String? bio,
    String? location, String? specialty, List<String>? skills, bool? isPremium,
    bool? isCertified, String? certificationBadge, String? createdAt,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    role: role ?? this.role,
    isVerified: isVerified ?? this.isVerified,
    isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    rating: rating ?? this.rating,
    reviewCount: reviewCount ?? this.reviewCount,
    completedMissions: completedMissions ?? this.completedMissions,
    trustScore: trustScore ?? this.trustScore,
    bio: bio ?? this.bio,
    location: location ?? this.location,
    specialty: specialty ?? this.specialty,
    skills: skills ?? this.skills,
    isPremium: isPremium ?? this.isPremium,
    isCertified: isCertified ?? this.isCertified,
    certificationBadge: certificationBadge ?? this.certificationBadge,
    createdAt: createdAt ?? this.createdAt,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String? ?? json['full_name'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    role: UserRole.values.firstWhere(
      (r) => r.name == (json['role'] as String?),
      orElse: () => UserRole.client,
    ),
    isVerified: json['is_verified'] as bool? ?? false,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: json['review_count'] as int? ?? 0,
    completedMissions: json['completed_missions'] as int? ?? 0,
    trustScore: (json['trust_score'] as num?)?.toDouble() ?? 0.0,
    location: json['location'] as String?,
    specialty: json['specialty'] as String?,
    isPremium: json['is_premium'] as bool? ?? false,
    isCertified: json['is_certified'] as bool? ?? false,
    certificationBadge: json['certification_badge'] as String?,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthTokens
// ─────────────────────────────────────────────────────────────────────────────
class AuthTokens {
  const AuthTokens({required this.access, required this.refresh, required this.user});
  final String access;
  final String refresh;
  final User user;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    access: json['access'] as String,
    refresh: json['refresh'] as String,
    user: User.fromJson(json['user'] as Map<String, dynamic>),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Mission
// ─────────────────────────────────────────────────────────────────────────────
class Mission {
  const Mission({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.budget,
    this.currency = 'FCFA',
    required this.category,
    required this.location,
    this.scheduledAt,
    this.completedAt,
    this.clientId,
    this.providerId,
    this.client,
    this.provider,
    this.clientRating = 0.0,
    this.providerRating = 0.0,
    this.clientReview,
    this.providerReview,
    this.createdAt,
    this.isPremiumPack = false,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  final String id;
  final String title;
  final String? description;
  final MissionStatusType status;
  final int budget;
  final String currency;
  final String category;
  final String location;
  final String? scheduledAt;
  final String? completedAt;
  final String? clientId;
  final String? providerId;
  final User? client;
  final User? provider;
  final double clientRating;
  final double providerRating;
  final String? clientReview;
  final String? providerReview;
  final String? createdAt;
  final bool isPremiumPack;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;

  Mission copyWith({
    String? id, String? title, String? description, MissionStatusType? status,
    int? budget, String? category, String? location, String? scheduledAt,
  }) => Mission(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    budget: budget ?? this.budget,
    category: category ?? this.category,
    location: location ?? this.location,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    currency: currency,
    clientRating: clientRating,
    providerRating: providerRating,
  );

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    status: MissionStatusType.values.firstWhere(
      (s) => s.name == (json['status'] as String?),
      orElse: () => MissionStatusType.pending,
    ),
    budget: json['budget'] as int? ?? 0,
    category: json['category'] as String? ?? '',
    location: json['location'] as String? ?? '',
    scheduledAt: json['scheduled_at'] as String?,
    createdAt: json['created_at'] as String?,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Transaction
// ─────────────────────────────────────────────────────────────────────────────
class Transaction {
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    this.currency = 'FCFA',
    required this.description,
    this.counterpartyName,
    this.missionId,
    required this.createdAt,
    this.isEscrow = false,
  });

  final String id;
  final TransactionType type;
  final int amount;
  final String currency;
  final String description;
  final String? counterpartyName;
  final String? missionId;
  final String createdAt;
  final bool isEscrow;

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'] as String,
    type: TransactionType.values.firstWhere(
      (t) => t.name == (json['type'] as String?),
      orElse: () => TransactionType.credit,
    ),
    amount: json['amount'] as int? ?? 0,
    description: json['description'] as String? ?? '',
    counterpartyName: json['counterparty_name'] as String?,
    createdAt: json['created_at'] as String? ?? '',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ChatMessage
// ─────────────────────────────────────────────────────────────────────────────
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    this.attachmentUrl,
    required this.sentAt,
    this.isRead = false,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final MessageType type;
  final String? attachmentUrl;
  final String sentAt;
  final bool isRead;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    conversationId: json['conversation_id'] as String? ?? '',
    senderId: json['sender_id'] as String? ?? '',
    content: json['content'] as String? ?? '',
    sentAt: json['sent_at'] as String? ?? '',
    isRead: json['is_read'] as bool? ?? false,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Conversation
// ─────────────────────────────────────────────────────────────────────────────
class Conversation {
  const Conversation({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
    this.missionId,
    this.missionTitle,
  });

  final String id;
  final User otherUser;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final String? missionId;
  final String? missionTitle;

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'] as String,
    otherUser: User.fromJson(json['other_user'] as Map<String, dynamic>),
    unreadCount: json['unread_count'] as int? ?? 0,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppNotification
// ─────────────────────────────────────────────────────────────────────────────
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.isRead = false,
    this.actionRoute,
    this.actionId,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final bool isRead;
  final String? actionRoute;
  final String? actionId;
  final String createdAt;

  AppNotification copyWith({
    String? id, String? title, String? body, NotificationCategory? category,
    bool? isRead, String? actionRoute, String? createdAt,
  }) => AppNotification(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    category: category ?? this.category,
    isRead: isRead ?? this.isRead,
    actionRoute: actionRoute ?? this.actionRoute,
    createdAt: createdAt ?? this.createdAt,
  );

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    category: NotificationCategory.values.firstWhere(
      (c) => c.name == (json['category'] as String?),
      orElse: () => NotificationCategory.system,
    ),
    isRead: json['is_read'] as bool? ?? false,
    actionRoute: json['action_route'] as String?,
    createdAt: json['created_at'] as String? ?? '',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Wallet
// ─────────────────────────────────────────────────────────────────────────────
class Wallet {
  const Wallet({
    required this.id,
    required this.balance,
    this.currency = 'FCFA',
    this.escrowBalance = 0,
    this.monthlyEarnings = 0,
    this.monthlyGrowthPercent = 0.0,
    this.totalEarned = 0,
  });

  final String id;
  final int balance;
  final String currency;
  final int escrowBalance;
  final int monthlyEarnings;
  final double monthlyGrowthPercent;
  final int totalEarned;

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json['id'] as String,
    balance: json['balance'] as int? ?? 0,
    escrowBalance: json['escrow_balance'] as int? ?? 0,
    monthlyEarnings: json['monthly_earnings'] as int? ?? 0,
    monthlyGrowthPercent: (json['monthly_growth_percent'] as num?)?.toDouble() ?? 0.0,
    totalEarned: json['total_earned'] as int? ?? 0,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PaginatedResponse
// ─────────────────────────────────────────────────────────────────────────────
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<T> results;
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock data factory
// ─────────────────────────────────────────────────────────────────────────────
abstract final class MockData {
  static User get currentProvider => const User(
    id: 'user-001', name: 'Moussa Diarra', phone: '+22376543210',
    role: UserRole.provider, specialty: 'Plombier Expert',
    location: 'Bamako, ACI 2000', isVerified: true, isPhoneVerified: true,
    rating: 4.8, reviewCount: 124, completedMissions: 47, trustScore: 87,
    isCertified: true, certificationBadge: 'Certifié Plomberie',
    skills: ['Fuite d\'eau', 'Installation', 'Chauffe-eau', 'WC'],
  );

  static User get currentClient => const User(
    id: 'user-002', name: 'Aminata Coulibaly', phone: '+22377654321',
    role: UserRole.client, location: 'Bamako, Hippodrome',
    isVerified: true, isPhoneVerified: true,
  );

  static List<User> get topArtisans => const [
    User(id: 'art-001', name: 'Moussa Diarra', phone: '+22376543210',
      specialty: 'Plombier Expert', location: 'ACI 2000', isVerified: true,
      rating: 4.8, reviewCount: 124, completedMissions: 47, trustScore: 87,
      skills: ['Fuite d\'eau', 'Installation', 'Chauffe-eau', 'WC']),
    User(id: 'art-002', name: 'Fatoumata Koné', phone: '+22378765432',
      specialty: 'Ménagère Pro', location: 'Badalabougou', isVerified: true,
      rating: 5.0, reviewCount: 89, completedMissions: 63, trustScore: 95,
      skills: ['Ménage', 'Repassage', 'Cuisine', 'Garde enfant']),
    User(id: 'art-003', name: 'Ibrahim Koné', phone: '+22379876543',
      specialty: 'Maître Électricien', location: 'Magnambougou', isVerified: true,
      rating: 4.9, reviewCount: 67, completedMissions: 38, trustScore: 91,
      isPremium: true, skills: ['Installation', 'Câblage', 'Tableau électrique']),
    User(id: 'art-004', name: 'Mariam Traoré', phone: '+22375432109',
      specialty: 'Couturière', location: 'Lafiabougou', isVerified: true,
      rating: 4.7, reviewCount: 43, completedMissions: 29, trustScore: 78,
      skills: ['Couture', 'Broderie', 'Retouche']),
  ];

  static List<Mission> get activeMissions => const [
    Mission(
      id: 'mis-001', title: 'Réparation fuite salle de bain',
      description: 'Fuite au niveau du robinet principal.',
      status: MissionStatusType.inProgress, budget: 25000,
      category: 'Plomberie', location: 'ACI 2000, Bamako',
      scheduledAt: '2025-05-14T10:30:00Z',
    ),
    Mission(
      id: 'mis-002', title: 'Installation robinet cuisine',
      status: MissionStatusType.inEscrow, budget: 18000,
      category: 'Plomberie', location: 'Hippodrome, Bamako',
      scheduledAt: '2025-05-15T09:00:00Z',
    ),
  ];

  static Wallet get providerWallet => const Wallet(
    id: 'wal-001', balance: 450000, escrowBalance: 43000,
    monthlyEarnings: 450000, monthlyGrowthPercent: 12.0, totalEarned: 2340000,
  );

  static List<Transaction> get recentTransactions => const [
    Transaction(id: 'tx-001', type: TransactionType.credit, amount: 25000,
      description: 'Paiement mission — Fuite', counterpartyName: 'Aminata C.',
      createdAt: '2025-05-14T14:32:00Z'),
    Transaction(id: 'tx-002', type: TransactionType.credit, amount: 18000,
      description: 'Paiement mission — Installation', counterpartyName: 'Modibo T.',
      createdAt: '2025-05-13T11:15:00Z'),
    Transaction(id: 'tx-003', type: TransactionType.debit, amount: 50000,
      description: 'Retrait Orange Money', createdAt: '2025-05-12T09:00:00Z'),
  ];
}
