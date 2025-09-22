import 'package:flutter_test/flutter_test.dart';
import 'package:stacks/domain/entities/recipe.dart';
import 'package:stacks/domain/value_objects/user_id.dart';
import 'package:stacks/domain/value_objects/time.dart';
import 'package:stacks/domain/value_objects/money.dart';
import 'package:stacks/domain/exceptions/domain_exception.dart';

void main() {
  group('Recipe', () {
    late UserId recipeId;
    late Time createdAt;

    setUp(() {
      recipeId = UserId.generate();
      createdAt = Time.now();
    });

    group('creation', () {
      test('should create Recipe with valid data', () {
        final ingredients = [
          Ingredient(
            name: 'Beef Patty',
            quantity: '1 piece',
            allergens: ['beef'],
          ),
          Ingredient(name: 'Lettuce', quantity: '2 leaves'),
          Ingredient(name: 'Tomato', quantity: '2 slices'),
        ];

        final recipe = Recipe(
          id: recipeId,
          name: 'Classic Burger',
          description: 'A delicious classic burger',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.medium,
          preparationTimeMinutes: 15,
          cookingTimeMinutes: 10,
          ingredients: ingredients,
          instructions: ['Grill the patty', 'Assemble burger'],
          price: Money(12.99),
          allergens: ['beef', 'gluten'],
          createdAt: createdAt,
        );

        expect(recipe.id, equals(recipeId));
        expect(recipe.name, equals('Classic Burger'));
        expect(recipe.description, equals('A delicious classic burger'));
        expect(recipe.category, equals(RecipeCategory.main));
        expect(recipe.difficulty, equals(RecipeDifficulty.medium));
        expect(recipe.preparationTimeMinutes, equals(15));
        expect(recipe.cookingTimeMinutes, equals(10));
        expect(recipe.totalTimeMinutes, equals(25));
        expect(recipe.ingredients, hasLength(3));
        expect(recipe.instructions, hasLength(2));
        expect(recipe.price.amount, equals(12.99));
        expect(recipe.allergens, hasLength(2));
        expect(recipe.isActive, isTrue);
        expect(recipe.isVegetarian, isFalse);
        expect(recipe.isVegan, isFalse);
      });

      test('should create Recipe with minimum required fields', () {
        final recipe = Recipe(
          id: recipeId,
          name: 'Simple Recipe',
          category: RecipeCategory.appetizer,
          difficulty: RecipeDifficulty.easy,
          preparationTimeMinutes: 5,
          cookingTimeMinutes: 0,
          ingredients: [Ingredient(name: 'Bread', quantity: '1 slice')],
          instructions: ['Toast the bread'],
          price: Money(3.50),
          createdAt: createdAt,
        );

        expect(recipe.description, isNull);
        expect(recipe.allergens, isEmpty);
        expect(recipe.isActive, isTrue);
      });

      test('should throw DomainException for empty name', () {
        expect(
          () => Recipe(
            id: recipeId,
            name: '',
            category: RecipeCategory.main,
            difficulty: RecipeDifficulty.easy,
            preparationTimeMinutes: 10,
            cookingTimeMinutes: 5,
            ingredients: [Ingredient(name: 'Test', quantity: '1')],
            instructions: ['Test'],
            price: Money(5.0),
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException for name too long', () {
        final longName = 'A' * 201; // Exceeds max length
        expect(
          () => Recipe(
            id: recipeId,
            name: longName,
            category: RecipeCategory.main,
            difficulty: RecipeDifficulty.easy,
            preparationTimeMinutes: 10,
            cookingTimeMinutes: 5,
            ingredients: [Ingredient(name: 'Test', quantity: '1')],
            instructions: ['Test'],
            price: Money(5.0),
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException for negative preparation time', () {
        expect(
          () => Recipe(
            id: recipeId,
            name: 'Test Recipe',
            category: RecipeCategory.main,
            difficulty: RecipeDifficulty.easy,
            preparationTimeMinutes: -1,
            cookingTimeMinutes: 5,
            ingredients: [Ingredient(name: 'Test', quantity: '1')],
            instructions: ['Test'],
            price: Money(5.0),
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException for negative cooking time', () {
        expect(
          () => Recipe(
            id: recipeId,
            name: 'Test Recipe',
            category: RecipeCategory.main,
            difficulty: RecipeDifficulty.easy,
            preparationTimeMinutes: 10,
            cookingTimeMinutes: -1,
            ingredients: [Ingredient(name: 'Test', quantity: '1')],
            instructions: ['Test'],
            price: Money(5.0),
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException for empty ingredients', () {
        expect(
          () => Recipe(
            id: recipeId,
            name: 'Test Recipe',
            category: RecipeCategory.main,
            difficulty: RecipeDifficulty.easy,
            preparationTimeMinutes: 10,
            cookingTimeMinutes: 5,
            ingredients: [],
            instructions: ['Test'],
            price: Money(5.0),
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException for empty instructions', () {
        expect(
          () => Recipe(
            id: recipeId,
            name: 'Test Recipe',
            category: RecipeCategory.main,
            difficulty: RecipeDifficulty.easy,
            preparationTimeMinutes: 10,
            cookingTimeMinutes: 5,
            ingredients: [Ingredient(name: 'Test', quantity: '1')],
            instructions: [],
            price: Money(5.0),
            createdAt: createdAt,
          ),
          throwsA(isA<DomainException>()),
        );
      });
    });

    group('business rules', () {
      test('should identify vegetarian recipes', () {
        final vegetarianRecipe = Recipe(
          id: recipeId,
          name: 'Veggie Burger',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.medium,
          preparationTimeMinutes: 10,
          cookingTimeMinutes: 15,
          ingredients: [
            Ingredient(name: 'Black Bean Patty', quantity: '1 piece'),
            Ingredient(name: 'Lettuce', quantity: '2 leaves'),
          ],
          instructions: ['Grill the patty', 'Assemble burger'],
          price: Money(11.99),
          dietaryCategories: [DietaryCategory.vegetarian],
          createdAt: createdAt,
        );

        expect(vegetarianRecipe.isVegetarian, isTrue);
        expect(vegetarianRecipe.isVegan, isFalse);
      });

      test('should identify vegan recipes', () {
        final veganRecipe = Recipe(
          id: recipeId,
          name: 'Vegan Salad',
          category: RecipeCategory.appetizer,
          difficulty: RecipeDifficulty.easy,
          preparationTimeMinutes: 5,
          cookingTimeMinutes: 0,
          ingredients: [
            Ingredient(name: 'Lettuce', quantity: '100g'),
            Ingredient(name: 'Tomato', quantity: '2 pieces'),
          ],
          instructions: ['Mix ingredients'],
          price: Money(8.99),
          dietaryCategories: [DietaryCategory.vegan],
          createdAt: createdAt,
        );

        expect(veganRecipe.isVegan, isTrue);
        expect(veganRecipe.isVegetarian, isTrue); // Vegan is also vegetarian
      });

      test('should calculate total time correctly', () {
        final recipe = Recipe(
          id: recipeId,
          name: 'Test Recipe',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.medium,
          preparationTimeMinutes: 20,
          cookingTimeMinutes: 35,
          ingredients: [Ingredient(name: 'Test', quantity: '1')],
          instructions: ['Test'],
          price: Money(15.0),
          createdAt: createdAt,
        );

        expect(recipe.totalTimeMinutes, equals(55));
      });

      test('should check if recipe requires cooking', () {
        final cookedRecipe = Recipe(
          id: recipeId,
          name: 'Grilled Chicken',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.medium,
          preparationTimeMinutes: 10,
          cookingTimeMinutes: 25,
          ingredients: [Ingredient(name: 'Chicken', quantity: '1 piece')],
          instructions: ['Grill chicken'],
          price: Money(18.0),
          createdAt: createdAt,
        );

        final rawRecipe = Recipe(
          id: recipeId,
          name: 'Garden Salad',
          category: RecipeCategory.appetizer,
          difficulty: RecipeDifficulty.easy,
          preparationTimeMinutes: 5,
          cookingTimeMinutes: 0,
          ingredients: [Ingredient(name: 'Lettuce', quantity: '100g')],
          instructions: ['Mix ingredients'],
          price: Money(7.0),
          createdAt: createdAt,
        );

        expect(cookedRecipe.requiresCooking, isTrue);
        expect(rawRecipe.requiresCooking, isFalse);
      });

      test('should determine complexity based on criteria', () {
        final simpleRecipe = Recipe(
          id: recipeId,
          name: 'Toast',
          category: RecipeCategory.appetizer,
          difficulty: RecipeDifficulty.easy,
          preparationTimeMinutes: 2,
          cookingTimeMinutes: 3,
          ingredients: [Ingredient(name: 'Bread', quantity: '1 slice')],
          instructions: ['Toast bread'],
          price: Money(2.0),
          createdAt: createdAt,
        );

        final complexRecipe = Recipe(
          id: recipeId,
          name: 'Beef Wellington',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.hard,
          preparationTimeMinutes: 60,
          cookingTimeMinutes: 45,
          ingredients: List.generate(
            12,
            (i) => Ingredient(name: 'Ingredient $i', quantity: '1'),
          ),
          instructions: List.generate(15, (i) => 'Step ${i + 1}'),
          price: Money(45.0),
          createdAt: createdAt,
        );

        expect(simpleRecipe.isComplex, isFalse);
        expect(complexRecipe.isComplex, isTrue);
      });
    });

    group('recipe modifications', () {
      test('should update recipe details', () {
        final recipe = Recipe(
          id: recipeId,
          name: 'Original Recipe',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.easy,
          preparationTimeMinutes: 10,
          cookingTimeMinutes: 5,
          ingredients: [Ingredient(name: 'Test', quantity: '1')],
          instructions: ['Test'],
          price: Money(10.0),
          createdAt: createdAt,
        );

        final updatedRecipe = recipe.updateDetails(
          name: 'Updated Recipe',
          description: 'New description',
          price: Money(12.0),
        );

        expect(updatedRecipe.name, equals('Updated Recipe'));
        expect(updatedRecipe.description, equals('New description'));
        expect(updatedRecipe.price.amount, equals(12.0));
        expect(updatedRecipe.id, equals(recipe.id)); // ID should remain same
      });

      test('should activate inactive recipe', () {
        final recipe = Recipe(
          id: recipeId,
          name: 'Test Recipe',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.easy,
          preparationTimeMinutes: 10,
          cookingTimeMinutes: 5,
          ingredients: [Ingredient(name: 'Test', quantity: '1')],
          instructions: ['Test'],
          price: Money(10.0),
          createdAt: createdAt,
          isActive: false,
        );

        final activatedRecipe = recipe.activate();

        expect(activatedRecipe.isActive, isTrue);
      });

      test('should deactivate active recipe', () {
        final recipe = Recipe(
          id: recipeId,
          name: 'Test Recipe',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.easy,
          preparationTimeMinutes: 10,
          cookingTimeMinutes: 5,
          ingredients: [Ingredient(name: 'Test', quantity: '1')],
          instructions: ['Test'],
          price: Money(10.0),
          createdAt: createdAt,
        );

        final deactivatedRecipe = recipe.deactivate();

        expect(deactivatedRecipe.isActive, isFalse);
      });

      test('should update cooking times', () {
        final recipe = Recipe(
          id: recipeId,
          name: 'Test Recipe',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.easy,
          preparationTimeMinutes: 10,
          cookingTimeMinutes: 5,
          ingredients: [Ingredient(name: 'Test', quantity: '1')],
          instructions: ['Test'],
          price: Money(10.0),
          createdAt: createdAt,
        );

        final updatedRecipe = recipe.updateTimes(
          preparationTimeMinutes: 15,
          cookingTimeMinutes: 8,
        );

        expect(updatedRecipe.preparationTimeMinutes, equals(15));
        expect(updatedRecipe.cookingTimeMinutes, equals(8));
        expect(updatedRecipe.totalTimeMinutes, equals(23));
      });
    });

    group('ingredients', () {
      test('should create Ingredient with valid data', () {
        final ingredient = Ingredient(
          name: 'Tomato',
          quantity: '2 pieces',
          allergens: ['tomato'],
          isOptional: false,
        );

        expect(ingredient.name, equals('Tomato'));
        expect(ingredient.quantity, equals('2 pieces'));
        expect(ingredient.allergens, contains('tomato'));
        expect(ingredient.isOptional, isFalse);
      });

      test('should create optional ingredient', () {
        final ingredient = Ingredient(
          name: 'Extra Cheese',
          quantity: '30g',
          isOptional: true,
        );

        expect(ingredient.isOptional, isTrue);
        expect(ingredient.allergens, isEmpty);
      });

      test('should throw DomainException for empty ingredient name', () {
        expect(
          () => Ingredient(name: '', quantity: '1'),
          throwsA(isA<DomainException>()),
        );
      });

      test('should throw DomainException for empty quantity', () {
        expect(
          () => Ingredient(name: 'Test', quantity: ''),
          throwsA(isA<DomainException>()),
        );
      });
    });

    group('equality', () {
      test('should be equal when ids are the same', () {
        final recipe1 = Recipe(
          id: recipeId,
          name: 'Test Recipe',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.easy,
          preparationTimeMinutes: 10,
          cookingTimeMinutes: 5,
          ingredients: [Ingredient(name: 'Test', quantity: '1')],
          instructions: ['Test'],
          price: Money(10.0),
          createdAt: createdAt,
        );

        final recipe2 = Recipe(
          id: recipeId,
          name: 'Different Name',
          category: RecipeCategory.dessert,
          difficulty: RecipeDifficulty.hard,
          preparationTimeMinutes: 30,
          cookingTimeMinutes: 20,
          ingredients: [Ingredient(name: 'Different', quantity: '2')],
          instructions: ['Different'],
          price: Money(20.0),
          createdAt: Time.now(),
        );

        expect(recipe1, equals(recipe2));
        expect(recipe1.hashCode, equals(recipe2.hashCode));
      });

      test('should not be equal when ids are different', () {
        final recipe1 = Recipe(
          id: recipeId,
          name: 'Test Recipe',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.easy,
          preparationTimeMinutes: 10,
          cookingTimeMinutes: 5,
          ingredients: [Ingredient(name: 'Test', quantity: '1')],
          instructions: ['Test'],
          price: Money(10.0),
          createdAt: createdAt,
        );

        final differentId = UserId('different-recipe-id');
        final recipe2 = Recipe(
          id: differentId,
          name: 'Test Recipe',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.easy,
          preparationTimeMinutes: 10,
          cookingTimeMinutes: 5,
          ingredients: [Ingredient(name: 'Test', quantity: '1')],
          instructions: ['Test'],
          price: Money(10.0),
          createdAt: createdAt,
        );

        expect(recipe1, isNot(equals(recipe2)));
      });
    });

    group('string representation', () {
      test('should return string representation', () {
        final recipe = Recipe(
          id: recipeId,
          name: 'Test Recipe',
          category: RecipeCategory.main,
          difficulty: RecipeDifficulty.medium,
          preparationTimeMinutes: 15,
          cookingTimeMinutes: 10,
          ingredients: [Ingredient(name: 'Test', quantity: '1')],
          instructions: ['Test'],
          price: Money(12.50),
          createdAt: createdAt,
        );

        final string = recipe.toString();
        expect(string, contains('Recipe'));
        expect(string, contains('Test Recipe'));
        expect(string, contains('main'));
        expect(string, contains('medium'));
      });
    });
  });
}
