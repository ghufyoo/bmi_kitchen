import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class TestPrint {
  BlueThermalPrinter printer = BlueThermalPrinter.instance;

  bill(Map<String, dynamic> order) {
    Map<String, dynamic> data = <String, dynamic>{};

    for (dynamic type in order.keys) {
      data[type.toString()] = order[type];
    }
    //ALL
    List<String> allDrinkMenuName = [];
    List<num> allDrinkMenuQuantity = [];
    List<String> allDrinkMenuTopping = [];
    List<String> allMamuMenuName = [];
    List<num> allMamuMenuQuantity = [];
    List<String> allMamuMenuTopping = [];
    //MINUMAN
    List<String> bungkusMinumMenuName = [];
    List<num> bungkusMinumMenuQuantity = [];
    List<String> minumSiniMenuName = [];
    List<num> minumSiniMenuQuantity = [];
    List<String> minumSiniMenuTopping = [];
    //MAKANAN

    List<String> bungkusMamuMenuName = [];
    List<num> bungkusMamuMenuQuantity = [];
    List<String> makanSiniMenuName = [];
    List<num> makanSiniMenuQuantity = [];
    //FIRST STAGE FOR EXCLUDING MAMU AND MINUM
    for (int s = 0; s < order.length; s++) {
      if (order[s.toString()]['isDrink']) {
        allDrinkMenuName.add(order[s.toString()]['name']);
        allDrinkMenuQuantity.add(order[s.toString()]['quantity']);
        List<dynamic> l = order[s.toString()]['toppingName'];
        for (int top = 0; top < l.length; top++) {
          allDrinkMenuTopping.add(data[s.toString()]['toppingName'][top]);
        }
      } else if (order[s.toString()]['isDrink'] == false) {
        allMamuMenuName.add(order[s.toString()]['name']);
        allMamuMenuQuantity.add(order[s.toString()]['quantity']);
        List<dynamic> l = order[s.toString()]['toppingName'];
        for (int top = 0; top < l.length; top++) {
          allMamuMenuTopping.add(data[s.toString()]['toppingName'][top]);
        }
      }
    }

    //SECOND STAGE FOR EXCLUDING MINUM AND BUNGKUS
    for (int d = 0; d < allDrinkMenuName.length; d++) {
      if (allDrinkMenuName[d].contains('Bungkus')) {
        bungkusMinumMenuName.add(allDrinkMenuName[d]);
        bungkusMinumMenuQuantity.add(allDrinkMenuQuantity[d]);
        bungkusMamuMenuName.add(allMamuMenuName[d]);
        bungkusMamuMenuQuantity.add(allMamuMenuQuantity[d]);
      } else if (allDrinkMenuName[d].contains('Minum Sini')) {
        minumSiniMenuName.add(allDrinkMenuName[d]);
        minumSiniMenuQuantity.add(allDrinkMenuQuantity[d]);
      } else if (allDrinkMenuName[d].contains('Makan Sini')) {
        makanSiniMenuName.add(allMamuMenuName[d]);
        makanSiniMenuQuantity.add(allMamuMenuQuantity[d]);
      }
    }

    print('Minum Sini: $minumSiniMenuName');
    print('Quantity: $minumSiniMenuQuantity');
    print('Bungkus: $bungkusMinumMenuName');
    print('Quantity: $bungkusMinumMenuQuantity');
    print('-------------------------------------');
    print('Makan Sini: $makanSiniMenuName');
    print('Quantity: $makanSiniMenuQuantity');
    print('Bungkus: $bungkusMamuMenuName');
    print('Quantity: $bungkusMamuMenuQuantity');
    print('-------------------------------------');
    print('-------------------------------------');
    print('ALL DRINKS');
    print(allDrinkMenuName);
    print(allDrinkMenuQuantity);
    print(allDrinkMenuTopping);
    print('ALL MAMU');
    print(allMamuMenuName);
    print(allMamuMenuQuantity);
    print(allMamuMenuTopping);
  }

  sample(String pathImage) async {
    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT

//     var response = await http.get("IMAGE_URL");
//     Uint8List bytes = response.bodyBytes;
    printer.isConnected.then((isConnected) {
      if (isConnected!) {
        printer.printNewLine();
        printer.printCustom("HEADER", 3, 1);
        printer.printNewLine();
        printer.printImage(pathImage); //path of your image/logo
        printer.printNewLine();
//      bluetooth.printImageBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
        printer.printLeftRight("LEFT", "RIGHT", 0);
        printer.printLeftRight("LEFT", "RIGHT", 1);
        printer.printLeftRight("LEFT", "RIGHT", 1, format: "%-15s %15s %n");
        printer.printNewLine();
        printer.printLeftRight("LEFT", "RIGHT", 2);
        printer.printLeftRight("LEFT", "RIGHT", 3);
        printer.printLeftRight("LEFT", "RIGHT", 4);
        printer.printNewLine();
        printer.print3Column("Col1", "Col2", "Col3", 1);
        printer.print3Column("Col1", "Col2", "Col3", 1,
            format: "%-10s %10s %10s %n");
        printer.printNewLine();
        printer.print4Column("Col1", "Col2", "Col3", "Col4", 1);
        printer.print4Column("Col1", "Col2", "Col3", "Col4", 1,
            format: "%-8s %7s %7s %7s %n");
        printer.printNewLine();
        String testString = " čĆžŽšŠ-H-ščđ";
        printer.printCustom(testString, 1, 1, charset: "windows-1250");
        printer.printLeftRight("Številka:", "18000001", 1,
            charset: "windows-1250");
        printer.printCustom("Body left", 1, 0);
        printer.printCustom("Body right", 0, 2);
        printer.printNewLine();
        printer.printCustom("Thank You", 2, 1);
        printer.printNewLine();
        printer.printQRcode("Insert Your Own Text to Generate", 200, 200, 1);
        printer.printNewLine();
        printer.printNewLine();
        printer.paperCut();
      }
    });
  }
}
