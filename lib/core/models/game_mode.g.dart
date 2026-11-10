// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_mode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameMode _$GameModeFromJson(Map<String, dynamic> json) => _GameMode(
  id: json['id'] as String,
  titleAr: json['titleAr'] as String,
  titleEn: json['titleEn'] as String,
  descriptionAr: json['descriptionAr'] as String,
  descriptionEn: json['descriptionEn'] as String,
  minPlayers: (json['minPlayers'] as num?)?.toInt() ?? 2,
  maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 20,
  isAvailable: json['isAvailable'] as bool? ?? true,
  routeName: json['routeName'] as String,
);

Map<String, dynamic> _$GameModeToJson(_GameMode instance) => <String, dynamic>{
  'id': instance.id,
  'titleAr': instance.titleAr,
  'titleEn': instance.titleEn,
  'descriptionAr': instance.descriptionAr,
  'descriptionEn': instance.descriptionEn,
  'minPlayers': instance.minPlayers,
  'maxPlayers': instance.maxPlayers,
  'isAvailable': instance.isAvailable,
  'routeName': instance.routeName,
};
