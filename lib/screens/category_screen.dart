import 'package:flutter/material.dart';
import '../api/meal_api.dart';
import '../models/meal.dart';
import '../widgets/recipe_card.dart';
import '../widgets/loading_widget.dart';
import 'recipe_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final MealApi _mealApi = MealApi();
  List<Meal> _categories = [];
  List<Meal> _selectedCategoryMeals = [];
  bool _isLoading = true;
  bool _isLoadingMeals = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // LOAD CATEGORIES - FIXED (no null values)
  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _mealApi.getCategories();
      setState(() {
        _categories = categories.map((name) => Meal(
          id: name,
          name: name,
          image: null,
          category: name,
          area: null,
          instructions: null,
          isLocal: false,
          // Remove null, use empty list instead
          ingredients: [],
          measurements: [],
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load categories: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // LOAD MEALS BY CATEGORY
  Future<void> _loadMealsByCategory(String category) async {
    setState(() {
      _selectedCategory = category;
      _isLoadingMeals = true;
    });

    try {
      final meals = await _mealApi.getMealsByCategory(category);
      setState(() {
        _selectedCategoryMeals = meals;
        _isLoadingMeals = false;
      });
    } catch (e) {
      setState(() => _isLoadingMeals = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load meals: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategories,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading categories...')
          : Column(
              children: [
                // Horizontal category list
                _buildCategoryList(),
                const Divider(height: 0),
                // Meals grid
                Expanded(
                  child: _buildMealsGrid(),
                ),
              ],
            ),
    );
  }

  // CATEGORY LIST
  Widget _buildCategoryList() {
    if (_categories.isEmpty) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No categories available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category.name;
          return GestureDetector(
            onTap: () => _loadMealsByCategory(category.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              width: 100,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.deepOrange
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Colors.deepOrange
                      : Colors.grey[300]!,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.deepOrange.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Category Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.deepOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(category.name),
                      size: 30,
                      color: isSelected
                          ? Colors.white
                          : Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.grey[700],
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // MEALS GRID
  Widget _buildMealsGrid() {
    if (_selectedCategory == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Select a category to view recipes',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoadingMeals) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.deepOrange,
            ),
            SizedBox(height: 16),
            Text(
              'Loading recipes...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_selectedCategoryMeals.isEmpty) {
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
              'No recipes in this category',
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
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _selectedCategoryMeals.length,
      itemBuilder: (context, index) {
        final meal = _selectedCategoryMeals[index];
        return RecipeCard(
          meal: meal,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(
                  meal: meal,
                ),
              ),
            );
          },
        );
      },
    );
  }

  // GET CATEGORY ICON
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'beef':
        return Icons.emoji_food_beverage;
      case 'chicken':
        return Icons.emoji_food_beverage;
      case 'dessert':
        return Icons.cake;
      case 'lamb':
        return Icons.emoji_food_beverage;
      case 'miscellaneous':
        return Icons.fastfood;
      case 'pasta':
        return Icons.restaurant;
      case 'pork':
        return Icons.emoji_food_beverage;
      case 'seafood':
        return Icons.set_meal;
      case 'side':
        return Icons.food_bank;
      case 'starter':
        return Icons.food_bank;
      case 'vegan':
        return Icons.grass;
      case 'vegetarian':
        return Icons.grass;
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'goat':
        return Icons.emoji_food_beverage;
      default:
        return Icons.category;
    }
  }
}