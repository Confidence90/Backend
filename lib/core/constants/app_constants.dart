/// BaaraLink App Constants
abstract final class AppConstants {
  // ─── App Info ─────────────────────────────────────────────────────────────
  static const String appName = 'BaaraLink';
  static const String appTagline = 'Mali • Services • Emploi';
  static const String appVersion = '1.0.0';

  // ─── API ──────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://api.baaralink.ml/api/v1';
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // ─── Storage Keys ─────────────────────────────────────────────────────────
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyLanguage = 'app_language';
  static const String keyDarkMode = 'dark_mode';

  // ─── Pagination ───────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int chatPageSize = 50;

  // ─── Validation ───────────────────────────────────────────────────────────
  static const int phoneMinLength = 8;
  static const int phoneMaxLength = 12;
  static const int otpLength = 6;
  static const int minPasswordLength = 8;
  static const int maxBioLength = 500;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 1000;

  // ─── Business ─────────────────────────────────────────────────────────────
  static const String currency = 'FCFA';
  static const double commissionRate = 0.075; // 7.5%
  static const double commissionRateHigh = 0.10; // 10%
  static const int packBasicPrice = 4950;
  static const int packPremiumPrice = 6950;
  static const int packBasicProfiles = 4;
  static const int packPremiumProfiles = 9;
  static const int subscriptionMonthlyPrice = 2000;
  static const int subscriptionYearlyPrice = 21000;

  // ─── Trust Score ─────────────────────────────────────────────────────────
  static const double trustScoreMin = 0;
  static const double trustScoreMax = 100;
  static const double trustScoreVerifiedMin = 70;

  // ─── Country / Locale ─────────────────────────────────────────────────────
  static const String countryCode = 'ML';
  static const String phonePrefix = '+223';
  static const String defaultLocale = 'fr';
  static List<String> supportedLocales = ['fr', 'bm']; // Français, Bambara

  // ─── Map ──────────────────────────────────────────────────────────────────
  static const double bamakoCenterLat = 12.6392;
  static const double bamakoCenterLng = -8.0029;
  static const double defaultMapZoom = 13.0;
  static const double nearbyRadiusKm = 10.0;

  // ─── OTP ──────────────────────────────────────────────────────────────────
  static const int otpResendSeconds = 60;
  static const int otpExpiryMinutes = 10;

  // ─── Animation delays ─────────────────────────────────────────────────────
  static const int splashDurationMs = 2500;
  static const int onboardingAutoAdvanceMs = 5000;

  // ─── Image quality ────────────────────────────────────────────────────────
  static const int avatarMaxSizeKb = 500;
  static const int portfolioMaxSizeKb = 2000;
  static const int avatarMaxDimension = 400;
}
