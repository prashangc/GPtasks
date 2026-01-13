import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterfirebaseposts/features/svglayer/data/repo/media_permission_repository_impl.dart';
import 'package:flutterfirebaseposts/features/svglayer/data/repo/svg_repository_impl.dart';
import 'package:flutterfirebaseposts/features/svglayer/data/source/media_permission_datasource.dart';
import 'package:flutterfirebaseposts/features/svglayer/data/source/svg_file_picker.dart';
import 'package:flutterfirebaseposts/features/svglayer/data/source/svg_parser.dart';
import 'package:flutterfirebaseposts/features/svglayer/domain/usecase/parse_svg_layers_usecase.dart';
import 'package:flutterfirebaseposts/features/svglayer/domain/usecase/pick_svg_file_usecase.dart';
import 'package:flutterfirebaseposts/features/svglayer/domain/usecase/request_media_permission_usecase.dart';
import 'package:flutterfirebaseposts/features/svglayer/presentation/provider/svg_layer_provider.dart';
import 'package:flutterfirebaseposts/features/svglayer/presentation/widgets/svg_layer_tile.dart';
import 'package:flutterfirebaseposts/features/svglayer/presentation/widgets/svg_picker_fab.dart';
import 'package:provider/provider.dart';

class SvgLayerScreen extends StatelessWidget {
  const SvgLayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final permissionRepo =
            MediaPermissionRepositoryImpl(MediaPermissionDataSource());
        final svgRepo = SvgRepositoryImpl(
          picker: SvgFilePickerImpl(),
          parser: SvgParserImpl(),
        );

        return SvgLayerProvider(
          svgParserImpl: SvgParserImpl(),
          requestPermissionUseCase:
              RequestMediaPermissionUseCase(repository: permissionRepo),
          pickSvgFileUseCase: PickSvgFileUseCase(repository: svgRepo),
          parseSvgLayersUseCase: ParseSvgLayersUseCase(repository: svgRepo),
        );
      },
      child: const _SvgLayerView(),
    );
  }
}

class _SvgLayerView extends StatelessWidget {
  const _SvgLayerView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SvgLayerProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('SVG Layer')),
      floatingActionButton: SvgPickerFab(
        onPressed: () => context.read<SvgLayerProvider>().pickAndParse(),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(12.0),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.pickedFile?.name ?? '',
              ),
              SizedBox(
                width: 200,
                height: 200,
                child: SvgPicture.string(
                  provider.pickedFile?.content ?? '',
                ),
              ),
              const SizedBox(height: 8),
              if (provider.isLoading)
                Center(child: CircularProgressIndicator())
              else if (provider.error != null)
                Center(
                  child: Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              else if (provider.layers.isEmpty)
                Center(
                  child: Text('No image selected'),
                )
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.layers.length,
                    itemBuilder: (context, index) {
                      final layer = provider.layers[index];
                      return SvgLayerTile(
                        layer: layer,
                        i: index,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
