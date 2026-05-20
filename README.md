# BaaraLink Mobile — Flutter Application

> Plateforme numérique de mise en relation Emploi & Services au Mali  
> Compétition POESAM — Orange Mali 2025

## Architecture

```
lib/
├── core/
│   ├── constants/        # AppConstants
│   ├── services/         # Dio API client, repositories
│   ├── theme/            # Colors, Typography, Spacing, Radius, Animations
│   └── widgets/          # Reusable: buttons, inputs, layout, states
├── features/
│   ├── auth/             # Splash, Onboarding, Login, OTP, RoleSelect
│   ├── home/             # Provider & Client dashboards
│   ├── marketplace/      # Search, Artisan Profile, Favorites, Applications
│   ├── missions/         # Post, Detail, List, Active, Earnings, Reviews
│   ├── chat/             # Conversations, Chat Room
│   ├── wallet/           # Wallet, Payment (Orange Money / Wave)
│   ├── notifications/    # Notifications with grouping & swipe actions
│   ├── profile/          # Profile, Edit, Settings, ID Verification
│   └── packs/            # Pack Basic & Premium
├── shared/
│   ├── models/           # User, Mission, Wallet, Transaction, AppNotification
│   ├── navigation/       # GoRouter + AppRoutes constants
│   └── providers/        # Auth, Marketplace, Missions, Wallet, Notifications
└── main.dart
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart 3.1+) |
| State | Flutter Riverpod 2.x |
| Navigation | GoRouter 13.x |
| HTTP | Dio 5.x |
| Fonts | Google Fonts (Inter) |
| Loading | Shimmer |
| Storage | flutter_secure_storage |

## Design System

Based on **Modern Sahelian Professionalism** — custom Material 3 theme.

- **Primary**: `#FF7A00` (Vibrant Orange)
- **Tertiary**: `#006399` (Deep Blue)  
- **Surface**: `#FFF8F5` (Warm White)
- **Font**: Inter (400/500/600/700)

## Backend Integration

Django REST backend at `https://api.baaralink.ml/api/v1`  
Repository: https://github.com/Confidence90/Backend.git

Authentication: JWT with OTP SMS (Orange Mali)  
Payments: Orange Money, Wave, Moov Money (escrow model)

## Getting Started

```bash
flutter pub get
flutter run
```

## Production TODOs

- [ ] Connect real Django API endpoints
- [ ] Implement Firebase Cloud Messaging push notifications  
- [ ] Add Geolocator for nearby artisan search
- [ ] Integrate Orange Money / Wave payment SDKs
- [ ] Add image upload with cached_network_image
- [ ] Implement WebSocket for real-time chat
- [ ] Add offline mode with local caching
- [ ] Complete Bambara (bm) localization
- [ ] Add biometric authentication
- [ ] Submit to Google Play Store
