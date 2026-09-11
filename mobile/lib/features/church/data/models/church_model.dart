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
  final String? themePrimaryColor;
  final String? themeSecondaryColor;
  final int? themeVersion;

  const ChurchModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.slug,
    this.timezone,
    this.address,
    this.phone,
    this.logoUrl,
    this.themePrimaryColor,
    this.themeSecondaryColor,
    this.themeVersion,
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
      themePrimaryColor: json['theme_primary_color']?.toString(),
      themeSecondaryColor: json['theme_secondary_color']?.toString(),
      themeVersion: json['theme_version'] is int
          ? json['theme_version'] as int
          : int.tryParse(json['theme_version']?.toString() ?? ''),
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
      'theme_primary_color': themePrimaryColor,
      'theme_secondary_color': themeSecondaryColor,
      'theme_version': themeVersion,
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
      themePrimaryColor: themePrimaryColor,
      themeSecondaryColor: themeSecondaryColor,
      themeVersion: themeVersion,
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
      themePrimaryColor: church.themePrimaryColor,
      themeSecondaryColor: church.themeSecondaryColor,
      themeVersion: church.themeVersion,
    );
  }
}
