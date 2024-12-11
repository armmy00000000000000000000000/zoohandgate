import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_web_qrcode_scanner/flutter_web_qrcode_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class AutoScanExample extends StatefulWidget {
  const AutoScanExample({Key? key}) : super(key: key);

  @override
  State<AutoScanExample> createState() => _AutoScanExampleState();
}

class _AutoScanExampleState extends State<AutoScanExample> {
  String? _data;
  final AudioCache _audioPlayer = AudioCache(prefix: 'assets/');
  bool _isScanning = false; // เปลี่ยนสถานะการสแกนเป็น false เริ่มต้น
  final TextEditingController _orderController = TextEditingController();

  // ฟังก์ชันสำหรับส่งค่าไปยังหน้าอื่น
  void _goToNextPage(String order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(
          ref: order.toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ฟอร์มสำหรับกรอกหมายเลขคำสั่งซื้อ
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _orderController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'หมายเลขคำสั่งซื้อ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_orderController.text.isNotEmpty) {
                          _goToNextPage(_orderController
                              .text); // ส่งหมายเลขคำสั่งซื้อไปยังหน้าอื่น
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text('เช็ครายการ',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // แสดงข้อมูลที่สแกนได้
            if (_data != null)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _data!,
                    style: const TextStyle(fontSize: 18, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // ปุ่มเริ่มสแกน
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isScanning = true; // เริ่มการสแกน
                  _data = null; // รีเซ็ตข้อมูลที่สแกน
                });
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                backgroundColor: Colors.green,
              ),
              child: const Text('เริ่มสแกน',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            // แสดง FlutterWebQrcodeScanner ถ้ากำลังสแกน
            if (_isScanning)
              FlutterWebQrcodeScanner(
                cameraDirection: CameraDirection.back,
                onGetResult: (result) async {
                  // เล่นเสียงเมื่อสแกนสำเร็จ
                  await _audioPlayer.play('scan_sound.mp3');

                  setState(() {
                    _data = result;
                    _isScanning = false; // หยุดการสแกน
                    print(result);

                    _goToNextPage(result); // ส่งไปยังหน้าถัดไป
                  });

                  // คุณสามารถแสดงข้อความที่บอกว่า "สแกนเสร็จแล้ว" หรืออะไรก็ตาม
                  // เช่นแสดงปุ่มเพื่อให้ผู้ใช้สามารถกลับไปยังหน้าสแกนต่อได้
                },
                stopOnFirstResult: false, // ทำให้สแกนต่อไป
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
                onError: (error) {
                  print(error);
                },
                onPermissionDeniedError: () {
                  // แสดง dialog หรืออื่น ๆ
                },
              ),
          ],
        ),
      ),
    );
  }
}



/// เอาตัวล่าสุด /////////////////
class OrderDetailsPage extends StatefulWidget {
  final String ref;
  const OrderDetailsPage({super.key, required this.ref});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  List<Map<String, dynamic>> ticketList = [];
  bool isLoading = true;
  double totalAmount = 0.0;
  String zoo = '';
  String? status_pay;
  String? postpone;
  String? onDate;
  List<String> selectedTickets = [];

  @override
  void initState() {
    super.initState();
    fetchTickets(widget.ref);
  }

