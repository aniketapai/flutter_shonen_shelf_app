import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/anilist_service.dart';
import '../services/user_anime_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final authService = AuthService();
  return authService;
});

// AniList Service Provider
final anilistServiceProvider = Provider<AniListService>((ref) {
  return AniListService();
});

// User Anime Storage Service Provider
final userAnimeStorageServiceProvider = Provider<UserAnimeStorageService>((
  ref,
) {
  return UserAnimeStorageService();
});

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  final authService = ref.watch(authServiceProvider);
  final notifier = AuthStateNotifier(authService);
  return notifier;
});

final userAnimeListsProvider = FutureProvider<Map<String, List<dynamic>>>((
  ref,
) async {
  final authState = ref.watch(authStateProvider);
  if (!authState.isAuthenticated || authState.userId == null) {
    return {};
  }
  final anilistService = AniListService(
    accessToken: ref.read(authServiceProvider).accessToken,
    userId: authState.userId,
  );
  try {
    final lists = await anilistService.fetchUserAnimeLists();

    // Also load local data to merge with API data
    final storageService = ref.read(userAnimeStorageServiceProvider);
    final localData = await storageService.getUserAnimeData();

    // Merge local data with API data for better persistence
    for (final listName in lists.keys) {
      for (final entry in lists[listName]!) {
        final animeId = entry['media']['id'];
        final localEntry = localData[animeId.toString()];
        if (localEntry != null) {
          // Update entry with local data if it's more recent
          entry['progress'] = localEntry['progress'] ?? entry['progress'];
          entry['score'] = localEntry['score'] ?? entry['score'];
          entry['status'] = localEntry['status'] ?? entry['status'];
        }
      }
    }

    return lists;
  } on InvalidTokenException {
    throw InvalidTokenException();
  }
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(AuthState.initial()) {
    _authService.setAuthStateCallback(_onAuthStateChanged);
    _initialize();
  }

  void _onAuthStateChanged() {
    state = AuthState(
      isAuthenticated: _authService.isAuthenticated,
      userId: _authService.userId,
      username: _authService.username,
      avatarUrl: _authService.avatarUrl,
      isLoading: false,
    );
  }

  Future<void> _initialize() async {
    try {
      await _authService.initialize();
      state = AuthState(
        isAuthenticated: _authService.isAuthenticated,
        userId: _authService.userId,
        username: _authService.username,
        avatarUrl: _authService.avatarUrl,
        isLoading: false,
      );
    } catch (e) {
      state = AuthState(
        isAuthenticated: false,
        userId: null,
        username: null,
        avatarUrl: null,
        isLoading: false,
      );
    }
  }

  Future<void> login() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.login();
      state = AuthState(
        isAuthenticated: _authService.isAuthenticated,
        userId: _authService.userId,
        username: _authService.username,
        avatarUrl: _authService.avatarUrl,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.logout();
      state = AuthState(
        isAuthenticated: false,
        userId: null,
        username: null,
        avatarUrl: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

class AuthState {
  final bool isAuthenticated;
  final int? userId;
  final String? username;
  final String? avatarUrl;
  final bool isLoading;
  final String? error;

  const AuthState({
    required this.isAuthenticated,
    this.userId,
    this.username,
    this.avatarUrl,
    required this.isLoading,
    this.error,
  });

  factory AuthState.initial() {
    return const AuthState(isAuthenticated: false, isLoading: true);
  }

  AuthState copyWith({
    bool? isAuthenticated,
    int? userId,
    String? username,
    String? avatarUrl,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>(
  (ref) => FontSizeNotifier(),
);

class FontSizeNotifier extends StateNotifier<double> {
  static const String _key = 'font_size';
  FontSizeNotifier() : super(14.0) {
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_key);
    if (saved != null) state = saved;
  }

  @override
  set state(double value) {
    super.state = value;
    _saveFontSize(value);
  }

  Future<void> _saveFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, value);
  }
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
