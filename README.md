# BaaraLink — Backend Django

**Marketplace Emploi & Services — Mali**

Plateforme numérique de mise en relation entre prestataires de services, chercheurs d'emploi et clients au Mali.

---

## Stack Technique

| Composant | Technologie |
|-----------|-------------|
| Backend | Django 4.2 + Django REST Framework |
| Base de données | PostgreSQL 15 |
| Cache & Queue | Redis 7 + Celery |
| Auth | JWT (SimpleJWT) + OTP SMS |
| Paiements | Orange Money, Wave, Moov Money |
| Notifications | Firebase Cloud Messaging (FCM) |
| Hébergement | Docker + docker-compose |

---

## Structure du Projet

```
apps/
├── users/          # Auth (phone + OTP), rôles client/prestataire/admin
├── profiles/       # Profils, compétences, catégories, portfolio
├── jobs/           # Missions & offres d'emploi (CRUD + workflow)
├── reviews/        # Notation bidirectionnelle
├── payments/       # Orange Money, Wave (initiation + webhook)
├── matching/       # Algorithme de recommandation de prestataires
└── notifications/  # Push FCM + in-app (via Celery)
config/
├── settings.py     # Configuration complète
├── urls.py         # Routes API v1
└── celery.py       # Worker async
```

---

## Démarrage Rapide

```bash
# 1. Cloner le projet
git clone https://github.com/Confidence90/Backend.git
cd Backend

# 2. Variables d'environnement
copy .env.example .env
# Éditer .env avec vos valeurs

# 3. Lancer avec Docker
docker-compose up -d

# 4. Migrations
docker-compose exec api python manage.py migrate

# 5. Créer un superadmin
docker-compose exec api python manage.py createsuperuser

# 6. Charger les catégories initiales (optionnel)
docker-compose exec api python manage.py loaddata fixtures/categories.json
```

---

## API Endpoints (v1)

| Module | Base URL | Description |
|--------|----------|-------------|
| Auth | `/api/v1/auth/` | Inscription, connexion OTP, JWT |
| Profils | `/api/v1/profiles/` | Prestataires, catégories |
| Missions | `/api/v1/jobs/` | CRUD + candidatures |
| Avis | `/api/v1/reviews/` | Notation bidirectionnelle |
| Paiements | `/api/v1/payments/` | Mobile Money |
| Matching | `/api/v1/matching/` | Recommandations |
| Notifications | `/api/v1/notifications/` | In-app + FCM |

**Documentation interactive :** `http://localhost:8000/api/docs/`

---

## Variables d'environnement (.env)

```env
SECRET_KEY=your-secret-key
DEBUG=True
DB_NAME=baaralink_db
DB_USER=baaralink_user
DB_PASSWORD=strongpassword
DB_HOST=localhost
REDIS_URL=redis://localhost:6379
SMS_PROVIDER=twilio
TWILIO_ACCOUNT_SID=ACxxxxx
TWILIO_AUTH_TOKEN=xxxxx
TWILIO_FROM_NUMBER=+1234567890
ORANGE_MONEY_API_KEY=your-key
WAVE_API_KEY=your-key
```

---

## Application Mobile Flutter

L'application mobile (Android) est développée en Flutter avec :
- Architecture Clean Architecture + Riverpod
- Design premium Material 3
- Connexion complète à ce backend via JWT

---

*BaaraLink — Connecter les talents maliens aux opportunités*
