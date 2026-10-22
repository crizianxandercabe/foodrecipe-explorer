class Meal {
  final String id;
  final String name;
  final String? image;
  final String? category;
  final String? area;
  // Used by foreign recipes such as TheMealDB.
  final String? instructions;

  // Used mainly by the Filipino Food API.
  final String? description;

  // Filipino Food API additional information.
  final List<String> occasions;
  final List<String> flavorProfile;
  final List<String> cookingMethods;
  final List<String> tags;

  final bool isLocal;

  final List<String> ingredients;
  final List<String> measurements;

  final int servings;

  Meal({
    required this.id,
    required this.name,
    this.image,
    this.category,
    this.area,
    this.instructions,
    this.description,
    this.occasions = const [],
    this.flavorProfile = const [],
    this.cookingMethods = const [],
    this.tags = const [],
    this.isLocal = false,
    this.ingredients = const [],
    this.measurements = const [],
    this.servings = 4,
  });

  // ============================================================
  // FOREIGN RECIPE
  // ============================================================

  factory Meal.fromJson(Map<String, dynamic> json) {
    final ingredients = <String>[];
    final measurements = <String>[];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'] as String?;
      final measure = json['strMeasure$i'] as String?;

      if (ingredient != null &&
          ingredient.trim().isNotEmpty) {
        ingredients.add(ingredient.trim());
        measurements.add(measure?.trim() ?? '');
      }
    }

    return Meal(
      id: json['idMeal']?.toString() ??
          json['id']?.toString() ??
          '',

      name: json['strMeal']?.toString() ??
          json['name']?.toString() ??
          'Unknown',

      image: json['strMealThumb']?.toString() ??
          json['image']?.toString(),

      category: json['strCategory']?.toString() ??
          json['category']?.toString(),

      area: json['strArea']?.toString() ??
          json['area']?.toString(),

      instructions: json['strInstructions']?.toString() ??
          json['instructions']?.toString(),

      description: json['description']?.toString(),

      isLocal: false,

      ingredients: ingredients,
      measurements: measurements,

      servings: 4,
    );
  }

  // ============================================================
  // LOCAL / FILIPINO RECIPE
  // ============================================================

  factory Meal.local({
    required String id,
    required String name,
    String? image,
    String? category,
    String? area,
    String? instructions,
    String? description,

    List<String> occasions = const [],
    List<String> flavorProfile = const [],
    List<String> cookingMethods = const [],
    List<String> tags = const [],

    List<String> ingredients = const [],
    List<String> measurements = const [],

    int servings = 4,
  }) {
    return Meal(
      id: id,
      name: name,
      image: image,
      category: category,
      area: area,
      instructions: instructions,
      description: description,

      occasions: occasions,
      flavorProfile: flavorProfile,
      cookingMethods: cookingMethods,
      tags: tags,

      isLocal: true,

      ingredients: ingredients,
      measurements: measurements,

      servings: servings,
    );
  }

  // ============================================================
  // SCALE SERVINGS
  // ============================================================

  Meal scaleServings(int newServings) {
    if (newServings == servings) {
      return this;
    }

    final scaleFactor = newServings / servings;

    final newMeasurements = measurements.map((measure) {
      final numericValue = _extractNumericValue(measure);

      if (numericValue != null) {
        final scaledValue =
            (numericValue * scaleFactor).toStringAsFixed(1);

        return measure.replaceFirst(
          numericValue.toString(),
          scaledValue,
        );
      }

      return measure;
    }).toList();

    return Meal(
      id: id,
      name: name,
      image: image,
      category: category,
      area: area,

      instructions: instructions,
      description: description,

      occasions: occasions,
      flavorProfile: flavorProfile,
      cookingMethods: cookingMethods,
      tags: tags,

      isLocal: isLocal,

      ingredients: ingredients,
      measurements: newMeasurements,

      servings: newServings,
    );
  }

  // ============================================================
  // GET NUMBER FROM MEASUREMENT
  // ============================================================

  static double? _extractNumericValue(String measure) {
    final regex = RegExp(r'(\d+\.?\d*)');

    final match = regex.firstMatch(measure);

    if (match != null) {
      return double.tryParse(match.group(1)!);
    }

    return null;
  }

  // ============================================================
  // JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'category': category,
      'area': area,

      'instructions': instructions,
      'description': description,

      'occasions': occasions,
      'flavorProfile': flavorProfile,
      'cookingMethods': cookingMethods,
      'tags': tags,

      'isLocal': isLocal,

      'ingredients': ingredients,
      'measurements': measurements,

      'servings': servings,
    };
  }
}