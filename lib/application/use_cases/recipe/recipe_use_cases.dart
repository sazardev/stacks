// Recipe Use Cases for Clean Architecture Application Layer

import 'package:dartz/dartz.dart';
import '../../../domain/entities/recipe.dart';
import '../../../domain/repositories/recipe_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/money.dart';
import '../../dtos/recipe_dtos.dart';

/// Use case for creating a recipe
class CreateRecipeUseCase {
  final RecipeRepository _repository;

  CreateRecipeUseCase(this._repository);

  Future<Either<Failure, Recipe>> call(CreateRecipeDto dto) {
    final recipe = dto.toEntity();
    return _repository.createRecipe(recipe);
  }
}

/// Use case for getting recipe by ID
class GetRecipeByIdUseCase {
  final RecipeRepository _repository;

  GetRecipeByIdUseCase(this._repository);

  Future<Either<Failure, Recipe>> call(UserId recipeId) {
    return _repository.getRecipeById(recipeId);
  }
}

/// Use case for getting all recipes
class GetAllRecipesUseCase {
  final RecipeRepository _repository;

  GetAllRecipesUseCase(this._repository);

  Future<Either<Failure, List<Recipe>>> call() {
    return _repository.getAllRecipes();
  }
}

/// Use case for getting recipes by category
class GetRecipesByCategoryUseCase {
  final RecipeRepository _repository;

  GetRecipesByCategoryUseCase(this._repository);

  Future<Either<Failure, List<Recipe>>> call(RecipeCategory category) {
    return _repository.getRecipesByCategory(category);
  }
}

/// Use case for getting recipes by difficulty
class GetRecipesByDifficultyUseCase {
  final RecipeRepository _repository;

  GetRecipesByDifficultyUseCase(this._repository);

  Future<Either<Failure, List<Recipe>>> call(RecipeDifficulty difficulty) {
    return _repository.getRecipesByDifficulty(difficulty);
  }
}

/// Use case for getting active recipes
class GetActiveRecipesUseCase {
  final RecipeRepository _repository;

  GetActiveRecipesUseCase(this._repository);

  Future<Either<Failure, List<Recipe>>> call() {
    return _repository.getActiveRecipes();
  }
}

/// Use case for getting recipes by dietary category
class GetRecipesByDietaryCategoryUseCase {
  final RecipeRepository _repository;

  GetRecipesByDietaryCategoryUseCase(this._repository);

  Future<Either<Failure, List<Recipe>>> call(DietaryCategory dietaryCategory) {
    return _repository.getRecipesByDietaryCategory(dietaryCategory);
  }
}

/// Use case for searching recipes
class SearchRecipesUseCase {
  final RecipeRepository _repository;

  SearchRecipesUseCase(this._repository);

  Future<Either<Failure, List<Recipe>>> call(String query) async {
    // Get all recipes and filter by name/description containing query
    final allRecipesResult = await _repository.getAllRecipes();

    return allRecipesResult.fold((failure) => Left(failure), (recipes) {
      final filteredRecipes = recipes
          .where(
            (recipe) =>
                recipe.name.toLowerCase().contains(query.toLowerCase()) ||
                (recipe.description?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
      return Right(filteredRecipes);
    });
  }
}

/// Use case for getting recipes by price range
class GetRecipesByPriceRangeUseCase {
  final RecipeRepository _repository;

  GetRecipesByPriceRangeUseCase(this._repository);

  Future<Either<Failure, List<Recipe>>> call(Money minPrice, Money maxPrice) {
    return _repository.getRecipesByPriceRange(minPrice, maxPrice);
  }
}

/// Use case for getting recipes by allergens
class GetRecipesByAllergensUseCase {
  final RecipeRepository _repository;

  GetRecipesByAllergensUseCase(this._repository);

  Future<Either<Failure, List<Recipe>>> call(List<String> allergens) async {
    // Get all recipes and filter by allergens
    final allRecipesResult = await _repository.getAllRecipes();

    return allRecipesResult.fold((failure) => Left(failure), (recipes) {
      final filteredRecipes = recipes
          .where(
            (recipe) => !recipe.allergens.any(
              (allergen) => allergens.contains(allergen),
            ),
          )
          .toList();
      return Right(filteredRecipes);
    });
  }
}

/// Use case for updating recipe
class UpdateRecipeUseCase {
  final RecipeRepository _repository;

  UpdateRecipeUseCase(this._repository);

  Future<Either<Failure, Recipe>> call(UpdateRecipeDto dto) async {
    // Get existing recipe
    final existingRecipeResult = await _repository.getRecipeById(
      UserId(dto.id),
    );

    return existingRecipeResult.fold((failure) => Left(failure), (
      existingRecipe,
    ) {
      // Create updated recipe preserving existing data where not provided
      final updatedRecipe = Recipe(
        id: existingRecipe.id,
        name: dto.name ?? existingRecipe.name,
        description: dto.description ?? existingRecipe.description,
        category: dto.category != null
            ? _parseRecipeCategory(dto.category!)
            : existingRecipe.category,
        difficulty: dto.difficulty != null
            ? _parseRecipeDifficulty(dto.difficulty!)
            : existingRecipe.difficulty,
        preparationTimeMinutes:
            dto.prepTimeMinutes ?? existingRecipe.preparationTimeMinutes,
        cookingTimeMinutes:
            dto.cookTimeMinutes ?? existingRecipe.cookingTimeMinutes,
        ingredients:
            dto.ingredients?.map((dto) => dto.toEntity()).toList() ??
            existingRecipe.ingredients,
        instructions: dto.instructions ?? existingRecipe.instructions,
        price: dto.estimatedCost != null
            ? Money(dto.estimatedCost!)
            : existingRecipe.price,
        allergens: dto.allergens ?? existingRecipe.allergens,
        dietaryCategories:
            dto.dietaryCategories?.map(_parseDietaryCategory).toList() ??
            existingRecipe.dietaryCategories,
        isActive: dto.isActive ?? existingRecipe.isActive,
        createdAt: existingRecipe.createdAt,
      );

      return _repository.updateRecipe(updatedRecipe);
    });
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
}

/// Use case for activating recipe
class ActivateRecipeUseCase {
  final RecipeRepository _repository;

  ActivateRecipeUseCase(this._repository);

  Future<Either<Failure, Recipe>> call(UserId recipeId) {
    return _repository.activateRecipe(recipeId);
  }
}

/// Use case for deactivating recipe
class DeactivateRecipeUseCase {
  final RecipeRepository _repository;

  DeactivateRecipeUseCase(this._repository);

  Future<Either<Failure, Recipe>> call(UserId recipeId) {
    return _repository.deactivateRecipe(recipeId);
  }
}

/// Use case for deleting recipe
class DeleteRecipeUseCase {
  final RecipeRepository _repository;

  DeleteRecipeUseCase(this._repository);

  Future<Either<Failure, Unit>> call(UserId recipeId) {
    return _repository.deleteRecipe(recipeId);
  }
}

/// Use case for calculating recipe cost
class CalculateRecipeCostUseCase {
  final RecipeRepository _repository;

  CalculateRecipeCostUseCase(this._repository);

  Future<Either<Failure, Money>> call(UserId recipeId) async {
    // Get recipe and return its price
    final recipeResult = await _repository.getRecipeById(recipeId);

    return recipeResult.fold(
      (failure) => Left(failure),
      (recipe) => Right(recipe.price),
    );
  }
}
