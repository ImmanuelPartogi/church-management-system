class SelectedDocument {
  final String documentName;
  final String filePath;
  final String fileName;
  final int fileSize;
  final String mimeType;

  const SelectedDocument({
    required this.documentName,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
  });
}
