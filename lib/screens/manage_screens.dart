import 'package:easi_kitchen/screens/history_screens.dart';
import 'package:easi_kitchen/screens/home_screens.dart';
import 'package:easi_kitchen/screens/receipt_screens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final _firestore = FirebaseFirestore.instance;

class MenuManager extends StatefulWidget {
  const MenuManager({Key? key}) : super(key: key);

  @override
  _MenuManagerState createState() => _MenuManagerState();
}

num switching = 1;

class _MenuManagerState extends State<MenuManager> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    setState(() {
      switching;
    });
    var _value = false;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Menu Manager'),
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
                  Get.to(const Home());
                },
              ),
              ListTile(
                title: const Text('Menu Manager'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Past Order'),
                onTap: () {
                  Get.to(const HistoryScreen());
                },
              ),
              ListTile(
                title: const Text('Receipt Setting'),
                onTap: () {
                  Get.to(const ReceiptScreen());
                },
              )
            ],
          ),
        ),
        body: Column(
          children: const [
            Center(
              child: Text('Menu'),
            ),
            MenuStream(),
            Center(
              child: Text('Topping'),
            ),
            ToppingStream(),
          ],
        ));
  }
}

class ToppingStream extends StatelessWidget {
  const ToppingStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('Topping').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Column(
            children: [
              Center(
                child: LoadingAnimationWidget.newtonCradle(
                    color: Colors.white, size: 70),
              ),
            ],
          );
        }
        final orderss = snapshot.data?.docs;
        // final order = snapshot.data?.docs;
        List<ToppingSwitchUI> ticketKitchen = [];
        for (var ticket in orderss!) {
          final name = ticket.get('name');
          final inStock = ticket.get('bool');

          final messageBubble = ToppingSwitchUI(
            name: name,
            inStock: inStock,
          );

          ticketKitchen.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: ticketKitchen,
          ),
        );
      },
    );
  }
}

class MenuStream extends StatelessWidget {
  const MenuStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('Menu').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Column(
            children: [
              Center(
                child: LoadingAnimationWidget.newtonCradle(
                    color: Colors.white, size: 70),
              ),
            ],
          );
        }
        final orderss = snapshot.data?.docs;
        // final order = snapshot.data?.docs;
        List<MenuSwitchUI> ticketKitchen = [];
        for (var ticket in orderss!) {
          final name = ticket.get('name');
          final inStock = ticket.get('inStock');
          final id = ticket.get('id');

          final messageBubble = MenuSwitchUI(
            name: name,
            inStock: inStock,
            id: id,
          );

          ticketKitchen.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: ticketKitchen,
          ),
        );
      },
    );
  }
}

class ToppingSwitchUI extends StatefulWidget {
  ToppingSwitchUI({Key? key, required this.name, required this.inStock})
      : super(key: key);

  final String name;

  bool inStock;
  @override
  State<ToppingSwitchUI> createState() => _ToppingSwitchUIState();
}

class _ToppingSwitchUIState extends State<ToppingSwitchUI> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SwitchListTile(
            title: Text(widget.name),
            value: widget.inStock,
            onChanged: (bool value) {
              setState(() {
                widget.inStock = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

class MenuSwitchUI extends StatefulWidget {
  MenuSwitchUI(
      {Key? key, required this.name, required this.id, required this.inStock})
      : super(key: key);
  final String name;
  final String id;
  bool inStock;
  @override
  State<MenuSwitchUI> createState() => _MenuSwitchUIState();
}

class _MenuSwitchUIState extends State<MenuSwitchUI> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: SwitchListTile(
        title: Text(widget.name),
        value: widget.inStock,
        onChanged: (bool value) {
          setState(() {
            widget.inStock = value;

            _firestore
                .collection('Menu')
                .doc(widget.id)
                .update({'inStock': false});
            if (value == true) {
              _firestore
                  .collection('Menu')
                  .doc(widget.id)
                  .update({'inStock': true});
            }
          });
        },
      ),
    );
  }
}
