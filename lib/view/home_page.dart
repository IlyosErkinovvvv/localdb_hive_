import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localdb_hive_/data/service/get_currency_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool isConnected = false;
  ConnectivityResult connectivityResult = ConnectivityResult.none;

  @override
  void initState() {
    checkConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hive")),
      body: FutureBuilder(
        future: CurrencyService.getCurrency(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return isConnected
                ? RefreshIndicator(
                    onRefresh: CurrencyService.getCurrency,
                    child: ListView.builder(
                      itemCount: CurrencyService.currencyBox.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title:
                                Text(snapshot.data[index]['title'].toString()),
                            subtitle:
                                Text(snapshot.data[index]['code'].toString()),
                            trailing:
                                Text(snapshot.data[index]['date'].toString()),
                          ),
                        );
                      },
                    ),
                  )
                : _item();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        // await CurrencyService.getCurrency();
        // await Hive.deleteBoxFromDisk("currency");
        setState(() {});
      }),
    );
  }

  Widget _item() {
    if (CurrencyService.currencyBox.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Please check your internet connection"),
            ElevatedButton(
              onPressed: () {
                print("Refresh connection");
                setState(() {});
              },
              child: const Text("Refresh connection"),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: CurrencyService.currencyBox.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(
                  CurrencyService.currencyBox.get(index)!.title.toString()),
              subtitle:
                  Text(CurrencyService.currencyBox.get(index)!.code.toString()),
              trailing:
                  Text(CurrencyService.currencyBox.get(index)!.date.toString()),
            ),
          );
        },
      );
    }
  }

  checkConnection() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.wifi ||
          event == ConnectivityResult.mobile) {
        isConnected = true;
        Fluttertoast.showToast(msg: "You are online");
        setState(() {});
      } else {
        isConnected = false;
        Fluttertoast.showToast(msg: "You are offline");
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription!.cancel();
    super.dispose();
  }
}
