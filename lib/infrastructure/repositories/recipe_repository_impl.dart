// Recipe Repository Implementation for Clean Architecture Infrastructure Layer
// Simplified mock implementation with recipe management and search capabilities

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/failures/failures.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/money.dart';
import '../mappers/recipe_mapper.dart';

@LazySingleton(as: RecipeRepository)
class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeMapper _recipeMapper;

  // In-memory storage for development
  final Map<String, Map<String, dynamic>> _recipes = {};

  RecipeRepositoryImpl({required RecipeMapper recipeMapper})
    : _recipeMapper = recipeMapper;

  @override
  Future<Either<Failure, Recipe>> createRecipe(Recipe recipe) async {
    try {
      if (_recipes.containsKey(recipe.id.value)) {
        return Left(
          ValidationFailure('Recipe already exists: ${recipe.id.value}'),
        );
      }

      final recipeData = _recipeMapper.toFirestore(recipe);
      _recipes[recipe.id.value] = recipeData;

      return Right(recipe);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Recipe>> getRecipeById(UserId recipeId) async {
    try {
      final recipeData = _recipes[recipeId.value];
      if (recipeData == null) {
        return Left(NotFoundFailure('Recipe not found: ${recipeId.value}'));
      }

      final recipe = _recipeMapper.fromFirestore(recipeData, recipeId.value);
      return Right(recipe);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getAllRecipes() async {
    try {
      final recipes = _recipes.entries
          .map((entry) => _recipeMapper.fromFirestore(entry.value, entry.key))
          .toList();
      return Right(recipes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getRecipesByCategory(
    RecipeCategory category,
  ) async {
    try {
      final categoryString = _getCategoryString(category);
      final recipes = _recipes.values
          .where((recipeData) => recipeData['category'] == categoryString)
          .map(
            (recipeData) => _recipeMapper.fromFirestore(
              recipeData,
              recipeData['id'] as String,
            ),
          )
          .toList();
      return Right(recipes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getRecipesByDifficulty(
    RecipeDifficulty difficulty,
  ) async {
    try {
      final difficultyString = _getDifficultyString(difficulty);
      final recipes = _recipes.values
          .where((recipeData) => recipeData['difficulty'] == difficultyString)
          .map(
            (recipeData) => _recipeMapper.fromFirestore(
              recipeData,
              recipeData['id'] as String,
            ),
          )
          .toList();
      return Right(recipes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getActiveRecipes() async {
    try {
      final recipes = _recipes.values
          .where((recipeData) => recipeData['isActive'] as bool? ?? true)
          .map(
            (recipeData) => _recipeMapper.fromFirestore(
              recipeData,
              recipeData['id'] as String,
            ),
          )
          .toList();
      return Right(recipes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getRecipesByDietaryCategory(
    DietaryCategory dietary,
  ) async {
    try {
      final dietaryString = _getDietaryCategoryString(dietary);
      final recipes = _recipes.values
          .where((recipeData) {
            final categories =
                recipeData['dietaryCategories'] as List<dynamic>? ?? [];
            return categories.contains(dietaryString);
          })
          .map(
            (recipeData) => _recipeMapper.fromFirestore(
              recipeData,
              recipeData['id'] as String,
            ),
          )
          .toList();
      return Right(recipes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> searchRecipesByName(String name) async {
    try {
      final lowerName = name.toLowerCase();
      final recipes = _recipes.values
          .where((recipeData) {
            final recipeName = (recipeData['name'] as String? ?? '')
                .toLowerCase();
            return recipeName.contains(lowerName);
          })
          .map(
            (recipeData) => _recipeMapper.fromFirestore(
              recipeData,
              recipeData['id'] as String,
            ),
          )
          .toList();
      return Right(recipes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> searchRecipesByIngredient(
    String ingredient,
  ) async {
    try {
      final lowerIngredient = ingredient.toLowerCase();
      final recipes = _recipes.values
          .where((recipeData) {
            final ingredients =
                recipeData['ingredients'] as List<dynamic>? ?? [];
            return ingredients.any((ingredientMap) {
              if (ingredientMap is Map<String, dynamic>) {
                final name = (ingredientMap['name'] as String? ?? '')
                    .toLowerCase();
                return name.contains(lowerIngredient);
              }
              return false;
            });
          })
          .map(
            (recipeData) => _recipeMapper.fromFirestore(
              recipeData,
              recipeData['id'] as String,
            ),
          )
          .toList();
      return Right(recipes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getRecipesByPriceRange(
    Money minPrice,
    Money maxPrice,
  ) async {
    try {
      final recipes = _recipes.values
          .where((recipeData) {
            final price = (recipeData['price'] as double? ?? 0.0);
            return price >= minPrice.amount && price <= maxPrice.amount;
          })
          .map(
            (recipeData) => _recipeMapper.fromFirestore(
              recipeData,
              recipeData['id'] as String,
            ),
          )
          .toList();
      return Right(recipes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getRecipesByPreparationTime(
    int maxMinutes,
  ) async {
    try {
      final recipes = _recipes.values
          .where((recipeData) {
            final prepTime = recipeData['preparationTimeMinutes'] as int? ?? 0;
            return prepTime <= maxMinutes;
          })
          .map(
            (recipeData) => _recipeMapper.fromFirestore(
              recipeData,
              recipeData['id'] as String,
            ),
          )
          .toList();
      return Right(recipes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getPopularRecipes() async {
    // For mock implementation, return first 10 active recipes
    try {
      final recipes = await getActiveRecipes();
      return recipes.fold(
        (failure) => Left(failure),
        (recipeList) => Right(recipeList.take(10).toList()),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Recipe>> updateRecipe(Recipe recipe) async {
    try {
      if (!_recipes.containsKey(recipe.id.value)) {
        return Left(NotFoundFailure('Recipe not found: ${recipe.id.value}'));
      }

      final recipeData = _recipeMapper.toFirestore(recipe);
      _recipes[recipe.id.value] = recipeData;

      return Right(recipe);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Recipe>> updateRecipePrice(
    UserId recipeId,
    Money price,
  ) async {
    try {
      final result = await getRecipeById(recipeId);
      return result.fold((failure) => Left(failure), (recipe) {
        final recipeData = _recipes[recipeId.value]!;
        recipeData['price'] = price.amount;
        recipeData['currency'] = price.currency;

        final updatedRecipe = _recipeMapper.fromFirestore(
          recipeData,
          recipeId.value,
        );
        return Right(updatedRecipe);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Recipe>> updateRecipeTimes(
    UserId recipeId,
    int preparationTime,
    int cookingTime,
  ) async {
    try {
      final recipeData = _recipes[recipeId.value];
      if (recipeData == null) {
        return Left(NotFoundFailure('Recipe not found: ${recipeId.value}'));
      }

      recipeData['preparationTimeMinutes'] = preparationTime;
      recipeData['cookingTimeMinutes'] = cookingTime;
      recipeData['totalTimeMinutes'] = preparationTime + cookingTime;

      final recipe = _recipeMapper.fromFirestore(recipeData, recipeId.value);
      return Right(recipe);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Recipe>> activateRecipe(UserId recipeId) async {
    try {
      final recipeData = _recipes[recipeId.value];
      if (recipeData == null) {
        return Left(NotFoundFailure('Recipe not found: ${recipeId.value}'));
      }

      recipeData['isActive'] = true;
      final recipe = _recipeMapper.fromFirestore(recipeData, recipeId.value);
      return Right(recipe);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Recipe>> deactivateRecipe(UserId recipeId) async {
    try {
      final recipeData = _recipes[recipeId.value];
      if (recipeData == null) {
        return Left(NotFoundFailure('Recipe not found: ${recipeId.value}'));
      }

      recipeData['isActive'] = false;
      final recipe = _recipeMapper.fromFirestore(recipeData, recipeId.value);
      return Right(recipe);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRecipeStatistics(
    UserId recipeId,
  ) async {
    try {
      final result = await getRecipeById(recipeId);
      return result.fold((failure) => Left(failure), (recipe) {
        final statistics = <String, dynamic>{
          'recipeId': recipe.id.value,
          'name': recipe.name,
          'category': recipe.category.name,
          'difficulty': recipe.difficulty.name,
          'totalTimeMinutes': recipe.totalTimeMinutes,
          'ingredientsCount': recipe.ingredients.length,
          'instructionsCount': recipe.instructions.length,
          'price': recipe.price.amount,
          'allergensCount': recipe.allergens.length,
          'dietaryCategories': recipe.dietaryCategories
              .map((c) => c.name)
              .toList(),
          'isActive': recipe.isActive,
        };
        return Right(statistics);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getIngredientsInventory() async {
    try {
      final allIngredients = <String, int>{};

      for (final recipeData in _recipes.values) {
        final ingredients = recipeData['ingredients'] as List<dynamic>? ?? [];
        for (final ingredientMap in ingredients) {
          if (ingredientMap is Map<String, dynamic>) {
            final name = ingredientMap['name'] as String? ?? '';
            if (name.isNotEmpty) {
              allIngredients[name] = (allIngredients[name] ?? 0) + 1;
            }
          }
        }
      }

      final inventory = <String, dynamic>{
        'totalUniqueIngredients': allIngredients.length,
        'ingredientUsage': allIngredients,
        'mostUsedIngredients': allIngredients.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      };

      return Right(inventory);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRecipe(UserId recipeId) async {
    try {
      if (!_recipes.containsKey(recipeId.value)) {
        return Left(NotFoundFailure('Recipe not found: ${recipeId.value}'));
      }

      _recipes.remove(recipeId.value);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Recipe>>> watchRecipes() {
    return Stream.periodic(const Duration(seconds: 2), (_) {
      try {
        final recipes = _recipes.values
            .map(
              (recipeData) => _recipeMapper.fromFirestore(
                recipeData,
                recipeData['id'] as String,
              ),
            )
            .toList();
        return Right<Failure, List<Recipe>>(recipes);
      } catch (e) {
        return Left<Failure, List<Recipe>>(ServerFailure(e.toString()));
      }
    });
  }

  @override
  Stream<Either<Failure, Recipe>> watchRecipe(UserId recipeId) {
    return Stream.periodic(const Duration(seconds: 2), (_) {
      try {
        final recipeData = _recipes[recipeId.value];
        if (recipeData == null) {
          return Left<Failure, Recipe>(
            NotFoundFailure('Recipe not found: ${recipeId.value}'),
          );
        }

        final recipe = _recipeMapper.fromFirestore(recipeData, recipeId.value);
        return Right<Failure, Recipe>(recipe);
      } catch (e) {
        return Left<Failure, Recipe>(ServerFailure(e.toString()));
      }
    });
  }

  // Helper methods for enum conversions
  String _getCategoryString(RecipeCategory category) {
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

  String _getDifficultyString(RecipeDifficulty difficulty) {
    switch (difficulty) {
      case RecipeDifficulty.easy:
        return 'easy';
      case RecipeDifficulty.medium:
        return 'medium';
      case RecipeDifficulty.hard:
        return 'hard';
    }
  }

  String _getDietaryCategoryString(DietaryCategory category) {
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
}
