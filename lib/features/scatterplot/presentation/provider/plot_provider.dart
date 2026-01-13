import 'package:flutter/material.dart';
import 'package:flutterfirebaseposts/features/scatterplot/data/model/plot_model.dart';
import 'package:flutterfirebaseposts/features/scatterplot/domain/usecase/plot_usecase.dart';

class PlotProvider extends ChangeNotifier {
  final PlotUsecase plotUsecase;

  PlotProvider(this.plotUsecase);

  bool isLoading = false;
  List<Plot> data = [];
  String? error;
  final Set<String> selectedYears = {'2024'};

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      PlotModel? plotModel = await plotUsecase.call();
      data = plotModel?.data ?? [];
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleYear(String year) {
    if (selectedYears.contains(year)) {
      if (selectedYears.length == 1) return;
      selectedYears.remove(year);
    } else {
      selectedYears.add(year);
    }
    notifyListeners();
  }

  double? valueForYear(Plot plot, String year) {
    switch (year) {
      case '2022':
        return plot.i2022?.toDouble();
      case '2023':
        return plot.i2023?.toDouble();
      case '2024':
        return plot.d2024?.toDouble();
      case '2025':
        return plot.d2025?.toDouble();
      default:
        return null;
    }
  }
}
