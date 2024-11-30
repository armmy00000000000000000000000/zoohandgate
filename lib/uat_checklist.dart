import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UatChecklist extends StatefulWidget {
  final String ref;
  const UatChecklist({super.key, required this.ref});

  @override
  State<UatChecklist> createState() => _UatChecklistState();
}

class _UatChecklistState extends State<UatChecklist> {
  List<Map<String, dynamic>> ticketList = [];
  bool isLoading = true;
  double totalAmount = 0.0;
  String zoo = '';
  String? textdata;
  String? status_pay;
  String? status;
  String? check;
  String? msg;
  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    var headers = {
      'Content-Type': 'application/json',
    };
    var request = http.Request(
        'POST', Uri.parse('https://addpay.net/api/v1/zoo/check_qr'));
    request.body = json.encode({
      "ref1": widget.ref, // ใช้ค่า ref ที่รับมาจาก widget
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String jsonResponse = await response.stream.bytesToString();
      var decodedResponse = json.decode(jsonResponse);
      int zooId = decodedResponse['order']['zoo_id'];
      setState(() {
        status_pay = decodedResponse['order']['status'];
      });
      print(decodedResponse['order']['zoo_id']);
      switch (zooId) {
        case 1:
          setState(() {
            zoo = "สวนสัตว์เปิดเขาเขียว";
          });
          break;
        case 2:
          setState(() {
            zoo = "สวนสัตว์เชียงใหม่";
          });
          // ทำบางสิ่งสำหรับ zoo_id 2
          break;
        case 3:
          setState(() {
            zoo = "สวนสัตว์นครราชสีมา";
          });
          // ทำบางสิ่งสำหรับ zoo_id 3
          break;
        case 4:
          setState(() {
            zoo = "สวนสัตว์อุบลราชธานี";
          });
          // ทำบางสิ่งสำหรับ zoo_id 3
          break;
        case 5:
          setState(() {
            zoo = "สวนสัตว์ขอนแก่น";
          });
          // ทำบางสิ่งสำหรับ zoo_id 3
          break;
        case 6:
          setState(() {
            zoo = "สวนสัตว์สงขลา";
          });
          // ทำบางสิ่งสำหรับ zoo_id 3
          break;
        default:
          setState(() {
            zoo = "ไม่พบข้อมูลสวนสัตว์ที่ตรงกัน";
          });
        // ทำบางสิ่งเมื่อไม่พบกรณีที่ตรงกัน
      }
      setState(() {
        ticketList = List<Map<String, dynamic>>.from(
            decodedResponse['tickets']['online_tickets']);
        ticketList = _groupTicketsByType(ticketList);
        totalAmount = _calculateTotalAmount(ticketList); // คำนวณราคารวมทั้งหมด
        isLoading = false;
      });
    } else {
      print(response.reasonPhrase);
      setState(() {
        isLoading = false;
      });
    }
  }

  // ฟังก์ชันจัดกลุ่มรายการบัตรที่มี ticket_type_id เหมือนกัน
  List<Map<String, dynamic>> _groupTicketsByType(
      List<Map<String, dynamic>> tickets) {
    Map<int, Map<String, dynamic>> groupedTickets = {};

    for (var ticket in tickets) {
      int id = ticket['ticket_type']['id'];
      if (groupedTickets.containsKey(id)) {
        groupedTickets[id]!['quantity'] += 1;
        groupedTickets[id]!['total_price'] += ticket['ticket_type']['price'];
      } else {
        groupedTickets[id] = {
          'ticket_type': ticket['ticket_type'],
          'quantity': 1,
          'total_price': ticket['ticket_type']['price'],
          'active_date': ticket['expire_date'],
        };
      }
    }

    return groupedTickets.values.toList();
  }

  // ฟังก์ชันคำนวณราคารวมทั้งหมด
  double _calculateTotalAmount(List<Map<String, dynamic>> tickets) {
    double total = 0.0;
    for (var ticket in tickets) {
      total += ticket['total_price'];
    }
    return total;
  }

  Future<void> send_qr() async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://addpay.net/api/v1/zoo/handGate'));
    request.body = json.encode({"data": "${widget.ref}", "action": "in"});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var data = await response.stream.bytesToString();
    var decodedData = jsonDecode(data);
    if (response.statusCode == 200) {
      // พิมพ์ค่า status ที่ได้รับจากเซิร์ฟเวอร์
      if (decodedData['status'] == 'success') {
        setState(() {
          send_user(decodedData['line_token'], 'in', widget.ref);
          msg = decodedData['msg'];
          status = 'เช็คอินสำเร็จ';
          check = decodedData['status'];
        });
      } else {
        setState(() {
          msg = decodedData['msg'];
          status = 'เช็คอินไม่สำเร็จ';
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
            'https://addpay.net/emember/zoolineoa/Connected/Check_payment.php?token=${lineToken}&name=Arm&ref=${ref}&date=2024-08-02&status=${check}&total=4&zoo=4'));

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
      appBar: AppBar(
        title: Text(
          'เช็ครายการบัตรเข้าชม uat',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
      Text(
                    '${zoo}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                       Text(
                    'เลขที่คำสั่งซื้อ: ${widget.ref}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                             Text(
                    'สถานะการชำระ: ${status_pay}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Table(
                      border: TableBorder.all(),
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(3),
                        3: FlexColumnWidth(2),
                      },
                      children: [
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('รายการบัตร',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('จำนวน',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('วันที่',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('รวม',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        for (var ticket in ticketList)
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(ticket['ticket_type']['name']),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                    Text('${ticket['quantity'].toString()}X'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(ticket['active_date']),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${ticket['total_price']} บาท'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
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
                                    'ID:: ${widget.ref}',
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
                            color:
                                check == 'success' ? Colors.green : Colors.red,
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
                  Text(
                    'ราคารวมทั้งหมด: ${totalAmount.toStringAsFixed(2)} บาท',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: send_qr,
                      child: Text(
                        'เช็คอิน',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _checkIn() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เช็คอินสำเร็จ'),
          content: Text('คุณได้ทำการเช็คอินเรียบร้อยแล้ว!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ปิด'),
            ),
          ],
        );
      },
    );
  }
}
