import 'package:flutterfirebaseposts/features/svglayer/data/model/picked_svg_file.dart';
import 'package:flutterfirebaseposts/features/svglayer/domain/repo/svg_repository.dart';

class PickSvgFileUseCase {
  final SvgRepository repository;

  PickSvgFileUseCase({required this.repository});

  Future<PickedSvgFile?> call() => repository.pickSvgFile();
}


