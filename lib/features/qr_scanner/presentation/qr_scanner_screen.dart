import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/models/f1_models.dart';
import '../../../data/store/app_store.dart';

String? parseF1RaceQrCode(String value, Iterable<F1Race> races) {
  final match = RegExp(r'^F1RACE:([a-z0-9_-]+)$', caseSensitive: false)
      .firstMatch(value.trim());
  final raceId = match?.group(1)?.toLowerCase();
  if (raceId == null || !races.any((race) => race.id == raceId)) return null;
  return raceId;
}

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  PermissionStatus? _cameraPermission;
  bool _requestingPermission = false;
  bool _handlingCode = false;
  late AppStore _store;

  bool get _supportsCamera =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.android;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = StoreScope.of(context);
  }

  @override
  void initState() {
    super.initState();
    if (_supportsCamera) _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    setState(() => _requestingPermission = true);
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() {
      _cameraPermission = status;
      _requestingPermission = false;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handlingCode) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null) return;
    _handlingCode = true;

    final raceId = parseF1RaceQrCode(value, _store.races);
    if (raceId != null) {
      Navigator.pushReplacementNamed(context, Routes.race, arguments: raceId);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Бұл QR-код F1 Tracker жарысына сәйкес келмейді.'),
      ),
    );
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _handlingCode = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final permission = _cameraPermission;
    return Scaffold(
      appBar: AppBar(title: const Text('F1 QR-сканері')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: !_supportsCamera
                ? const F1Panel(
                    child: Text(
                      'QR-сканер веб-браузерде және Android құрылғысында қолжетімді.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : _requestingPermission || permission == null
                    ? const CircularProgressIndicator()
                    : permission.isGranted
                        ? Column(
                            children: [
                              const Text(
                                'Камераны жарыс билетіндегі F1 Tracker QR-кодына бағыттаңыз.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: MobileScanner(onDetect: _onDetect),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Код пішімі: F1RACE:<жарыс ID>',
                                style: TextStyle(color: F1Colors.muted),
                              ),
                            ],
                          )
                        : _permissionDenied(context, permission),
          ),
        ),
      ),
    );
  }

  Widget _permissionDenied(
    BuildContext context,
    PermissionStatus permission,
  ) {
    final permanentlyDenied =
        permission.isPermanentlyDenied || permission.isRestricted;
    final browserPermissionBlocked = kIsWeb && permission.isPermanentlyDenied;
    return F1Panel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.no_photography_outlined,
              size: 46, color: F1Colors.red),
          const SizedBox(height: 16),
          Text(
            browserPermissionBlocked
                ? 'Браузерде камераға рұқсат бұғатталған. Сайт баптауларынан камераға рұқсат беріп, қайта тексеріңіз.'
                : permanentlyDenied
                    ? 'Камераға рұқсат бұғатталған. QR-сканерді пайдалану үшін құрылғы баптауларынан рұқсат беріңіз.'
                    : 'QR-кодты оқу үшін камераға рұқсат қажет.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          F1Button(
            label: browserPermissionBlocked
                ? 'Рұқсатты қайта тексеру'
                : permanentlyDenied
                    ? 'Құрылғы баптауларын ашу'
                    : 'Рұқсатты қайта сұрау',
            icon: Icons.camera_alt_outlined,
            onPressed: browserPermissionBlocked
                ? _requestCameraPermission
                : permanentlyDenied
                    ? openAppSettings
                    : _requestCameraPermission,
          ),
        ],
      ),
    );
  }
}
