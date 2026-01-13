import 'package:flutterfirebaseposts/features/svglayer/data/source/media_permission_datasource.dart';
import 'package:flutterfirebaseposts/features/svglayer/domain/repo/media_permission_repository.dart';

class MediaPermissionRepositoryImpl implements MediaPermissionRepository {
  final MediaPermissionDataSource dataSource;

  MediaPermissionRepositoryImpl(this.dataSource);

  @override
  Future<bool> requestAccess() {
    return dataSource.requestMediaAccess();
  }
}


