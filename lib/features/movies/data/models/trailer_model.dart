import '../../domain/entities/trailer.dart';

class TrailerModel extends Trailer {
  const TrailerModel({
    required super.id,
    required super.key,
    required super.name,
    required super.site,
    required super.type,
  });

  factory TrailerModel.fromJson(Map<String, dynamic> json) {
    return TrailerModel(
      id: json['id'] as String? ?? '',
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      site: json['site'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'site': site,
      'type': type,
    };
  }
}
