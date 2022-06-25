import 'package:easi_kitchen/screens/home_screens.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'provider/printer_provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PrinterProvider(),
      child: GetMaterialApp(
        theme: ThemeData(
            textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        )),
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        initialRoute: '/',
        home: Home(),
      ),
    );
  }
}
