import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterfirebaseposts/features/svglayer/data/model/svg_layer_model.dart';
import 'package:flutterfirebaseposts/features/svglayer/presentation/provider/svg_layer_provider.dart';
import 'package:flutterfirebaseposts/utils/color_ext.dart';
import 'package:provider/provider.dart';

class SvgLayerTile extends StatelessWidget {
  final int i;
  final SvgLayer layer;
  const SvgLayerTile({
    super.key,
    required this.layer,
    required this.i,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SvgLayerProvider>();
    return Card(
      elevation: 2,
      child: ListTile(
        onTap: () {
          showColorPickerDialog(
            context: context,
            initialColor: layer.color.toHexColor(),
            onColorChanged: (Color v) {
              provider.updateLayerColor(
                document: layer.document,
                i: i,
                layerId: layer.id,
                paths: layer.paths,
                pickedColor: v,
              );
            },
          );
        },
        leading: SizedBox(
          width: 40,
          height: 40,
          child: SvgPicture.string(
            layer.svgLayer,
            fit: BoxFit.contain,
            color: layer.color.toHexColor(),
          ),
        ),
        title: Text(
          layer.id,
          style: TextStyle(
            color: layer.color.toHexColor(),
          ),
        ),
        subtitle: Text(
          layer.color,
          style: TextStyle(
            color: layer.color.toHexColor(),
          ),
        ),
        trailing: Icon(
          Icons.edit,
          color: layer.color.toColor(),
        ),
      ),
    );
  }

  void showColorPickerDialog({
    required BuildContext context,
    required Color initialColor,
    required ValueChanged<Color> onColorChanged,
  }) {
    Color tempColor = initialColor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
              enableAlpha: false,
              labelTypes: const [],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onColorChanged(tempColor);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
