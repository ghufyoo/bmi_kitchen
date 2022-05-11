import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easi_kitchen/screens/manage_screens.dart';
import 'package:easi_kitchen/screens/receipt_screens.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        title: Text('Past Order For Today'),
      ),
      drawer: Drawer(
        backgroundColor: Colors.teal,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                        'images/drawer.png',
                      ),
                      fit: BoxFit.cover)),
              child: Text('Setting'),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Get.to(Home());
              },
            ),
            ListTile(
              title: Text('Menu Manager'),
              onTap: () {
                Get.to(MenuManager());
              },
            ),
            ListTile(
              title: Text('Past Order'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Receipt Setting'),
              onTap: () {
                Get.to(ReceiptScreen());
              },
            )
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
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
    var today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('newOrder')
          .where('datetime', isGreaterThan: today)
          .where('isDone', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final orderss = snapshot.data?.docs;
        // final order = snapshot.data?.docs;
        List<PastTicketUI> ticketKitchen = [];
        for (var ticket in orderss!) {
          final customer = ticket.get('user_email');
          final datetime = ticket.get('datetime');
          final receiptID = ticket.get('receipt_id');
          final dishName = List.from(ticket.get('name'));
          final dishTopping = List.from(ticket.get('topping'));
          final dishPrice = List.from(ticket.get('price'));
          final dishQuantity = List.from(ticket.get('quantity'));
          final isDone = ticket.get('isDone');
          final isPaid = ticket.get('isPaid');
          final totalPrice = ticket.get('totalPrice');

          final messageBubble = PastTicketUI(
            lenght: orderss.length,
            orderID: receiptID,
            orderTime: datetime,
            customerEmail: customer,
            price: dishPrice,
            quantity: dishQuantity,
            dishName: dishName,
            dishTopping: dishTopping,
            isPaid: isPaid,
            isDone: isDone,
            totalPrice: totalPrice,
          );

          ticketKitchen.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
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
      required this.lenght,
      required this.orderID,
      required this.orderTime,
      required this.customerEmail,
      required this.price,
      required this.quantity,
      required this.dishName,
      required this.dishTopping,
      required this.isPaid,
      required this.isDone,
      required this.totalPrice})
      : super(key: key);
  final int lenght;
  final num orderID;
  final String orderTime;
  final String customerEmail;
  final List<dynamic> price;
  final List<dynamic> quantity;
  final List<dynamic> dishName;
  final List<dynamic> dishTopping;
  final num totalPrice;
  bool isPaid;
  bool isDone;

  @override
  _PastTicketUIState createState() => _PastTicketUIState();
}

class _PastTicketUIState extends State<PastTicketUI> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return widget.isDone
        ? Row(
            children: [
              Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                width: screenSize.width / 4,
                height: screenSize.height * 0.95,
                child: widget.isPaid
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: screenSize.width / 4,
                            decoration: BoxDecoration(
                                color: Colors.teal,
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 2.0,
                                      offset: Offset(2.0, 2.0))
                                ]),
                            child: Center(
                              child: Text(
                                '${widget.orderID}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30.0,
                                ),
                              ),
                            ),
                          ),
                          Text('Masa Order = ${widget.orderTime}'),
                          Text('Email Customer =  ${widget.customerEmail}'),
                          SizedBox(
                            width: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text('Order'), Text('Kuantiti')],
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: screenSize.width / 4,
                                height: screenSize.height * 0.5,
                                child: ListView.builder(
                                    itemCount: widget.dishName.length,
                                    itemBuilder: (context, index) {
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
                                                  widget.dishName[index],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.0,
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                              SizedBox(
                                                width: screenSize.width / 5,
                                                child: AutoSizeText(
                                                  widget.dishTopping[index],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15.0,
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'x${widget.quantity[index]}',
                                            style: TextStyle(
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
                          Spacer(),
                          InkWell(
                            onTap: () {
                              // printer.printCustom('message', 1, 1);

                              setState(() {
                                _firestore
                                    .collection('newOrder')
                                    .doc('${widget.orderID}')
                                    .update({'isDone': true});
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
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 2.0,
                                        offset: Offset(2.0, 2.0))
                                  ]),
                              child: Center(
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
                        children: [
                          Text(
                              'email: ${widget.customerEmail} \n id: ${widget.orderID} \n status: belum Bayar'),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  _firestore
                                      .collection('newOrder')
                                      .doc('${widget.orderID}')
                                      .update({'isPaid': true});
                                });
                              },
                              child: Text(
                                  'Jumlah perlu dibayar ${widget.totalPrice} '))
                        ],
                      ),
              ),
              SizedBox(
                width: 10,
              )
            ],
          )
        : SizedBox();
  }
}
