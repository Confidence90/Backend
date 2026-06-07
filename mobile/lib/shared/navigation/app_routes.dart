/// BaaraLink Route Path Constants — no circular dependency
abstract final class AppRoutes {
  // Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String roleSelect = '/role-select';

  // Provider
  static const String providerDashboard = '/provider/dashboard';
  static const String missionsList = '/provider/missions';
  static const String activeMissions = '/provider/missions/active';
  static const String earnings = '/provider/earnings';
  static const String reviews = '/provider/reviews';

  // Client
  static const String clientDashboard = '/client/dashboard';
  static const String postMission = '/client/mission/post';
  static const String favorites = '/client/favorites';
  static const String applications = '/client/applications';

  // Shared
  static const String search = '/search';
  static const String artisanProfile = '/artisan/:id';
  static const String missionDetail = '/mission/:id';
  static const String wallet = '/wallet';
  static const String payment = '/payment';
  static const String chatList = '/chat';
  static const String chatRoom = '/chat/:id';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/profile/settings';
  static const String idVerification = '/profile/verify';
  static const String packs = '/packs';

  // Path helpers
  static String artisanPath(String id) => '/artisan/$id';
  static String missionPath(String id) => '/mission/$id';
  static String chatRoomPath(String id) => '/chat/$id';
  static String paymentPath({required int amount, String? title}) {
    var path = '/payment?amount=$amount';
    if (title != null) path += '&title=${Uri.encodeComponent(title)}';
    return path;
  }
}
