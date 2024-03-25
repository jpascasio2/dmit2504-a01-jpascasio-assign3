// ignore_for_file: todo, avoid_print, use_key_in_widget_constructors, avoid_function_literals_in_foreach_calls, use_build_context_synchronously, unused_local_variable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'dart:async';
import '../services/stock-service.dart';
import '../services/db-service.dart';

class HomeView extends StatefulWidget {
  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  final StockService stockService = StockService();
  final SQFliteDbService databaseService = SQFliteDbService();
  List<Map<String, dynamic>> stockList = [];
  String stockSymbol = "";

  @override
  void initState() {
    super.initState();
    getOrCreateDbAndDisplayAllStocksInDb();
  }

  void getOrCreateDbAndDisplayAllStocksInDb() async {
    await databaseService.getOrCreateDatabaseHandle();
    stockList = await databaseService.getAllStocksFromDb();
    await databaseService.printAllStocksInDbToConsole();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Ticker'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text(
                'Delete All Records and Db',
              ),
              onPressed: () async {
                await databaseService.deleteDb();
                await databaseService.getOrCreateDatabaseHandle();
                stockList = await databaseService.getAllStocksFromDb();
                await databaseService.printAllStocksInDbToConsole();
                setState(() {});
              },
            ),
            ElevatedButton(
              child: const Text(
                'Add Stock',
              ),
              onPressed: () {
                inputStock();
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: stockList.length,
                itemBuilder: (BuildContext context, index) {
                  final stockItem = stockList[index];
                  return Card(
                    child: ListTile(
                      title: Text('Symbol: ${stockItem['symbol']}'),
                      subtitle: Text(
                        'Name: ${stockItem['companyName']}',
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        'Price: \$${stockItem['price']} USD',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> inputStock() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Input Stock Symbol'),
          contentPadding: const EdgeInsets.all(5.0),
          content: TextField(
            decoration: const InputDecoration(hintText: "Symbol"),
            onChanged: (String value) {
              stockSymbol = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Add Stock"),
              onPressed: () async {
                if (stockSymbol.isNotEmpty) {
                  print('User entered Symbol: $stockSymbol');
                  var symbol = stockSymbol;
                  var companyName = '';
                  var price = '';
                  try {
                    var companyData = await stockService.getCompanyInfo(symbol);
                    var quoteData =
                        (await stockService.getQuote(symbol))["Global Quote"];

                    if (companyData != null && quoteData != null) {
                      symbol = companyData['Symbol'];
                      companyName = companyData['Name'];
                      price = quoteData['05. price'];
                    }

                    if (symbol.isEmpty ||
                        companyName.isEmpty ||
                        price.isEmpty) {
                      setState(() {});
                      return;
                    }

                    var stock = <String, dynamic>{
                      'symbol': symbol,
                      'companyName': companyName,
                      'price': price,
                    };

                    await databaseService.getOrCreateDatabaseHandle();
                    await databaseService.insertStock(stock);
                    stockList = await databaseService.getAllStocksFromDb();
                    await databaseService.printAllStocksInDbToConsole();
                    setState(() {});
                  } catch (e) {
                    print('HomeView inputStock catch: $e');
                  }
                }
                stockSymbol = "";
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
