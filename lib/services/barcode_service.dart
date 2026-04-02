import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/nutrition.dart';

/// Barcode scan result
class BarcodeScanResult {
  final String barcode;
  final String format;
  final DateTime scannedAt;

  BarcodeScanResult({
    required this.barcode,
    required this.format,
    DateTime? scannedAt,
  }) : scannedAt = scannedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'barcode': barcode,
    'format': format,
    'scannedAt': scannedAt.toIso8601String(),
  };

  factory BarcodeScanResult.fromJson(Map<String, dynamic> json) {
    return BarcodeScanResult(
      barcode: json['barcode'] as String? ?? '',
      format: json['format'] as String? ?? 'Unknown',
      scannedAt: DateTime.tryParse(json['scannedAt'] as String? ?? ''),
    );
  }

  @override
  String toString() => 'Barcode: $barcode (Format: $format)';
}

/// Food product from barcode lookup
class BarcodeProduct {
  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;
  final NutritionInfo nutritionPer100g;
  final double? servingSize;
  final String? servingUnit;
  final List<String>? ingredients;
  final List<String>? allergens;
  final String? nutriscore;
  final Map<String, dynamic>? rawData;

  BarcodeProduct({
    required this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
    required this.nutritionPer100g,
    this.servingSize,
    this.servingUnit,
    this.ingredients,
    this.allergens,
    this.nutriscore,
    this.rawData,
  });

  /// Convert to FoodItem for use in the app
  FoodItem toFoodItem() {
    return FoodItem(
      id: 'barcode_$barcode',
      name: name,
      brand: brand,
      category: FoodCategory.other,
      nutrition: nutritionPer100g,
      servingSize: servingSize ?? 100,
      servingUnit: servingUnit ?? 'g',
      barcode: barcode,
    );
  }

  Map<String, dynamic> toJson() => {
    'barcode': barcode,
    'name': name,
    'brand': brand,
    'imageUrl': imageUrl,
    'nutritionPer100g': {
      'calories': nutritionPer100g.calories,
      'protein': nutritionPer100g.protein,
      'carbs': nutritionPer100g.carbs,
      'fat': nutritionPer100g.fat,
      'fiber': nutritionPer100g.fiber,
      'sugar': nutritionPer100g.sugar,
      'sodium': nutritionPer100g.sodium,
    },
    'servingSize': servingSize,
    'servingUnit': servingUnit,
    'ingredients': ingredients,
    'allergens': allergens,
    'nutriscore': nutriscore,
  };

  factory BarcodeProduct.fromJson(Map<String, dynamic> json) {
    final nutrition = json['nutritionPer100g'] as Map<String, dynamic>;
    return BarcodeProduct(
      barcode: json['barcode'],
      name: json['name'],
      brand: json['brand'],
      imageUrl: json['imageUrl'],
      nutritionPer100g: NutritionInfo(
        calories: (nutrition['calories'] as num?)?.toDouble() ?? 0,
        protein: (nutrition['protein'] as num?)?.toDouble() ?? 0,
        carbs: (nutrition['carbs'] as num?)?.toDouble() ?? 0,
        fat: (nutrition['fat'] as num?)?.toDouble() ?? 0,
        fiber: (nutrition['fiber'] as num?)?.toDouble(),
        sugar: (nutrition['sugar'] as num?)?.toDouble(),
        sodium: (nutrition['sodium'] as num?)?.toDouble(),
      ),
      servingSize: (json['servingSize'] as num?)?.toDouble(),
      servingUnit: json['servingUnit'],
      ingredients: (json['ingredients'] as List?)?.cast<String>(),
      allergens: (json['allergens'] as List?)?.cast<String>(),
      nutriscore: json['nutriscore'],
      rawData: json,
    );
  }
}

/// Barcode lookup error types
enum BarcodeLookupError {
  notFound,
  networkError,
  invalidBarcode,
  serviceUnavailable,
  rateLimited,
}

/// Barcode Service - handles barcode scanning and food database lookup
/// Note: This is a mock implementation. For production:
/// - Use mobile_scanner package for scanning
/// - Use OpenFoodFacts API for product lookup
class BarcodeService {
  static const String _scanHistoryStorageKey = 'barcode_scan_history';

  static final BarcodeService _instance = BarcodeService._internal();
  factory BarcodeService() => _instance;
  BarcodeService._internal();

  // Cache for scanned products
  final Map<String, BarcodeProduct> _productCache = {};

  // Recently scanned barcodes
  final List<BarcodeScanResult> _scanHistory = [];
  bool _isInitialized = false;

  List<BarcodeScanResult> get scanHistory => List.unmodifiable(_scanHistory);

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    final prefs = await SharedPreferences.getInstance();
    final rawHistory = prefs.getStringList(_scanHistoryStorageKey) ?? const [];
    if (rawHistory.isEmpty) {
      return;
    }

