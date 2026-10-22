import 'package:flutter/foundation.dart';
import "package:shared_preferences/shared_preferences.dart";

class FavoriteService {
  static const String _favoritesKey = 'favorites';

  // Used to notify all screens that favorites changed.
  static final ValueNotifier<int> favoritesChanged = ValueNotifier<int>(0);

  Future<void> toggleFavorite(String mealId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();

      if (favorites.contains(mealId)) {
        favorites.remove(mealId);
      } else {
        favorites.add(mealId);
      }

      await prefs.setStringList(_favoritesKey, favorites);

      // Notify other screens immediately.
      favoritesChanged.value++;
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Future<List<String>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getStringList(_favoritesKey) ?? [];
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  Future<bool> isFavorite(String mealId) async {
    try {
      final favorites = await getFavorites();

      return favorites.contains(mealId);
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  Future<void> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_favoritesKey);

      // Notify other screens.
      favoritesChanged.value++;
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }

  Future<int> getFavoriteCount() async {
    final favorites = await getFavorites();

    return favorites.length;
  }
}
