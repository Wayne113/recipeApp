import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'recipe.dart';
import 'database.dart';
import 'recipe_detail.dart';
import 'recipe_form.dart';

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  final db = DatabaseHelper();
  List<Recipe> recipes = [];
  List<RecipeType> types = [];
  int selectedTypeId = -1;

  List<Recipe> get filteredRecipes {
    if (selectedTypeId == -1) return recipes;
    return recipes.where((r) => r.typeId == selectedTypeId).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedRecipes = await db.getRecipes();

    final jsonString = await rootBundle.loadString('assets/recipetypes.json');
    final jsonList = jsonDecode(jsonString) as List;
    final loadedTypes = jsonList
        .map((item) => RecipeType.fromJson(item))
        .toList();

    setState(() {
      recipes = loadedRecipes;
      types = loadedTypes;
    });
  }

  Future<void> _goToAddRecipe() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => RecipeFormPage(types: types)),
    );
    if (saved == true) _loadData();
  }

  Future<void> _goToDetail(Recipe recipe) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailPage(recipe: recipe, types: types),
      ),
    );
    if (changed == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Recipes')),
      floatingActionButton: FloatingActionButton(
        onPressed: types.isEmpty ? null : _goToAddRecipe,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<int>(
              isExpanded: true,
              value: selectedTypeId,
              items: [
                const DropdownMenuItem(value: -1, child: Text('All')),
                ...types.map(
                  (type) =>
                      DropdownMenuItem(value: type.id, child: Text(type.name)),
                ),
              ],
              onChanged: (value) {
                setState(() => selectedTypeId = value ?? -1);
              },
            ),
          ),
          Expanded(
            child: filteredRecipes.isEmpty
                ? const Center(child: Text('No recipes found'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return ListTile(
                        leading: RecipeImage(
                          path: recipe.imagePath,
                          width: 56,
                          height: 56,
                        ),
                        title: Text(recipe.title),
                        onTap: () => _goToDetail(recipe),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
