import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi_kitchen/screens/history_screens.dart';
import 'package:easi_kitchen/screens/manage_screens.dart';
import 'package:easi_kitchen/screens/receipt_setting.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'home_screens.dart';

final _firestore = FirebaseFirestore.instance;

class UnpaidOrder extends StatefulWidget {
  const UnpaidOrder({Key? key}) : super(key: key);

  @override
  State<UnpaidOrder> createState() => _UnpaidOrderState();
}

class _UnpaidOrderState extends State<UnpaidOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Unpaid Orders'),
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
                  MaterialPageRoute(builder: (context) => ReceiptPage()),
                );
              },
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Unpaid Orders',
              textAlign: TextAlign.center,
            ),
            OrderStream(),
          ],
        ),
      ),
    );
  }
}

class OrderStream extends StatefulWidget {
  const OrderStream({
    Key? key,
  }) : super(key: key);

  @override
  State<OrderStream> createState() => _OrderStreamState();
}

class _OrderStreamState extends State<OrderStream> {
  ScrollController _scrollController = ScrollController(initialScrollOffset: 0);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('newOrder')
          .where('isDone', isEqualTo: false)
          .where('isPaid', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
              padding: EdgeInsets.only(top: 200, left: 520),
              child: LoadingAnimationWidget.newtonCradle(
                  color: Colors.teal, size: 300));
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
              padding: EdgeInsets.only(top: 200, left: 520),
              child: LoadingAnimationWidget.newtonCradle(
                  color: Colors.teal, size: 300));
        } else if (snapshot.connectionState == ConnectionState.none) {
          return Padding(
              padding: EdgeInsets.only(top: 200, left: 520),
              child: LoadingAnimationWidget.newtonCradle(
                  color: Colors.teal, size: 300));
        } else if (snapshot.data!.docChanges.isEmpty) {
          return Padding(
              padding: EdgeInsets.only(top: 200, left: 520),
              child: LoadingAnimationWidget.newtonCradle(
                  color: Colors.teal, size: 300));
        } else if (snapshot.hasError) {
          return Padding(
              padding: EdgeInsets.only(top: 200, left: 520),
              child: LoadingAnimationWidget.newtonCradle(
                  color: Colors.teal, size: 300));
        }
        final orderss = snapshot.data?.docs;
        // final order = snapshot.data?.docs;
        List<UnpaidTicketUi> ticketKitchen = [];
        if (orderss == null) {
          WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              }));
        }
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

          final token = ticket.toString().contains('fcmToken')
              ? ticket.get('fcmToken')
              : '';

          final messageBubble = UnpaidTicketUi(
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
            token: token == null ? '' : token,
          );

          ticketKitchen.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
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

