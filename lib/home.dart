

import 'package:flutter/material.dart';
import 'package:zoohandgate/Production.dart';
import 'package:zoohandgate/Uat.dart';

/// Flutter code sample for [TabBar].


class Home extends StatefulWidget {
  const Home( {super.key});

 

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(height: 50,),
             TabBar.secondary(
            controller: _tabController,
            tabs: const <Widget>[
              Tab(text: 'Uat'),
              Tab(text: 'Production'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Uat(endport: 'กำลังใช้งานอยู่ในโหมด UAT ',),
                ),
                Card(
                  margin: const EdgeInsets.all(16.0),
                  child: Production(endport: 'กำลังใช้งานอยู่ในโหมด Production ',)
                )
              ],
            ),
          ),
       
        ],
      ),
    );
  }
}
