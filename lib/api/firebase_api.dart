import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi_kitchen/model/printer_model.dart';

import '../utils.dart';

class FirebaseApi {
  static Future<String> addDevice(PrinterModel printerModel) async {
    final docTodo = FirebaseFirestore.instance
        .collection('Devices')
        .doc(printerModel.address);

    printerModel.id = docTodo.id;
    try {
      await docTodo.set(printerModel.toJson());
    } catch (e) {
      print('ERROR FIRABASE API : $e');
    }
    return docTodo.id;
  }

  static Stream<List<PrinterModel>> readPrinters() => FirebaseFirestore.instance
      .collection('Devices')
      .snapshots()
      .transform(Utils.transformer(PrinterModel.fromJson));
}
