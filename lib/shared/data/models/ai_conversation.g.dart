// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AIConversationAdapter extends TypeAdapter<AIConversation> {
  @override
  final int typeId = 13;

  @override
  AIConversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AIConversation(
      id: fields[0] as String,
      title: fields[1] as String,
      messages: (fields[2] as List).cast<AIChatMessage>(),
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      context: fields[5] as ConversationContext,
      settings: (fields[6] as Map?)?.cast<String, dynamic>(),
      isPinned: fields[7] as bool,
      tripId: fields[8] as String?,
      userId: fields[9] as String?,
      metadata: (fields[10] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AIConversation obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.messages)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.context)
      ..writeByte(6)
      ..write(obj.settings)
      ..writeByte(7)
      ..write(obj.isPinned)
      ..writeByte(8)
      ..write(obj.tripId)
      ..writeByte(9)
      ..write(obj.userId)
      ..writeByte(10)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConversationContextAdapter extends TypeAdapter<ConversationContext> {
  @override
  final int typeId = 14;

  @override
  ConversationContext read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ConversationContext.general;
      case 1:
        return ConversationContext.tripPlanning;
      case 2:
        return ConversationContext.accommodation;
      case 3:
        return ConversationContext.emergency;
      case 4:
        return ConversationContext.translation;
      case 5:
        return ConversationContext.budget;
      case 6:
        return ConversationContext.cultural;
      case 7:
        return ConversationContext.food;
      case 8:
        return ConversationContext.weather;
      default:
        return ConversationContext.general;
    }
  }

  @override
  void write(BinaryWriter writer, ConversationContext obj) {
    switch (obj) {
      case ConversationContext.general:
        writer.writeByte(0);
        break;
      case ConversationContext.tripPlanning:
        writer.writeByte(1);
        break;
      case ConversationContext.accommodation:
        writer.writeByte(2);
        break;
      case ConversationContext.emergency:
        writer.writeByte(3);
        break;
      case ConversationContext.translation:
        writer.writeByte(4);
        break;
      case ConversationContext.budget:
        writer.writeByte(5);
        break;
      case ConversationContext.cultural:
        writer.writeByte(6);
        break;
      case ConversationContext.food:
        writer.writeByte(7);
        break;
      case ConversationContext.weather:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationContextAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
