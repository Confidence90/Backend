abstract class AppConstants {
  // API
  static const apiBaseUrl     = 'http://10.0.2.2:8000/api/v1'; // Android emulator → localhost
  static const apiTimeout     = Duration(seconds: 15);
  static const connectTimeout = Duration(seconds: 10);

  // Storage keys
  static const kAccessToken  = 'access_token';
  static const kRefreshToken = 'refresh_token';
  static const kUserId       = 'user_id';
  static const kUserRole     = 'user_role';
  static const kUserPhone    = 'user_phone';
  static const kOnboardingDone = 'onboarding_done';

  // Pagination
  static const pageSize = 20;

  // Mali phone prefix
  static const maliPrefix = '+223';

  // Categories icons map
  static const categoryIcons = {
    'plomberie':     '🔧',
    'electricite':   '⚡',
    'menage':        '🧹',
    'maconnerie':    '🧱',
    'peinture':      '🖌️',
    'jardinage':     '🌱',
    'informatique':  '💻',
    'chauffeur':     '🚗',
    'cuisine':       '🍳',
    'couture':       '🪡',
  };
}

abstract class AppRoutes {
  static const splash      = '/';
  static const onboarding  = '/onboarding';
  static const login       = '/auth/login';
  static const otpVerify   = '/auth/otp';
  static const register    = '/auth/register';
  static const home        = '/home';
  static const jobList     = '/jobs';
  static const jobDetail   = '/jobs/:id';
  static const jobCreate   = '/jobs/create';
  static const profileMe   = '/profile/me';
  static const profileView = '/profile/:id';
  static const chat        = '/chat';
  static const chatDetail  = '/chat/:id';
  static const notifications = '/notifications';
}
