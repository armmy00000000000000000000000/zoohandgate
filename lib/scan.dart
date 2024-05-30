import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodeScannerApp extends StatefulWidget {
  @override
  _QRCodeScannerAppState createState() => _QRCodeScannerAppState();
}

class _QRCodeScannerAppState extends State<QRCodeScannerApp> {
  late QRViewController _controller;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  final AudioCache _audioCache = AudioCache();
  int selectedPayment = 0;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: Text('QR Code Scanner'),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 5,
              child: QRView(
                key: _qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.red,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 300,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text('Scan a QR code'),
              ),
            ),
          ],
        ),
      );

  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
      _controller.scannedDataStream.listen((scanData) {
        print('Scanned data: ${scanData.code}');
        _playSound(); // Play sound when QR code is scanned
        _navigateToNextPage(scanData.code!); // Navigate to next page
      });
    });
  }

  void _playSound() {
    _audioCache.play('scan_sound.mp3');
  }

  void _navigateToNextPage(String data) {
    
    Get.to(NextPage(data: data)); // Navigate to NextPage and pass scanned data
  }
}

class NextPage extends StatelessWidget {
  final String data;

  const NextPage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Page'),
      ),
      body: Center(
        child: Text('Scanned data: $data'), // Display scanned data
      ),
    );
  }
}
