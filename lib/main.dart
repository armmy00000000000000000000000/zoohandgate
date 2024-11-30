
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoohandgate/home.dart';
import 'package:zoohandgate/home_web.dart';
import 'package:zoohandgate/login/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TicKet-Zoo',
      debugShowCheckedModeBanner: false,
      home: CheckAuth(),
      theme: ThemeData(
        primaryIconTheme: IconThemeData(color: Colors.white),
        scaffoldBackgroundColor:  Color(0xFFC4F5FF)
   
      ),
      themeMode: ThemeMode.dark,

    );
  }
}

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  void _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');print(token);
    if (token != null) {
      if (mounted) {
        setState(() {
          isAuth = true;
        });
      }
    }else{

    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildSplashView(),
    );
  }

  Widget _buildSplashView() {
    if (isAuth) {
      return _buildSplashViewWithText();
    } else {
      return _buildSplashViewWithAnimatedText();
    }
  }

  Widget _buildSplashViewWithText() {
    return AutoScanExample();
  }

  Widget _buildSplashViewWithAnimatedText() {
    return Login();
  }
}



