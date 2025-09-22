import '../value_objects/user_id.dart';
import '../value_objects/time.dart';
import '../value_objects/money.dart';
import '../exceptions/domain_exception.dart';

/// Recipe categories available in the kitchen
enum RecipeCategory { appetizer, main, dessert, beverage, side }

/// Recipe difficulty levels
enum RecipeDifficulty { easy, medium, hard }

/// Dietary categories for recipes
enum DietaryCategory { vegetarian, vegan, glutenFree, dairyFree, nutFree }

/// Ingredient entity for recipes
class Ingredient {
  static const int _maxNameLength = 100;
  static const int _maxQuantityLength = 50;

  final String _name;
  final String _quantity;
  final List<String> _allergens;
  final bool _isOptional;

  /// Creates an Ingredient with the specified properties
  Ingredient({
    required String name,
    required String quantity,
    List<String>? allergens,
    bool isOptional = false,
  }) : _name = _validateName(name),
       _quantity = _validateQuantity(quantity),
       _allergens = List.unmodifiable(allergens ?? []),
       _isOptional = isOptional;

  /// Ingredient name
  String get name => _name;

  /// Ingredient quantity
  String get quantity => _quantity;

  /// Allergens in this ingredient
  List<String> get allergens => _allergens;

  /// Whether this ingredient is optional
  bool get isOptional => _isOptional;

  /// Validates ingredient name
  static String _validateName(String name) {
    if (name.trim().isEmpty) {
      throw const DomainException('Ingredient name cannot be empty');
    }

    if (name.length > _maxNameLength) {
      throw DomainException(
        'Ingredient name cannot exceed $_maxNameLength characters',
      );
    }

    return name.trim();
  }

  /// Validates ingredient quantity
  static String _validateQuantity(String quantity) {
    if (quantity.trim().isEmpty) {
      throw const DomainException('Ingredient quantity cannot be empty');
    }

    if (quantity.length > _maxQuantityLength) {
      throw DomainException(
        'Ingredient quantity cannot exceed $_maxQuantityLength characters',
      );
    }

    return quantity.trim();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient &&
          runtimeType == other.runtimeType &&
          _name == other._name &&
          _quantity == other._quantity;

  @override
  int get hashCode => Object.hash(_name, _quantity);

  @override
  String toString() => 'Ingredient(name: $_name, quantity: $_quantity)';
}

/// Recipe entity representing a dish that can be prepared
class Recipe {
  static const int _maxNameLength = 200;
  static const int _maxDescriptionLength = 1000;
  static const int _maxInstructionLength = 500;
  static const int _maxIngredientsCount = 50;
  static const int _maxInstructionsCount = 30;
  static const int _complexityThresholdIngredients = 10;
  static const int _complexityThresholdInstructions = 8;
  static const int _complexityThresholdTime = 60; // minutes

  final UserId _id;
  final String _name;
  final String? _description;
  final RecipeCategory _category;
  final RecipeDifficulty _difficulty;
  final int _preparationTimeMinutes;
  final int _cookingTimeMinutes;
  final List<Ingredient> _ingredients;
  final List<String> _instructions;
  final Money _price;
  final List<String> _allergens;
  final List<DietaryCategory> _dietaryCategories;
  final bool _isActive;
  final Time _createdAt;

  /// Creates a Recipe with the specified properties
  Recipe({
    required UserId id,
    required String name,
    String? description,
    required RecipeCategory category,
    required RecipeDifficulty difficulty,
    required int preparationTimeMinutes,
    required int cookingTimeMinutes,
    required List<Ingredient> ingredients,
    required List<String> instructions,
    required Money price,
    List<String>? allergens,
    List<DietaryCategory>? dietaryCategories,
    bool isActive = true,
    required Time createdAt,
  }) : _id = id,
       _name = _validateName(name),
       _description = _validateDescription(description),
       _category = category,
       _difficulty = difficulty,
       _preparationTimeMinutes = _validateTimeMinutes(
         preparationTimeMinutes,
         'preparation',
       ),
       _cookingTimeMinutes = _validateTimeMinutes(
         cookingTimeMinutes,
         'cooking',
       ),
       _ingredients = _validateIngredients(ingredients),
       _instructions = _validateInstructions(instructions),
       _price = price,
       _allergens = List.unmodifiable(allergens ?? []),
       _dietaryCategories = List.unmodifiable(dietaryCategories ?? []),
       _isActive = isActive,
       _createdAt = createdAt;