  Future<void> fetchTickets(String ref) async {
    setState(() {
      isLoading = true;
    });

    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://addpay.net/api/v1/zoo/check_qr'));
    request.body = json.encode({"ref1": ref});
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String jsonResponse = await response.stream.bytesToString();
        var decodedResponse = json.decode(jsonResponse);
        int zooId = decodedResponse['order']['zoo_id'];

        setState(() {
          status_pay = decodedResponse['order']['status'];
          postpone = decodedResponse['order']['postpone'];
          onDate = decodedResponse['order']['onDate'];
          zoo = _getZooName(zooId);
          ticketList = List<Map<String, dynamic>>.from(
              decodedResponse['tickets']['online_tickets']);
          totalAmount = _calculateTotalAmount(ticketList);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getZooName(int zooId) {
    switch (zooId) {
      case 1:
        return "สวนสัตว์เปิดเขาเขียว";
      case 2:
        return "สวนสัตว์เชียงใหม่";
      case 3:
        return "สวนสัตว์นครราชสีมา";
      case 4:
        return "สวนสัตว์อุบลราชธานี";
      case 5:
        return "สวนสัตว์ขอนแก่น";
      case 6:
        return "สวนสัตว์สงขลา";
      default:
        return "ไม่พบข้อมูลสวนสัตว์ที่ตรงกัน";
    }
  }

  double _calculateTotalAmount(List<Map<String, dynamic>> tickets) {
    double total = 0.0;
    for (var ticket in tickets) {
      total += ticket['ticket_type']['price'];
    }
    return total;
  }

  void toggleSelectAll(bool? isChecked) {
    setState(() {
      if (isChecked == true) {
        selectedTickets = ticketList
            .where((ticket) => ticket['status'] != 'active')
            .map((ticket) => '${ticket['id']}')
            .toList();
      } else {
        selectedTickets.clear();
      }
    });
  }

  Future<void> sendSelectedTickets() async {
    print(selectedTickets.toList());

    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://addpay.net/api/v1/zoo/handGate'));
    request.body = json.encode({
      "data": "${widget.ref}",
      "action": "in",
      "checker": "true",
      "tickets": selectedTickets.toList()
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var data = await response.stream.bytesToString();
    var decodedData = jsonDecode(data);

    if (response.statusCode == 200) {
      if (decodedData['status'] == 'success') {
        setState(() {
          send_user(decodedData['line_token'], 'in', widget.ref);
        });
        // แสดงข้อความแจ้งเตือนว่าการเช็คอินสำเร็จ
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('สำเร็จ'),
              content: Text('เช็คอินไอดี ${widget.ref} สำเร็จ'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('ตกลง'),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('แจ้งเตือน'),
                content: Text(
                    'มีข้อผิดผลาด ${widget.ref} หรือได้ทำการเช็คอินไปแล้ว'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('ตกลง'),
                  ),
                ],
              );
            },
          );
        });
      }
    } else {
      // พิมพ์ข้อความผิดพลาดที่ได้รับจากเซิร์ฟเวอร์
      print(response.reasonPhrase);
    }
  }

  Future<void> send_user(lineToken, check, ref) async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://addpay.net/emember/zoolineoa/Connected/Check_payment.php?token=${lineToken}&name=Arm&ref=${ref}&date=2024-08-02&status=${check}&total=4&zoo=4'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Widget _buildCheckbox(
      bool isSelected, bool isDisabled, Function(bool?)? onChanged) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Checkbox(
        value: isSelected,
        onChanged: isDisabled ? null : onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เช็ครายการบัตรเข้าชม ${widget.ref}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: Order Details
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ข้อมูลคำสั่งซื้อ',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('🌟 สวนสัตว์: ${zoo}',
                              style: TextStyle(fontSize: 16)),
                          Text('📋 เลขที่คำสั่งซื้อ: ${widget.ref}',
                              style: TextStyle(fontSize: 16)),
                          Text('💳 สถานะการชำระเงิน: ${status_pay}',
                              style: TextStyle(fontSize: 16)),
                          Text(
                            '🗓 วันที่เข้าชม: ${postpone ?? onDate}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Section: Tickets Table
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📜 รายการบัตร',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: selectedTickets.length ==
                                ticketList
                                    .where((ticket) =>
                                        ticket['status'] != 'active')
                                    .length,
                            onChanged: toggleSelectAll,
                          ),
                          Text(
                            'เลือกทั้งหมด',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Table(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                      4: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey.shade200),
                        children: [
                          _buildTableCell('รายการบัตร', isHeader: true),
                          _buildTableCell('X', isHeader: true),
                          _buildTableCell('สถานะ', isHeader: true),
                          _buildTableCell('รวม', isHeader: true),
                          _buildTableCell('เลือก', isHeader: true),
                        ],
                      ),
                      for (var ticket in ticketList)
                        TableRow(
                          children: [
                            _buildTableCell(ticket['ticket_type']['name']),
                            _buildTableCell('1x'),
                            _buildTableCell(
                              ticket['status'] == 'active' &&   ticket['status'] == 'finished'
                                  ? 'เช็คอินแล้ว'
                                  : ticket['status'] == 'ready'
                                      ? 'พร้อมใช้งาน'
                                      : 'ไม่สามารถระบุได้',
                            ),
                            _buildTableCell(
                                '${ticket['ticket_type']['price']} บาท'),
                            _buildCheckbox(
                              selectedTickets.contains('${ticket['id']}') ||
                                  (ticket['status'] == 'active' ||
                                      ticket['status'] == 'finished'),
                              ticket['status'] == 'active' ||
                                  ticket['status'] == 'finished',
                              (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedTickets.add('${ticket['id']}');
                                  } else {
                                    selectedTickets.remove('${ticket['id']}');
                                  }
                                });
                              },
                            ),

                            // _buildCheckbox(
                            //   selectedTickets.contains(
                            //           '${ticket['id']}') ||
                            //       ticket['status'] == 'active',
                            //   ticket['status'] == 'active',
                            //   (value) {
                            //     setState(() {
                            //       if (value == true) {
                            //         selectedTickets
                            //             .add('${ticket['id']}');
                            //       } else {
                            //         selectedTickets.remove(
                            //             '${ticket['id']}');
                            //       }
                            //     });
                            //   },
                            // ),
                          ],
                        ),
                    ],
                  ),

                  // Section: Total Price
                  SizedBox(height: 16),
                  Text(
                    '💰 ราคารวมทั้งหมด: ${totalAmount.toStringAsFixed(2)} บาท',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700),
                  ),

                  // Section: Action Buttons
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: sendSelectedTickets,
                        icon: Icon(Icons.check),
                        label: Text('เช็คอิน'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.all(16)),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          fetchTickets(widget.ref);
                        },
                        icon: Icon(Icons.refresh),
                        label: Text('รีเฟรช'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow.shade700,
                            padding: EdgeInsets.all(16)),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.add),
                        label: Text('ทำรายการใหม่'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.all(16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.black : Colors.grey.shade800,
        ),
      ),
    );
  }
}

