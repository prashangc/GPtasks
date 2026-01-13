import 'package:flutterfirebaseposts/features/svglayer/domain/repo/media_permission_repository.dart';

class RequestMediaPermissionUseCase {
  final MediaPermissionRepository repository;

  RequestMediaPermissionUseCase({required this.repository});

  Future<bool> call() => repository.requestAccess();
}


