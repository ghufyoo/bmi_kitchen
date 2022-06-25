import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

import 'package:easi_kitchen/screens/history_screens.dart';
import 'package:easi_kitchen/screens/manage_screens.dart';
import 'package:easi_kitchen/screens/receipt_setting.dart';
import 'package:easi_kitchen/screens/unpaid_order_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

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

  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
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
  void initState() {
    // TODO: implement initState
    loadFCM();
    listenFCM();
    getToken();
    super.initState();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((value) => print(value));
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,

              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        // description
        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  bool open = true;

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
                  open = data['isOpen'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 40, left: 10),
                    child: SizedBox(
                      height: 20,
                      width: 31,
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
                  MaterialPageRoute(builder: (context) => ReceiptPage()),
                );
              },
            )
          ],
        ),
      ),
      body: open
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: const [
                  OrderStream(),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: Column(
                children: const [
                  Icon(
                    Icons.close,
                    size: 300,
                  ),
                  Text('Kedai Tutup',
                      style: TextStyle(
                        fontSize: 150,
                      )),
                ],
              )),
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
  ScrollController _scrollController = ScrollController();
  String nameCollection = 'newOrder';
  final StreamController _myStreamCtrl = StreamController.broadcast();
  void updateMyUI() => _myStreamCtrl.onListen;
  @override
  void initState() {
    // TODO: implement initState

    // _scrollController.addListener(() async {
    //   if (_scrollController.position.pixels ==
    //       _scrollController.position.maxScrollExtent) {
    //     setState(() async {
    //       nameCollection = '';
    //       await Future.delayed(Duration(microseconds: 200));
    //       nameCollection = 'newOrder';
    //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //           content: Text(
    //         'Page Refreshed',
    //         style: TextStyle(fontSize: 25),
    //       )));
    //     });
    //   }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection(nameCollection)
          .where('isDone', isEqualTo: false)
          .where('isPaid', isEqualTo: true)
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

          final token = ticket.toString().contains('fcmToken')
              ? ticket.get('fcmToken')
              : '';

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
            token: token == null ? '' : token,
          );

          ticketKitchen.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            physics: BouncingScrollPhysics(),
            controller: _scrollController,
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
  State<TicketUI> createState() => _TicketUIState();
}

List<String> Bungkus = [];
List<String> MakanSini = [];
List<String> top = [];

class _TicketUIState extends State<TicketUI> {
  Duration duration = const Duration();
  Timer? timer;
  BlueThermalPrinter printer = BlueThermalPrinter.instance;
  var cashController = TextEditingController();
  bool isSelectedMethodCash = true;
  bool isSelectedMethodEwallet = false;
  bool isSelectedMethodCard = false;
  String paymentMethod = '';
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

