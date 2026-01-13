import 'package:xml/xml.dart';

class SvgLayer {
  final String id;
  final String color;
  final String svgLayer;
  final List<XmlElement> paths;
  final XmlDocument document;

  SvgLayer({
    required this.id,
    required this.document,
    required this.paths,
    required this.svgLayer,
    required this.color,
  });
}
