import 'package:excash/database/excash_database.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/widgets/Ketegori_form_widget.dart';
import 'package:flutter/material.dart';

class AddEditCategoryPage extends StatefulWidget {
  final Category? category;

  const AddEditCategoryPage({super.key, this.category});

  @override
  State<AddEditCategoryPage> createState() => _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends State<AddEditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late String _nameCategory;
  late bool _isUpdateForm;

  @override
  void initState() {
    super.initState();
    _nameCategory = widget.category?.name_category ?? '';
    _isUpdateForm = widget.category != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isUpdateForm ? 'Edit Category' : 'Add Category'),
        actions: [_saveCategoryButton()],
      ),
      body: Form(
        key: _formKey,
        child: CategoryFormWidget(
          nameCategory: _nameCategory,
          onChangeNameCategory: (value) => setState(() => _nameCategory = value),
        ),
      ),
    );
  }

  Widget _saveCategoryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            if (_isUpdateForm) {
              await _updateCategory();
            } else {
              await _addCategory();
            }
            Navigator.pop(context);
          }
        },
        child: const Text('Save'),
      ),
    );
  }

  Future<void> _addCategory() async {
    final category = Category(
      name_category: _nameCategory,
      created_at_category: DateTime.now(),
      updated_at_category: DateTime.now(),
    );
    await ExcashDatabase.instance.create(category);
  }

  Future<void> _updateCategory() async {
    final updatedCategory = widget.category!.copy(
      name_category: _nameCategory,
      updated_at_category: DateTime.now(),
    );
    await ExcashDatabase.instance.updateCategory(updatedCategory);
  }
}