  num balanceCashOut = 0;
  void sendPushMessage() async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAARpizqLE:APA91bFiqxJ2A3pyQdFEzrVA8LFA3m1mUoFpTMdckdIuoWw7vfa1-4xzs_qiA2o6XR6FExwqObQHc707IhD5-ppqAfJ8cFoVyDu42MebtixhAVLSA13-FI1n41MuoStn6wSV4QAQPw1B'
        },
        body: json.encode({
          'to': widget.token,
          'message': {
            'token': widget.token,
          },
          "notification": {
            "title": "Order Ready For ${widget.customerName}",
            "body": "Sila Ambil Makanan Anda Di Kaunter",
            "icon": "icons/icon-192.png",
            // "badge":
            //     "icons/badge.png" // Your App icon, up to 512x512px, any color
          }
        }),
      );
      //  print('FCM request for device sent! ${widget.token}');
    } catch (e) {
      print(e);
    }
  }

  TestPrint testPrint = TestPrint();
  ScrollController _scrollController = ScrollController(initialScrollOffset: 0);
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
    return Row(
      children: [
        Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              color: Colors.grey[200],
            ),
            width: screenSize.width * 0.3,
            child: Column(
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
                            if (await printer.isConnected == true) {
                              ByteData datas = await rootBundle
                                  .load("images/receipt-logo1.png");
                              List<int> imageBytes = datas.buffer.asUint8List(
                                  datas.offsetInBytes, datas.lengthInBytes);
                              String base64Image = base64Encode(imageBytes);
                              // list.add(LineText(
                              //     type: LineText.TYPE_IMAGE,
                              //     content: base64Image,
                              //     align: LineText.ALIGN_CENTER,
                              //     linefeed: 1));
                              printer.printImageBytes(datas.buffer.asUint8List(
                                  datas.offsetInBytes, datas.lengthInBytes));
                              printer.printNewLine();
                              // printer.printImageBytes(
                              //     bytes.buffer.asUint8List());
                              printer.printCustom(
                                  "Receipt For ${widget.customerName}", 3, 1);
                              printer.printNewLine();
                              printer.printNewLine();
                              printer.printCustom(
                                  'Total Foods: ${widget.totalFoods} ', 2, 1);
                              printer.printCustom(' ', 1, 1);
                              printer.printCustom(
                                  "Total Drinks: ${widget.totalDrinks}", 2, 1);
                              printer.printCustom(
                                  "Customer email: ${widget.customerEmail}",
                                  1,
                                  0);
                              printer.printCustom(
                                  "Customer email: ${widget.customerPhonenumber}",
                                  1,
                                  0);
                              printer.printCustom(
                                  "Nombor Order: ${widget.receiptId}", 1, 0);
                              printer.printCustom(
                                  '########################', 2, 0);
                              printer.printCustom(
                                  'BUZZER : ${buzzerNumber.toString()}', 4, 1);
                              printer.printCustom(
                                  '########################', 2, 0);
                              printer.printNewLine();
                              printer.printNewLine();
                              printer.print3Column("Menu", "QTY", "Harga", 2,
                                  format: "%1s %13s %1s %n");
                              for (int i = 0; i < widget.order.length; i++) {
                                printer.print3Column(
                                    ' ${i + 1})${data[i.toString()]['name'].toString()}',
                                    data[i.toString()]['quantity'].toString(),
                                    data[i.toString()]['totalPrice'].toString(),
                                    1,
                                    format: "%-40s %40s %5s %n");
                                List<dynamic> leceipt =
                                    data[i.toString()]['toppingName'];
                                for (int t = 0; t < leceipt.length; t++) {
                                  printer.printCustom(
                                      '~' +
                                          data[i.toString()]['toppingName'][t]
                                              .toString(),
                                      1,
                                      0);
                                }
                                printer.printNewLine();
                                if (data[i.toString()]['isDrink']) {
                                  printer.printCustom(
                                      'Note Sugar Level: ' +
                                          data[i.toString()]['sugarLevel']
                                              .toString(),
                                      1,
                                      0);
                                  printer.printCustom(
                                      'Note Ice Level: ' +
                                          data[i.toString()]['iceLevel']
                                              .toString(),
                                      1,
                                      0);
                                } else {
                                  printer.printCustom(
                                      'Note Spicy Level: ' +
                                          data[i.toString()]['spicyLevel']
                                              .toString(),
                                      1,
                                      0);
                                }

                                printer.printNewLine();
                              }

                              printer.printCustom(
                                  'Total: RM${widget.totalPrice} ', 4, 1);
                              printer.printNewLine();
                              printer.printNewLine();
                              printer.printNewLine();
                              printer.printCustom(
                                  'Kalau Sedap Bagitahu Kawan, Kalau Tidak Sedap\n Bagitahu Kami ',
                                  1,
                                  1);
                              printer.printCustom(
                                  'Cendol BMI Pekan Nilai\n Sejak 1985', 1, 1);
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
                              Get.snackbar('Please Connect To Printer First',
                                  'Go To Setting',
                                  colorText: Colors.white);
                            }

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
                              testPrint.bill(
                                  widget.order,
                                  widget.totalFoods,
                                  widget.totalDrinks,
                                  widget.receiptId,
                                  widget.buzzerNumber,
                                  widget.receiptTime,
                                  widget.customerName);
                            } else {
                              Get.snackbar('Please Connect To Printer First',
                                  'Go To Setting',
                                  colorText: Colors.white);
                            }
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
                Text('No fon Customer = ${widget.customerPhonenumber}'),

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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    SizedBox(
                                      width: screenSize.width / 5,
                                      child: AutoSizeText(
                                        '${index + 1}~' +
                                            data[index.toString()]['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                        ),
                                        maxLines: 3,
                                      ),
                                    ),
                                    data[index.toString()]['isDrink']
                                        ? SizedBox(
                                            width: screenSize.width / 5,
                                            child: AutoSizeText(
                                              'Sugar Level~' +
                                                  data[index.toString()]
                                                      ['sugarLevel'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0,
                                              ),
                                              maxLines: 3,
                                            ),
                                          )
                                        : SizedBox(
                                            width: screenSize.width / 5,
                                            child: AutoSizeText(
                                              'Spicy Level~' +
                                                  data[index.toString()]
                                                      ['spicyLevel'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
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
                                          itemBuilder: (context, indexx) {
                                            return SizedBox(
                                              width: screenSize.width / 2,
                                              child: Text(
                                                data[index.toString()]
                                                        ['toppingName'][indexx]
                                                    .toString(),
                                                textAlign: TextAlign.start,
                                                style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            );
                                          }),
                                    )
                                  ],
                                ),
                                Text(
                                  data[index.toString()]['quantity'].toString(),
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
                      sendPushMessage();
                      _firestore
                          .collection('newOrder')
                          .doc(widget.receiptUniqueId)
                          .update({'isDone': true});
                      _firestore
                          .collection('BuzzerNumber')
                          .doc(widget.buzzerNumber.toString())
                          .update({'inUse': false});
                    });
                  },
                  child: Container(
                    width: screenSize.width * 0.3,
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
                        'Siap',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30.0,
                            color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            )),
        const SizedBox(
          width: 10,
        )
      ],
    );
  }
}
