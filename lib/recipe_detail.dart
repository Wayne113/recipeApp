import 'package:flutter/material.dart';
import 'database.dart';
import 'recipe.dart';
import 'recipe_form.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;
  final List<RecipeType> types;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
    required this.types,
  });

  String get _typeName {
    for (final type in types) {
      if (type.id == recipe.typeId) return type.name;
    }
    return 'Unknown';
  }

  Future<void> _editRecipe(BuildContext context) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeFormPage(types: types, recipe: recipe),
      ),
    );
    if (updated == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteRecipe(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete recipe?'),
        content: Text('"${recipe.title}" will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await DatabaseHelper().deleteRecipe(recipe.id!);
    if (context.mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit),
            onPressed: () => _editRecipe(context),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteRecipe(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RecipeImage(
            path: recipe.imagePath,
            width: double.infinity,
            height: 200,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(label: Text(_typeName)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ingredients',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final item in recipe.ingredients) Text('• $item'),
          const SizedBox(height: 16),
          const Text(
            'Steps',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < recipe.steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('${i + 1}. ${recipe.steps[i]}'),
            ),
        ],
      ),
    );
  }
}