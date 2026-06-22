// BaaraLink Core Models & Mock Data

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

  factory User.fromJson(Map<String, dynamic> json) {
    final rawRole = (json['role'] as String?)?.toLowerCase();
    return User(
      id: json['id']?.toString() ?? '',
      name: json['full_name'] as String? ?? json['name'] as String? ?? '',
      phone: json['phone_number'] as String? ?? json['phone'] as String? ?? '',
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.values.firstWhere(
        (r) => r.name == rawRole,
        orElse: () => UserRole.client,
      ),
      isVerified: json['is_active'] as bool? ?? false,
      isPhoneVerified: json['phone_verified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      completedMissions: json['completed_missions'] as int? ?? 0,
      trustScore: (json['trust_score'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String?,
      specialty: json['specialty'] as String?,
      isPremium: json['is_premium'] as bool? ?? false,
      isCertified: json['is_certified'] as bool? ?? false,
      certificationBadge: json['certification_badge'] as String?,
      createdAt: json['date_joined'] as String?,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mission
// ─────────────────────────────────────────────────────────────────────────────
class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.budget,
    required this.clientName,
    this.clientId,
    this.providerId,
    this.createdAt,
    this.location = '',
    this.scheduledAt,
    this.category = 'Services',
  });

  final String id;
  final String title;
  final String description;
  final MissionStatusType status;
  final int budget;
  final String clientName;
  final String? clientId;
  final String? providerId;
  final String? createdAt;
  final String location;
  final String? scheduledAt;
  final String category;

  Mission copyWith({
    String? id, String? title, String? description,
    MissionStatusType? status, int? budget, String? clientName,
    String? clientId, String? providerId, String? createdAt,
    String? location, String? scheduledAt, String? category,
  }) => Mission(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    budget: budget ?? this.budget,
    clientName: clientName ?? this.clientName,
    clientId: clientId ?? this.clientId,
    providerId: providerId ?? this.providerId,
    createdAt: createdAt ?? this.createdAt,
    location: location ?? this.location,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    category: category ?? this.category,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Wallet & Transactions
// ─────────────────────────────────────────────────────────────────────────────
class Wallet {
  const Wallet({
    this.balance = 0,
    this.escrowBalance = 0,
    this.totalEarned = 0,
    this.monthlyEarnings = 0,
    this.monthlyGrowthPercent = 0.0,
  });
  final int balance;
  final int escrowBalance;
  final int totalEarned;
  final int monthlyEarnings;
  final double monthlyGrowthPercent;
}

class Transaction {
  const Transaction({
    required this.id,
    required this.amount,
    required this.title,
    required this.type,
    required this.createdAt,
    this.status = 'completed',
    required this.description,
    this.counterpartyName,
  });
  final String id;
  final int amount;
  final String title;
  final TransactionType type;
  final String createdAt;
  final String status;
  final String description;
  final String? counterpartyName;
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifications
// ─────────────────────────────────────────────────────────────────────────────
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.isRead = false,
    required this.createdAt,
    this.actionRoute,
  });
  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final bool isRead;
  final String createdAt;
  final String? actionRoute;

  AppNotification copyWith({
    String? id, String? title, String? body,
    NotificationCategory? category, bool? isRead,
    String? createdAt, String? actionRoute,
  }) => AppNotification(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    category: category ?? this.category,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt ?? this.createdAt,
    actionRoute: actionRoute ?? this.actionRoute,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat
// ─────────────────────────────────────────────────────────────────────────────
class Conversation {
  const Conversation({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
    this.missionTitle,
  });
  final String id;
  final User otherUser;
  final String? lastMessage;
  final int unreadCount;
  final String? missionTitle;
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
// MOCK DATA
// ─────────────────────────────────────────────────────────────────────────────
abstract final class MockData {
  static const currentProvider = User(
    id: 'art-001',
    name: 'Moussa Diarra',
    phone: '+223 70 00 00 00',
    role: UserRole.provider,
    specialty: 'Plomberie & Sanitaire',
    rating: 4.8,
    reviewCount: 24,
    isVerified: true,
  );

  static const currentClient = User(
    id: 'cli-001',
    name: 'Aminata Coulibaly',
    phone: '+223 60 00 00 00',
    role: UserRole.client,
  );

  static final topArtisans = [
    currentProvider,
    const User(
      id: 'art-002',
      name: 'Oumar Traoré',
      phone: '+223 71 11 11 11',
      role: UserRole.provider,
      specialty: 'Électricien Bâtiment',
      rating: 4.5,
      reviewCount: 18,
    ),
    const User(
      id: 'art-003',
      name: 'Fanta Keita',
      phone: '+223 72 22 22 22',
      role: UserRole.provider,
      specialty: 'Coiffure & Esthétique',
      rating: 4.9,
      reviewCount: 42,
    ),
  ];

  static final activeMissions = [
    const Mission(
      id: 'miss-001',
      title: 'Fuite d\'eau cuisine',
      description: 'Réparation d\'un robinet qui fuit.',
      status: MissionStatusType.inProgress,
      budget: 15000,
      clientName: 'Samba Diallo',
      location: 'ACI 2000',
      category: 'Plomberie',
      scheduledAt: '2025-05-15T09:00:00Z',
    ),
    const Mission(
      id: 'miss-002',
      title: 'Installation climatiseur',
      description: 'Pose d\'un split.',
      status: MissionStatusType.pending,
      budget: 25000,
      clientName: 'Fatoumata Koné',
      location: 'Badalabougou',
      category: 'Climatisation',
      scheduledAt: '2025-05-16T14:30:00Z',
    ),
  ];

  static const providerWallet = Wallet(
    balance: 45000,
    escrowBalance: 15000,
    totalEarned: 125000,
    monthlyEarnings: 35000,
    monthlyGrowthPercent: 12.5,
  );

  static final recentTransactions = [
    const Transaction(
      id: 'tx-001',
      amount: 25000,
      title: 'Paiement Mission #882',
      type: TransactionType.credit,
      createdAt: '2025-05-14T10:30:00Z',
      description: 'Paiement reçu',
      counterpartyName: 'Aminata Coulibaly',
    ),
    const Transaction(
      id: 'tx-002',
      amount: 10000,
      title: 'Retrait Orange Money',
      type: TransactionType.debit,
      createdAt: '2025-05-13T15:20:00Z',
      description: 'Retrait de fonds',
    ),
    const Transaction(
      id: 'tx-003',
      amount: 5000,
      title: 'Frais de service BaaraLink',
      type: TransactionType.debit,
      createdAt: '2025-05-12T09:00:00Z',
      description: 'Frais de service',
    ),
  ];
}
