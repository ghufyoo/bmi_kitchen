import 'package:easi_kitchen/screens/add_new_printer_screen.dart';
import 'package:easi_kitchen/screens/history_screens.dart';
import 'package:easi_kitchen/screens/home_screens.dart';
import 'package:easi_kitchen/screens/manage_screens.dart';

import 'package:flutter/material.dart';

import 'unpaid_order_screen.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({Key? key}) : super(key: key);

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final tabs = [
      Add_New_Printer(),
      Container(
        color: Colors.yellow,
      ),
      Container(
        color: Colors.cyan,
      )
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Receipt Setting'),
      ),
      drawer: Drawer(
        backgroundColor: Colors.teal,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                        'images/drawer.png',
                      ),
                      fit: BoxFit.cover)),
              child: Text('Setting'),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
            ),
             ListTile(
              tileColor: Colors.indigo,
              title: const Text('Unpaid Orders'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UnpaidOrder()),
                );
              },
            ),
            ListTile(
              title: const Text('Menu Manager'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenuManager()),
                );
              },
            ),
            ListTile(
              title: const Text('Past Order'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Receipt Setting'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceiptPage(),
                    ));
              },
            )
          ],
        ),
      ),
      body: Row(children: [
        Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => setState(
                    () => selectedIndex = 0,
                  ),
                  child: Container(
                    height: 50,
                    color: Colors.red,
                    child: Center(child: Text('Printer Connection 🖨')),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(
                    () => selectedIndex = 1,
                  ),
                  child: Container(
                    height: 50,
                    color: Colors.yellow,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(
                    () => selectedIndex = 2,
                  ),
                  child: Container(
                    height: 50,
                    color: Colors.cyan,
                  ),
                ),
                Spacer(),
                Center(
                  child: Text(
                    '*Receipt Setting*',
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            )),
        Expanded(flex: 3, child: tabs[selectedIndex]),
      ]),
    );
  }
}
