import 'package:flutterfirebaseposts/features/scatterplot/data/model/plot_model.dart';

abstract class PlotRepository {
  Future<PlotModel?> getPlotPoints();
}
