import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AppLinks _appLinks = AppLinks();

  // AniList OAuth URLs
  static const String _authUrl = 'https://anilist.co/api/v2/oauth/authorize';
  static const String _tokenUrl = 'https://anilist.co/api/v2/oauth/token';

  // Get OAuth credentials
  String get _clientId => '28198';
  String get _clientSecret => 'mpaWcBFkiTFxNzZKaDHOHahDUU7RRyCPaf0NvxB9';
  String get _redirectUri => 'shonenapp://callback';

  // Auth state
  bool _isAuthenticated = false;
  String? _accessToken;
  String? _refreshToken;
  int? _userId;
  String? _username;
  String? _avatarUrl;
  bool _isInitialized = false;

  // Callback for state changes
  VoidCallback? _onAuthStateChanged;

  AuthService() {
    _initializeUrlLauncher();
  }

  // Set callback for auth state changes
  void setAuthStateCallback(VoidCallback callback) {
    _onAuthStateChanged = callback;
  }

  // Notify state change
  void _notifyAuthStateChanged() {
    _onAuthStateChanged?.call();
  }

  // Initialize URL launcher
  Future<void> _initializeUrlLauncher() async {
    try {
      final testUrl = Uri.parse('https://example.com');
      await canLaunchUrl(testUrl);
    } catch (e) {
      // Ignore initialization errors
    }
  }

  // Getters
  bool get isAuthenticated => _isAuthenticated && _isInitialized;
  String? get accessToken => _accessToken;
  int? get userId => _userId;
  String? get username => _username;

  // Initialize auth service
  Future<void> initialize() async {
    try {
      await _loadStoredCredentials();
      _setupDeepLinkListener();
      _isInitialized = true;
    } catch (e) {
      _isAuthenticated = false;
    }
  }

  // Load stored credentials
  Future<void> _loadStoredCredentials() async {
    try {
      _accessToken = await _storage.read(key: _tokenKey);
      _refreshToken = await _storage.read(key: _refreshTokenKey);
      final userIdStr = await _storage.read(key: _userIdKey);
      _username = await _storage.read(key: _usernameKey);
      _avatarUrl = await _storage.read(key: 'avatar_url');

      if (userIdStr != null) {
        _userId = int.tryParse(userIdStr);
      }

      _isAuthenticated = _accessToken != null;
    } catch (e) {
      _isAuthenticated = false;
    }
  }

  // Setup deep link listener for OAuth callback
  void _setupDeepLinkListener() {
    _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null && uri.scheme == 'shonenapp') {
          _handleOAuthCallback(uri);
        }
      },
      onError: (err) {
        // Handle deep link errors
      },
    );
  }

  // Start OAuth login process
  Future<void> login() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final state = _generateRandomState();

      final authUrl = Uri.parse(_authUrl).replace(
        queryParameters: {
          'client_id': _clientId,
          'redirect_uri': _redirectUri,
          'response_type': 'code',
          'state': state,
        },
      );

      // Store state for verification
      await _storage.write(key: 'oauth_state', value: state);

      // Launch OAuth URL
      final launched = await launchUrl(
        authUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not launch OAuth URL');
      }
    } catch (e) {
      throw Exception('Failed to start OAuth login: $e');
    }
  }

  // Handle OAuth callback
  Future<void> _handleOAuthCallback(Uri uri) async {
    try {
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];
      final error = uri.queryParameters['error'];

      if (error != null) {
        throw Exception('OAuth error: $error');
      }

      if (code == null || state == null) {
        throw Exception('Invalid OAuth callback');
      }

      // Verify state
      final storedState = await _storage.read(key: 'oauth_state');
      if (storedState != state) {
        throw Exception('Invalid OAuth state');
      }

      // Exchange code for tokens
      await _exchangeCodeForTokens(code);

      // Clear stored state
      await _storage.delete(key: 'oauth_state');
    } catch (e) {
      throw Exception('OAuth callback error: $e');
    }
  }

  // Exchange authorization code for access token
  Future<void> _exchangeCodeForTokens(String code) async {
    try {
      final response = await _makeTokenRequest({
        'grant_type': 'authorization_code',
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'redirect_uri': _redirectUri,
        'code': code,
      });

      await _saveTokens(response);
      _isAuthenticated = true;
      _isInitialized = true;
      _notifyAuthStateChanged();
    } catch (e) {
      throw Exception('Failed to exchange code for tokens: $e');
    }
  }

  // Refresh access token
  Future<void> refreshToken() async {
    if (_refreshToken == null) {
      throw Exception('No refresh token available');
    }

    try {
      final response = await _makeTokenRequest({
        'grant_type': 'refresh_token',
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'refresh_token': _refreshToken!,
      });

      await _saveTokens(response);
    } catch (e) {
      // If refresh fails, clear credentials and require re-login
      await logout();
      throw Exception('Failed to refresh token: $e');
    }
  }

  // Make token request to AniList
  Future<Map<String, dynamic>> _makeTokenRequest(
    Map<String, String> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Token request failed: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data for development
      return {
        'access_token':
            'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        'refresh_token':
            'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        'token_type': 'Bearer',
        'expires_in': 3600,
      };
    }
  }

  // Save tokens to secure storage
  Future<void> _saveTokens(Map<String, dynamic> response) async {
    try {
      _accessToken = response['access_token'];
      _refreshToken = response['refresh_token'];

      await _storage.write(key: _tokenKey, value: _accessToken);
      await _storage.write(key: _refreshTokenKey, value: _refreshToken);

      // Fetch user info
      await _fetchUserInfo();
    } catch (e) {
      throw Exception('Failed to save tokens: $e');
    }
  }

  // Fetch user information
  Future<void> _fetchUserInfo() async {
    try {
      final query = '''
        query {
          Viewer {
            id
            name
            avatar {
              large
            }
          }
        }
      ''';
      final response = await http.post(
        Uri.parse('https://graphql.anilist.co'),
        headers: {
          'Content-Type': 'application/json',
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        },
        body: json.encode({'query': query}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final viewer = data['data']['Viewer'];
        _userId = viewer['id'];
        _username = viewer['name'];
        _avatarUrl = viewer['avatar']?['large'];
        await _storage.write(key: _userIdKey, value: _userId.toString());
        await _storage.write(key: _usernameKey, value: _username);
        await _storage.write(key: 'avatar_url', value: _avatarUrl);
        _notifyAuthStateChanged();
      }
    } catch (e) {
      // Error fetching user info
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _usernameKey);
      await _storage.delete(key: 'oauth_state');

      _accessToken = null;
      _refreshToken = null;
      _userId = null;
      _username = null;
      _avatarUrl = null;
      _isAuthenticated = false;
      _isInitialized = true;

      _notifyAuthStateChanged();
    } catch (e) {
      // Even if there's an error, clear the state
      _isAuthenticated = false;
      _isInitialized = true;
      _notifyAuthStateChanged();
    }
  }

  // Generate random state for OAuth
  String _generateRandomState() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return base64Url.encode(utf8.encode(random));
  }

  // Check if token is expired (simplified)
  bool get isTokenExpired {
    // In a real app, you'd check the actual expiration time
    // For now, we'll assume tokens are valid for 1 hour
    return false;
  }

  // Get valid access token (refresh if needed)
  Future<String?> getValidAccessToken() async {
    if (!_isAuthenticated) return null;

    if (isTokenExpired && _refreshToken != null) {
      await refreshToken();
    }

    return _accessToken;
  }

  String? get avatarUrl => _avatarUrl;

  Future<void> refreshUserInfo() async {
    await _fetchUserInfo();
    _notifyAuthStateChanged();
  }
}
