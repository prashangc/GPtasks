import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutterfirebaseposts/features/scatterplot/data/model/plot_model.dart';

abstract class PlotLocalDataSource {
  Future<PlotModel?> loadPlotPoints();
}

class PlotLocalDataSourceImpl implements PlotLocalDataSource {
  @override
  Future<PlotModel?> loadPlotPoints() async {
    try {
      final raw = await rootBundle.loadString('assets/json/jsondata.json');
      final Map<String, dynamic> jsonMap = json.decode(raw);
      final plotModel = PlotModel.fromJson(jsonMap);
      return plotModel;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
