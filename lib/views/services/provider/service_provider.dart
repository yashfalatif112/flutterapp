import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServicesProvider with ChangeNotifier {
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _randomSubcategories = [];
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> get categories => _categories;
  List<Map<String, dynamic>> get randomSubcategories => _randomSubcategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Original fetchServices stays unchanged
  Future<void> fetchServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance.collection('services').get();
      List<Map<String, dynamic>> fetchedCategories = [];

      for (var doc in snapshot.docs) {
        final subcatSnap = await doc.reference.collection('subcategories').get();
        final subcategories = subcatSnap.docs.map((subDoc) => subDoc['name'] as String).toList();

        fetchedCategories.add({
          'name': doc['categoryName'],
          'subcategories': subcategories,
        });
      }

      _categories = fetchedCategories;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMostPopular() async {
    _error = null;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance.collection('services').get();
      List<Map<String, dynamic>> allSubcategories = [];

      for (var doc in snapshot.docs) {
        final subcatSnap = await doc.reference.collection('subcategories').get();
        for (var subDoc in subcatSnap.docs) {
          allSubcategories.add({
            'name': subDoc['name'],
            'price': subDoc['price'],
            'rating': subDoc['rating'],
            'image': subDoc['image'],
          });
        }
      }

      allSubcategories.shuffle();
      _randomSubcategories = allSubcategories.take(5).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
