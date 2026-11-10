// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Player _$PlayerFromJson(Map<String, dynamic> json) => _Player(
  id: json['id'] as String? ?? '',
  name: json['name'] as String,
  avatarColor: (json['avatarColor'] as num?)?.toInt() ?? 0xFFE0A526,
);

Map<String, dynamic> _$PlayerToJson(_Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatarColor': instance.avatarColor,
};
