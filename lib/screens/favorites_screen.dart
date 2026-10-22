import 'package:flutter/material.dart';

import '../api/local_api.dart';
import '../api/meal_api.dart';
import '../models/meal.dart';
import '../services/favorite_service.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  final LocalApi _localApi = LocalApi();
  final MealApi _mealApi = MealApi();

  List<Meal> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Listen for favorite changes from ANY screen.
    FavoriteService.favoritesChanged.addListener(
      _favoriteChanged,
    );

    _loadFavorites();
  }

  @override
  void dispose() {
    FavoriteService.favoritesChanged.removeListener(
      _favoriteChanged,
    );

    super.dispose();
  }

  void _favoriteChanged() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final favoriteIds =
          await _favoriteService.getFavorites();

      final List<Meal> loadedFavorites = [];

      for (final id in favoriteIds) {
        Meal? meal;

        // Try Filipino API first.
        try {
          meal = await _localApi.getMealDetails(id);
        } catch (_) {
          meal = null;
        }

        // Try foreign API if not found.
        if (meal == null) {
          try {
            meal = await _mealApi.getMealDetails(id);
          } catch (_) {
            meal = null;
          }
        }

        if (meal != null) {
          loadedFavorites.add(meal);
        }
      }

      if (!mounted) return;

      setState(() {
        _favorites = loadedFavorites;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _favorites = [];
        _isLoading = false;
      });

      print('Error loading favorites: $e');
    }
  }

  void _openRecipe(Meal meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(
          meal: meal,
        ),
      ),
    ).then((_) {
      _loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.deepOrange,
        ),
      );
    }

    if (_favorites.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final meal = _favorites[index];

          return RecipeCard(
            meal: meal,
            onTap: () {
              _openRecipe(meal);
            },
            onFavoriteChanged: null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Favorites Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart button on a recipe to save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: const Color.fromARGB(255, 240, 12, 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}