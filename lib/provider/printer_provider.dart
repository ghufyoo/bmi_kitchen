import 'package:easi_kitchen/model/printer_model.dart';
import 'package:flutter/cupertino.dart';

import '../api/firebase_api.dart';

class PrinterProvider extends ChangeNotifier {
  List<PrinterModel> _printer = [];
  List<PrinterModel> get printer =>
      _printer.where((device) => device.connected == true).toList();

  void addPrinter(PrinterModel printerModel) {
    _printer.add(printerModel);
    FirebaseApi.addDevice(printerModel);
    notifyListeners();
  }

  void setPrinter(List<PrinterModel>? printer) =>
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _printer = printer!;
        notifyListeners();
      });
}
