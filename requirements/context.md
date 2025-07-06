# 📱 Flutter Anime App – AniList-Centric

## 🚀 Overview
A Flutter anime streaming app powered by AniList's GraphQL API. It` supports anime discovery, personalized lists, and mock video playback. The app uses Riverpod for state management, Material 3 dark theme, and a floating navigation bar design.

---

## 🔑 Core Features

### ✅ AniList Integration
- OAuth` Login:
  - `client_id`: 28194
  - `client_secret`: z0A3ZpS9lsYgpMxjXBoASGUxxBJnOaTqtvYjfeqW
  - `redirect_uri`: shonenshelf://callback
- Tokens stored securely via `flutter_secure_storage`
- Deep linking for Android and iOS

- GraphQL Queries`:
  - Trending Anime
  - Anime Details
  - User Lists (Watching, Planned, Dropped, Completed)

### 🎬 Video Streaming
- Mock MP4 URLs for now
- Fullscreen playback with `video_player` + `chewie`

### 👤 User Profile
- Lists with tabs: Watching / Planning / Dropped / Completed
- Empty state when no anime available
- Pull-to-refresh to sync lists

---

## 🎨 UI/UX

### Font & Colors
- **Font**: poppins

### Screens Summary

#### 1. **HomeScreen**
- Greeting ("Kon’nichiwa 👋")
- Carousel of anime cards (watchlist/trending)
- Horizontal scroll of “Top Rated Anime”
- **Floating Bottom NavBar (not fixed to bottom)** with:
  - Home (default)
  - Search (to search anime)
  - Settings
- **Top-right profile icon** → navigates to **ProfileScreen**

#### 2. **DetailsScreen**
Bottom navigation with 2 internal tabs:
- **Info Tab**:
  - Synopsis (expandable)
  - Tags, Genres, Quick Info
  - Characters (horizontal)
  - Related Anime
  - Recommended Anime
- **Videos Tab**:
  - Episode list
  - Source selector for each episode
  - Tap → opens WatchScreen

#### 3. **WatchScreen**
- Full video player
- Uses `video_player` + `chewie`
- Plays selected episode (mock stream)
- Fullscreen toggle

#### 4. **ProfileScreen**
- Tab bar with:
  - Watching
  - Planning
  - Dropped
  - Completed
- Each shows anime list if available, else shows blank state

#### 5. **SearchScreen**
- Search bar for AniList anime titles
- List/grid of results
- Tap result → goes to DetailsScreen

#### 6. **SettingsScreen**
- Accessible via bottom nav bar
- Sections:
  - Account
  - UI (Theme, Font)
  - Player (Playback settings)
  - General
  - App Info

---

## 🧱 Tech Stack

- **Flutter 3.32.5** (Material 3, Dart 3.8.1)
- **State Management**: Riverpod
- **Packages**:
  - `graphql_flutter`  
  - `flutter_secure_storage`
  - `url_launcher`
  - `app_links`
  - `video_player`
  - `chewie`
  - `yaml`

---

## 📁 Folder Structure

```
lib/
├── main.dart
├── screens/
│   ├── home_screen.dart
│   ├── details_screen.dart
│   ├── watch_screen.dart
│   ├── profile_screen.dart
│   ├── search_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── auth_service.dart
│   └── anilist_service.dart
├── widgets/
│   ├── anime_card.dart
│   ├── theme_switcher.dart
│   └── bottom_nav.dart
├── providers/
│   └── theme_provider.dart
└── models/
    └── anime.dart
```

---

---

## 🔐 Environment (.env)

```
ANILIST_CLIENT_ID=28194
ANILIST_CLIENT_SECRET=z0A3ZpS9lsYgpMxjXBoASGUxxBJnOaTqtvYjfeqW
REDIRECT_URI=shonenshelf://callback
```

Use the `flutter_dotenv` package to securely access these.

---

## 🧠 Cursor Initial Prompt

```
Set up a Flutter 3.32.5 project with:

- Material 3 dark theme
- Riverpod state management
- These packages:
  yaml
  graphql_flutter
  flutter_secure_storage
  url_launcher
  app_links
  video_player
  chewie
```