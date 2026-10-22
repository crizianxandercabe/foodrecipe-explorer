import 'dart:convert';
import "package:http/http.dart" as http;
import '../models/meal.dart';

class MealApi {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Meal>> searchMeals(String query) async {
    final url = Uri.parse('$baseUrl/search.php?s=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['meals'] == null) return [];
      return (data['meals'] as List)
          .map((meal) => Meal.fromJson(meal))
          .toList();
    }
    throw Exception('Failed to load recipes');
  }

  Future<Meal?> getMealDetails(String id) async {
    final url = Uri.parse('$baseUrl/lookup.php?i=$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['meals'] == null) return null;
      return Meal.fromJson(data['meals'][0]);
    }
    throw Exception('Failed to load recipe details');
  }

  Future<List<Meal>> getMealsByCategory(String category) async {
    final url = Uri.parse('$baseUrl/filter.php?c=$category');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['meals'] == null) return [];

      final List<Meal> fullMeals = [];
      for (var meal in data['meals'] as List) {
        try {
          final details = await getMealDetails(meal['idMeal']);
          if (details != null) {
            fullMeals.add(details);
          }
        } catch (e) {
          continue;
        }
      }
      return fullMeals;
    }
    throw Exception('Failed to load category');
  }

  Future<List<String>> getCategories() async {
    final url = Uri.parse('$baseUrl/categories.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['categories'] == null) return [];
      return (data['categories'] as List)
          .map((category) => category['strCategory'] as String)
          .toList();
    }
    throw Exception('Failed to load categories');
  }

  Future<List<Meal>> getAllForeignRecipes() async {
    final categories = await getCategories();
    final Map<String, Meal> uniqueMeals = {};

    final limitedCategories = categories.take(5).toList();

    for (final category in limitedCategories) {
      try {
        final meals = await getMealsByCategory(category);
        for (final meal in meals) {
          if (meal.ingredients.isNotEmpty) {
            uniqueMeals[meal.id] = meal;
          }
        }
      } catch (e) {
        continue;
      }
    }

    return uniqueMeals.values.toList();
  }

  Future<Meal?> getRandomMeal() async {
    final url = Uri.parse('$baseUrl/random.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['meals'] == null) return null;
      return Meal.fromJson(data['meals'][0]);
    }
    throw Exception('Failed to load random recipe');
  }
}
