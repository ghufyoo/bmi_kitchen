import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easi_kitchen/screens/history_screens.dart';
import 'package:easi_kitchen/screens/manage_screens.dart';
import 'package:easi_kitchen/screens/receipt_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../components/testprint.dart';

final _firestore = FirebaseFirestore.instance;
late String order;

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController pandaController = TextEditingController()..text = '#';
  TextEditingController grabController = TextEditingController()..text = 'GF';

  Future pandaDialog() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Masukkan Id Order FoodPanda'),
            content: TextField(
              keyboardType: TextInputType.number,
              autofocus: true,
              controller: pandaController,
              decoration: const InputDecoration(hintText: 'Order ID'),
              onChanged: (value) {
                order = value;
              },
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    pandaController.clear();
                    _firestore.collection('foodpanda').add({'order_id': order});
                    Get.back();
                  },
                  child: const Text('Panggil'))
            ],
          ));
  Future grabDialog() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Masukkan Id Order GrabFood'),
            content: TextField(
              keyboardType: TextInputType.number,
              autofocus: true,
              controller: grabController,
              decoration: const InputDecoration(hintText: 'Order ID'),
              onChanged: (value) {
                order = value;
              },
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    grabController.clear();
                    _firestore.collection('grabfood').add({'order_id': order});
                    Get.back();
                  },
                  child: const Text('Panggil'))
            ],
          ));
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Cendol BMI Pekan Nilai'),
        actions: [
          const Center(
            child: Text('Status Kedai', style: TextStyle(color: Colors.white)),
          ),
          StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('CendolPekanNilai')
                  .doc(1985.toString())
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something Went Wrong! ${snapshot.error}');
                } else if (snapshot.hasData) {
                  var data = snapshot.data!;
                  bool open = data['isOpen'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 40, left: 10),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: SwitchListTile(
                        value: open,
                        onChanged: (bool value) {
                          setState(() {
                            open = value;

                            _firestore
                                .collection('CendolPekanNilai')
                                .doc('1985')
                                .update({'isOpen': false});
                            if (value == true) {
                              _firestore
                                  .collection('CendolPekanNilai')
                                  .doc('1985')
                                  .update({'isOpen': true});
                            }
                          });
                        },
                      ),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
          InkWell(
            onTap: () {
              grabDialog();
            },
            child: Image.asset('images/grab.png', fit: BoxFit.cover),
          ),
          InkWell(
            onTap: () {
              pandaDialog();
            },
            child: Image.asset('images/fp.png', fit: BoxFit.cover),
          )
        ],
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
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Menu Manager'),
              onTap: () {
                Get.to(const MenuManager());
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
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: const [
            OrderStream(),
          ],
        ),
      ),
    );
  }
}

class OrderStream extends StatelessWidget {
  const OrderStream({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore.collection('newOrder').orderBy('timestamp').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final orderss = snapshot.data?.docs;
        // final order = snapshot.data?.docs;
        List<TicketUI> ticketKitchen = [];
        for (var ticket in orderss!) {
          final customerEmail = ticket.get('userEmail');
          final customerName = ticket.get('userName');
          final customerPhonenumber = ticket.get('userPhoneNumber');
          final receiptTime = ticket.get('currentTime');
          final receiptDate = ticket.get('currentDate');
          final receiptId = ticket.get('receiptId');
          final receiptUniqueId = ticket.get('ticketId');
          final buzzerNumber = ticket.get('buzzerNumber');
          final order = ticket.get('order');
          final totalPrice = ticket.get('totalPrice');
          final totalFoods = ticket.get('totalFoods');
          final totalDrinks = ticket.get('totalDrinks');
          final isDone = ticket.get('isDone');
          final isPickup = ticket.get('isPickup');
          final isPaid = ticket.get('isPaid');

          final messageBubble = TicketUI(
            orderLength: orderss.length,
            customerEmail: customerEmail,
            customerName: customerName,
            customerPhonenumber: customerPhonenumber,
            receiptTime: receiptTime,
            receiptDate: receiptDate,
            receiptId: receiptId,
            receiptUniqueId: receiptUniqueId,
            buzzerNumber: buzzerNumber,
            order: order,
            totalDrinks: totalDrinks,
            totalFoods: totalFoods,
            totalPrice: totalPrice,
            isPaid: isPaid,
            isPickup: isPickup,
            isDone: isDone,
          );

          ticketKitchen.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            children: ticketKitchen,
          ),
        );
      },
    );
  }
}

