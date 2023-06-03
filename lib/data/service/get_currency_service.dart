import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:localdb_hive_/core/config/dio_catch_error_config.dart';
import 'package:localdb_hive_/core/config/dio_config.dart';
import 'package:localdb_hive_/core/constants/project_urls.dart';
import 'package:localdb_hive_/data/model/currency_model.dart';
import 'package:path_provider/path_provider.dart';

// CurrencyService
class CurrencyService {
  // Box
  static late Box<CurrencyModel> currencyBox; // late or nullable/!

  // getCurrency
  static Future<dynamic> getCurrency() async {
    await openBox();
    try {
      Response response = await DioConfig.createRequest().get(ProjectUrls.url);
      if (response.statusCode == 200) {
        List<CurrencyModel> resData = (response.data as List)
            .map((e) => CurrencyModel.fromJson(e))
            .toList();
        await putToBox(resData);
        return response.data;
      } else {
        return response.statusMessage;
      }
    } on DioError catch (e) {
      DioCatchErrorConfig.catchError(e);
    }
  }

  // openBox
  static openBox() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);
    currencyBox = await Hive.openBox<CurrencyModel>("currency");
    print("openBox✔️✔️✔️  Successfully");
  }

  // putToBox
  static putToBox(List<CurrencyModel> data) async {
    for (CurrencyModel element in data) {
      await currencyBox.add(element);
    }
    print("putToBox✔️✔️✔️  Successfully");
  }

  // registerAdapters
  static void registerAdapters() {
    Hive.registerAdapter(CurrencyModelAdapter());
    print("registerAdapters✔️✔️✔️  Successfully");
  }
}
