import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/favorite_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Meal meal;
  final VoidCallback? onFavoriteChanged;

  const RecipeDetailScreen({
    super.key,
    required this.meal,
    this.onFavoriteChanged,
  });

  @override
  State<RecipeDetailScreen> createState() =>
      _RecipeDetailScreenState();
}

class _RecipeDetailScreenState
    extends State<RecipeDetailScreen> {
  late Meal _meal;

  int _currentServings = 4;

  bool _isFavorite = false;

  final FavoriteService _favoriteService =
      FavoriteService();

  @override
  void initState() {
    super.initState();

    _meal = widget.meal;

    _currentServings = _meal.servings;

    _checkFavorite();
  }

  // ============================================================
  // FAVORITE
  // ============================================================

  Future<void> _checkFavorite() async {
    final isFav =
        await _favoriteService.isFavorite(
      _meal.id,
    );

    if (!mounted) return;

    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    await _favoriteService.toggleFavorite(
      _meal.id,
    );

    if (!mounted) return;

    setState(() {
      _isFavorite = !_isFavorite;
    });

    widget.onFavoriteChanged?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? '${_meal.name} saved to favorites'
              : '${_meal.name} removed from favorites',
        ),
        backgroundColor:
            _isFavorite ? Colors.green : Colors.red,
        duration:
            const Duration(seconds: 2),
      ),
    );
  }

  // ============================================================
  // SERVINGS
  // ============================================================

  void _updateServings(int newServings) {
    setState(() {
      _currentServings = newServings;

      _meal = _meal.scaleServings(
        newServings,
      );
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ========================================================
          // HEADER
          // ========================================================

          SliverAppBar(
            expandedHeight: 320,
            pinned: true,

            backgroundColor:
                Colors.deepOrange,

            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),

            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,

                  color: _isFavorite
                      ? Colors.red
                      : Colors.white,
                ),

                onPressed:
                    _toggleFavorite,
              ),

              const SizedBox(width: 6),
            ],

            flexibleSpace:
                FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,

                children: [
                  // ==================================================
                  // IMAGE
                  // ==================================================

                  _meal.image != null &&
                          _meal.image!
                              .trim()
                              .isNotEmpty
                      ? Image.network(
                          _meal.image!,

                          fit: BoxFit.cover,

                          webHtmlElementStrategy:
                              WebHtmlElementStrategy.prefer,

                          errorBuilder:
                              (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Container(
                              color:
                                  Colors.grey[300],

                              child:
                                  const Center(
                                child: Icon(
                                  Icons.restaurant,
                                  size: 80,
                                  color:
                                      Colors.grey,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color:
                              Colors.grey[300],

                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                  // ==================================================
                  // DARK GRADIENT
                  // ==================================================

                  Container(
                    decoration:
                        BoxDecoration(
                      gradient:
                          LinearGradient(
                        begin:
                            Alignment.topCenter,
                        end:
                            Alignment.bottomCenter,

                        colors: [
                          Colors.transparent,
                          Colors.black
                              .withValues(alpha: 0.85),
                        ],

                        stops: const [
                          0.45,
                          1.0,
                        ],
                      ),
                    ),
                  ),

                  // ==================================================
                  // RECIPE TITLE
                  // ==================================================

                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            // Local / Foreign
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),

                              decoration:
                                  BoxDecoration(
                                color:
                                    _meal.isLocal
                                        ? Colors
                                            .deepOrange
                                        : Colors.blue,

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),

                              child: Row(
                                mainAxisSize:
                                    MainAxisSize
                                        .min,

                                children: [
                                  Icon(
                                    _meal.isLocal
                                        ? Icons.flag
                                        : Icons.public,

                                    color:
                                        Colors.white,

                                    size: 13,
                                  ),

                                  const SizedBox(
                                    width: 5,
                                  ),

                                  Text(
                                    _meal.isLocal
                                        ? 'Local'
                                        : 'Foreign',

                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            // Category
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),

                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .white
                                    .withValues(
                                  alpha: 0.2,
                                ),

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),

                              child: Text(
                                _meal.category ??
                                    'Unknown',

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Text(
                          _meal.name,

                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 28,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 15,
                              color:
                                  Colors.white70,
                            ),

                            const SizedBox(
                              width: 5,
                            ),

                            Text(
                              _meal.area ??
                                  'Unknown',

                              style:
                                  const TextStyle(
                                color:
                                    Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ========================================================
          // CONTENT
          // ========================================================

          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // Servings
                  _buildServingScaler(),

                  const SizedBox(
                    height: 24,
                  ),

                  // Filipino description
                  if (_meal.isLocal &&
                      _meal.description !=
                          null &&
                      _meal.description!
                          .trim()
                          .isNotEmpty) ...[
                    _buildDescriptionSection(),

                    const SizedBox(
                      height: 24,
                    ),
                  ],

                  // Ingredients
                  _buildIngredientsSection(),

                  const SizedBox(
                    height: 24,
                  ),

                  // Local additional information
                  if (_meal.isLocal) ...[
                    _buildCookingMethodSection(),

                    const SizedBox(
                      height: 24,
                    ),

                    _buildFlavorSection(),

                    const SizedBox(
                      height: 24,
                    ),

                    _buildOccasionSection(),

                    const SizedBox(
                      height: 24,
                    ),

                    _buildTagsSection(),

                    const SizedBox(
                      height: 24,
                    ),
                  ],

                  // Actual instructions ONLY when available.
                  if (!_meal.isLocal) ...[
                    _buildInstructionsSection(),

                    const SizedBox(
                      height: 24,
                    ),
                  ],

                  // Buttons
                  _buildActionButtons(),

                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SERVINGS
  // ============================================================

  Widget _buildServingScaler() {
    final servings = [
      2,
      4,
      6,
      8,
      10,
    ];

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            const Icon(
              Icons.people,
              color:
                  Colors.deepOrange,
              size: 20,
            ),

            const SizedBox(
              width: 8,
            ),

            const Text(
              'Servings',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const Spacer(),

            Text(
              '$_currentServings',

              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
                color:
                    Colors.deepOrange,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        Row(
          children:
              servings.map((serving) {
            final isSelected =
                serving ==
                    _currentServings;

            return Expanded(
              child: Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 4,
                ),

                child: GestureDetector(
                  onTap: () =>
                      _updateServings(
                    serving,
                  ),

                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 10,
                    ),

                    decoration:
                        BoxDecoration(
                      color: isSelected
                          ? Colors
                              .deepOrange
                          : Colors
                              .grey[200],

                      borderRadius:
                          BorderRadius
                              .circular(
                        8,
                      ),

                      border:
                          Border.all(
                        color: isSelected
                            ? Colors
                                .deepOrange
                            : Colors
                                .transparent,

                        width: 2,
                      ),
                    ),

                    child: Center(
                      child: Text(
                        '$serving',

                        style:
                            TextStyle(
                          color: isSelected
                              ? Colors
                                  .white
                              : Colors
                                  .grey[700],

                          fontWeight:
                              isSelected
                                  ? FontWeight
                                      .bold
                                  : FontWeight
                                      .normal,

                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Row(
          children: [
            Icon(
              Icons.description,
              color:
                  Colors.deepOrange,
              size: 21,
            ),

            SizedBox(width: 8),

            Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        Card(
          elevation: 2,

          child: Padding(
            padding:
                const EdgeInsets.all(16),

            child: Text(
              _meal.description ??
                  'No description available.',

              style:
                  const TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INGREDIENTS
  // ============================================================

  Widget _buildIngredientsSection() {
    final hasIngredients =
        _meal.ingredients.isNotEmpty;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            const Icon(
              Icons.shopping_cart,
              color:
                  Colors.deepOrange,
              size: 21,
            ),

            const SizedBox(
              width: 8,
            ),

            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const Spacer(),

            if (hasIngredients)
              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors
                      .deepOrange
                      .withValues(
                    alpha: 0.1,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
                  ),
                ),

                child: Text(
                  '${_meal.ingredients.length} items',

                  style:
                      TextStyle(
                    color:
                        Colors.deepOrange[700],
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        if (!hasIngredients)
          Card(
            child: Padding(
              padding:
                  const EdgeInsets
                      .all(20),

              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 40,
                      color:
                          Colors.grey[400],
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'No ingredients available',

                      style: TextStyle(
                        color:
                            Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Card(
            elevation: 2,

            child: Padding(
              padding:
                  const EdgeInsets.all(16),

              child: Column(
                children:
                    List.generate(
                  _meal.ingredients.length,
                  (index) =>
                      _buildIngredientItem(
                    index,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // INGREDIENT ITEM
  // ============================================================

  Widget _buildIngredientItem(
    int index,
  ) {
    final ingredient =
        _meal.ingredients[index];

    final hasMeasurement =
        index <
                _meal.measurements
                    .length &&
            _meal.measurements[index]
                .isNotEmpty;

    final measurement =
        hasMeasurement
            ? _meal.measurements[index]
            : '';

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),

      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,

            decoration:
                BoxDecoration(
              color: Colors
                  .deepOrange
                  .withValues(
                alpha: 0.1,
              ),

              borderRadius:
                  BorderRadius
                      .circular(
                6,
              ),

              border:
                  Border.all(
                color: Colors
                    .deepOrange
                    .withValues(
                  alpha: 0.3,
                ),
              ),
            ),

            child: Center(
              child: Text(
                '${index + 1}',

                style:
                    TextStyle(
                  color:
                      Colors.deepOrange[700],
                  fontSize: 11,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              ingredient,

              style:
                  const TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          if (hasMeasurement)
            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 12,
                vertical: 4,
              ),

              decoration:
                  BoxDecoration(
                color:
                    Colors.grey[100],

                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),

              child: Text(
                measurement,

                style:
                    TextStyle(
                  color:
                      Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // COOKING METHOD
  // ============================================================

  Widget _buildCookingMethodSection() {
    if (_meal.cookingMethods.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildChipSection(
      title: 'Cooking Method',
      icon: Icons.local_fire_department,
      items: _meal.cookingMethods,
    );
  }

  // ============================================================
  // FLAVOR
  // ============================================================

  Widget _buildFlavorSection() {
    if (_meal.flavorProfile.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildChipSection(
      title: 'Flavor Profile',
      icon: Icons.restaurant,
      items: _meal.flavorProfile,
    );
  }

  // ============================================================
  // OCCASION
  // ============================================================

  Widget _buildOccasionSection() {
    if (_meal.occasions.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildChipSection(
      title: 'Occasion',
      icon: Icons.celebration,
      items: _meal.occasions,
    );
  }

  // ============================================================
  // TAGS
  // ============================================================

  Widget _buildTagsSection() {
    if (_meal.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildChipSection(
      title: 'Tags',
      icon: Icons.local_offer,
      items: _meal.tags,
    );
  }

  // ============================================================
  // CHIP SECTION
  // ============================================================

  Widget _buildChipSection({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Icon(
              icon,
              color:
                  Colors.deepOrange,
              size: 21,
            ),

            const SizedBox(
              width: 8,
            ),

            Text(
              title,

              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        Card(
          elevation: 2,

          child: Padding(
            padding:
                const EdgeInsets.all(16),

            child: Wrap(
              spacing: 8,
              runSpacing: 8,

              children:
                  items.map((item) {
                return Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),

                  decoration:
                      BoxDecoration(
                    color: Colors
                        .deepOrange
                        .withValues(
                      alpha: 0.1,
                    ),

                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),

                  child: Text(
                    item,

                    style:
                        TextStyle(
                      color:
                          Colors.deepOrange[700],
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FOREIGN INSTRUCTIONS
  // ============================================================

  Widget _buildInstructionsSection() {
    final hasInstructions =
        _meal.instructions != null &&
            _meal.instructions!
                .trim()
                .isNotEmpty;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Row(
          children: [
            Icon(
              Icons.menu_book,
              color:
                  Colors.deepOrange,
              size: 21,
            ),

            SizedBox(width: 8),

            Text(
              'Instructions',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        Card(
          elevation: 2,

          child: Padding(
            padding:
                const EdgeInsets.all(16),

            child: hasInstructions
                ? Column(
                    children:
                        _meal.instructions!
                            .split('\n')
                            .where(
                              (step) => step
                                  .trim()
                                  .isNotEmpty,
                            )
                            .map(
                              (step) =>
                                  _buildInstructionStep(
                                step,
                              ),
                            )
                            .toList(),
                  )
                : const Padding(
                    padding:
                        EdgeInsets.all(20),

                    child: Center(
                      child: Text(
                        'No instructions available.',
                        style:
                            TextStyle(
                          fontSize: 16,
                          color:
                              Colors.grey,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  
  // INSTRUCTION STEP
  
  Widget _buildInstructionStep(
    String step,
  ) {
    final steps =
        _meal.instructions!
            .split('\n')
            .where(
              (s) =>
                  s.trim().isNotEmpty,
            )
            .toList();

    final stepNumber =
        steps.indexOf(step) + 1;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            width: 30,
            height: 30,

            decoration:
                BoxDecoration(
              color:
                  Colors.deepOrange,
              borderRadius:
                  BorderRadius.circular(
                8,
              ),
            ),

            child: Center(
              child: Text(
                '$stepNumber',

                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              step.trim(),

              style:
                  const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  // ACTION BUTTONS
  

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                _toggleFavorite,

            icon: Icon(
              _isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),

            label: Text(
              _isFavorite
                  ? 'Saved'
                  : 'Save',
            ),

            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  _isFavorite
                      ? Colors.green
                      : Colors.deepOrange,

              foregroundColor:
                  Colors.white,

              padding:
                  const EdgeInsets
                      .symmetric(
                vertical: 14,
              ),

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        
      ],
    );
  }
}