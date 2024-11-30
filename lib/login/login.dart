import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoohandgate/home.dart';
import 'package:zoohandgate/home_web.dart';

class Login extends StatefulWidget {
  const Login({Key? key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 298,
          height: 400,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(21),
            ),
            shadows: [
              BoxShadow(
                color: Color(0xAD000000),
                blurRadius: 3,
                offset: Offset(3, 3),
                spreadRadius: 0,
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  'Zoo hand Gate',
                  style: TextStyle(
                    color: Color(0xFF008BA2),
                    fontSize: 20,
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
              ),
              Container(
                child: Text(
                  'เข้าสู่ระบบ',
                  style: TextStyle(
                    color: Color(0xFF008BA2),
                    fontSize: 20,
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                ),
              ),
              Container(
                width: 213,
                height: 50,
                decoration: ShapeDecoration(
                  color: Color(0xFF04A0BB),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)),
                ),
                child: TextButton(
                  onPressed: () {
                    // เช็ค email และ password
                    if (emailController.text == 'admin' &&
                        passwordController.text == 'addpay') {
                      // บันทึกสถานะการเข้าสู่ระบบใน SharedPreferences
                      _login();
                    } else {
                      // แจ้งเตือนเมื่อข้อมูลไม่ถูกต้อง
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('อีเมลหรือรหัสผ่านไม่ถูกต้อง'),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'เข้าสู่ระบบ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // บันทึกสถานะการเข้าสู่ระบบ
  void _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token','00000002222222'); // บันทึกสถานะเข้าสู่ระบบ
    Get.off(AutoScanExample()); // ไปยังหน้าหลักหลังจากเข้าสู่ระบบ
  }
}
