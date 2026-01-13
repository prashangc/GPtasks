import 'package:flutterfirebaseposts/features/svglayer/data/model/svg_layer_model.dart';
import 'package:flutterfirebaseposts/features/svglayer/domain/repo/svg_repository.dart';

class ParseSvgLayersUseCase {
  final SvgRepository repository;

  ParseSvgLayersUseCase({required this.repository});

  List<SvgLayer> call(String svgContent) {
    return repository.parseLayers(svgContent);
  }
}