    _scanHistory
      ..clear()
      ..addAll(
        rawHistory.map((item) {
          try {
            final decoded = jsonDecode(item) as Map<String, dynamic>;
            return BarcodeScanResult.fromJson(decoded);
          } catch (_) {
            return BarcodeScanResult(barcode: '', format: 'Unknown');
          }
        }).where((scan) => scan.barcode.isNotEmpty),
      );
  }

  /// Lookup a product by barcode
  /// Uses OpenFoodFacts API (mock implementation)
  Future<BarcodeProduct?> lookupProduct(String barcode) async {
    // Check cache first
    if (_productCache.containsKey(barcode)) {
      return _productCache[barcode];
    }

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock database of common products
      final product = _mockProductDatabase[barcode];

      if (product != null) {
        _productCache[barcode] = product;
        return product;
      }

      // In production, call OpenFoodFacts API:
      // final response = await http.get(
      //   Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
      // );
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   if (data['status'] == 1) {
      //     return BarcodeProduct.fromOpenFoodFacts(data['product']);
      //   }
      // }

      return null;
    } catch (e) {
      throw BarcodeLookupError.networkError;
    }
  }

  /// Record a barcode scan
  void recordScan(BarcodeScanResult scan) {
    _scanHistory.insert(0, scan);
    // Keep only last 50 scans
    if (_scanHistory.length > 50) {
      _scanHistory.removeLast();
    }
    unawaited(_persistScanHistory());
  }

  /// Clear scan history
  void clearHistory() {
    _scanHistory.clear();
    unawaited(_persistScanHistory());
  }

  Future<void> _persistScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _scanHistory
        .map((scan) => jsonEncode(scan.toJson()))
        .toList();
    await prefs.setStringList(_scanHistoryStorageKey, encoded);
  }

  /// Clear product cache
  void clearCache() {
    _productCache.clear();
  }

  /// Validate barcode format
  bool isValidBarcode(String barcode) {
    // UPC-A: 12 digits
    // EAN-13: 13 digits
    // EAN-8: 8 digits
    final cleaned = barcode.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.length == 8 || cleaned.length == 12 || cleaned.length == 13;
  }

  /// Get barcode format
  String getBarcodeFormat(String barcode) {
    final cleaned = barcode.replaceAll(RegExp(r'[^0-9]'), '');
    switch (cleaned.length) {
      case 8:
        return 'EAN-8';
      case 12:
        return 'UPC-A';
      case 13:
        return 'EAN-13';
      default:
        return 'Unknown';
    }
  }

  // Mock product database for testing
  final Map<String, BarcodeProduct> _mockProductDatabase = {
    // Dairy
    '5000112637922': BarcodeProduct(
      barcode: '5000112637922',
      name: 'Semi-Skimmed Milk',
      brand: 'Dairy Farm',
      nutritionPer100g: NutritionInfo(
        calories: 50,
        protein: 3.6,
        carbs: 4.8,
        fat: 1.8,
        sugar: 4.8,
        sodium: 0.05,
      ),
      servingSize: 250,
      servingUnit: 'ml',
      nutriscore: 'A',
    ),
    '4006040256007': BarcodeProduct(
      barcode: '4006040256007',
      name: 'Greek Yogurt',
      brand: 'FAGE',
      nutritionPer100g: NutritionInfo(
        calories: 97,
        protein: 9.0,
        carbs: 4.0,
        fat: 5.0,
        sugar: 4.0,
        sodium: 0.06,
      ),
      servingSize: 170,
      servingUnit: 'g',
      nutriscore: 'A',
    ),

    // Grains
    '5010029000122': BarcodeProduct(
      barcode: '5010029000122',
      name: 'Rolled Oats',
      brand: 'Quaker',
      nutritionPer100g: NutritionInfo(
        calories: 367,
        protein: 13.5,
        carbs: 58.0,
        fat: 7.0,
        fiber: 10.0,
        sugar: 1.0,
        sodium: 0.004,
      ),
      servingSize: 40,
      servingUnit: 'g',
      nutriscore: 'A',
    ),
    '5053827177016': BarcodeProduct(
      barcode: '5053827177016',
      name: 'Whole Wheat Bread',
      brand: 'Hovis',
      nutritionPer100g: NutritionInfo(
        calories: 247,
        protein: 10.0,
        carbs: 41.0,
        fat: 3.5,
        fiber: 6.0,
        sugar: 4.0,
        sodium: 0.44,
      ),
      servingSize: 44,
      servingUnit: 'g',
      nutriscore: 'A',
    ),

    // Protein
    '5000295142893': BarcodeProduct(
      barcode: '5000295142893',
      name: 'Chicken Breast',
      brand: 'Fresh',
      nutritionPer100g: NutritionInfo(
        calories: 165,
        protein: 31.0,
        carbs: 0,
        fat: 3.6,
        sodium: 0.07,
      ),
      servingSize: 150,
      servingUnit: 'g',
      nutriscore: 'A',
    ),
    '7622210449283': BarcodeProduct(
      barcode: '7622210449283',
      name: 'Protein Bar',
      brand: 'Cadbury',
      nutritionPer100g: NutritionInfo(
        calories: 380,
        protein: 20.0,
        carbs: 35.0,
        fat: 18.0,
        fiber: 5.0,
        sugar: 15.0,
        sodium: 0.3,
      ),
      servingSize: 60,
      servingUnit: 'g',
      nutriscore: 'C',
    ),

    // Snacks
    '5000159407236': BarcodeProduct(
      barcode: '5000159407236',
      name: 'Cheddar Cheese',
      brand: 'Cathedral City',
      nutritionPer100g: NutritionInfo(
        calories: 416,
        protein: 25.4,
        carbs: 0.1,
        fat: 34.9,
        sodium: 1.8,
      ),
      servingSize: 30,
      servingUnit: 'g',
      nutriscore: 'D',
    ),
    '5000108041924': BarcodeProduct(
      barcode: '5000108041924',
      name: 'Dark Chocolate',
      brand: 'Lindt',
      nutritionPer100g: NutritionInfo(
        calories: 545,
        protein: 7.0,
        carbs: 45.0,
        fat: 38.0,
        fiber: 8.0,
        sugar: 35.0,
        sodium: 0.01,
      ),
      servingSize: 25,
      servingUnit: 'g',
      nutriscore: 'E',
    ),

    // Beverages
    '5449000214911': BarcodeProduct(
      barcode: '5449000214911',
      name: 'Sparkling Water',
      brand: 'San Pellegrino',
      nutritionPer100g: NutritionInfo(
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        sodium: 0.002,
      ),
      servingSize: 330,
      servingUnit: 'ml',
      nutriscore: 'A',
    ),
    '5449000000996': BarcodeProduct(
      barcode: '5449000000996',
      name: 'Orange Juice',
      brand: 'Tropicana',
      nutritionPer100g: NutritionInfo(
        calories: 43,
        protein: 0.7,
        carbs: 9.0,
        fat: 0.1,
        sugar: 8.4,
        sodium: 0.001,
      ),
      servingSize: 250,
      servingUnit: 'ml',
      nutriscore: 'B',
    ),

    // Fruits & Vegetables
    '0000000094011': BarcodeProduct(
      barcode: '0000000094011',
      name: 'Banana',
      brand: 'Fresh Produce',
      nutritionPer100g: NutritionInfo(
        calories: 89,
        protein: 1.1,
        carbs: 22.8,
        fat: 0.3,
        fiber: 2.6,
        sugar: 12.2,
        sodium: 0.001,
      ),
      servingSize: 118,
      servingUnit: 'g',
      nutriscore: 'A',
    ),
    '0000000094225': BarcodeProduct(
      barcode: '0000000094225',
      name: 'Apple (Gala)',
      brand: 'Fresh Produce',
      nutritionPer100g: NutritionInfo(
        calories: 52,
        protein: 0.3,
        carbs: 13.8,
        fat: 0.2,
        fiber: 2.4,
        sugar: 10.4,
        sodium: 0.001,
      ),
      servingSize: 182,
      servingUnit: 'g',
      nutriscore: 'A',
    ),

    // Supplements
    '5060245604567': BarcodeProduct(
      barcode: '5060245604567',
      name: 'Whey Protein Powder',
      brand: 'MyProtein',
      nutritionPer100g: NutritionInfo(
        calories: 380,
        protein: 80.0,
        carbs: 7.0,
        fat: 5.0,
        sodium: 0.15,
      ),
      servingSize: 30,
      servingUnit: 'g',
      nutriscore: 'A',
    ),
    '5029040004101': BarcodeProduct(
      barcode: '5029040004101',
      name: 'Creatine Monohydrate',
      brand: 'Optimum Nutrition',
      nutritionPer100g: NutritionInfo(
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
      ),
      servingSize: 5,
      servingUnit: 'g',
      nutriscore: 'A',
    ),
  };
}

/// Mock barcode scanner widget helper
/// In production, use mobile_scanner package
class BarcodeScannerHelper {
  /// Simulate scanning a barcode
  /// In production, this would open the camera and scan
  static Future<BarcodeScanResult?> scanBarcode() async {
    // Simulate camera delay
    await Future.delayed(const Duration(seconds: 2));

    // Return a mock scan result
    // In production, use MobileScannerController
    return BarcodeScanResult(
      barcode: '5010029000122', // Quaker Oats
      format: 'EAN-13',
    );
  }

  /// Check if camera is available
  static Future<bool> isCameraAvailable() async {
    // In production, check camera permission
    return true;
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    // In production, use permission_handler
    return true;
  }
}