  /// Recipe ID
  UserId get id => _id;

  /// Recipe name
  String get name => _name;

  /// Recipe description
  String? get description => _description;

  /// Recipe category
  RecipeCategory get category => _category;

  /// Recipe difficulty level
  RecipeDifficulty get difficulty => _difficulty;

  /// Preparation time in minutes
  int get preparationTimeMinutes => _preparationTimeMinutes;

  /// Cooking time in minutes
  int get cookingTimeMinutes => _cookingTimeMinutes;

  /// Total time (preparation + cooking) in minutes
  int get totalTimeMinutes => _preparationTimeMinutes + _cookingTimeMinutes;

  /// List of ingredients
  List<Ingredient> get ingredients => _ingredients;

  /// List of preparation instructions
  List<String> get instructions => _instructions;

  /// Recipe price
  Money get price => _price;

  /// List of allergens
  List<String> get allergens => _allergens;

  /// Dietary categories
  List<DietaryCategory> get dietaryCategories => _dietaryCategories;

  /// Whether the recipe is active
  bool get isActive => _isActive;

  /// When the recipe was created
  Time get createdAt => _createdAt;

  /// Validates recipe name
  static String _validateName(String name) {
    if (name.trim().isEmpty) {
      throw const DomainException('Recipe name cannot be empty');
    }

    if (name.length > _maxNameLength) {
      throw DomainException(
        'Recipe name cannot exceed $_maxNameLength characters',
      );
    }

    return name.trim();
  }

  /// Validates recipe description
  static String? _validateDescription(String? description) {
    if (description == null) return null;

    if (description.length > _maxDescriptionLength) {
      throw DomainException(
        'Recipe description cannot exceed $_maxDescriptionLength characters',
      );
    }

    return description.trim().isEmpty ? null : description.trim();
  }

  /// Validates time values
  static int _validateTimeMinutes(int timeMinutes, String type) {
    if (timeMinutes < 0) {
      throw DomainException('Recipe $type time cannot be negative');
    }

    return timeMinutes;
  }

  /// Validates ingredients list
  static List<Ingredient> _validateIngredients(List<Ingredient> ingredients) {
    if (ingredients.isEmpty) {
      throw const DomainException('Recipe must have at least one ingredient');
    }

    if (ingredients.length > _maxIngredientsCount) {
      throw DomainException(
        'Recipe cannot have more than $_maxIngredientsCount ingredients',
      );
    }

    return List.unmodifiable(ingredients);
  }

  /// Validates instructions list
  static List<String> _validateInstructions(List<String> instructions) {
    if (instructions.isEmpty) {
      throw const DomainException('Recipe must have at least one instruction');
    }

    if (instructions.length > _maxInstructionsCount) {
      throw DomainException(
        'Recipe cannot have more than $_maxInstructionsCount instructions',
      );
    }

    for (final instruction in instructions) {
      if (instruction.trim().isEmpty) {
        throw const DomainException('Recipe instructions cannot be empty');
      }

      if (instruction.length > _maxInstructionLength) {
        throw DomainException(
          'Recipe instruction cannot exceed $_maxInstructionLength characters',
        );
      }
    }

    return List.unmodifiable(instructions.map((i) => i.trim()).toList());
  }

  // Category checkers
  bool get isAppetizer => _category == RecipeCategory.appetizer;
  bool get isMainCourse => _category == RecipeCategory.main;
  bool get isDessert => _category == RecipeCategory.dessert;
  bool get isBeverage => _category == RecipeCategory.beverage;
  bool get isSide => _category == RecipeCategory.side;