class UnpaidTicketUi extends StatefulWidget {
  UnpaidTicketUi(
      {Key? key,
      required this.orderLength,
      required this.customerEmail,
      required this.customerName,
      required this.customerPhonenumber,
      required this.receiptTime,
      required this.receiptDate,
      required this.token,
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
  final String token;
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
  State<UnpaidTicketUi> createState() => _UnpaidTicketUiState();
}

class _UnpaidTicketUiState extends State<UnpaidTicketUi> {
  Duration duration = const Duration();
  Timer? timer;

  var cashController = TextEditingController();
  bool isSelectedMethodCash = true;
  bool isSelectedMethodEwallet = false;
  bool isSelectedMethodCard = false;
  String paymentMethod = '';

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
  int _selectedIndex = 37;
  num balanceCashOut = 0;
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: Colors.grey[200],
      ),
      width: screenSize.width * 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
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
            'Jumlah perlu dibayar: RM ' + widget.totalPrice.toString(),
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
                      offset: const Offset(0, 5), // changes position of shadow
                    ),
                  ],
                ),
                child: Text(
                  'Bayar: RM' + widget.totalPrice.toString(),
                  style: const TextStyle(fontSize: 30),
                ),
              ),
              onTap: () {
                showCustomDialog(context, screenSize);
              },
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Center(
            child: LoadingAnimationWidget.beat(color: Colors.teal, size: 95),
          ),
          const SizedBox(
            height: 150,
          ),
          InkWell(
            onTap: () async {
              await _firestore
                  .collection('newOrder')
                  .doc(widget.receiptUniqueId)
                  .delete();
            },
            child: Center(
                child: Text(
              'Cancel Order',
              style: TextStyle(color: Colors.red),
            )),
          )
        ],
      ),
    );
  }

  void showCustomDialog(BuildContext context, Size screenSize) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) {
        return Dialog(
          child: SingleChildScrollView(
            child: StatefulBuilder(builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: screenSize.height * 0.8,
                  width: screenSize.width * 0.95,
                  child: Column(
                    children: [
                      Text(
                        'Buzzer Number',
                        textAlign: TextAlign.center,
                      ),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _firestore
                              .collection('BuzzerNumber')
                              .orderBy('number', descending: false)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: SizedBox());
                            }
                            final docs = snapshot.data!.docs;
                            return SizedBox(
                              height: 100,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: docs.length,
                                  itemBuilder: (_, i) {
                                    final data = docs[i].data();
                                    return data['inUse'] == false
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                right: 40),
                                            child: Container(
                                              width: 100,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 3.0,
                                                    color: Colors.black),
                                                borderRadius: const BorderRadius
                                                        .all(
                                                    Radius.circular(
                                                        5.0) //                 <--- border radius here
                                                    ),
                                              ),
                                              child: Center(
                                                child: ListTile(
                                                  tileColor: Colors.grey,
                                                  selectedColor: Colors.white,
                                                  selectedTileColor:
                                                      Colors.teal,
                                                  selected: i == _selectedIndex,
                                                  title: Text(
                                                      data['number'].toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          fontSize: 35,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  onTap: () {
                                                    buzzerNumber =
                                                        data['number'];

                                                    setState(() {
                                                      _selectedIndex = i;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          )
                                        : SizedBox();
                                  }),
                            );
                          }),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                            height: 430,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: AssetImage(
                                      "images/decoimgfluttertest.png")),
                              borderRadius: BorderRadius.circular(17),
                              color: Colors.grey[200],
                            ),
                            child: Column(
                              children: [
                                Text('RECEIPT FOR ' + widget.customerName),
                                Text('Makanan: ' +
                                    widget.totalFoods.toString() +
                                    '\tMinuman: ' +
                                    widget.totalDrinks.toString()),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: screenSize.width / 4,
                                      child: const Text(
                                        'Menu',
                                        style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.black),
                                      ),
                                    ),
                                    const Spacer(),
                                    const Text(
                                      'Quantity',
                                      style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black),
                                    ),
                                    const Spacer(),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Text(
                                        'RM',
                                        style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: screenSize.width * 0.95,
                                  height: 290,
                                  child: SingleChildScrollView(
                                    child: ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: widget.order.length,
                                        itemBuilder: (context, index) {
                                          Map<String, dynamic> data =
                                              <String, dynamic>{};

                                          for (dynamic type
                                              in widget.order.keys) {
                                            data[type.toString()] =
                                                widget.order[type];
                                          }

                                          List<dynamic> l =
                                              data[index.toString()]
                                                  ['toppingName'];
                                          print('index' +
                                              index.toString() +
                                              '------' +
                                              l.toString());
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                children: [
                                                  SizedBox(
                                                      width:
                                                          screenSize.width / 4,
                                                      child: Text(
                                                        '${index + 1}~' +
                                                            data[index
                                                                    .toString()]
                                                                ['name'],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      )),
                                                  SizedBox(
                                                    width: screenSize.width / 4,
                                                    child: ListView.builder(
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount: l.length,
                                                        itemBuilder:
                                                            (context, indexx) {
                                                          return SizedBox(
                                                            width: screenSize
                                                                    .width /
                                                                2,
                                                            child: Text(
                                                              data[index.toString()]
                                                                              [
                                                                              'toppingName']
                                                                          [
                                                                          indexx]
                                                                      .toString() +
                                                                  '(${data[index.toString()]['toppingPrice'][indexx].toString()})',
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: const TextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          );
                                                        }),
                                                  )
                                                ],
                                              ),
                                              const Spacer(),
                                              Text(
                                                data[index.toString()]
                                                        ['quantity']
                                                    .toString(),
                                              ),
                                              const Spacer(),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: Text(
                                                  data[index.toString()]
                                                          ['totalPrice']
                                                      .toString(),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        'Total : RM' +
                                            widget.totalPrice.toString(),
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Baki RM $balanceCashOut',
                                        style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                          Expanded(
                              child: Column(
                            children: [
                              Container(
                                child: Text(
                                  'Payment Method',
                                  style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              isSelectedMethodCash
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                        left: 150,
                                        right: 150,
                                      ),
                                      child: TextFormField(
                                        controller: cashController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            borderSide: BorderSide(
                                              color: Colors.blue,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            borderSide: BorderSide(
                                              color: Colors.teal,
                                              width: 2.0,
                                            ),
                                          ),
                                          labelText: 'RM',
                                          suffixIcon: Padding(
                                            padding: EdgeInsets.only(),
                                            child: Icon(Icons.attach_money,
                                                color: Colors.teal),
                                          ),
                                        ),
                                        onChanged: (text) {
                                          setState(() {
                                            balanceCashOut = double.parse(
                                                    cashController.text) -
                                                widget.totalPrice;
                                          });
                                        },
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return 'Enter Cash In';
                                          } else {}
                                          return null;
                                        },
                                      ),
                                    )
                                  : SizedBox(),
                              SizedBox(
                                height: 40,
                              ),
                              InkWell(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  width: 450,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: isSelectedMethodCash
                                          ? Colors.teal
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey[50]!
                                              .withOpacity(0.60))),
                                  child: Text(
                                    'Cash',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: isSelectedMethodCash
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    isSelectedMethodCash = true;
                                    isSelectedMethodCard = false;
                                    isSelectedMethodEwallet = false;
                                    if (isSelectedMethodCash == true) {
                                      paymentMethod = 'Cash';
                                    }
                                  });
                                },
                              ),
                              InkWell(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  width: 450,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: isSelectedMethodCard
                                          ? Colors.teal
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey[50]!
                                              .withOpacity(0.60))),
                                  child: Text(
                                    'Card',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: isSelectedMethodCard
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    isSelectedMethodCard = true;
                                    isSelectedMethodCash = false;
                                    isSelectedMethodEwallet = false;
                                    if (isSelectedMethodCard == true) {
                                      paymentMethod = 'Card';
                                    }
                                  });
                                },
                              ),
                              InkWell(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  width: 450,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: isSelectedMethodEwallet
                                          ? Colors.teal
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey[50]!
                                              .withOpacity(0.60))),
                                  child: Center(
                                    child: Text(
                                      'E-Wallet',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 25,
                                          color: isSelectedMethodEwallet
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    isSelectedMethodEwallet = true;
                                    isSelectedMethodCash = false;
                                    isSelectedMethodCard = false;
                                    if (isSelectedMethodEwallet == true) {
                                      paymentMethod = 'E-Wallet';
                                    }
                                  });
                                },
                              ),
                            ],
                          ))
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () async {
                          Navigator.of(context, rootNavigator: true).pop();
                          if (balanceCashOut != 0) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                        'Balance RM${balanceCashOut.toString()}'),
                                  );
                                });
                          }

                          if (buzzerNumber != 37) {
                            await _firestore
                                .collection('BuzzerNumber')
                                .doc(buzzerNumber.toString())
                                .update({'inUse': true});
                            await Future.delayed(Duration(seconds: 1));
                            await _firestore
                                .collection('newOrder')
                                .doc(widget.receiptUniqueId)
                                .update({
                              'buzzerNumber': buzzerNumber,
                              'cashIn': cashController.text,
                              'paymentMethod': paymentMethod,
                              'cashOutBalance': balanceCashOut,
                              'isPaid': true
                            });

                            cashController.clear();
                          }
                          //print('object');

                          // await _firestore
                          //     .collection('newOrder')
                          //     .doc(widget.receiptUniqueId)
                          //     .update({'isPaid': true});

                          //                             WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() {
                          //  Navigator.of(context, rootNavigator: true).pop();
                          //         }));
                        },
                        child: Container(
                          width: 200,
                          height: 50,
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
                          child: !_loading
                              ? Center(
                                  child: Text(
                                  'Bayar',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 25),
                                ))
                              : LoadingAnimationWidget.flickr(
                                  leftDotColor: Colors.white,
                                  rightDotColor: Colors.teal.shade100,
                                  size: 25),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: Offset(1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }
}
