import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'recipe.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database == null) {
      final path = join(await getDatabasesPath(), 'recipes.db');
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE recipes(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, typeId INTEGER, imagePath TEXT, ingredients TEXT, steps TEXT)',
          );
          for (final recipe in _starterRecipes) {
            await db.insert('recipes', recipe.toMap());
          }
        },
      );
    }
    return _database!;
  }

  Future<int> insertRecipe(Recipe recipe) async {
    final db = await database;
    return db.insert('recipes', recipe.toMap());
  }

  Future<List<Recipe>> getRecipes() async {
    final db = await database;
    final results = await db.query('recipes', orderBy: 'id DESC');
    return results.map((row) => Recipe.fromMap(row)).toList();
  }

  Future<int> updateRecipe(Recipe recipe) async {
    final db = await database;
    return db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<int> deleteRecipe(int id) async {
    final db = await database;
    return db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }
}

final List<Recipe> _starterRecipes = [
  Recipe(
    title: 'Pancakes',
    typeId: 1,
    imagePath: 'assets/images/pancakes.jpg',
    ingredients: ['Flour', 'Eggs', 'Milk', 'Sugar', 'Baking powder'],
    steps: [
      'Mix dry ingredients',
      'Whisk in eggs and milk',
      'Cook on a pan until golden',
      'Serve with syrup',
    ],
  ),
  Recipe(
    title: 'Grilled Chicken Sandwich',
    typeId: 2,
    imagePath: 'assets/images/sandwich.jpg',
    ingredients: ['Chicken breast', 'Bread', 'Lettuce', 'Mayo', 'Tomato'],
    steps: [
      'Grill the chicken',
      'Toast the bread',
      'Assemble sandwich',
      'Serve',
    ],
  ),
  Recipe(
    title: 'Spaghetti Bolognese',
    typeId: 3,
    imagePath: 'assets/images/spaghetti.jpg',
    ingredients: [
      'Spaghetti',
      'Ground beef',
      'Tomato sauce',
      'Onion',
      'Garlic',
    ],
    steps: [
      'Boil pasta',
      'Cook beef with onion and garlic',
      'Add tomato sauce and simmer',
      'Combine and serve',
    ],
  ),
  Recipe(
    title: 'Chocolate Brownie',
    typeId: 4,
    imagePath: 'assets/images/brownie.jpg',
    ingredients: ['Chocolate', 'Butter', 'Sugar', 'Eggs', 'Flour'],
    steps: [
      'Melt chocolate and butter',
      'Mix in sugar and eggs',
      'Fold in flour',
      'Bake for 25 minutes',
    ],
  ),
  Recipe(
    title: 'Iced Lemon Tea',
    typeId: 5,
    imagePath: 'assets/images/iced_tea.jpg',
    ingredients: ['Tea bags', 'Lemon', 'Sugar', 'Ice', 'Water'],
    steps: [
      'Brew tea',
      'Add sugar while hot',
      'Add lemon juice',
      'Pour over ice',
    ],
  ),
];