/// เอาตัวล่าสุด /////////////////








// class OrderDetailsPage extends StatefulWidget {
//   final String ref;
//   const OrderDetailsPage({super.key, required this.ref});

//   @override
//   State<OrderDetailsPage> createState() => _OrderDetailsPageState();
// }

// class _OrderDetailsPageState extends State<OrderDetailsPage> {
//   List<Map<String, dynamic>> ticketList = [];
//   bool isLoading = true;
//   double totalAmount = 0.0;
//   String zoo = '';
//   String? textdata;
//   String? status_pay;
//   String? status;
//   String? check;
//   String? msg;

//   @override
//   void initState() {
//     super.initState();
//     fetchTickets(widget.ref);
//   }

//   Future<void> fetchTickets(String ref) async {
//     setState(() {
//       isLoading = true; // เริ่มต้นการโหลดข้อมูลใหม่
//     });

//     var headers = {
//       'Content-Type': 'application/json',
//     };
//     var request = http.Request(
//         'POST', Uri.parse('https://zooe-ticket.com/api/v1/zoo/check_qr'));
//     request.body = json.encode({"ref1": ref});
//     request.headers.addAll(headers);

//     try {
//       http.StreamedResponse response = await request.send();

//       if (response.statusCode == 200) {
//         String jsonResponse = await response.stream.bytesToString();
//         var decodedResponse = json.decode(jsonResponse);
//         int zooId = decodedResponse['order']['zoo_id'];
        
//         setState(() {
//           status_pay = decodedResponse['order']['status'];
//           zoo = _getZooName(zooId);
//           ticketList = List<Map<String, dynamic>>.from(decodedResponse['tickets']['online_tickets']);
//           ticketList = _groupTicketsByType(ticketList);
//           totalAmount = _calculateTotalAmount(ticketList);
//           isLoading = false; // เสร็จสิ้นการโหลด
//         });
//       } else {
//         print(response.reasonPhrase);
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print(e);
//       setState(() {
//         isLoading = false; // จบการโหลดเมื่อเกิดข้อผิดพลาด
//       });
//     }
//   }

//   String _getZooName(int zooId) {
//     switch (zooId) {
//       case 1: return "สวนสัตว์เปิดเขาเขียว";
//       case 2: return "สวนสัตว์เชียงใหม่";
//       case 3: return "สวนสัตว์นครราชสีมา";
//       case 4: return "สวนสัตว์อุบลราชธานี";
//       case 5: return "สวนสัตว์ขอนแก่น";
//       case 6: return "สวนสัตว์สงขลา";
//       default: return "ไม่พบข้อมูลสวนสัตว์ที่ตรงกัน";
//     }
//   }

//   // ฟังก์ชันจัดกลุ่มรายการบัตรที่มี ticket_type_id เหมือนกัน
//   List<Map<String, dynamic>> _groupTicketsByType(List<Map<String, dynamic>> tickets) {
//     Map<int, Map<String, dynamic>> groupedTickets = {};

//     for (var ticket in tickets) {
//       int id = ticket['ticket_type']['id'];
//       if (groupedTickets.containsKey(id)) {
//         groupedTickets[id]!['quantity'] += 1;
//         groupedTickets[id]!['total_price'] += ticket['ticket_type']['price'];
//       } else {
//         groupedTickets[id] = {
//           'ticket_type': ticket['ticket_type'],
//           'quantity': 1,
//           'total_price': ticket['ticket_type']['price'],
//           'active_date': ticket['expire_date'],
//         };
//       }
//     }

//     return groupedTickets.values.toList();
//   }

