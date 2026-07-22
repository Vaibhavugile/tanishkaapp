import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String title;
  final String image;
  final int showNumber;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.image,
    required this.showNumber,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CategoryModel(
      id: doc.id,
      title: data["title"] ?? "",
      image: data["image"] ?? "",
      showNumber: data["showNumber"] ?? 999,
    );
  }
}