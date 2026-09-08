import 'package:flutter/material.dart';

/// Backend does not expose product images, so we provide deterministic,
/// category-aware placeholder images for a polished UI.
class ProductImages {
  static const String _base = 'https://images.unsplash.com/photo-';

  static const List<String> _genericMedicine = [
    '1587854692152-cbe660dbde88?q=80&w=800&auto=format&fit=crop',
    '1585435557343-3b092031a831?q=80&w=800&auto=format&fit=crop',
    '1579154392128-bf8c7ebee2a0?q=80&w=800&auto=format&fit=crop',
    '1550576617-3f22517c4df0?q=80&w=800&auto=format&fit=crop',
  ];

  static const List<String> _vitamins = [
    '1584308666744-24d5c474f2ae?q=80&w=800&auto=format&fit=crop',
    '1577178881669-5aa7d37c5ce7?q=80&w=800&auto=format&fit=crop',
    '1629197938061-00d18d8f8f1e?q=80&w=800&auto=format&fit=crop',
  ];

  static const List<String> _personalCare = [
    '1571875257727-256c39da42af?q=80&w=800&auto=format&fit=crop',
    '1615397349754-cfa2066a298e?q=80&w=800&auto=format&fit=crop',
    '1576872381149-7847515ce5d8?q=80&w=800&auto=format&fit=crop',
  ];

  static String forProduct({
    required int productId,
    required String categoryName,
  }) {
    final normalized = categoryName.toLowerCase();

    if (normalized.contains('vitamin') ||
        normalized.contains('supplement')) {
      return '$_base${_vitamins[productId % _vitamins.length]}';
    }
    if (normalized.contains('care') ||
        normalized.contains('beauty') ||
        normalized.contains('skin')) {
      return '$_base${_personalCare[productId % _personalCare.length]}';
    }

    return '$_base${_genericMedicine[productId % _genericMedicine.length]}';
  }

  static ImageProvider provider({
    required int productId,
    required String categoryName,
  }) {
    return NetworkImage(forProduct(productId: productId, categoryName: categoryName));
  }
}