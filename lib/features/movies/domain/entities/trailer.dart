import 'package:equatable/equatable.dart';

class Trailer extends Equatable {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;

  const Trailer({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
  });

  @override
  List<Object?> get props => [
        id,
        key,
        name,
        site,
        type,
      ];
}
