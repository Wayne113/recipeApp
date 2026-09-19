import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.dart';
import 'recipe.dart';


class RecipeFormPage extends StatefulWidget {
  final List<RecipeType> types;
  final Recipe? recipe; 

  const RecipeFormPage({super.key, required this.types, this.recipe});

  @override
  State<RecipeFormPage> createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<RecipeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();
  final _picker = ImagePicker();

  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();

  int? _typeId;
  String? _imagePath;
  bool _saving = false; 
  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    if (recipe != null) {
      _titleController.text = recipe.title;
      _ingredientsController.text = recipe.ingredients.join('\n');
      _stepsController.text = recipe.steps.join('\n');
      _typeId = recipe.typeId;
      _imagePath = recipe.imagePath;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  //Photo 

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, maxWidth: 1200);
      if (picked == null) return; //user cancel

      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
      final savedPath = p.join(dir.path, fileName);
      await picked.saveTo(savedPath);

      if (!mounted) return;
      setState(() => _imagePath = savedPath);
    } catch (e) {
      debugPrint('Pick image failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get the photo. Try again.')),
      );
    }
  }

  //Save


  List<String> _toList(String text) {
    return text
        .split('\n')
        .map((line) => line.trim().replaceAll('|', '/'))
        .where((line) => line.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    _saving = true;

    final recipe = Recipe(
      id: widget.recipe?.id,
      title: _titleController.text.trim(),
      typeId: _typeId!,
      imagePath: _imagePath,
      ingredients: _toList(_ingredientsController.text),
      steps: _toList(_stepsController.text),
    );

    try {
      if (_isEditing) {
        await _db.updateRecipe(recipe);
      } else {
        await _db.insertRecipe(recipe);
      }
    } finally {
      _saving = false;
    }
    if (mounted) Navigator.pop(context, true);
  }

  // UI 

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        height: 180,
        width: double.infinity,
        color: Colors.grey[300],
        child: _imagePath == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 40),
                  SizedBox(height: 8),
                  Text('Add a photo'),
                ],
              )
            : RecipeImage(path: _imagePath, width: double.infinity, height: 180),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Recipe' : 'New Recipe')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildImagePicker(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Recipe title',
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please enter a title'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue:
                  widget.types.any((t) => t.id == _typeId) ? _typeId : null,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Recipe type',
                border: OutlineInputBorder(),
              ),
              items: widget.types
                  .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
                  .toList(),
              onChanged: (value) => setState(() => _typeId = value),
              validator: (value) =>
                  value == null ? 'Please select a type' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ingredientsController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Ingredients (one per line)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please enter at least one ingredient'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stepsController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Steps (one per line)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please enter at least one step'
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}


class RecipeImage extends StatelessWidget {
  final String? path;
  final double width;
  final double height;

  const RecipeImage({
    super.key,
    required this.path,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = SizedBox(
      width: width,
      height: height,
      child: const Icon(Icons.restaurant, size: 32),
    );

    final imagePath = path;
    if (imagePath == null) return placeholder;

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
    return Image.file(
      File(imagePath),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => placeholder,
    );
  }
}