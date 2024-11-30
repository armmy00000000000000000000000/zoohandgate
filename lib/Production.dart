import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:zoohandgate/Produc_checklist.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

class Production extends StatefulWidget {
  final String endport;
  const Production({super.key, required this.endport});

  @override
  State<Production> createState() => _ProductionState();
}

class _ProductionState extends State<Production> {
  late QRViewController _controller;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  final AudioCache _audioCache = AudioCache();
  final TextEditingController _refController = TextEditingController();
  String? textdata;
  String? status;
  String? check;
  String? msg;
  int selectedPayment = 0;
  bool isScanning = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
      _controller.scannedDataStream.listen((scanData) async {
        if (isScanning) return;
        isScanning = true;

        print('Scanned data: ${scanData.code}');
        _playSound(); // Play sound when QR code is scanned
        setState(() {
          textdata = scanData.code!;
        });

        if (selectedPayment == 0) {
          await send_qr(textdata, 'in');
        } else if (selectedPayment == 1) {
          await send_qr(textdata, 'out');
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Produchecklist(
                      ref: textdata.toString(),
                    )),
          );
        }

        _playSound();
        await Future.delayed(Duration(seconds: 5));
        setState(() {
          status = null;
        });

        isScanning = false; // Reset scanning flag after delay
      });
    });
  }

  void send_text() {}

  void _playSound() {
    _audioCache.play('scan_sound.mp3');
  }

  Future<void> send_qr(dataqr, c) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://zooe-ticket.com/api/v1/zoo/handGate'));
    request.body = json.encode({"data": "$dataqr", "action": "$c"});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var data = await response.stream.bytesToString();
    var decodedData = jsonDecode(data);
    if (response.statusCode == 200) {
      // พิมพ์ค่า status ที่ได้รับจากเซิร์ฟเวอร์
      if (decodedData['status'] == 'success') {
        setState(() {
          send_user(decodedData['line_token'], c, dataqr);
          msg = decodedData['msg'];
          status = 'สแกนสำเร็จ';
          check = decodedData['status'];
        });
      } else {
        setState(() {
          msg = decodedData['msg'];
          status = 'สแกนไม่สำเร็จ';
          check = decodedData['status'];
        });
      }
      ;
    } else {
      // พิมพ์ข้อความผิดพลาดที่ได้รับจากเซิร์ฟเวอร์
      print(response.reasonPhrase);
    }
  }

  Future<void> send_user(lineToken, check, ref) async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://zooe-ticket.com/emember/zoolineoa/Connected/Check_payment.php?token=${lineToken}&name=Arm&ref=${ref}&date=2024-08-02&status=${check}&total=4&zoo=4'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            status == null
                ? Container()
                : Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            '$status',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ),
                        Container(
                            child: Column(
                          children: [
                            Text(
                              'ID:: $textdata',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                            Text(
                              '$msg',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ],
                        ))
                      ],
                    ),
                    width: 319,
                    height: 120,
                    decoration: ShapeDecoration(
                      color: check == 'success' ? Colors.green : Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 3,
                          offset: Offset(2, 2),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                  ),
            Column(
              children: [
                Container(
                  child: status == null
                      ? Text(
                          'พร้อมใช้งาน',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        )
                      : Text(
                          '',
                        ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  alignment: Alignment.center,
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
                  width: 319,
                  height: 300,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 3,
                        offset: Offset(2, 2),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    child: Text(
                      '${widget.endport}',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6800000071525574),
                        fontSize: 16,
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        child: CustomPaymentCardButton("สแกนเข้า", 0),
                      ),
                      Container(
                        child: CustomPaymentCardButton("สแกนออก", 1),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    child: CustomPaymentCardButton("สแกนเช็ครายการบัตร", 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('กรอกเลข ref'),
                content: TextField(
                  controller: _refController,
                  decoration: InputDecoration(hintText: "ใส่เลข ref ที่นี่"),
                ),
                actions: [
                  TextButton(
                    child: Text('เช็คอิน'),
                    onPressed: () {
                      setState(() {
                        textdata = _refController.text;
                        print(_refController.text);
                        send_qr(_refController.text, 'in');
                      });
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green, // สีพื้นหลัง
                    ),
                  ),
                  TextButton(
                    child: Text('เช็คเอ้าค์'),
                    onPressed: () {
                      setState(() {
                        textdata = _refController.text;
                        send_qr(_refController.text, 'out');
                      });

                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red, // สีพื้นหลัง
                    ),
                  ),
                  TextButton(
                    child: Text('เช็ครายการ'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Produchecklist(
                                  ref: _refController.text.toString(),
                                )),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue, // สีพื้นหลัง
                    ),
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'กรอกเลข ref',
        child: Icon(Icons.edit), // ใช้ไอคอนแทนข้อความ
      ),
    );
  }

  Widget CustomPaymentCardButton(String assetName, int index) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          selectedPayment = index;
        });
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        side: BorderSide(
            width: (selectedPayment == index) ? 2.0 : 0.5,
            color: (selectedPayment == 0)
                ? Colors.green
                : (selectedPayment == 1)
                    ? Colors.red
                    : Colors.blue),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
                child: Container(
              alignment: Alignment.center,
              child: Text(
                '$assetName',
                style: assetName == "สแกนเข้า"
                    ? TextStyle(
                        color: Colors.green,
                        fontSize: 13,
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      )
                    : assetName == "สแกนออก"
                        ? TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w500,
                            height: 0,
                          )
                        : TextStyle(
                            color: Colors.blue,
                            fontSize: 13,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w500,
                            height: 0,
                          ),
              ),
              width: 145,
              height: 53,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            )),
          ),
          if (selectedPayment == index)
            Positioned(
                top: 5,
                right: 5,
                child: Icon(
                  Icons.qr_code,
                  size: 40,
                  color: selectedPayment == 0
                      ? Colors.green
                      : selectedPayment == 1
                          ? Colors.red
                          : Colors.blue,
                )),
        ],
      ),
    );
  }
}
