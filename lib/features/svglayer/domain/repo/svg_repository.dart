import 'package:flutterfirebaseposts/features/svglayer/data/model/picked_svg_file.dart';
import 'package:flutterfirebaseposts/features/svglayer/data/model/svg_layer_model.dart';

abstract class SvgRepository {
  Future<PickedSvgFile?> pickSvgFile();
  List<SvgLayer> parseLayers(String svgContent);
}


