// Recipe Management DTOs for Clean Architecture Application Layer

import 'package:equatable/equatable.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/value_objects/time.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/money.dart';

/// DTO for creating a recipe
class CreateRecipeDto extends Equatable {
  final String name;
  final String description;
  final String category;
  final String difficulty;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final List<IngredientDto> ingredients;
  final List<String> instructions;
  final List<String> dietaryCategories;
  final double? estimatedCost;
  final String? notes;
  final List<String>? allergens;

  const CreateRecipeDto({
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    this.dietaryCategories = const [],
    this.estimatedCost,
    this.notes,
    this.allergens,
  });

  /// Convert DTO to Recipe entity
  Recipe toEntity() {
    return Recipe(
      id: UserId.generate(),
      name: name,
      description: description,
      category: _parseRecipeCategory(category),
      difficulty: _parseRecipeDifficulty(difficulty),
      preparationTimeMinutes: prepTimeMinutes,
      cookingTimeMinutes: cookTimeMinutes,
      ingredients: ingredients.map((dto) => dto.toEntity()).toList(),
      instructions: instructions,
      price: Money(estimatedCost ?? 0.0),
      allergens: allergens,
      dietaryCategories: dietaryCategories.map(_parseDietaryCategory).toList(),
      isActive: true,
      createdAt: Time.now(),
    );
  }

  RecipeCategory _parseRecipeCategory(String category) {
    switch (category.toLowerCase()) {
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
        return RecipeCategory.main;
    }
  }

  RecipeDifficulty _parseRecipeDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return RecipeDifficulty.easy;
      case 'medium':
        return RecipeDifficulty.medium;
      case 'hard':
        return RecipeDifficulty.hard;
      default:
        return RecipeDifficulty.medium;
    }
  }

  DietaryCategory _parseDietaryCategory(String category) {
    switch (category.toLowerCase()) {
      case 'vegetarian':
        return DietaryCategory.vegetarian;
      case 'vegan':
        return DietaryCategory.vegan;
      case 'glutenfree':
        return DietaryCategory.glutenFree;
      case 'dairyfree':
        return DietaryCategory.dairyFree;
      case 'nutfree':
        return DietaryCategory.nutFree;
      default:
        return DietaryCategory.vegetarian;
    }
  }

  @override
  List<Object?> get props => [
    name,
    description,
    category,
    difficulty,
    prepTimeMinutes,
    cookTimeMinutes,
    servings,
    ingredients,
    instructions,
    dietaryCategories,
    estimatedCost,
    notes,
    allergens,
  ];
}

/// DTO for ingredient in recipe
class IngredientDto extends Equatable {
  final String name;
  final String quantity;
  final List<String> allergens;
  final bool isOptional;

  const IngredientDto({
    required this.name,
    required this.quantity,
    this.allergens = const [],
    this.isOptional = false,
  });

  /// Convert DTO to Ingredient entity
  Ingredient toEntity() {
    return Ingredient(
      name: name,
      quantity: quantity,
      allergens: allergens,
      isOptional: isOptional,
    );
  }

  @override
  List<Object?> get props => [name, quantity, allergens, isOptional];
}

/// DTO for updating a recipe
class UpdateRecipeDto extends Equatable {
  final String id;
  final String? name;
  final String? description;
  final String? category;
  final String? difficulty;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? servings;
  final List<IngredientDto>? ingredients;
  final List<String>? instructions;
  final List<String>? dietaryCategories;
  final double? estimatedCost;
  final String? notes;
  final List<String>? allergens;
  final bool? isActive;

  const UpdateRecipeDto({
    required this.id,
    this.name,
    this.description,
    this.category,
    this.difficulty,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings,
    this.ingredients,
    this.instructions,
    this.dietaryCategories,
    this.estimatedCost,
    this.notes,
    this.allergens,
    this.isActive,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    category,
    difficulty,
    prepTimeMinutes,
    cookTimeMinutes,
    servings,
    ingredients,
    instructions,
    dietaryCategories,
    estimatedCost,
    notes,
    allergens,
    isActive,
  ];
}

/// DTO for recipe queries
class RecipeQueryDto extends Equatable {
  final String? category;
  final String? difficulty;
  final List<String>? dietaryCategories;
  final int? maxPrepTime;
  final int? maxCookTime;
  final int? servings;
  final double? maxCost;
  final List<String>? excludeAllergens;
  final bool? isActive;

  const RecipeQueryDto({
    this.category,
    this.difficulty,
    this.dietaryCategories,
    this.maxPrepTime,
    this.maxCookTime,
    this.servings,
    this.maxCost,
    this.excludeAllergens,
    this.isActive,
  });

  @override
  List<Object?> get props => [
    category,
    difficulty,
    dietaryCategories,
    maxPrepTime,
    maxCookTime,
    servings,
    maxCost,
    excludeAllergens,
    isActive,
  ];
}

/// DTO for recipe nutrition calculation
class RecipeNutritionDto extends Equatable {
  final String recipeId;
  final int servings;
  final Map<String, double> nutritionalValues;

  const RecipeNutritionDto({
    required this.recipeId,
    required this.servings,
    required this.nutritionalValues,
  });

  @override
  List<Object?> get props => [recipeId, servings, nutritionalValues];
}
