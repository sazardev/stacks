import 'package:dartz/dartz.dart' show Either, Unit;
import '../entities/recipe.dart';
import '../value_objects/user_id.dart';
import '../value_objects/money.dart';
import '../failures/failures.dart';

/// Repository interface for Recipe operations
abstract class RecipeRepository {
  /// Creates a new recipe
  Future<Either<Failure, Recipe>> createRecipe(Recipe recipe);

  /// Gets a recipe by its ID
  Future<Either<Failure, Recipe>> getRecipeById(UserId recipeId);

  /// Gets all recipes
  Future<Either<Failure, List<Recipe>>> getAllRecipes();

  /// Gets recipes by category
  Future<Either<Failure, List<Recipe>>> getRecipesByCategory(
    RecipeCategory category,
  );

  /// Gets recipes by difficulty
  Future<Either<Failure, List<Recipe>>> getRecipesByDifficulty(
    RecipeDifficulty difficulty,
  );

  /// Gets active recipes
  Future<Either<Failure, List<Recipe>>> getActiveRecipes();

  /// Gets recipes by dietary category
  Future<Either<Failure, List<Recipe>>> getRecipesByDietaryCategory(
    DietaryCategory dietary,
  );

  /// Searches recipes by name
  Future<Either<Failure, List<Recipe>>> searchRecipesByName(String name);

  /// Searches recipes by ingredient
  Future<Either<Failure, List<Recipe>>> searchRecipesByIngredient(
    String ingredient,
  );

  /// Gets recipes by price range
  Future<Either<Failure, List<Recipe>>> getRecipesByPriceRange(
    Money minPrice,
    Money maxPrice,
  );

  /// Gets recipes by preparation time
  Future<Either<Failure, List<Recipe>>> getRecipesByPreparationTime(
    int maxMinutes,
  );

  /// Gets popular recipes
  Future<Either<Failure, List<Recipe>>> getPopularRecipes();

  /// Updates a recipe
  Future<Either<Failure, Recipe>> updateRecipe(Recipe recipe);

  /// Updates recipe price
  Future<Either<Failure, Recipe>> updateRecipePrice(
    UserId recipeId,
    Money price,
  );

  /// Updates recipe times
  Future<Either<Failure, Recipe>> updateRecipeTimes(
    UserId recipeId,
    int preparationTime,
    int cookingTime,
  );

  /// Activates a recipe
  Future<Either<Failure, Recipe>> activateRecipe(UserId recipeId);

  /// Deactivates a recipe
  Future<Either<Failure, Recipe>> deactivateRecipe(UserId recipeId);

  /// Gets recipe statistics
  Future<Either<Failure, Map<String, dynamic>>> getRecipeStatistics(
    UserId recipeId,
  );

  /// Gets ingredients inventory needs
  Future<Either<Failure, Map<String, dynamic>>> getIngredientsInventory();

  /// Deletes a recipe
  Future<Either<Failure, Unit>> deleteRecipe(UserId recipeId);

  /// Watches real-time recipe updates
  Stream<Either<Failure, List<Recipe>>> watchRecipes();

  /// Watches specific recipe updates
  Stream<Either<Failure, Recipe>> watchRecipe(UserId recipeId);
}
