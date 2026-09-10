import '../../domain/entities/church.dart';

class ChurchModel {
  final int id;
  final String uuid;
  final String name;
  final String slug;
  final String? timezone;
  final String? address;
  final String? phone;
  final String? logoUrl;

  const ChurchModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.slug,
    this.timezone,
    this.address,
    this.phone,
    this.logoUrl,
  });

  factory ChurchModel.fromJson(Map<String, dynamic> json) {
    return ChurchModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      timezone: json['timezone']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      logoUrl: json['logo_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'slug': slug,
      'timezone': timezone,
      'address': address,
      'phone': phone,
      'logo_url': logoUrl,
    };
  }

  Church toEntity() {
    return Church(
      id: id,
      uuid: uuid,
      name: name,
      slug: slug,
      timezone: timezone,
      address: address,
      phone: phone,
      logoUrl: logoUrl,
    );
  }

  factory ChurchModel.fromEntity(Church church) {
    return ChurchModel(
      id: church.id,
      uuid: church.uuid,
      name: church.name,
      slug: church.slug,
      timezone: church.timezone,
      address: church.address,
      phone: church.phone,
      logoUrl: church.logoUrl,
    );
  }
}
