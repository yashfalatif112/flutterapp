import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoriesProvider with ChangeNotifier {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('services').get();
      List<Map<String, dynamic>> allCategories = [];

      for (var doc in snapshot.docs) {
        final subcategoriesSnapshot =
            await doc.reference.collection('subcategories').get();
        final subcategoryNames =
            subcategoriesSnapshot.docs.map((subDoc) => subDoc.id).toList();

        allCategories.add({
          'name': doc['categoryName'],
          'subcategories': subcategoryNames,
        });
      }

      _categories = allCategories;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
