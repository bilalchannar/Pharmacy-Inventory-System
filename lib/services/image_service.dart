import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service responsible for automatically retrieving or generating relevant medicine image URLs.
class ImageService {
  static const Map<String, String> _categoryFallbackImages = {
    'Tablet': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop',
    'Capsule': 'https://images.unsplash.com/photo-1550572017-edf7928d10b8?w=500&auto=format&fit=crop',
    'Syrup': 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=500&auto=format&fit=crop',
    'Injection': 'https://images.unsplash.com/photo-1579165466541-71e22a308351?w=500&auto=format&fit=crop',
    'Cream': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=500&auto=format&fit=crop',
    'Ointment': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=500&auto=format&fit=crop',
    'Drops': 'https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?w=500&auto=format&fit=crop',
    'Powder': 'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=500&auto=format&fit=crop',
  };

  static const String _defaultFallback =
      'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop';

  /// Automatically searches online for a relevant image based on medicine name and category.
  static Future<String> fetchMedicineImageUrl(String medicineName, String category) async {
    final cleanQuery = medicineName.trim();
    if (cleanQuery.isEmpty) {
      return _categoryFallbackImages[category] ?? _defaultFallback;
    }

    try {
      // Search Wikipedia REST API for relevant medicine image thumbnail
      final encodedQuery = Uri.encodeComponent(cleanQuery);
      final url = Uri.parse(
        'https://en.wikipedia.org/w/api.php?action=query&titles=$encodedQuery&prop=pageimages&format=json&pithumbsize=500',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pages = data['query']?['pages'] as Map<String, dynamic>?;

        if (pages != null && pages.isNotEmpty) {
          final firstPageKey = pages.keys.first;
          if (firstPageKey != '-1') {
            final thumbnail = pages[firstPageKey]?['thumbnail']?['source'] as String?;
            if (thumbnail != null && thumbnail.isNotEmpty) {
              return thumbnail;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Online image search error/timeout: $e');
    }

    // Return curated category fallback if online search yields no image or times out
    return _categoryFallbackImages[category] ?? _defaultFallback;
  }
}