class TicketUI extends StatefulWidget {
  TicketUI(
      {Key? key,
      required this.orderLength,
      required this.customerEmail,
      required this.customerName,
      required this.customerPhonenumber,
      required this.receiptTime,
      required this.receiptDate,
      required this.receiptUniqueId,
      required this.receiptId,
      required this.buzzerNumber,
      required this.order,
      required this.totalDrinks,
      required this.totalFoods,
      required this.totalPrice,
      required this.isPaid,
      required this.isPickup,
      required this.isDone})
      : super(key: key);
  final int orderLength;
  final String customerEmail;
  final String customerName;
  final String customerPhonenumber;
  final String receiptTime;
  final String receiptDate;
  final num receiptId;
  final String receiptUniqueId;
  final num buzzerNumber;
  final Map<String, dynamic> order;
  final num totalDrinks;
  final num totalFoods;
  final num totalPrice;

  bool isPaid;
  bool isPickup;
  bool isDone;

  @override
  State<TicketUI> createState() => _TicketUIState();
}

List<String> Bungkus = [];
List<String> MakanSini = [];
List<String> top = [];

ticket(List<dynamic> name) {
  print(name);
}

enum paymentMethod { Cash, Ewallet, Card, none }
paymentMethod? _type = paymentMethod.none;

