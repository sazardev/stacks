import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/recipe.dart';
import '../../../domain/repositories/recipe_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../dtos/recipe_dtos.dart';

/// Use case for creating recipes with comprehensive validation
@injectable
class CreateRecipeUseCase {
  final RecipeRepository _recipeRepository;

  CreateRecipeUseCase(this._recipeRepository);

  /// Execute the recipe creation use case
  Future<Either<Failure, Recipe>> execute(CreateRecipeDto dto) async {
    try {
      // Step 1: Validate recipe data
      final validation = _validateRecipeData(dto);
      if (validation != null) {
        return Left(ValidationFailure(validation));
      }

      // Step 2: Create recipe entity from DTO
      final recipe = dto.toEntity();

      // Step 3: Save recipe
      final result = await _recipeRepository.createRecipe(recipe);

      return result.fold(
        (failure) => Left(failure),
        (createdRecipe) => Right(createdRecipe),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to create recipe: ${e.toString()}'));
    }
  }

  /// Validate recipe creation data
  String? _validateRecipeData(CreateRecipeDto dto) {
    if (dto.name.trim().isEmpty) {
      return 'Recipe name is required';
    }

    if (dto.name.length > 200) {
      return 'Recipe name cannot exceed 200 characters';
    }

    if (dto.instructions.isEmpty) {
      return 'Recipe instructions are required';
    }

    if (dto.prepTimeMinutes < 0) {
      return 'Preparation time cannot be negative';
    }

    if (dto.cookTimeMinutes < 0) {
      return 'Cooking time cannot be negative';
    }

    if (dto.servings <= 0) {
      return 'Servings must be greater than 0';
    }

    return null;
  }
}

/// Use case for retrieving recipes with filtering capabilities
@injectable
class GetRecipesUseCase {
  final RecipeRepository _recipeRepository;

  GetRecipesUseCase(this._recipeRepository);

  /// Execute the recipe retrieval use case
  Future<Either<Failure, List<Recipe>>> execute({
    String? category,
    String? difficulty,
    int? maxPreparationTime,
  }) async {
    try {
      final result = await _recipeRepository.getAllRecipes();

      return result.fold((failure) => Left(failure), (recipes) {
        // Apply filters if provided
        var filteredRecipes = recipes;

        if (category != null) {
          filteredRecipes = filteredRecipes
              .where(
                (recipe) => recipe.category.toString().toLowerCase().contains(
                  category.toLowerCase(),
                ),
              )
              .toList();
        }

        if (difficulty != null) {
          filteredRecipes = filteredRecipes
              .where(
                (recipe) => recipe.difficulty.toString().toLowerCase().contains(
                  difficulty.toLowerCase(),
                ),
              )
              .toList();
        }

        if (maxPreparationTime != null) {
          filteredRecipes = filteredRecipes
              .where(
                (recipe) => recipe.preparationTimeMinutes <= maxPreparationTime,
              )
              .toList();
        }

        return Right(filteredRecipes);
      });
    } catch (e) {
      return Left(ServerFailure('Failed to get recipes: ${e.toString()}'));
    }
  }
}

/// Use case for getting a recipe by ID
@injectable
class GetRecipeByIdUseCase {
  final RecipeRepository _recipeRepository;

  GetRecipeByIdUseCase(this._recipeRepository);

  /// Execute the recipe retrieval use case
  Future<Either<Failure, Recipe>> execute(UserId recipeId) async {
    try {
      final result = await _recipeRepository.getRecipeById(recipeId);

      return result.fold((failure) => Left(failure), (recipe) => Right(recipe));
    } catch (e) {
      return Left(ServerFailure('Failed to get recipe: ${e.toString()}'));
    }
  }
}
