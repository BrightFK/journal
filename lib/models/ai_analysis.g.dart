// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_analysis.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AIAnalysisAdapter extends TypeAdapter<AIAnalysis> {
  @override
  final int typeId = 1;

  @override
  AIAnalysis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AIAnalysis(
      sentiment: fields[0] as String,
      themes: (fields[1] as List).cast<String>(),
      summary: fields[2] as String,
      advice: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AIAnalysis obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.sentiment)
      ..writeByte(1)
      ..write(obj.themes)
      ..writeByte(2)
      ..write(obj.summary)
      ..writeByte(3)
      ..write(obj.advice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIAnalysisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
