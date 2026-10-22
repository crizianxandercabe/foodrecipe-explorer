import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/favorite_service.dart';

class RecipeCard extends StatefulWidget {
  final Meal meal;
  final VoidCallback onTap;

  final Future<void> Function()? onFavoriteChanged;

  const RecipeCard({
    super.key,
    required this.meal,
    required this.onTap,
    this.onFavoriteChanged,
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  final FavoriteService _favoriteService = FavoriteService();

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final isFavorite =
        await _favoriteService.isFavorite(widget.meal.id);

    if (!mounted) return;

    setState(() {
      _isFavorite = isFavorite;
    });
  }

  Future<void> _toggleFavorite() async {
    await _favoriteService.toggleFavorite(
      widget.meal.id,
    );

    if (!mounted) return;

    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (widget.onFavoriteChanged != null) {
      await widget.onFavoriteChanged!();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? '${widget.meal.name} added to favorites'
              : '${widget.meal.name} removed from favorites',
        ),
        backgroundColor:
            _isFavorite ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: widget.meal.image != null &&
                          widget.meal.image!
                              .trim()
                              .isNotEmpty
                      ? Image.network(
                          widget.meal.image!,
                          fit: BoxFit.cover,
                          webHtmlElementStrategy:
                              WebHtmlElementStrategy.prefer,
                          loadingBuilder:
                              (
                            context,
                            child,
                            loadingProgress,
                          ) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return const Center(
                              child:
                                  CircularProgressIndicator(
                                color: Colors.deepOrange,
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorBuilder:
                              (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Center(
                              child: Icon(
                                Icons.restaurant,
                                size: 55,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.restaurant,
                            size: 55,
                            color: Colors.grey,
                          ),
                        ),
                ),

                // ============================================
                // LOCAL / FOREIGN BADGE
                // ============================================

                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.meal.isLocal
                          ? Colors.deepOrange
                          : Colors.blue,
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.meal.isLocal
                              ? Icons.flag
                              : Icons.public,
                          color: Colors.white,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.meal.isLocal
                              ? 'Local'
                              : 'Foreign',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ============================================
                // FAVORITE BUTTON
                // ============================================

                Positioned(
                  top: 10,
                  right: 10,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder:
                          const CircleBorder(),
                      onTap: _toggleFavorite,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(8),
                        child: Icon(
                          _isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _isFavorite
                              ? Colors.red
                              : Colors.grey[700],
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                // ============================================
                // SERVINGS
                // ============================================

                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Colors.black.withValues(
                        alpha: 0.65,
                      ),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people,
                          color: Colors.white,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.meal.servings}',
                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ============================================
            // RECIPE INFORMATION
            // ============================================

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // RECIPE NAME
                  Text(
                    widget.meal.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // CATEGORY
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 15,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.meal.category ??
                              'Unknown',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // AREA / COUNTRY
                  if (widget.meal.area != null &&
                      widget.meal.area!
                          .trim()
                          .isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 15,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.meal.area!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 10),

                  // VIEW RECIPE
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange
                          .withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 15,
                          color:
                              Colors.deepOrange[700],
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'View Recipe',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Colors.deepOrange[700],
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}