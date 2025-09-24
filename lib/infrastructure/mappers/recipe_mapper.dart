// Recipe Mapper for Clean Architecture Infrastructure Layer
// Handles conversion between Recipe entities and Firestore documents

import 'package:injectable/injectable.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/time.dart';
import '../../domain/value_objects/money.dart';

@injectable
class RecipeMapper {
  /// Converts a Recipe entity to a Firestore-compatible Map
  Map<String, dynamic> toFirestore(Recipe recipe) {
    return {
      'id': recipe.id.value,
      'name': recipe.name,
      'description': recipe.description,
      'category': _recipeCategoryToString(recipe.category),
      'difficulty': _recipeDifficultyToString(recipe.difficulty),
      'preparationTimeMinutes': recipe.preparationTimeMinutes,
      'cookingTimeMinutes': recipe.cookingTimeMinutes,
      'totalTimeMinutes': recipe.totalTimeMinutes,
      'ingredients': recipe.ingredients.map(_ingredientToMap).toList(),
      'instructions': recipe.instructions,
      'price': recipe.price.amount,
      'currency': recipe.price.currency,
      'allergens': recipe.allergens,
      'dietaryCategories': recipe.dietaryCategories
          .map(_dietaryCategoryToString)
          .toList(),
      'isActive': recipe.isActive,
      'createdAt': recipe.createdAt.millisecondsSinceEpoch,
    };
  }

  /// Converts Firestore document data to a Recipe entity
  Recipe fromFirestore(Map<String, dynamic> data, String documentId) {
    return Recipe(
      id: UserId(data['id'] ?? documentId),
      name: data['name'] ?? '',
      description: data['description'],
      category: _stringToRecipeCategory(data['category']),
      difficulty: _stringToRecipeDifficulty(data['difficulty']),
      preparationTimeMinutes: data['preparationTimeMinutes'] ?? 0,
      cookingTimeMinutes: data['cookingTimeMinutes'] ?? 0,
      ingredients: _parseIngredients(data['ingredients']),
      instructions: _parseInstructions(data['instructions']),
      price: Money(
        (data['price'] ?? 0.0).toDouble(),
        currency: data['currency'] ?? 'USD',
      ),
      allergens: _parseAllergens(data['allergens']),
      dietaryCategories: _parseDietaryCategories(data['dietaryCategories']),
      isActive: data['isActive'] ?? true,
      createdAt: Time.fromMillisecondsSinceEpoch(
        data['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Converts Ingredient to Map for Firestore storage
  Map<String, dynamic> _ingredientToMap(Ingredient ingredient) {
    return {
      'name': ingredient.name,
      'quantity': ingredient.quantity,
      'allergens': ingredient.allergens,
      'isOptional': ingredient.isOptional,
    };
  }

  /// Converts Map from Firestore to Ingredient
  Ingredient _mapToIngredient(Map<String, dynamic> data) {
    return Ingredient(
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? '',
      allergens: _parseStringList(data['allergens']),
      isOptional: data['isOptional'] ?? false,
    );
  }

  /// Converts RecipeCategory enum to string for Firestore storage
  String _recipeCategoryToString(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.appetizer:
        return 'appetizer';
      case RecipeCategory.main:
        return 'main';
      case RecipeCategory.dessert:
        return 'dessert';
      case RecipeCategory.beverage:
        return 'beverage';
      case RecipeCategory.side:
        return 'side';
    }
  }

  /// Converts string from Firestore to RecipeCategory enum
  RecipeCategory _stringToRecipeCategory(dynamic value) {
    if (value == null || value is! String) return RecipeCategory.main;

    switch (value.toLowerCase()) {
      case 'appetizer':
        return RecipeCategory.appetizer;
      case 'main':
        return RecipeCategory.main;
      case 'dessert':
        return RecipeCategory.dessert;
      case 'beverage':
        return RecipeCategory.beverage;
      case 'side':
        return RecipeCategory.side;
      default:
        return RecipeCategory.main; // Default fallback
    }
  }

  /// Converts RecipeDifficulty enum to string for Firestore storage
  String _recipeDifficultyToString(RecipeDifficulty difficulty) {
    switch (difficulty) {
      case RecipeDifficulty.easy:
        return 'easy';
      case RecipeDifficulty.medium:
        return 'medium';
      case RecipeDifficulty.hard:
        return 'hard';
    }
  }

  /// Converts string from Firestore to RecipeDifficulty enum
  RecipeDifficulty _stringToRecipeDifficulty(dynamic value) {
    if (value == null || value is! String) return RecipeDifficulty.medium;

    switch (value.toLowerCase()) {
      case 'easy':
        return RecipeDifficulty.easy;
      case 'medium':
        return RecipeDifficulty.medium;
      case 'hard':
        return RecipeDifficulty.hard;
      default:
        return RecipeDifficulty.medium; // Default fallback
    }
  }

  /// Converts DietaryCategory enum to string for Firestore storage
  String _dietaryCategoryToString(DietaryCategory category) {
    switch (category) {
      case DietaryCategory.vegetarian:
        return 'vegetarian';
      case DietaryCategory.vegan:
        return 'vegan';
      case DietaryCategory.glutenFree:
        return 'gluten_free';
      case DietaryCategory.dairyFree:
        return 'dairy_free';
      case DietaryCategory.nutFree:
        return 'nut_free';
    }
  }

  /// Converts string from Firestore to DietaryCategory enum
  DietaryCategory? _stringToDietaryCategory(String value) {
    switch (value.toLowerCase()) {
      case 'vegetarian':
        return DietaryCategory.vegetarian;
      case 'vegan':
        return DietaryCategory.vegan;
      case 'gluten_free':
        return DietaryCategory.glutenFree;
      case 'dairy_free':
        return DietaryCategory.dairyFree;
      case 'nut_free':
        return DietaryCategory.nutFree;
      default:
        return null; // Unknown category
    }
  }

  /// Parses ingredients list from Firestore data
  List<Ingredient> _parseIngredients(dynamic value) {
    if (value == null || value is! List) return [];

    return value
        .map((item) {
          if (item is Map<String, dynamic>) {
            try {
              return _mapToIngredient(item);
            } catch (e) {
              return null; // Skip invalid ingredients
            }
          }
          return null;
        })
        .where((ingredient) => ingredient != null)
        .cast<Ingredient>()
        .toList();
  }

  /// Parses instructions list from Firestore data
  List<String> _parseInstructions(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => item is String ? item : item.toString())
          .where((instruction) => instruction.trim().isNotEmpty)
          .toList();
    }
    return [];
  }

  /// Parses allergens list from Firestore data
  List<String> _parseAllergens(dynamic value) {
    return _parseStringList(value);
  }

  /// Parses dietary categories list from Firestore data
  List<DietaryCategory> _parseDietaryCategories(dynamic value) {
    if (value == null || value is! List) return [];

    return value
        .map((item) {
          if (item is String) {
            return _stringToDietaryCategory(item);
          }
          return null;
        })
        .where((category) => category != null)
        .cast<DietaryCategory>()
        .toList();
  }

  /// Helper method to parse string lists from Firestore data
  List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => item is String ? item : item.toString())
          .toList();
    }
    return [];
  }
}
