import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserAnimeStorageService {
  static const String _storageKey = 'user_anime_data';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Store user anime data locally
  Future<void> storeUserAnimeData(
    int animeId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final existingData = await getUserAnimeData();
      existingData[animeId.toString()] = userData;

      await _storage.write(key: _storageKey, value: json.encode(existingData));
    } catch (e) {
      // Error handling for storage operations
    }
  }

  // Get all stored user anime data
  Future<Map<String, dynamic>> getUserAnimeData() async {
    try {
      final data = await _storage.read(key: _storageKey);
      if (data != null) {
        return Map<String, dynamic>.from(json.decode(data));
      }
    } catch (e) {
      // Error handling for storage operations
    }
    return {};
  }

  // Get specific anime user data
  Future<Map<String, dynamic>?> getAnimeUserData(int animeId) async {
    try {
      final allData = await getUserAnimeData();
      return allData[animeId.toString()];
    } catch (e) {
      // Error handling for storage operations
    }
    return null;
  }

  // Update specific anime user data
  Future<void> updateAnimeUserData(
    int animeId,
    Map<String, dynamic> userData,
  ) async {
    await storeUserAnimeData(animeId, userData);
  }

  // Clear all stored data
  Future<void> clearAllData() async {
    try {
      await _storage.delete(key: _storageKey);
    } catch (e) {
      // Error handling for storage operations
    }
  }
}