  // Difficulty checkers
  bool get isEasy => _difficulty == RecipeDifficulty.easy;
  bool get isMedium => _difficulty == RecipeDifficulty.medium;
  bool get isHard => _difficulty == RecipeDifficulty.hard;

  // Dietary checkers
  bool get isVegetarian =>
      _dietaryCategories.contains(DietaryCategory.vegetarian) ||
      _dietaryCategories.contains(DietaryCategory.vegan);
  bool get isVegan => _dietaryCategories.contains(DietaryCategory.vegan);
  bool get isGlutenFree =>
      _dietaryCategories.contains(DietaryCategory.glutenFree);
  bool get isDairyFree =>
      _dietaryCategories.contains(DietaryCategory.dairyFree);
  bool get isNutFree => _dietaryCategories.contains(DietaryCategory.nutFree);

  /// Whether the recipe requires cooking (cooking time > 0)
  bool get requiresCooking => _cookingTimeMinutes > 0;

  /// Whether the recipe is complex based on ingredients count, instructions, and time
  bool get isComplex =>
      _ingredients.length >= _complexityThresholdIngredients ||
      _instructions.length >= _complexityThresholdInstructions ||
      totalTimeMinutes >= _complexityThresholdTime;

  /// Updates recipe details
  Recipe updateDetails({String? name, String? description, Money? price}) {
    return Recipe(
      id: _id,
      name: name ?? _name,
      description: description ?? _description,
      category: _category,
      difficulty: _difficulty,
      preparationTimeMinutes: _preparationTimeMinutes,
      cookingTimeMinutes: _cookingTimeMinutes,
      ingredients: _ingredients,
      instructions: _instructions,
      price: price ?? _price,
      allergens: _allergens,
      dietaryCategories: _dietaryCategories,
      isActive: _isActive,
      createdAt: _createdAt,
    );
  }

  /// Updates cooking times
  Recipe updateTimes({int? preparationTimeMinutes, int? cookingTimeMinutes}) {
    return Recipe(
      id: _id,
      name: _name,
      description: _description,
      category: _category,
      difficulty: _difficulty,
      preparationTimeMinutes: preparationTimeMinutes ?? _preparationTimeMinutes,
      cookingTimeMinutes: cookingTimeMinutes ?? _cookingTimeMinutes,
      ingredients: _ingredients,
      instructions: _instructions,
      price: _price,
      allergens: _allergens,
      dietaryCategories: _dietaryCategories,
      isActive: _isActive,
      createdAt: _createdAt,
    );
  }

  /// Activates the recipe
  Recipe activate() {
    return Recipe(
      id: _id,
      name: _name,
      description: _description,
      category: _category,
      difficulty: _difficulty,
      preparationTimeMinutes: _preparationTimeMinutes,
      cookingTimeMinutes: _cookingTimeMinutes,
      ingredients: _ingredients,
      instructions: _instructions,
      price: _price,
      allergens: _allergens,
      dietaryCategories: _dietaryCategories,
      isActive: true,
      createdAt: _createdAt,
    );
  }

  /// Deactivates the recipe
  Recipe deactivate() {
    return Recipe(
      id: _id,
      name: _name,
      description: _description,
      category: _category,
      difficulty: _difficulty,
      preparationTimeMinutes: _preparationTimeMinutes,
      cookingTimeMinutes: _cookingTimeMinutes,
      ingredients: _ingredients,
      instructions: _instructions,
      price: _price,
      allergens: _allergens,
      dietaryCategories: _dietaryCategories,
      isActive: false,
      createdAt: _createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() {
    return 'Recipe(id: ${_id.value}, name: $_name, category: ${_category.name}, '
        'difficulty: ${_difficulty.name}, time: ${totalTimeMinutes}min, '
        'price: ${_price.toString()})';
  }
}
