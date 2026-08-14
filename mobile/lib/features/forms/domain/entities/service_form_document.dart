class ServiceFormDocument {
  final int id;
  final int serviceFormApplicationId;
  final String documentName;
  final String fileName;
  final String mimeType;
  final int fileSize;
  final String? createdAt;
  final String? updatedAt;

  const ServiceFormDocument({
    required this.id,
    required this.serviceFormApplicationId,
    required this.documentName,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    this.createdAt,
    this.updatedAt,
  });
}
