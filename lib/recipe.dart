class RecipeType {
  final int id;
  final String name;

  RecipeType({required this.id, required this.name});

  factory RecipeType.fromJson(Map<String, dynamic> json) {
    return RecipeType(id: json['id'], name: json['name']);
  }
}

class Recipe {
  final int? id;
  final String title;
  final int typeId;
  final String? imagePath;
  final List<String> ingredients;
  final List<String> steps;

  Recipe({
    this.id,
    required this.title,
    required this.typeId,
    this.imagePath,
    required this.ingredients,
    required this.steps,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'typeId': typeId,
      'imagePath': imagePath,
      'ingredients': ingredients.join('|'),
      'steps': steps.join('|'),
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      typeId: map['typeId'],
      imagePath: map['imagePath'],
      ingredients: (map['ingredients'] as String).split('|'),
      steps: (map['steps'] as String).split('|'),
    );
  }
}
