// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AIChatMessageAdapter extends TypeAdapter<AIChatMessage> {
  @override
  final int typeId = 10;

  @override
  AIChatMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AIChatMessage(
      id: fields[0] as String,
      content: fields[1] as String,
      role: fields[2] as MessageRole,
      timestamp: fields[3] as DateTime,
      type: fields[4] as MessageType,
      metadata: (fields[5] as Map?)?.cast<String, dynamic>(),
      attachments: (fields[6] as List?)?.cast<String>(),
      isStreaming: fields[7] as bool,
      error: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AIChatMessage obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.metadata)
      ..writeByte(6)
      ..write(obj.attachments)
      ..writeByte(7)
      ..write(obj.isStreaming)
      ..writeByte(8)
      ..write(obj.error);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIChatMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageRoleAdapter extends TypeAdapter<MessageRole> {
  @override
  final int typeId = 11;

  @override
  MessageRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageRole.user;
      case 1:
        return MessageRole.assistant;
      case 2:
        return MessageRole.system;
      default:
        return MessageRole.user;
    }
  }

  @override
  void write(BinaryWriter writer, MessageRole obj) {
    switch (obj) {
      case MessageRole.user:
        writer.writeByte(0);
        break;
      case MessageRole.assistant:
        writer.writeByte(1);
        break;
      case MessageRole.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageTypeAdapter extends TypeAdapter<MessageType> {
  @override
  final int typeId = 12;

  @override
  MessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageType.text;
      case 1:
        return MessageType.image;
      case 2:
        return MessageType.location;
      case 3:
        return MessageType.suggestion;
      case 4:
        return MessageType.tripPlan;
      case 5:
        return MessageType.accommodation;
      case 6:
        return MessageType.tour;
      case 7:
        return MessageType.budget;
      default:
        return MessageType.text;
    }
  }

  @override
  void write(BinaryWriter writer, MessageType obj) {
    switch (obj) {
      case MessageType.text:
        writer.writeByte(0);
        break;
      case MessageType.image:
        writer.writeByte(1);
        break;
      case MessageType.location:
        writer.writeByte(2);
        break;
      case MessageType.suggestion:
        writer.writeByte(3);
        break;
      case MessageType.tripPlan:
        writer.writeByte(4);
        break;
      case MessageType.accommodation:
        writer.writeByte(5);
        break;
      case MessageType.tour:
        writer.writeByte(6);
        break;
      case MessageType.budget:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
