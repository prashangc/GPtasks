import 'dart:developer';

import 'package:flutterfirebaseposts/features/svglayer/data/model/svg_layer_model.dart';
import 'package:xml/xml.dart';

abstract class SvgParser {
  List<SvgLayer> parseLayers(String svgContent);
}

class SvgParserImpl implements SvgParser {
  @override
  List<SvgLayer> parseLayers(String svgContent) {
    try {
      XmlDocument document = XmlDocument.parse(svgContent);
      final List<SvgLayer> layers = [];
      List<XmlElement> paths = document.findAllElements('path').toList();
      for (int i = 0; i < paths.length; i++) {
        final path = paths[i];
        int layer = i + 1;
        final id =
            // path.getAttribute('id') ??
            'Layer $layer';
        String color = path.getAttribute('fill')?.toString() ?? 'D7D3D2';
        path.setAttribute('id', id);
        String layerSvg = buildLayerSvg(
          fullDocument: document,
          layerId: id,
        );
        log("look here= $layerSvg");
        layers.add(
          SvgLayer(
            id: id,
            document: document,
            paths: paths,
            svgLayer: layerSvg,
            color: color,
          ),
        );
      }

      return layers;
    } on XmlException {
      log("npt found");
      return [];
    }
  }

  String buildLayerSvg({
    required XmlDocument fullDocument,
    required String layerId,
  }) {
    final originalSvg = fullDocument.findElements('svg').first;
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('svg', nest: () {
      for (final attr in originalSvg.attributes) {
        builder.attribute(attr.name.toString(), attr.value);
      }
      final path = fullDocument.findAllElements('path').firstWhere(
            (p) => p.getAttribute('id') == layerId,
            orElse: () => XmlElement(
              XmlName(layerId),
            ),
          );

      builder.element('path', nest: () {
        for (final attr in path.attributes) {
          builder.attribute(attr.name.toString(), attr.value);
        }
      });
    });

    return builder.buildDocument().toXmlString(pretty: true);
  }
}
