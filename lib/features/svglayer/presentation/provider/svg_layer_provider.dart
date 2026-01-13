import 'package:flutter/material.dart';
import 'package:flutterfirebaseposts/features/svglayer/data/model/picked_svg_file.dart';
import 'package:flutterfirebaseposts/features/svglayer/data/model/svg_layer_model.dart';
import 'package:flutterfirebaseposts/features/svglayer/data/source/svg_parser.dart';
import 'package:flutterfirebaseposts/features/svglayer/domain/usecase/parse_svg_layers_usecase.dart';
import 'package:flutterfirebaseposts/features/svglayer/domain/usecase/pick_svg_file_usecase.dart';
import 'package:flutterfirebaseposts/features/svglayer/domain/usecase/request_media_permission_usecase.dart';
import 'package:flutterfirebaseposts/utils/color_ext.dart';
import 'package:xml/xml.dart';

class SvgLayerProvider extends ChangeNotifier {
  final RequestMediaPermissionUseCase requestPermissionUseCase;
  final PickSvgFileUseCase pickSvgFileUseCase;
  final ParseSvgLayersUseCase parseSvgLayersUseCase;
  final SvgParserImpl svgParserImpl;

  SvgLayerProvider({
    required this.requestPermissionUseCase,
    required this.pickSvgFileUseCase,
    required this.parseSvgLayersUseCase,
    required this.svgParserImpl,
  });

  bool isLoading = false;
  String? error;
  PickedSvgFile? pickedFile;
  List<SvgLayer> layers = [];

  Future<void> pickAndParse() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final granted = await requestPermissionUseCase();
    if (!granted) {
      error = 'Media permission is required to pick SVG files.';
      isLoading = false;
      notifyListeners();
      return;
    }

    final file = await pickSvgFileUseCase();
    if (file == null) {
      error = 'No SVG selected.';
      isLoading = false;
      notifyListeners();
      return;
    }

    pickedFile = file;
    layers = parseSvgLayersUseCase(file.content);
    if (layers.isEmpty) {
      error = 'Unable to detect layers in the selected SVG.';
    }

    isLoading = false;
    notifyListeners();
  }

  void updateLayerColor({
    required String layerId,
    required Color pickedColor,
    required int i,
    required List<XmlElement> paths,
    required XmlDocument document,
  }) {
    if (i != -1) {
      paths[i].setAttribute('fill', pickedColor.toHex());
      final updatedLayerSvg = svgParserImpl.buildLayerSvg(
        fullDocument: document,
        layerId: layerId,
      );
      layers[i] = SvgLayer(
          id: layers[i].id,
          document: document,
          color: pickedColor.toHex(),
          paths: paths,
          svgLayer: updatedLayerSvg);
    }
    pickedFile = pickedFile!.copyWith(
      content: document.toXmlString(),
    );
    notifyListeners();
  }
}
