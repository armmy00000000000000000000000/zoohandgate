import 'package:flutter/material.dart';

class OrderCheckPage extends StatefulWidget {
  final String barcode;

  OrderCheckPage({required this.barcode});

  @override
  _OrderCheckPageState createState() => _OrderCheckPageState();
}

class _OrderCheckPageState extends State<OrderCheckPage> {
  final TextEditingController _orderController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เช็ครายการคำสั่งซื้อ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('บาร์โค้ดที่สแกนได้: ${widget.barcode}'),
            SizedBox(height: 20),
            TextField(
              controller: _orderController,
              decoration: InputDecoration(
                labelText: 'หมายเลขคำสั่งซื้อ',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // ทำการเช็ครายการคำสั่งซื้อที่กรอก
                String orderNumber = _orderController.text;
                checkOrder(orderNumber);
              },
              child: Text('เช็ครายการ'),
            ),
          ],
        ),
      ),
    );
  }

  void checkOrder(String orderNumber) {
    // เขียนโค้ดเพื่อเช็ครายการคำสั่งซื้อที่นี่
    print('เช็ครายการสำหรับคำสั่งซื้อ: $orderNumber');
  }
}
