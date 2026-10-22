import 'package:flutter/material.dart';
import '../api/meal_api.dart';
import '../api/local_api.dart';
import '../models/meal.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MealApi _mealApi = MealApi();
  final LocalApi _localApi = LocalApi();
  final TextEditingController _searchController = TextEditingController();
  List<Meal> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _searchType = 'All';

  Future<void> _searchRecipes() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
      _hasSearched = true;
    });

    try {
      List<Meal> results = [];

      if (_searchType == 'All' || _searchType == 'Foreign') {
        final foreignResults = await _mealApi.searchMeals(query);
        results.addAll(foreignResults);
      }

      if (_searchType == 'All' || _searchType == 'Local') {
        final localRecipes = await _localApi.getLocalRecipes();
        final filteredLocal = localRecipes
            .where((meal) =>
                meal.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        results.addAll(filteredLocal);
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Recipes'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for recipes...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onSubmitted: (_) => _searchRecipes(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchRecipes,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('🇵🇭 Local', 'Local'),
                const SizedBox(width: 8),
                _buildFilterChip('🌍 Foreign', 'Foreign'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _searchType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _searchType = value;
        });
        if (_searchController.text.isNotEmpty) {
          _searchRecipes();
        }
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.deepOrange.shade100,
      checkmarkColor: Colors.deepOrange,
      labelStyle: TextStyle(
        color: isSelected ? Colors.deepOrange : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildResults() {
    if (!_hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Search for delicious recipes',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No recipes found',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final meal = _searchResults[index];
        return RecipeCard(
          meal: meal,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(meal: meal),
              ),
            );
          },
        );
      },
    );
  }
}