class _TicketUIState extends State<TicketUI> {
  Duration duration = const Duration();
  Timer? timer;
  BlueThermalPrinter printer = BlueThermalPrinter.instance;
  var cashController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // startTimer();
    // reset();
    // ticket(widget.dishName);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Bungkus.clear();
    MakanSini.clear();
    cashController.clear();
    super.dispose();
  }

  num buzzerNumber = 37;
  bool _loading = false;
  TestPrint testPrint = TestPrint();
  num balanceCashOut = 0;
  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    var screenSize = MediaQuery.of(context).size;
    DocumentReference documentReference = _firestore
        .collection('newOrder')
        .doc(widget.receiptUniqueId.toString());
    Map<String, dynamic> data = <String, dynamic>{};

    for (dynamic type in widget.order.keys) {
      data[type.toString()] = widget.order[type];
    }
    List splitList = [];
    int _selectedIndex = 37;

    setState(() {
      buzzerNumber;
      balanceCashOut;
    });
    return !widget.isDone
        ? Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  color: Colors.grey[200],
                ),
                width: screenSize.width * 0.3,
                child: widget.isPaid
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: screenSize.width * 0.3,
                            decoration: BoxDecoration(
                                color: Colors.teal.shade800,
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 2.0,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 2.0,
                                      offset: Offset(2.0, 2.0))
                                ]),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      var bytes = await rootBundle
                                          .load("images/receipt.png");
                                      if (await printer.isConnected == true) {
                                        printer.printNewLine();
                                        // printer.printImageBytes(
                                        //     bytes.buffer.asUint8List());
                                        printer.printCustom(
                                            "Cendol BMI Pekan Nilai", 3, 1);
                                        printer.printNewLine();
                                        printer.printNewLine();
                                        printer.printCustom(
                                            'Total Foods: ${widget.totalFoods} ',
                                            1,
                                            1);
                                        printer.printCustom(
                                            'Total Drinks: ${widget.totalDrinks} ',
                                            1,
                                            1);
                                        printer.printCustom(
                                            "Customer Name: ${widget.customerName}",
                                            1,
                                            0);
                                        printer.printCustom(
                                            "Customer email: ${widget.customerEmail}",
                                            1,
                                            0);
                                        printer.printCustom(
                                            "Customer email: ${widget.customerPhonenumber}",
                                            1,
                                            0);
                                        printer.printCustom(
                                            "Nombor Order: ${widget.receiptId}",
                                            1,
                                            0);
                                        printer.printCustom(
                                            "Nombor Buzzer: ${widget.buzzerNumber}",
                                            4,
                                            1);
                                        printer.printNewLine();
                                        printer.printNewLine();
                                        printer.print3Column(
                                            "Menu", "QTY", "Harga", 2,
                                            format: "%1s %13s %1s %n");
                                        for (int i = 0;
                                            i < widget.order.length;
                                            i++) {
                                          printer.print3Column(
                                              ' ${i + 1})${data[i.toString()]['name'].toString()}',
                                              data[i.toString()]['quantity']
                                                  .toString(),
                                              data[i.toString()]['totalPrice']
                                                  .toString(),
                                              1,
                                              format: "%-40s %40s %5s %n");
                                          List<dynamic> leceipt =
                                              data[i.toString()]['toppingName'];
                                          for (int t = 0;
                                              t < leceipt.length;
                                              t++) {
                                            printer.printCustom(
                                                '~' +
                                                    data[i.toString()]
                                                            ['toppingName'][t]
                                                        .toString(),
                                                1,
                                                0);
                                          }
                                          printer.printNewLine();
                                          if (data[i.toString()]['isDrink']) {
                                            printer.printCustom(
                                                'Note Sugar Level: ' +
                                                    data[i.toString()]
                                                            ['sugarLevel']
                                                        .toString(),
                                                1,
                                                0);
                                            printer.printCustom(
                                                'Note Ice Level: ' +
                                                    data[i.toString()]
                                                            ['iceLevel']
                                                        .toString(),
                                                1,
                                                0);
                                          } else {
                                            printer.printCustom(
                                                'Note Spicy Level: ' +
                                                    data[i.toString()]
                                                            ['spicyLevel']
                                                        .toString(),
                                                1,
                                                0);
                                          }

                                          printer.printNewLine();
                                        }

                                        printer.printCustom(
                                            'Total: RM${widget.totalPrice} ',
                                            4,
                                            1);
                                        printer.printNewLine();
                                        printer.printNewLine();
                                        printer.printNewLine();
                                        printer.printCustom(
                                            'Kalau Sedap Bagitahu Kawan, Kalau Tidak Sedap\n Bagitahu Kami ',
                                            1,
                                            1);
                                        printer.printCustom(
                                            'Cendol BMI Pekan Nilai\n Sejak 1985',
                                            1,
                                            1);
                                        printer.printCustom('0172986265', 1, 1);
                                        printer.printCustom(
                                            ' NO 3 GERAI MAJLIS DAERAH NILAI JALAN BESAR NILAI, Pekan Nilai, 71800 Nilai, Negeri Sembilan',
                                            0,
                                            1);
                                        printer.printCustom(
                                            'Buka Setiap Hari Dari Pukul 10pagi - 6petang\nkecuali Hari Rabu',
                                            0,
                                            1);
                                        printer.paperCut();
                                      } else {
                                        Get.snackbar(
                                            'Please Connect To Printer First',
                                            'Go To Setting',
                                            colorText: Colors.white);
                                      }
                                      print(printer.isConnected);
                                      // printer.printImage('receipt.png');
                                    },
                                    icon: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )),
                                Text(
                                  'Buzzer ${widget.buzzerNumber}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25.0,
                                      color: Colors.white),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      if (await printer.isConnected == true) {
                                        testPrint.bill(widget.order);
                                        // for (int i = 0;
                                        //     i < widget.order.length;
                                        //     i++) {
                                        //   if (data[i.toString()]['isDrink']) {
                                        //     printer.printCustom(
                                        //         'Minuman', 3, 1);
                                        //     printer.printCustom(
                                        //         '${data[i.toString()]['quantity'].toString()}x ${data[i.toString()]['name'].toString()}',
                                        //         4,
                                        //         0);
                                        //     List<dynamic> leceipt =
                                        //         data[i.toString()]
                                        //             ['toppingName'];
                                        //     for (int t = 0;
                                        //         t < leceipt.length;
                                        //         t++) {
                                        //       printer.printCustom(
                                        //           '-' +
                                        //               data[i.toString()]
                                        //                       ['toppingName'][t]
                                        //                   .toString(),
                                        //           2,
                                        //           0);
                                        //     }
                                        //   } else {}
                                        // }

                                      } else {}
                                    },
                                    icon: const Icon(
                                      Icons.print,
                                      color: Colors.white,
                                    ))
                              ],
                            ),
                          ),
                          Text('Masa Order = ${widget.receiptTime}'),
                          Text('Email Customer =  ${widget.customerEmail}'),
                          //Text('Masa : ${minutes}:${seconds}'),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [Text('Order'), Text('Kuantiti')],
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: screenSize.width * 0.98,
                                height: screenSize.height * 0.6,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: widget.order.length,
                                    itemBuilder: (context, index) {
                                      List<dynamic> l =
                                          data[index.toString()]['toppingName'];
                                      print('index' +
                                          index.toString() +
                                          '------' +
                                          l.toString());
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              SizedBox(
                                                width: screenSize.width / 5,
                                                child: AutoSizeText(
                                                  '${index + 1}~' +
                                                      data[index.toString()]
                                                          ['name'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.0,
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              data[index.toString()]['isDrink']
                                                  ? SizedBox(
                                                      width:
                                                          screenSize.width / 5,
                                                      child: AutoSizeText(
                                                        'Sugar Level~' +
                                                            data[index
                                                                    .toString()]
                                                                ['sugarLevel'],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20.0,
                                                        ),
                                                        maxLines: 3,
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      width:
                                                          screenSize.width / 5,
                                                      child: AutoSizeText(
                                                        '${index + 1}~' +
                                                            data[index
                                                                    .toString()]
                                                                ['name'],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20.0,
                                                        ),
                                                        maxLines: 3,
                                                      ),
                                                    ),
                                              SizedBox(
                                                width: screenSize.width / 5,
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount: l.length,
                                                    itemBuilder:
                                                        (context, indexx) {
                                                      return SizedBox(
                                                        width:
                                                            screenSize.width /
                                                                2,
                                                        child: Text(
                                                          data[index.toString()]
                                                                      [
                                                                      'toppingName']
                                                                  [indexx]
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: const TextStyle(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      );
                                                    }),
                                              )
                                            ],
                                          ),
                                          Text(
                                            data[index.toString()]['quantity']
                                                .toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 26.0,
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                              )
                            ],
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              // printer.printCustom('message', 1, 1);

                              setState(() {
                                _firestore
                                    .collection('newOrder')
                                    .doc(widget.receiptUniqueId)
                                    .update({'isDone': true});
                                _firestore
                                    .collection('BuzzerNumber')
                                    .doc(widget.buzzerNumber.toString())
                                    .update({'inUse': true});
                              });
                            },
                            child: Container(
                              width: screenSize.width / 4,
                              decoration: BoxDecoration(
                                  color: Colors.teal,
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2.0,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 2.0,
                                        offset: Offset(2.0, 2.0))
                                  ]),
                              child: const Center(
                                child: Text(
                                  'Siap',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30.0,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'email : ' + widget.customerEmail,
                            style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black),
                          ),
                          Text(
                            'name : ' + widget.customerName,
                            style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black),
                          ),
                          Text(
                            'Phone Number : ' + widget.customerPhonenumber,
                            style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black),
                          ),
                          const Text(
                            'Status : Belum Bayar',
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black),
                          ),
                          Text(
                            'Jumlah perlu dibayar: RM ' +
                                widget.totalPrice.toString(),
                            style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Center(
                            child: Text(
                              'No Order: ${widget.receiptId}',
                              style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 50,
                                  color: Colors.black),
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Center(
                            child: InkWell(
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(17),
                                  color: Colors.teal,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.teal.withOpacity(0.6),
                                      spreadRadius: 2,
                                      blurRadius: 2,
                                      offset: const Offset(
                                          0, 5), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Bayar: RM' + widget.totalPrice.toString(),
                                  style: const TextStyle(fontSize: 30),
                                ),
                              ),
                              onTap: () {
                                Get.defaultDialog(
                                  title: widget.customerName,
                                  content: SingleChildScrollView(
                                    child: StatefulBuilder(
                                        builder: (context, setStateSB) {
                                      return SizedBox(
                                        height: screenSize.height * 0.6,
                                        width: screenSize.width * 0.8,
                                        child: Column(
                                          children: [
                                            StreamBuilder<
                                                    QuerySnapshot<
                                                        Map<String, dynamic>>>(
                                                stream: _firestore
                                                    .collection('BuzzerNumber')
                                                    .orderBy('number',
                                                        descending: false)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return const Center(
                                                        child: SizedBox());
                                                  }
                                                  final docs =
                                                      snapshot.data!.docs;
                                                  return SizedBox(
                                                    height: 100,
                                                    child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount: docs.length,
                                                        itemBuilder: (_, i) {
                                                          final data =
                                                              docs[i].data();
                                                          return data['inUse'] ==
                                                                  false
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          40),
                                                                  child:
                                                                      Container(
                                                                    width: 100,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border: Border.all(
                                                                          width:
                                                                              3.0,
                                                                          color:
                                                                              Colors.black),
                                                                      borderRadius: const BorderRadius
                                                                              .all(
                                                                          Radius.circular(
                                                                              5.0) //                 <--- border radius here
                                                                          ),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          ListTile(
                                                                        tileColor:
                                                                            Colors.grey,
                                                                        selectedColor:
                                                                            Colors.white,
                                                                        selectedTileColor:
                                                                            Colors.teal,
                                                                        selected:
                                                                            i ==
                                                                                _selectedIndex,
                                                                        title: Text(
                                                                            data['number']
                                                                                .toString(),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                                                                        onTap:
                                                                            () {
                                                                          buzzerNumber =
                                                                              data['number'];

                                                                          setStateSB(
                                                                              () {
                                                                            _selectedIndex =
                                                                                i;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : const SizedBox();
                                                        }),
                                                  );
                                                }),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              screenSize.width /
                                                                  4,
                                                          child: const Text(
                                                            'Menu',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        const Text(
                                                          'Quantity',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Roboto',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        const Spacer(),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 8.0),
                                                          child: Text(
                                                            'RM',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: screenSize.width *
                                                          0.95,
                                                      height: 300,
                                                      child:
                                                          SingleChildScrollView(
                                                        child: ListView.builder(
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            itemCount: widget
                                                                .order.length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              Map<String,
                                                                      dynamic>
                                                                  data = <
                                                                      String,
                                                                      dynamic>{};

                                                              for (dynamic type
                                                                  in widget
                                                                      .order
                                                                      .keys) {
                                                                data[type
                                                                        .toString()] =
                                                                    widget.order[
                                                                        type];
                                                              }

                                                              List<dynamic> l =
                                                                  data[index
                                                                          .toString()]
                                                                      [
                                                                      'toppingName'];
                                                              print('index' +
                                                                  index
                                                                      .toString() +
                                                                  '------' +
                                                                  l.toString());
                                                              return Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Column(
                                                                    children: [
                                                                      SizedBox(
                                                                          width: screenSize.width /
                                                                              4,
                                                                          child:
                                                                              Text(
                                                                            '${index + 1}~' +
                                                                                data[index.toString()]['name'],
                                                                            style:
                                                                                const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          )),
                                                                      SizedBox(
                                                                        width:
                                                                            screenSize.width /
                                                                                4,
                                                                        child: ListView.builder(
                                                                            physics: const NeverScrollableScrollPhysics(),
                                                                            shrinkWrap: true,
                                                                            itemCount: l.length,
                                                                            itemBuilder: (context, indexx) {
                                                                              return SizedBox(
                                                                                width: screenSize.width / 2,
                                                                                child: Text(
                                                                                  data[index.toString()]['toppingName'][indexx].toString() + '(${data[index.toString()]['toppingPrice'][indexx].toString()})',
                                                                                  textAlign: TextAlign.start,
                                                                                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14, color: Colors.black),
                                                                                ),
                                                                              );
                                                                            }),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  const Spacer(),
                                                                  Text(
                                                                    data[index.toString()]
                                                                            [
                                                                            'quantity']
                                                                        .toString(),
                                                                  ),
                                                                  const Spacer(),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            8.0),
                                                                    child: Text(
                                                                      data[index.toString()]
                                                                              [
                                                                              'totalPrice']
                                                                          .toString(),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            }),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                                Expanded(
                                                    child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                          child: Text(
                                                            'Jumlah RM ${widget.totalPrice}',
                                                            style: const TextStyle(
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Text(
                                                            'Baki RM $balanceCashOut',
                                                            style: const TextStyle(
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    ListTile(
                                                      title: const Text('Cash'),
                                                      trailing:
                                                          Radio<paymentMethod>(
                                                        fillColor:
                                                            MaterialStateColor
                                                                .resolveWith(
                                                                    (states) =>
                                                                        Colors
                                                                            .teal),
                                                        activeColor:
                                                            Colors.black,
                                                        value:
                                                            paymentMethod.Cash,
                                                        groupValue: _type,
                                                        onChanged:
                                                            (paymentMethod?
                                                                value) {
                                                          setStateSB(() {
                                                            _type = value;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    _type == paymentMethod.Cash
                                                        ? TextFormField(
                                                            controller:
                                                                cashController,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Cash RM',
                                                              suffixIcon:
                                                                  Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(),
                                                                child: Icon(
                                                                    Icons
                                                                        .attach_money,
                                                                    color: Colors
                                                                        .teal),
                                                              ),
                                                            ),
                                                            onChanged: (text) {
                                                              setStateSB(() {
                                                                balanceCashOut =
                                                                    double.parse(cashController
                                                                            .text) -
                                                                        widget
                                                                            .totalPrice;
                                                              });
                                                            },
                                                            validator: (text) {
                                                              if (text ==
                                                                      null ||
                                                                  text.isEmpty) {
                                                                return 'Enter Cash In';
                                                              } else {}
                                                              return null;
                                                            },
                                                          )
                                                        : const SizedBox(),
                                                    ListTile(
                                                      title: const Text(
                                                          'E-Wallet'),
                                                      trailing:
                                                          Radio<paymentMethod>(
                                                        fillColor:
                                                            MaterialStateColor
                                                                .resolveWith(
                                                                    (states) =>
                                                                        Colors
                                                                            .teal),
                                                        activeColor:
                                                            Colors.black,
                                                        value: paymentMethod
                                                            .Ewallet,
                                                        groupValue: _type,
                                                        onChanged:
                                                            (paymentMethod?
                                                                value) {
                                                          setStateSB(() {
                                                            _type = value;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    ListTile(
                                                      title: const Text('Card'),
                                                      trailing:
                                                          Radio<paymentMethod>(
                                                        fillColor:
                                                            MaterialStateColor
                                                                .resolveWith(
                                                                    (states) =>
                                                                        Colors
                                                                            .teal),
                                                        activeColor:
                                                            Colors.black,
                                                        value:
                                                            paymentMethod.Card,
                                                        groupValue: _type,
                                                        onChanged:
                                                            (paymentMethod?
                                                                value) {
                                                          setStateSB(() {
                                                            _type = value;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ))
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                  confirm: Center(
                                    child: !_loading
                                        ? InkWell(
                                            onTap: () async {
                                              if (buzzerNumber != 37 &&
                                                  _type != paymentMethod.none) {
                                                setState(() => _loading = true);
                                                await _firestore
                                                    .collection('BuzzerNumber')
                                                    .doc(
                                                        buzzerNumber.toString())
                                                    .update({'inUse': true});
                                                await _firestore
                                                    .collection('newOrder')
                                                    .doc(widget.receiptUniqueId)
                                                    .update({
                                                  'buzzerNumber': buzzerNumber
                                                });
                                                await _firestore
                                                    .collection('newOrder')
                                                    .doc(widget.receiptUniqueId)
                                                    .update({'isPaid': true});

                                                cashController.clear();
                                                Get.off(() => const Home());
                                              } else {
                                                Get.snackbar(
                                                    'Silih Pilih Nombor', '',
                                                    colorText: Colors.white);
                                              }
                                            },
                                            child: Container(
                                              width: 200,
                                              height: 50,
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(17),
                                                color: Colors.teal,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.teal
                                                        .withOpacity(0.6),
                                                    spreadRadius: 2,
                                                    blurRadius: 2,
                                                    offset: const Offset(0,
                                                        5), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              child: const Center(
                                                  child: Text(
                                                'Bayar',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 25),
                                              )),
                                            ),
                                          )
                                        : LoadingAnimationWidget.newtonCradle(
                                            color: Colors.black, size: 70),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Center(
                            child: LoadingAnimationWidget.beat(
                                color: Colors.teal, size: 95),
                          ),
                        ],
                      ),
              ),
              const SizedBox(
                width: 10,
              )
            ],
          )
        : const SizedBox();
  }
}
