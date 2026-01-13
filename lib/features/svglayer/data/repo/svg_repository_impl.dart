import 'package:flutterfirebaseposts/features/svglayer/data/model/picked_svg_file.dart';
import 'package:flutterfirebaseposts/features/svglayer/data/model/svg_layer_model.dart';
import 'package:flutterfirebaseposts/features/svglayer/data/source/svg_file_picker.dart';
import 'package:flutterfirebaseposts/features/svglayer/data/source/svg_parser.dart';
import 'package:flutterfirebaseposts/features/svglayer/domain/repo/svg_repository.dart';

class SvgRepositoryImpl implements SvgRepository {
  final SvgFilePicker picker;
  final SvgParser parser;

  SvgRepositoryImpl({
    required this.picker,
    required this.parser,
  });

  @override
  Future<PickedSvgFile?> pickSvgFile() {
    return picker.pickSvg();
  }

  @override
  List<SvgLayer> parseLayers(String svgContent) {
    return parser.parseLayers(svgContent);
  }
}


