// Firebase Recipe Repository Implementation - Production Ready
// Real Firestore implementation for recipe management and menu operations

import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/failures/failures.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/money.dart';
import '../config/firebase_config.dart';
import '../config/firebase_collections.dart';
import '../mappers/recipe_mapper.dart';

/// Firebase implementation of RecipeRepository with real Firestore operations
@LazySingleton(as: RecipeRepository)
class FirebaseRecipeRepository implements RecipeRepository {
  final RecipeMapper _recipeMapper;
  late final FirebaseFirestore _firestore;

  FirebaseRecipeRepository(this._recipeMapper) {
    _firestore = FirebaseConfig.firestore;
  }

  CollectionReference<Map<String, dynamic>> get _recipesCollection =>
      _firestore.collection(FirebaseCollections.recipes);

  @override
  Future<Either<Failure, Recipe>> createRecipe(Recipe recipe) async {
    try {
      developer.log(
        'Creating recipe: ${recipe.name}',
        name: 'FirebaseRecipeRepository',
      );

      final recipeData = _recipeMapper.toFirestore(recipe);
      final docRef = await _recipesCollection.add(recipeData);

      // Create recipe with Firestore document ID
      final createdRecipe = Recipe(
        id: UserId(docRef.id),
        name: recipe.name,
        description: recipe.description,
        category: recipe.category,
        difficulty: recipe.difficulty,
        preparationTimeMinutes: recipe.preparationTimeMinutes,
        cookingTimeMinutes: recipe.cookingTimeMinutes,
        ingredients: recipe.ingredients,
        instructions: recipe.instructions,
        price: recipe.price,
        allergens: recipe.allergens,
        dietaryCategories: recipe.dietaryCategories,
        isActive: recipe.isActive,
        createdAt: recipe.createdAt,
      );

      await docRef.update({'id': docRef.id});

      developer.log(
        'Recipe created successfully: ${docRef.id}',
        name: 'FirebaseRecipeRepository',
      );
      return Right(createdRecipe);
    } catch (e, stackTrace) {
      developer.log(
        'Error creating recipe: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(NetworkFailure('Failed to create recipe: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Recipe>> getRecipeById(UserId recipeId) async {
    try {
      developer.log(
        'Getting recipe by ID: ${recipeId.value}',
        name: 'FirebaseRecipeRepository',
      );

      final doc = await _recipesCollection.doc(recipeId.value).get();

      if (!doc.exists) {
        developer.log(
          'Recipe not found: ${recipeId.value}',
          name: 'FirebaseRecipeRepository',
        );
        return Left(NotFoundFailure('Recipe not found'));
      }

      final recipe = _recipeMapper.fromFirestore(doc.data()!, doc.id);
      return Right(recipe);
    } catch (e, stackTrace) {
      developer.log(
        'Error getting recipe: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(NetworkFailure('Failed to get recipe: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getAllRecipes() async {
    try {
      developer.log('Getting all recipes', name: 'FirebaseRecipeRepository');

      final querySnapshot = await _recipesCollection.orderBy('name').get();

      final recipes = querySnapshot.docs
          .map((doc) => _recipeMapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${recipes.length} recipes',
        name: 'FirebaseRecipeRepository',
      );
      return Right(recipes);
    } catch (e, stackTrace) {
      developer.log(
        'Error getting recipes: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(NetworkFailure('Failed to get recipes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getRecipesByCategory(
    RecipeCategory category,
  ) async {
    try {
      developer.log(
        'Getting recipes by category: $category',
        name: 'FirebaseRecipeRepository',
      );

      final categoryString = _recipeCategoryToString(category);
      final querySnapshot = await _recipesCollection
          .where('category', isEqualTo: categoryString)
          .orderBy('name')
          .get();

      final recipes = querySnapshot.docs
          .map((doc) => _recipeMapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${recipes.length} recipes for category $category',
        name: 'FirebaseRecipeRepository',
      );
      return Right(recipes);
    } catch (e, stackTrace) {
      developer.log(
        'Error getting recipes by category: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(
        NetworkFailure('Failed to get recipes by category: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getRecipesByDifficulty(
    RecipeDifficulty difficulty,
  ) async {
    try {
      developer.log(
        'Getting recipes by difficulty: $difficulty',
        name: 'FirebaseRecipeRepository',
      );

      final difficultyString = _recipeDifficultyToString(difficulty);
      final querySnapshot = await _recipesCollection
          .where('difficulty', isEqualTo: difficultyString)
          .orderBy('name')
          .get();

      final recipes = querySnapshot.docs
          .map((doc) => _recipeMapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${recipes.length} recipes with difficulty $difficulty',
        name: 'FirebaseRecipeRepository',
      );
      return Right(recipes);
    } catch (e, stackTrace) {
      developer.log(
        'Error getting recipes by difficulty: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(
        NetworkFailure('Failed to get recipes by difficulty: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getActiveRecipes() async {
    try {
      developer.log('Getting active recipes', name: 'FirebaseRecipeRepository');

      final querySnapshot = await _recipesCollection
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      final recipes = querySnapshot.docs
          .map((doc) => _recipeMapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${recipes.length} active recipes',
        name: 'FirebaseRecipeRepository',
      );
      return Right(recipes);
    } catch (e, stackTrace) {
      developer.log(
        'Error getting active recipes: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(
        NetworkFailure('Failed to get active recipes: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getRecipesByDietaryCategory(
    DietaryCategory dietary,
  ) async {
    try {
      developer.log(
        'Getting recipes by dietary category: $dietary',
        name: 'FirebaseRecipeRepository',
      );

      final dietaryString = _dietaryCategoryToString(dietary);
      final querySnapshot = await _recipesCollection
          .where('dietaryCategory', isEqualTo: dietaryString)
          .orderBy('name')
          .get();

      final recipes = querySnapshot.docs
          .map((doc) => _recipeMapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${recipes.length} recipes for dietary category $dietary',
        name: 'FirebaseRecipeRepository',
      );
      return Right(recipes);
    } catch (e, stackTrace) {
      developer.log(
        'Error getting recipes by dietary category: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(
        NetworkFailure(
          'Failed to get recipes by dietary category: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> searchRecipesByName(String name) async {
    try {
      developer.log(
        'Searching recipes by name: $name',
        name: 'FirebaseRecipeRepository',
      );

      // Note: For better search, consider using Algolia or similar service
      // This is a basic implementation using Firestore array-contains
      final querySnapshot = await _recipesCollection
          .where('searchTerms', arrayContains: name.toLowerCase())
          .orderBy('name')
          .get();

      final recipes = querySnapshot.docs
          .map((doc) => _recipeMapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Found ${recipes.length} recipes matching name search',
        name: 'FirebaseRecipeRepository',
      );
      return Right(recipes);
    } catch (e, stackTrace) {
      developer.log(
        'Error searching recipes by name: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(
        NetworkFailure('Failed to search recipes by name: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> searchRecipesByIngredient(
    String ingredient,
  ) async {
    try {
      developer.log(
        'Searching recipes by ingredient: $ingredient',
        name: 'FirebaseRecipeRepository',
      );

      final querySnapshot = await _recipesCollection
          .where('ingredientNames', arrayContains: ingredient.toLowerCase())
          .orderBy('name')
          .get();

      final recipes = querySnapshot.docs
          .map((doc) => _recipeMapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Found ${recipes.length} recipes with ingredient $ingredient',
        name: 'FirebaseRecipeRepository',
      );
      return Right(recipes);
    } catch (e, stackTrace) {
      developer.log(
        'Error searching recipes by ingredient: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(
        NetworkFailure(
          'Failed to search recipes by ingredient: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getRecipesByPriceRange(
    Money minPrice,
    Money maxPrice,
  ) async {
    try {
      developer.log(
        'Getting recipes by price range: ${minPrice.amount} - ${maxPrice.amount}',
        name: 'FirebaseRecipeRepository',
      );

      final querySnapshot = await _recipesCollection
          .where('price', isGreaterThanOrEqualTo: minPrice.amount)
          .where('price', isLessThanOrEqualTo: maxPrice.amount)
          .orderBy('price')
          .get();

      final recipes = querySnapshot.docs
          .map((doc) => _recipeMapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${recipes.length} recipes in price range',
        name: 'FirebaseRecipeRepository',
      );
      return Right(recipes);
    } catch (e, stackTrace) {
      developer.log(
        'Error getting recipes by price range: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(
        NetworkFailure('Failed to get recipes by price range: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getRecipesByPreparationTime(
    int maxMinutes,
  ) async {
    try {
      developer.log(
        'Getting recipes by preparation time: max $maxMinutes minutes',
        name: 'FirebaseRecipeRepository',
      );

      final querySnapshot = await _recipesCollection
          .where('preparationTime', isLessThanOrEqualTo: maxMinutes)
          .orderBy('preparationTime')
          .get();

      final recipes = querySnapshot.docs
          .map((doc) => _recipeMapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${recipes.length} recipes with prep time ≤ $maxMinutes minutes',
        name: 'FirebaseRecipeRepository',
      );
      return Right(recipes);
    } catch (e, stackTrace) {
      developer.log(
        'Error getting recipes by preparation time: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(
        NetworkFailure(
          'Failed to get recipes by preparation time: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getPopularRecipes() async {
    try {
      developer.log(
        'Getting popular recipes',
        name: 'FirebaseRecipeRepository',
      );

      // Note: This assumes you have an orderCount field for tracking popularity
      final querySnapshot = await _recipesCollection
          .where('isActive', isEqualTo: true)
          .orderBy('orderCount', descending: true)
          .limit(20)
          .get();

      final recipes = querySnapshot.docs
          .map((doc) => _recipeMapper.fromFirestore(doc.data(), doc.id))
          .toList();

      developer.log(
        'Retrieved ${recipes.length} popular recipes',
        name: 'FirebaseRecipeRepository',
      );
      return Right(recipes);
    } catch (e, stackTrace) {
      developer.log(
        'Error getting popular recipes: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(
        NetworkFailure('Failed to get popular recipes: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Recipe>> updateRecipe(Recipe recipe) async {
    try {
      developer.log(
        'Updating recipe: ${recipe.id.value}',
        name: 'FirebaseRecipeRepository',
      );

      final recipeData = _recipeMapper.toFirestore(recipe);
      await _recipesCollection.doc(recipe.id.value).update(recipeData);

      developer.log(
        'Recipe updated successfully: ${recipe.id.value}',
        name: 'FirebaseRecipeRepository',
      );
      return Right(recipe);
    } catch (e, stackTrace) {
      developer.log(
        'Error updating recipe: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(NetworkFailure('Failed to update recipe: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Recipe>> updateRecipePrice(
    UserId recipeId,
    Money price,
  ) async {
    try {
      developer.log(
        'Updating recipe price: ${recipeId.value} to ${price.amount}',
        name: 'FirebaseRecipeRepository',
      );

      await _recipesCollection.doc(recipeId.value).update({
        'price': price.amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Retrieve and return updated recipe
      final updatedRecipeResult = await getRecipeById(recipeId);
      return updatedRecipeResult;
    } catch (e, stackTrace) {
      developer.log(
        'Error updating recipe price: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(
        NetworkFailure('Failed to update recipe price: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Recipe>> updateRecipeTimes(
    UserId recipeId,
    int preparationTime,
    int cookingTime,
  ) async {
    try {
      developer.log(
        'Updating recipe times: ${recipeId.value}',
        name: 'FirebaseRecipeRepository',
      );

      await _recipesCollection.doc(recipeId.value).update({
        'preparationTime': preparationTime,
        'cookingTime': cookingTime,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Retrieve and return updated recipe
      final updatedRecipeResult = await getRecipeById(recipeId);
      return updatedRecipeResult;
    } catch (e, stackTrace) {
      developer.log(
        'Error updating recipe times: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(
        NetworkFailure('Failed to update recipe times: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Recipe>> activateRecipe(UserId recipeId) async {
    try {
      developer.log(
        'Activating recipe: ${recipeId.value}',
        name: 'FirebaseRecipeRepository',
      );

      await _recipesCollection.doc(recipeId.value).update({
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Retrieve and return updated recipe
      final updatedRecipeResult = await getRecipeById(recipeId);
      return updatedRecipeResult;
    } catch (e, stackTrace) {
      developer.log(
        'Error activating recipe: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(NetworkFailure('Failed to activate recipe: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Recipe>> deactivateRecipe(UserId recipeId) async {
    try {
      developer.log(
        'Deactivating recipe: ${recipeId.value}',
        name: 'FirebaseRecipeRepository',
      );

      await _recipesCollection.doc(recipeId.value).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Retrieve and return updated recipe
      final updatedRecipeResult = await getRecipeById(recipeId);
      return updatedRecipeResult;
    } catch (e, stackTrace) {
      developer.log(
        'Error deactivating recipe: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(
        NetworkFailure('Failed to deactivate recipe: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRecipeStatistics(
    UserId recipeId,
  ) async {
    try {
      developer.log(
        'Getting recipe statistics: ${recipeId.value}',
        name: 'FirebaseRecipeRepository',
      );

      final doc = await _recipesCollection.doc(recipeId.value).get();

      if (!doc.exists) {
        return Left(NotFoundFailure('Recipe not found'));
      }

      final data = doc.data()!;
      final recipe = _recipeMapper.fromFirestore(data, doc.id);

      // Calculate basic statistics
      final statistics = {
        'recipeId': recipeId.value,
        'name': recipe.name,
        'category': recipe.category.toString(),
        'difficulty': recipe.difficulty.toString(),
        'preparationTime': recipe.preparationTimeMinutes,
        'cookingTime': recipe.cookingTimeMinutes,
        'totalTime': recipe.totalTimeMinutes,
        'price': recipe.price.amount,
        'ingredientsCount': recipe.ingredients.length,
        'instructionsCount': recipe.instructions.length,
        'allergensCount': recipe.allergens.length,
        'dietaryCategoriesCount': recipe.dietaryCategories.length,
        'isActive': recipe.isActive,
        'orderCount': data['orderCount'] ?? 0,
      };

      developer.log(
        'Retrieved recipe statistics',
        name: 'FirebaseRecipeRepository',
      );
      return Right(statistics);
    } catch (e, stackTrace) {
      developer.log(
        'Error getting recipe statistics: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(
        NetworkFailure('Failed to get recipe statistics: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getIngredientsInventory() async {
    try {
      developer.log(
        'Getting ingredients inventory needs',
        name: 'FirebaseRecipeRepository',
      );

      final querySnapshot = await _recipesCollection
          .where('isActive', isEqualTo: true)
          .get();

      final recipes = querySnapshot.docs
          .map((doc) => _recipeMapper.fromFirestore(doc.data(), doc.id))
          .toList();

      // Aggregate ingredients across all active recipes
      final Map<String, Map<String, dynamic>> ingredientsInventory = {};

      for (final recipe in recipes) {
        for (final ingredient in recipe.ingredients) {
          final ingredientName = ingredient.name.toLowerCase();

          if (ingredientsInventory.containsKey(ingredientName)) {
            ingredientsInventory[ingredientName]!['usedInRecipes'] += 1;
            ingredientsInventory[ingredientName]!['recipes'].add(recipe.name);
          } else {
            ingredientsInventory[ingredientName] = {
              'name': ingredient.name,
              'quantity': ingredient.quantity,
              'usedInRecipes': 1,
              'recipes': [recipe.name],
              'allergens': ingredient.allergens,
              'isOptional': ingredient.isOptional,
            };
          }
        }
      }

      final inventory = {
        'totalIngredients': ingredientsInventory.length,
        'totalRecipes': recipes.length,
        'ingredients': ingredientsInventory,
        'timestamp': DateTime.now().toIso8601String(),
      };

      developer.log(
        'Retrieved ingredients inventory for ${recipes.length} recipes',
        name: 'FirebaseRecipeRepository',
      );
      return Right(inventory);
    } catch (e, stackTrace) {
      developer.log(
        'Error getting ingredients inventory: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(
        NetworkFailure('Failed to get ingredients inventory: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRecipe(UserId recipeId) async {
    try {
      developer.log(
        'Deleting recipe: ${recipeId.value}',
        name: 'FirebaseRecipeRepository',
      );

      await _recipesCollection.doc(recipeId.value).delete();

      developer.log(
        'Recipe deleted successfully: ${recipeId.value}',
        name: 'FirebaseRecipeRepository',
      );
      return const Right(unit);
    } catch (e, stackTrace) {
      developer.log(
        'Error deleting recipe: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Left(NetworkFailure('Failed to delete recipe: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<Recipe>>> watchRecipes() {
    try {
      developer.log(
        'Starting real-time recipes stream',
        name: 'FirebaseRecipeRepository',
      );

      return _recipesCollection.orderBy('name').snapshots().asyncMap((
        querySnapshot,
      ) async {
        try {
          final recipes = querySnapshot.docs
              .map((doc) => _recipeMapper.fromFirestore(doc.data(), doc.id))
              .toList();

          developer.log(
            'Real-time recipes update: ${recipes.length} recipes',
            name: 'FirebaseRecipeRepository',
          );
          return Right<Failure, List<Recipe>>(recipes);
        } catch (e, stackTrace) {
          developer.log(
            'Error in recipes stream: $e',
            error: e,
            stackTrace: stackTrace,
            name: 'FirebaseRecipeRepository',
          );
          return Left<Failure, List<Recipe>>(
            NetworkFailure('Failed to process recipes stream: ${e.toString()}'),
          );
        }
      });
    } catch (e, stackTrace) {
      developer.log(
        'Error creating recipes stream: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Stream.value(
        Left(
          NetworkFailure('Failed to create recipes stream: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Stream<Either<Failure, Recipe>> watchRecipe(UserId recipeId) {
    try {
      developer.log(
        'Starting real-time recipe stream: ${recipeId.value}',
        name: 'FirebaseRecipeRepository',
      );

      return _recipesCollection.doc(recipeId.value).snapshots().asyncMap((
        documentSnapshot,
      ) async {
        try {
          if (!documentSnapshot.exists) {
            developer.log(
              'Recipe not found in stream: ${recipeId.value}',
              name: 'FirebaseRecipeRepository',
            );
            return Left<Failure, Recipe>(NotFoundFailure('Recipe not found'));
          }

          final recipe = _recipeMapper.fromFirestore(
            documentSnapshot.data()!,
            documentSnapshot.id,
          );

          developer.log(
            'Real-time recipe update: ${recipe.name}',
            name: 'FirebaseRecipeRepository',
          );
          return Right<Failure, Recipe>(recipe);
        } catch (e, stackTrace) {
          developer.log(
            'Error in recipe stream: $e',
            error: e,
            stackTrace: stackTrace,
            name: 'FirebaseRecipeRepository',
          );
          return Left<Failure, Recipe>(
            NetworkFailure('Failed to process recipe stream: ${e.toString()}'),
          );
        }
      });
    } catch (e, stackTrace) {
      developer.log(
        'Error creating recipe stream: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseRecipeRepository',
      );
      return Stream.value(
        Left(NetworkFailure('Failed to create recipe stream: ${e.toString()}')),
      );
    }
  }

  // Helper methods for enum conversions
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

  String _dietaryCategoryToString(DietaryCategory dietary) {
    switch (dietary) {
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
