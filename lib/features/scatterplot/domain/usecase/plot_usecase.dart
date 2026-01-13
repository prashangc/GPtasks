import 'package:flutterfirebaseposts/features/scatterplot/data/model/plot_model.dart';
import 'package:flutterfirebaseposts/features/scatterplot/data/repo/plot_repository_impl.dart';

class PlotUsecase {
  final PlotRepositoryImpl repository;

  PlotUsecase({required this.repository});

  Future<PlotModel?> call() {
    return repository.getPlotPoints();
  }
}
