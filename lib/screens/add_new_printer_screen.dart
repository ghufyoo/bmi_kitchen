import 'dart:io';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Add_New_Printer extends StatefulWidget {
  const Add_New_Printer({Key? key}) : super(key: key);

  @override
  State<Add_New_Printer> createState() => _Add_New_PrinterState();
}

class _Add_New_PrinterState extends State<Add_New_Printer> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String?> _future;

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    getDevices();
    initSavetoPath();
  }

  initSavetoPath() async {
    //read and write
    //image max 300px X 300px
    const filename = 'receipt-logo.png';
    var bytes = await rootBundle.load("images/receipt-logo.png");
    String dir = (await getExternalStorageDirectory())!.path;
    writeToFile(bytes, '$dir/$filename');
    setState(() {
      pathImage = filename;
    });
  }

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      // TODO - Error
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            print("bluetooth device state: error");
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      devices = devices;
    });

    if (isConnected!) {
      setState(() {
        _connected = true;
      });
    }
  }

  String pathImage = '';
  void getDevices() async {
    devices = await bluetooth.getBondedDevices();
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'Device:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                Expanded(
                  child: DropdownButton<BluetoothDevice>(
                      value: selectedDevice,
                      onChanged: (device) {
                        setState(() {
                          selectedDevice = device!;
                        });
                      },
                      items: devices
                          .map((e) => DropdownMenuItem(
                                child: Text(e.name!),
                                value: e,
                              ))
                          .toList()),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.brown),
                  onPressed: () {
                    initPlatformState();
                  },
                  child: const Text(
                    'Refresh',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: _connected ? Colors.red : Colors.green),
                  onPressed: _connected ? _disconnect : _connect,
                  child: Text(
                    _connected ? 'Disconnect' : 'Connect',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.brown),
                onPressed: () {
                  bluetooth.printImage(pathImage);
                  bluetooth.paperCut();
                },
                child: const Text('PRINT TEST',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );

    // List<BluetoothDevice> devices = [];
    // BluetoothDevice? selectedDevice;
    // BlueThermalPrinter printer = BlueThermalPrinter.instance;
    // String _devicesMsg = "";
    // final f = NumberFormat("\$###,###.00", "en_US");

    // @override
    // void initState() {
    //   super.initState();
    //   getDevices();
    // }

    // void getDevices() async {
    //   devices = await printer.getBondedDevices();
    //   setState(() {});
    // }

    // @override
    // Widget build(BuildContext context) {
    //   return MaterialApp(
    //     home: Scaffold(
    //       appBar: AppBar(
    //         backgroundColor: Colors.black,
    //         title: Text('Receipt Setting'),
    //       ),
    //       drawer: Drawer(
    //         backgroundColor: Colors.teal,
    //         child: ListView(
    //           padding: EdgeInsets.zero,
    //           children: [
    //             DrawerHeader(
    //               decoration: BoxDecoration(
    //                   image: DecorationImage(
    //                       image: AssetImage(
    //                         'images/drawer.png',
    //                       ),
    //                       fit: BoxFit.cover)),
    //               child: Text('Setting'),
    //             ),
    //             ListTile(
    //               title: Text('Home'),
    //               onTap: () {
    //                 Get.to(Home());
    //               },
    //             ),
    //             ListTile(
    //               title: Text('Menu Manager'),
    //               onTap: () {
    //                 Get.to(MenuManager());
    //               },
    //             ),
    //             ListTile(
    //               title: Text('Past Order'),
    //               onTap: () {
    //                 Get.to(HistoryScreen());
    //               },
    //             ),
    //             ListTile(
    //               title: Text('Receipt Setting'),
    //               onTap: () {
    //                 Navigator.pop(context);
    //               },
    //             )
    //           ],
    //         ),
    //       ),
    //       body: Center(
    //         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    //           DropdownButton<BluetoothDevice>(
    //               value: selectedDevice,
    //               onChanged: (device) {
    //                 setState(() {
    //                   selectedDevice = device;
    //                 });
    //               },
    //               items: devices
    //                   .map((e) => DropdownMenuItem(
    //                         child: Text(e.name!),
    //                         value: e,
    //                       ))
    //                   .toList()),
    //           const SizedBox(
    //             height: 10,
    //           ),
    //           ElevatedButton(
    //               onPressed: () {
    //                 printer.connect(selectedDevice!);
    //               },
    //               child: Text('connect')),
    //           ElevatedButton(
    //               onPressed: () {
    //                 printer.disconnect();
    //               },
    //               child: Text('disconnect')),
    //           ElevatedButton(
    //               onPressed: () async {
    //                 if ((await printer.isConnected)!) {
    //                   printer.write('yoo');
    //                   printer.printCustom('message', 1, 2);
    //                   printer.printNewLine();
    //                   printer.printNewLine();
    //                 }
    //               },
    //               child: Text('print')),
    //         ]),
    //       ),
    //     ),
    //   );
    // }
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (devices.isEmpty) {
      items.add(const DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      for (var device in devices) {
        items.add(DropdownMenuItem(
          child: Text(device.name.toString()),
          value: device,
        ));
      }
    }
    return items;
  }

  void _connect() {
    if (selectedDevice == null) {
      show('No device selected.');
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected!) {
          bluetooth.connect(selectedDevice!).catchError((error) {
            setState(() => _connected = false);
          });
          setState(() => _connected = true);
        }
      });
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _connected = false);
  }

//write to app path

  Future show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }
}
