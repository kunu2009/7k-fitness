import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/app_theme.dart';
import '../../services/barcode_service.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final BarcodeService _barcodeService = BarcodeService();
  final TextEditingController _manualBarcodeController =
      TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isScanning = false;
  bool _isLookingUp = false;
  bool _isTorchOn = false;
  bool _hasDetectedDuringSession = false;
  BarcodeProduct? _scannedProduct;
  String? _error;

  @override
  void dispose() {
    _manualBarcodeController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showScanHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scanner preview area
            _buildScannerArea(),

            const SizedBox(height: 24),

            // Manual barcode entry
            _buildManualEntry(),

            const SizedBox(height: 24),

            // Scanned product info
            if (_scannedProduct != null) _buildProductCard(_scannedProduct!),

            // Error message
            if (_error != null) _buildErrorCard(),

            // Loading indicator
            if (_isLookingUp)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),

            const SizedBox(height: 24),

            // Recently scanned
            _buildRecentlyScanned(),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerArea() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          if (_isScanning)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  if (_hasDetectedDuringSession) {
                    return;
                  }
                  final code = capture.barcodes
                      .map((barcode) => barcode.rawValue?.trim())
                      .firstWhere(
                        (value) => value != null && value!.isNotEmpty,
                        orElse: () => null,
                      );
                  if (code != null) {
                    _handleDetectedBarcode(code);
                  }
                },
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera_alt, size: 64, color: Colors.white54),
                  SizedBox(height: 16),
                  Text(
                    'Tap to scan barcode',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

          // Scan frame overlay
          if (_isScanning)
            Center(
              child: Container(
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(height: 2, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),

          // Scan button
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _isScanning ? _stopScanning : _startScanning,
                icon: Icon(_isScanning ? Icons.stop : Icons.qr_code_scanner),
                label: Text(_isScanning ? 'Stop Scanning' : 'Start Scanning'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isScanning ? Colors.red : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Flash toggle
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: Icon(
                _isTorchOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              onPressed: _isScanning ? _toggleTorch : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntry() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Barcode Manually',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualBarcodeController,
                    decoration: const InputDecoration(
                      hintText: 'Enter barcode number',
                      prefixIcon: Icon(Icons.dialpad),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _lookupManualBarcode,
                  child: const Text('Look Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BarcodeProduct product) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (product.brand != null)
                        Text(
                          product.brand!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
                if (product.nutriscore != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getNutriscoreColor(product.nutriscore!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.nutriscore!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Nutrition info
            const Text(
              'Nutrition per 100g',
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrientColumn(
                  'Calories',
                  '${product.nutritionPer100g.calories.toInt()}',
                  'kcal',
                ),
                _buildNutrientColumn(
                  'Protein',
                  product.nutritionPer100g.protein.toStringAsFixed(1),
                  'g',
                ),
                _buildNutrientColumn(
                  'Carbs',
                  product.nutritionPer100g.carbs.toStringAsFixed(1),
                  'g',
                ),
                _buildNutrientColumn(
                  'Fat',
                  product.nutritionPer100g.fat.toStringAsFixed(1),
                  'g',
                ),
              ],
            ),

            if (product.servingSize != null) ...[
              const SizedBox(height: 16),
              Text(
                'Serving size: ${product.servingSize} ${product.servingUnit ?? 'g'}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _scannedProduct = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addToFood(product),
                    icon: const Icon(Icons.add),
                    label: const Text('Add to Diary'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientColumn(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(unit, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Not Found',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    _error ?? 'Unable to find this product',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _error = null);
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyScanned() {
    final history = _barcodeService.scanHistory;

    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recently Scanned',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            TextButton(
              onPressed: () {
                _barcodeService.clearHistory();
                setState(() {});
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...history
            .take(5)
            .map(
              (scan) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: Text(scan.barcode),
                  subtitle: Text(scan.format),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _lookupBarcode(scan.barcode),
                ),
              ),
            ),
      ],
    );
  }

  Future<void> _startScanning() async {
    _hasDetectedDuringSession = false;
    setState(() {
      _isScanning = true;
      _error = null;
    });
    await _scannerController.start();
  }

  Future<void> _stopScanning() async {
    await _scannerController.stop();
    setState(() => _isScanning = false);
  }

  Future<void> _toggleTorch() async {
    await _scannerController.toggleTorch();
    if (!mounted) {
      return;
    }
    setState(() => _isTorchOn = !_isTorchOn);
  }

  Future<void> _handleDetectedBarcode(String code) async {
    if (!_barcodeService.isValidBarcode(code)) {
      return;
    }
    _hasDetectedDuringSession = true;

    final scan = BarcodeScanResult(
      barcode: code,
      format: _barcodeService.getBarcodeFormat(code),
    );
    _barcodeService.recordScan(scan);

    await _stopScanning();
    await _lookupBarcode(code);
  }

  Future<void> _lookupManualBarcode() async {
    final barcode = _manualBarcodeController.text.trim();
    if (barcode.isEmpty) return;

    if (!_barcodeService.isValidBarcode(barcode)) {
      setState(() {
        _error = 'Invalid barcode format. Please enter 8, 12, or 13 digits.';
        _scannedProduct = null;
      });
      return;
    }

    await _lookupBarcode(barcode);
  }

  Future<void> _lookupBarcode(String barcode) async {
    setState(() {
      _isLookingUp = true;
      _error = null;
      _scannedProduct = null;
    });

    try {
      final product = await _barcodeService.lookupProduct(barcode);

      if (mounted) {
        setState(() {
          _isLookingUp = false;
          if (product != null) {
            _scannedProduct = product;
          } else {
            _error =
                'Product not found in database. Try entering nutrition manually.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLookingUp = false;
          _error = 'Error looking up product. Please try again.';
        });
      }
    }
  }

  void _showScanHistory() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Scan History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_barcodeService.scanHistory.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No scans yet'),
                ),
              )
            else
              ...(_barcodeService.scanHistory
                  .take(10)
                  .map(
                    (scan) => ListTile(
                      leading: const Icon(Icons.qr_code),
                      title: Text(scan.barcode),
                      subtitle: Text(
                        '${scan.format} • ${_formatTime(scan.scannedAt)}',
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _lookupBarcode(scan.barcode);
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  void _addToFood(BarcodeProduct product) {
    final foodItem = product.toFoodItem();

    // Navigate back with the food item
    Navigator.pop(context, foodItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to food diary'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getNutriscoreColor(String score) {
    switch (score.toUpperCase()) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.yellow.shade700;
      case 'D':
        return Colors.orange;
      case 'E':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
