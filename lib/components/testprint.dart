import 'dart:convert';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';

class TestPrint {
  BlueThermalPrinter printer = BlueThermalPrinter.instance;

  bill(
      Map<String, dynamic> order,
      num totalFoods,
      num totalDrinks,
      num ticketId,
      num buzzerNumber,
      String orderTime,
      String customerName) async {
    Map<String, dynamic> data = <String, dynamic>{};
    ByteData datas = await rootBundle.load("images/receipt-logo.png");
    List<int> imageBytes =
        datas.buffer.asUint8List(datas.offsetInBytes, datas.lengthInBytes);
    String base64Image = base64Encode(imageBytes);
    for (dynamic type in order.keys) {
      data[type.toString()] = order[type];
    }
    //ALL
    List<String> allDrinkMenuName = [];
    List<num> allDrinkMenuQuantity = [];
    List<String> allDrinkMenuTopping = [];
    List<String> allDrinkMenuGulaLevel = [];
    List<String> allMamuMenuName = [];
    List<num> allMamuMenuQuantity = [];
    List<String> allMamuMenuTopping = [];
    //MINUMAN
    List<String> bungkusMinumMenuName = [];
    List<num> bungkusMinumMenuQuantity = [];
    List<String> bungkusMinumMenuTopping = [];
    List<String> minumSiniMenuName = [];
    List<num> minumSiniMenuQuantity = [];
    List<String> minumSiniMenuTopping = [];
    List<String> minumSiniMenuGulaLevel = [];
    //MAKANAN

    List<String> bungkusMamuMenuName = [];
    List<num> bungkusMamuMenuQuantity = [];
    List<String> bungkusMamuMenuTopping = [];
    List<String> makanSiniMenuName = [];
    List<num> makanSiniMenuQuantity = [];
    List<String> makanSiniMenuTopping = [];
    //FIRST STAGE FOR EXCLUDING MAMU AND MINUM
    for (int s = 0; s < order.length; s++) {
      if (order[s.toString()]['isDrink']) {
        allDrinkMenuName.add(order[s.toString()]['name']);
        allDrinkMenuQuantity.add(order[s.toString()]['quantity']);
        List<dynamic> l = order[s.toString()]['toppingName'];
        for (int top = 0; top < l.length; top++) {
          allDrinkMenuTopping.add(data[s.toString()]['toppingName'][top]);
        }
        allDrinkMenuGulaLevel.add(order[s.toString()]['sugarLevel']);
      } else if (order[s.toString()]['isDrink'] == false) {
        allMamuMenuName.add(order[s.toString()]['name']);
        allMamuMenuQuantity.add(order[s.toString()]['quantity']);
        List<dynamic> l = order[s.toString()]['toppingName'];
        for (int top = 0; top < l.length; top++) {
          allMamuMenuTopping
              .add(data[s.toString()]['toppingName'][top].toString());
        }
      }
    }

    //SECOND STAGE FOR EXCLUDING MINUM AND BUNGKUS
    for (int d = 0; d < allDrinkMenuName.length; d++) {
      if (allDrinkMenuName[d].contains('Bungkus')) {
        //MINUMAN
        bungkusMinumMenuName.add(allDrinkMenuName[d]);
        bungkusMinumMenuQuantity.add(allDrinkMenuQuantity[d]);
        for (int top = 0; top < allDrinkMenuTopping.length; top++) {
          bungkusMinumMenuTopping.add(allDrinkMenuTopping[top]);
        }
      } else if (allDrinkMenuName[d].contains('Minum Sini')) {
        minumSiniMenuName.add(allDrinkMenuName[d]);
        minumSiniMenuQuantity.add(allDrinkMenuQuantity[d]);
        for (int top = 0; top < allDrinkMenuTopping.length; top++) {
          minumSiniMenuTopping.add(allDrinkMenuTopping[top]);
        }
        minumSiniMenuGulaLevel.add(allDrinkMenuGulaLevel[d]);
      }
    }
    for (int d = 0; d < allMamuMenuName.length; d++) {
      if (allMamuMenuName[d].contains('Makan Sini')) {
        makanSiniMenuName.add(allMamuMenuName[d]);
        makanSiniMenuQuantity.add(allMamuMenuQuantity[d]);
        for (int top = 0; top < allMamuMenuTopping.length; top++) {
          makanSiniMenuTopping.add(allMamuMenuTopping[top]);
        }
      } else if (allMamuMenuName[d].contains('Bungkus')) {
        bungkusMamuMenuName.add(allMamuMenuName[d]);
        bungkusMamuMenuQuantity.add(allMamuMenuQuantity[d]);
        for (int top = 0; top < allMamuMenuTopping.length; top++) {
          bungkusMamuMenuTopping.add(allMamuMenuTopping[top]);
        }
      }
    }

    if (allDrinkMenuName.isNotEmpty) {
      if (totalDrinks != 0 && totalFoods != 0) {
        printer.printImageBytes(
            datas.buffer.asUint8List(datas.offsetInBytes, datas.lengthInBytes));
        printer.printCustom('Untuk: $customerName  ', 2, 1);
        printer.printCustom('Nombor Order $ticketId  ', 1, 0);
        printer.printCustom('Masa Order $orderTime  ', 1, 0);
        printer.printCustom('Jumlah Makanan : $totalFoods', 1, 0);
        printer.printCustom('Jumlah Minuman : $totalDrinks', 1, 0);
        printer.printCustom('<<<<<<<<<<<<<>>>>>>>>>>>', 2, 0);
        printer.printCustom('SET MAMU', 4, 1);
        printer.printCustom('<<<<<<<<<<<<<>>>>>>>>>>>', 2, 0);
        printer.printCustom('UNTUK CENDOL', 3, 1);
        printer.printNewLine();
        for (int s = 0; s < order.length; s++) {
          if (order[s.toString()]['isDrink']) {
            if (order[s.toString()]['name'].toString().contains('Minum Sini')) {
              printer.printCustom(
                  '${order[s.toString()]['quantity']}x${order[s.toString()]['name'].toString().replaceAll('Minum Sini', '\n(MINUM SINI)')}',
                  2,
                  0);

              List<dynamic> l = order[s.toString()]['toppingName'];
              for (int top = 0; top < l.length; top++) {
                printer.printCustom(
                    '>>${data[s.toString()]['toppingName'][top]}', 2, 0);
              }
              printer.printCustom(
                  '* GULA: ${data[s.toString()]['sugarLevel']}', 3, 0);
              printer.printCustom(
                  '* ICE: ${data[s.toString()]['iceLevel']}', 3, 0);
              printer.printNewLine();
            } else if (order[s.toString()]['name']
                .toString()
                .contains('Bungkus')) {
              printer.printCustom(
                  '${order[s.toString()]['quantity']}x${order[s.toString()]['name'].toString().replaceAll('Bungkus', '\n(Bungkus)')}',
                  2,
                  0);

              List<dynamic> l = order[s.toString()]['toppingName'];
              for (int top = 0; top < l.length; top++) {
                printer.printCustom(
                    '>>${data[s.toString()]['toppingName'][top]}', 2, 0);
              }
              printer.printCustom(
                  '* GULA: ${data[s.toString()]['sugarLevel']}', 3, 0);
              printer.printCustom(
                  '* ICE: ${data[s.toString()]['iceLevel']}', 3, 0);
              printer.printNewLine();
            }
          }
        }

        printer.printCustom('########################', 2, 0);
        printer.printCustom('BUZZER : ${buzzerNumber.toString()}', 4, 1);
        printer.printCustom('########################', 2, 0);
        printer.printNewLine();
        printer.paperCut();
        if (allMamuMenuName.isNotEmpty) {
          printer.printImageBytes(datas.buffer
              .asUint8List(datas.offsetInBytes, datas.lengthInBytes));
          printer.printCustom('Untuk: $customerName  ', 2, 1);
          printer.printCustom('Nombor Order $ticketId  ', 1, 0);
          printer.printCustom('Masa Order $orderTime  ', 1, 0);
          printer.printCustom('Jumlah Makanan : $totalFoods', 1, 0);
          printer.printCustom('Jumlah Minuman : $totalDrinks', 1, 0);
          printer.printCustom('<<<<<<<<<<<<<>>>>>>>>>>>', 2, 0);
          printer.printCustom('SET MAMU', 4, 1);
          printer.printCustom('<<<<<<<<<<<<<>>>>>>>>>>>', 2, 0);
          printer.printCustom('UNTUK DAPUR', 3, 1);
          printer.printNewLine();
          for (int s = 0; s < order.length; s++) {
            if (order[s.toString()]['isDrink'] == false) {
              if (order[s.toString()]['name']
                  .toString()
                  .contains('Makan Sini')) {
                printer.printCustom(
                    '${order[s.toString()]['quantity']}x${order[s.toString()]['name'].toString().replaceAll('Makan Sini', '\n')}(MAKAN SINI)',
                    2,
                    0);

                List<dynamic> l = order[s.toString()]['toppingName'];
                for (int top = 0; top < l.length; top++) {
                  printer.printCustom(
                      '>>${data[s.toString()]['toppingName'][top]}', 2, 0);
                }

                printer.printNewLine();
              } else if (order[s.toString()]['name']
                  .toString()
                  .contains('Bungkus')) {
                printer.printCustom(
                    '${order[s.toString()]['quantity']}x${order[s.toString()]['name'].toString().replaceAll('Bungkus', '\n')}(BUNGKUS)',
                    2,
                    0);

                List<dynamic> l = order[s.toString()]['toppingName'];
                for (int top = 0; top < l.length; top++) {
                  printer.printCustom(
                      '>>${data[s.toString()]['toppingName'][top]}', 2, 0);
                }
                printer.printCustom(
                    '* Pedas: ${data[s.toString()]['spicyLevel']}', 3, 0);

                printer.printNewLine();
              }
            }
          }
          printer.printCustom('########################', 2, 0);
          printer.printCustom('BUZZER : ${buzzerNumber.toString()}', 4, 1);
          printer.printCustom('########################', 2, 0);
          printer.printNewLine();
          printer.paperCut();
        }
      } else if (totalDrinks != 0 && totalFoods == 0) {
        printer.printImageBytes(
            datas.buffer.asUint8List(datas.offsetInBytes, datas.lengthInBytes));
        printer.printCustom('Untuk: $customerName  ', 2, 1);
        printer.printCustom('Nombor Order $ticketId  ', 1, 0);
        printer.printCustom('Masa Order $orderTime  ', 1, 0);
        printer.printCustom('Jumlah Makanan : $totalFoods', 1, 0);
        printer.printCustom('Jumlah Minuman : $totalDrinks', 1, 0);
        printer.printCustom('<<<<<<<<<<<<<>>>>>>>>>>>', 2, 0);
        printer.printCustom('AIR SAHAJA', 4, 1);
        printer.printCustom('<<<<<<<<<<<<<>>>>>>>>>>>', 2, 0);
        printer.printCustom('UNTUK CENDOL', 3, 1);
        printer.printNewLine();
        for (int s = 0; s < order.length; s++) {
          if (order[s.toString()]['isDrink']) {
            if (order[s.toString()]['name'].toString().contains('Minum Sini')) {
              printer.printCustom(
                  '${order[s.toString()]['quantity']}x${order[s.toString()]['name'].toString().replaceAll('Minum Sini', '\n(MINUM SINI)')}',
                  2,
                  0);

              List<dynamic> l = order[s.toString()]['toppingName'];
              for (int top = 0; top < l.length; top++) {
                printer.printCustom(
                    '>>${data[s.toString()]['toppingName'][top]}', 2, 0);
              }
              printer.printCustom(
                  '* GULA: ${data[s.toString()]['sugarLevel']}', 3, 0);
              printer.printCustom(
                  '* ICE: ${data[s.toString()]['iceLevel']}', 3, 0);
              printer.printNewLine();
            } else if (order[s.toString()]['name']
                .toString()
                .contains('Bungkus')) {
              printer.printCustom(
                  '${order[s.toString()]['quantity']}x${order[s.toString()]['name'].toString().replaceAll('Bungkus', '\n(Bungkus)')}',
                  2,
                  0);

              List<dynamic> l = order[s.toString()]['toppingName'];
              for (int top = 0; top < l.length; top++) {
                printer.printCustom(
                    '>>${data[s.toString()]['toppingName'][top]}', 2, 0);
              }
              printer.printCustom(
                  '* GULA: ${data[s.toString()]['sugarLevel']}', 3, 0);
              printer.printCustom(
                  '* ICE: ${data[s.toString()]['iceLevel']}', 3, 0);
              printer.printNewLine();
            }
          }
        }
        printer.printCustom('########################', 2, 0);
        printer.printCustom('BUZZER : ${buzzerNumber.toString()}', 4, 1);
        printer.printCustom('########################', 2, 0);
        printer.printNewLine();
        printer.paperCut();
      }
    } else {
      if (allDrinkMenuName.isEmpty) {
        printer.printImageBytes(
            datas.buffer.asUint8List(datas.offsetInBytes, datas.lengthInBytes));
        printer.printCustom('Untuk: $customerName  ', 2, 1);
        printer.printCustom('Nombor Order $ticketId  ', 1, 0);
        printer.printCustom('Masa Order $orderTime  ', 1, 0);
        printer.printCustom('Jumlah Makanan : $totalFoods', 1, 0);
        printer.printCustom('Jumlah Minuman : $totalDrinks', 1, 0);
        printer.printCustom('<<<<<<<<<<<<<>>>>>>>>>>>', 2, 0);
        printer.printCustom('MAKANAN SAHAJA', 4, 1);
        printer.printCustom('<<<<<<<<<<<<<>>>>>>>>>>>', 2, 0);
        printer.printCustom('UNTUK DAPUR', 3, 1);
        printer.printNewLine();
        for (int s = 0; s < order.length; s++) {
          if (order[s.toString()]['name'].toString().contains('Makan Sini')) {
            printer.printCustom(
                '${order[s.toString()]['quantity']}x${order[s.toString()]['name'].toString().replaceAll('Makan Sini', '\n')}(MAKAN SINI)',
                2,
                0);

            List<dynamic> l = order[s.toString()]['toppingName'];
            for (int top = 0; top < l.length; top++) {
              printer.printCustom(
                  '>>${data[s.toString()]['toppingName'][top]}', 2, 0);
            }

            printer.printNewLine();
          } else if (order[s.toString()]['name']
              .toString()
              .contains('Bungkus')) {
            printer.printCustom(
                '${order[s.toString()]['quantity']}x${order[s.toString()]['name'].toString().replaceAll('Bungkus', '\n')}(BUNGKUS)',
                2,
                0);

            List<dynamic> l = order[s.toString()]['toppingName'];
            for (int top = 0; top < l.length; top++) {
              printer.printCustom(
                  '>>${data[s.toString()]['toppingName'][top]}', 2, 0);
            }
            printer.printCustom(
                '* Pedas: ${data[s.toString()]['spicyLevel']}', 3, 0);

            printer.printNewLine();
          }
        }
        printer.printCustom('########################', 2, 0);
        printer.printCustom('BUZZER : ${buzzerNumber.toString()}', 4, 1);
        printer.printCustom('########################', 2, 0);
        printer.printNewLine();
        printer.paperCut();
      }
    }
  }
}