//   // ฟังก์ชันคำนวณราคารวมทั้งหมด
//   double _calculateTotalAmount(List<Map<String, dynamic>> tickets) {
//     double total = 0.0;
//     for (var ticket in tickets) {
//       total += ticket['total_price'];
//     }
//     return total;
//   }

//   Future<void> send_qr() async {
//     var headers = {'Content-Type': 'application/json'};
//     var request = http.Request(
//         'POST', Uri.parse('https://zooe-ticket.com/api/v1/zoo/handGate'));
//     request.body = json.encode({"data": "${widget.ref}", "action": "in"});
//     request.headers.addAll(headers);

//     try {
//       http.StreamedResponse response = await request.send();
//       var data = await response.stream.bytesToString();
//       var decodedData = jsonDecode(data);
      
//       if (response.statusCode == 200) {
//         setState(() {
//           msg = decodedData['msg'];
//           status = (decodedData['status'] == 'success') ? 'เช็คอินสำเร็จ' : 'เช็คอินไม่สำเร็จ';
//           check = decodedData['status'];
//         });
//       } else {
//         print(response.reasonPhrase);
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'เช็ครายการบัตรเข้าชม production ${widget.ref}',
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   Text('${zoo}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   Text('เลขที่คำสั่งซื้อ: ${widget.ref}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   Text('สถานะการชำระ: ${status_pay}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   SizedBox(height: 16),
//                   Expanded(
//                     child: Table(
//                       border: TableBorder.all(),
//                       columnWidths: const {
//                         0: FlexColumnWidth(3),
//                         1: FlexColumnWidth(2),
//                         2: FlexColumnWidth(3),
//                         3: FlexColumnWidth(2),
//                       },
//                       children: [
//                         TableRow(
//                           children: [
//                             Padding(padding: const EdgeInsets.all(8.0), child: Text('รายการบัตร', style: TextStyle(fontWeight: FontWeight.bold))),
//                             Padding(padding: const EdgeInsets.all(8.0), child: Text('จำนวน', style: TextStyle(fontWeight: FontWeight.bold))),
//                             Padding(padding: const EdgeInsets.all(8.0), child: Text('วันที่', style: TextStyle(fontWeight: FontWeight.bold))),
//                             Padding(padding: const EdgeInsets.all(8.0), child: Text('รวม', style: TextStyle(fontWeight: FontWeight.bold))),
//                           ],
//                         ),
//                         for (var ticket in ticketList)
//                           TableRow(
//                             children: [
//                               Padding(padding: const EdgeInsets.all(8.0), child: Text(ticket['ticket_type']['name'])),
//                               Padding(padding: const EdgeInsets.all(8.0), child: Text('${ticket['quantity']}X')),
//                               Padding(padding: const EdgeInsets.all(8.0), child: Text(ticket['active_date'])),
//                               Padding(padding: const EdgeInsets.all(8.0), child: Text('${ticket['total_price']} บาท')),
//                             ],
//                           ),
//                       ],
//                     ),
//                   ),
//                   status == null
//                       ? Container()
//                       : Container(
//                           alignment: Alignment.center,
//                           child: Column(
//                             children: [
//                               Container(
//                                 padding: EdgeInsets.all(8),
//                                 child: Text('$status', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w400)),
//                               ),
//                               Container(
//                                 child: Column(
//                                   children: [
//                                     Text('ID:: ${widget.ref}', style: TextStyle(color: Colors.white, fontSize: 16)),
//                                     Text('$msg', style: TextStyle(color: Colors.white, fontSize: 16)),
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),
//                           width: 319,
//                           height: 120,
//                           decoration: BoxDecoration(
//                             color: check == 'success' ? Colors.green : Colors.red,
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(color: Color(0x3F000000), blurRadius: 3, offset: Offset(2, 2), spreadRadius: 0),
//                             ],
//                           ),
//                         ),
//                   Text('ราคารวมทั้งหมด: ${totalAmount.toStringAsFixed(2)} บาท', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         width: 200,
//                         child: ElevatedButton(
//                           onPressed: send_qr,
//                           child: Text('เช็คอิน', style: TextStyle(fontSize: 18, color: Colors.white)),
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(vertical: 16),
//                             backgroundColor: Colors.green,
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 200,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             fetchTickets(widget.ref); // เรียกดูข้อมูลใหม่
//                           },
//                           child: Text('ตรวจสอบรายการอีกครั้ง', style: TextStyle(fontSize: 18, color: Colors.black)),
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(vertical: 16),
//                             backgroundColor: Colors.yellow,
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 200,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => AutoScanExample(),
//                               ),
//                             );
//                           },
//                           child: Text('ทำรายการใหม่', style: TextStyle(fontSize: 18, color: Colors.black)),
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(vertical: 16),
//                             backgroundColor: Colors.blue,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
