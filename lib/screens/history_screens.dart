import 'package:easi_kitchen/screens/receipt_setting.dart';
import 'package:easi_kitchen/screens/unpaid_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:easi_kitchen/screens/manage_screens.dart';
import 'package:easi_kitchen/screens/receipt_screens.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'home_screens.dart';

final _firestore = FirebaseFirestore.instance;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Past Order For Today'),
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
                Get.to(const MenuManager());
              },
            ),
            ListTile(
              title: const Text('Past Order'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Receipt Setting'),
              onTap: () {
                Get.to(const ReceiptPage());
              },
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: const [
            PastOrderStream(),
          ],
        ),
      ),
    );
  }
}

class PastOrderStream extends StatelessWidget {
  const PastOrderStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String datetime = DateFormat.yMd().format(DateTime.now());
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('newOrder')
          .where('currentDate', isEqualTo: datetime)
          .where('isDone', isEqualTo: true)
          .snapshots(),
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
        List<PastTicketUI> ticketKitchen = [];
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

          final messageBubble = PastTicketUI(
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

class PastTicketUI extends StatefulWidget {
  PastTicketUI(
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
  _PastTicketUIState createState() => _PastTicketUIState();
}

class _PastTicketUIState extends State<PastTicketUI> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: screenSize.width / 3.5,
            height: screenSize.height * 0.8,
            padding: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              color: Colors.grey[200],
            ),
            child: Column(
              children: [
                Center(
                  child: Text(
                    'Order No: ${widget.receiptId}',
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ),
                Center(
                  child: Text(
                    'Buzzer Number: ${widget.buzzerNumber}',
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.black),
                  ),
                ),
                Center(
                  child: Text(
                    'Dipesan pada Pukul ${widget.receiptTime} Pada Hari Ini',
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: screenSize.width / 5,
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
                Column(
                  children: [
                    SizedBox(
                      width: screenSize.width / 3.2,
                      height: screenSize.height * 0.4,
                      child: ListView.builder(
                          itemCount: widget.order.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> data = <String, dynamic>{};

                            for (dynamic type in widget.order.keys) {
                              data[type.toString()] = widget.order[type];
                            }

                            List<dynamic> l =
                                data[index.toString()]['toppingName'];
                           
                            return Row(
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                        width: screenSize.width / 6,
                                        child: Text(
                                          '${index + 1}~' +
                                              data[index.toString()]['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                    SizedBox(
                                      width: screenSize.width / 6,
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: l.length,
                                          itemBuilder: (context, indexx) {
                                            return SizedBox(
                                              width: screenSize.width / 2,
                                              child: Text(
                                                data[index.toString()]
                                                                ['toppingName']
                                                            [indexx]
                                                        .toString() +
                                                    '(${data[index.toString()]['toppingPrice'][indexx].toString()})',
                                                textAlign: TextAlign.start,
                                                style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 14,
                                                    color: Colors.black),
                                              ),
                                            );
                                          }),
                                    )
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  data[index.toString()]['quantity'].toString(),
                                ),
                                const Spacer(),
                                Text(
                                  data[index.toString()]['totalPrice']
                                      .toString(),
                                ),
                              ],
                            );
                          }),
                    ),
                    Container(
                      height: 2,
                      width: screenSize.width * 0.95,
                      color: Colors.black,
                    ),
                    Center(
                      child: Text(
                        'Jumlah RM${widget.totalPrice}',
                        style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            // printer.printCustom('message', 1, 1);

            setState(() {
              _firestore
                  .collection('newOrder')
                  .doc(widget.receiptUniqueId)
                  .update({'isDone': false});
              _firestore
                  .collection('BuzzerNumber')
                  .doc(widget.buzzerNumber.toString())
                  .update({'inUse': true});
            });
          },
          child: Container(
            width: screenSize.width / 4,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                color: Colors.teal,
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey,
                      blurRadius: 2.0,
                      offset: Offset(2.0, 2.0))
                ]),
            child: const Center(
              child: Text(
                'Belum Siap!',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                    color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }
}
