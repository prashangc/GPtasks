class PickedSvgFile {
  final String name;
  final String path;
  final String content;

  PickedSvgFile({
    required this.name,
    required this.path,
    required this.content,
  });
}

extension PickedSvgFileCopy on PickedSvgFile {
  PickedSvgFile copyWith({
    String? name,
    String? content,
    String? path,
  }) {
    return PickedSvgFile(
      name: name ?? this.name,
      content: content ?? this.content,
      path: path ?? this.path,
    );
  }
}
