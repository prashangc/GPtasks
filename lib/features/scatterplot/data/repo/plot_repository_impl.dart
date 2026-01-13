import 'package:flutterfirebaseposts/features/scatterplot/data/model/plot_model.dart';
import 'package:flutterfirebaseposts/features/scatterplot/data/source/plot_local_datasource.dart';
import 'package:flutterfirebaseposts/features/scatterplot/domain/repo/plot_repository.dart';

class PlotRepositoryImpl implements PlotRepository {
  final PlotLocalDataSource localDataSource;

  PlotRepositoryImpl(this.localDataSource);

  @override
  Future<PlotModel?> getPlotPoints() async {
    return await localDataSource.loadPlotPoints();
  }
}
