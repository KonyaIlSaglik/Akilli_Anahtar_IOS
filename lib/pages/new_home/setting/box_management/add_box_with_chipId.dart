import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/pages/managers/install/smart_config_page.dart';
import 'package:akilli_anahtar/pages/new_home/layout.dart';
import 'package:akilli_anahtar/pages/new_home/setting/box_management/add_box_onboarding_page.dart';
import 'package:akilli_anahtar/pages/new_home/setting/settings_page.dart';
import 'package:akilli_anahtar/services/api/management_service.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AddBoxByChipIdPage extends StatefulWidget {
  const AddBoxByChipIdPage({super.key});

  @override
  State<AddBoxByChipIdPage> createState() => _AddBoxByChipIdPageState();
}

class _AddBoxByChipIdPageState extends State<AddBoxByChipIdPage> {
  final AuthController _authController = Get.find();
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isLoading = false;
  bool _isHandled = false;
  bool _showScanner = false;
  String? _lastScannedCode;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Kutu Kurulumu"),
      backgroundColor: sheetBackground,
      actions: [
        IconButton(
          tooltip: "Kurulum rehberini aç",
          icon: const Icon(Icons.help_outline),
          onPressed: () =>
              Get.to(() => const AddBoxOnboardingPage(allowSkipExit: true)),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          _buildDeviceImage(),
          const SizedBox(height: 16),
          _buildInstructions(),
          const SizedBox(height: 24),
          _buildScannerSection(),
        ],
      ),
    );
  }

  Widget _buildDeviceImage() {
    final w = MediaQuery.of(context).size.width * 0.9;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: w,
          height: 180,
          child: Image.asset(
            'assets/box.png',
            fit: BoxFit.contain,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.blue[50],
              alignment: Alignment.center,
              child: const Icon(Icons.device_unknown, size: 48),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Text(
      _showScanner
          ? "QR kodu tarama alanına yerleştirin"
          : "Cihazın üzerinde bulunan QR kodunu okutun",
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildScannerSection() {
    return _showScanner ? _buildQRScanner() : _buildScanButton();
  }

  Widget _buildScanButton() {
    return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldColor,
          padding: const EdgeInsets.symmetric(vertical: 2),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: const Icon(Icons.qr_code_scanner, size: 28, color: Colors.white),
        label: const Text("QR ile Tara", style: TextStyle(color: Colors.white)),
        onPressed: () async {
          _openScanner();
        });
  }

  Widget _buildQRScanner() {
    const double previewHeight = 360;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double previewWidth = constraints.maxWidth;

        final double winW = previewWidth * 0.70;
        final double winH = previewHeight * 0.70;

        final double verticalOffset = 32;

        final double left = (previewWidth - winW) / 2;
        final double top = (previewHeight - winH) / 2 + verticalOffset;

        final Rect scanRect = Rect.fromLTWH(left, top, winW, winH);

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: previewHeight,
            width: double.infinity,
            child: Stack(
              children: [
                MobileScanner(
                  controller: _cameraController,
                  onDetect: _handleQRDetection,
                  scanWindow: scanRect,
                  fit: BoxFit.cover,
                ),
                Positioned.fromRect(
                  rect: scanRect,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.cameraswitch, color: Colors.white),
                        onPressed: () => _cameraController.switchCamera(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flash_on, color: Colors.white),
                        onPressed: () => _cameraController.toggleTorch(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _closeScanner,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScannerOverlay() {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildScannerControls() {
    return Positioned(
      top: 8,
      right: 8,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: () => _cameraController.switchCamera(),
          ),
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _closeScanner,
          ),
        ],
      ),
    );
  }

  Future<void> _handleQRDetection(BarcodeCapture capture) async {
    if (_isHandled) return;

    final rawValue = capture.barcodes.firstOrNull?.rawValue ?? '';
    final chipId = _parseChipId(rawValue);
    final barcode = capture.barcodes.first;
    print("--------$rawValue format ${barcode.format}");

    if (chipId != null) {
      _isHandled = true;
      _lastScannedCode = rawValue;
      await HapticFeedback.mediumImpact();
      await _closeScanner();
      await _handleScan(chipId);
    }
  }

  int? _parseChipId(String content) {
    try {
      final uri = Uri.tryParse(content);
      if (uri != null && uri.queryParameters.containsKey('chipId')) {
        return int.tryParse(uri.queryParameters['chipId']!);
      }

      final kvMatch = RegExp(r'chipid\s*=\s*(\d+)', caseSensitive: false)
          .firstMatch(content);
      if (kvMatch != null) return int.tryParse(kvMatch.group(1)!);

      if (RegExp(r'^\d{4,12}$').hasMatch(content)) {
        return int.parse(content);
      }

      final anyNumberMatch = RegExp(r'(\d{4,12})').firstMatch(content);
      if (anyNumberMatch != null) return int.tryParse(anyNumberMatch.group(1)!);

      return null;
    } catch (e) {
      debugPrint('Chip ID parse error: $e');
      return null;
    }
  }

  Future<void> _handleScan(int chipId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final userId = _authController.user.value.id;
      if (userId == null) {
        throw Exception('Kullanıcı ID bulunamadı');
      }

      final result = await ManagementService.addUserDeviceByChipId(chipId);
      if (result == null) {
        throw Exception("Cihaz eklenemedi");
      }

      final msg = result["message"] ?? "Cihaz eklendi";

      await _saveDeviceData(chipId, userId);

      if (!mounted) return;
      successSnackbar("Başarılı", msg);
      await Future.delayed(const Duration(milliseconds: 700));
      Get.offAll(() => const SmartConfigPage());
    } catch (e) {
      _showErrorSnackbar(
          "Cihaz Ekleme Başarısız. Bu cihazın yöneticisi olmadığından emin olun.");
      await Future.delayed(const Duration(milliseconds: 400));
      await _openScanner();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveDeviceData(int chipId, int userId) async {
    await Future.wait([
      //LocalDb.add("accessToken", token),
      LocalDb.add("pendingWiFiChipId", chipId.toString()),
      LocalDb.add("pendingWiFiUserId", userId.toString()),
    ]);
  }

  void _navigateToSettingsWithSuccess(String? message) {
    Get.offAll(() => const SettingsPage());
    successSnackbar("Başarılı", message ?? "Cihaz başarıyla eklendi");
  }

  void _showErrorSnackbar(dynamic error) {
    final message = error is Exception
        ? error.toString()
        : "Bir hata oluştu. Lütfen tekrar deneyin.";
    errorSnackbar("Hata", message);
    if (_lastScannedCode != null && !message.contains('Kullanıcı ID')) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted)
          setState(() {
            _isHandled = false;
            _showScanner = true;
          });
      });
    }
  }

  Future<void> _openScanner() async {
    if (!mounted) return;
    setState(() {
      _showScanner = true;
      _isHandled = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _cameraController.start();
      } catch (e) {
        debugPrint('camera start error: $e');
      }
    });
  }

  Future<void> _closeScanner() async {
    try {
      await _cameraController.stop();
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) setState(() => _showScanner = false);
    } catch (e) {
      debugPrint('Camera stop error: $e');
    }
  }
}
