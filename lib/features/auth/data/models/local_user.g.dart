// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalUserAdapter extends TypeAdapter<LocalUser> {
  @override
  final int typeId = 1;

  @override
  LocalUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalUser(
      email: fields[0] as String,
      fullName: fields[1] as String,
      phone: fields[2] as String,
      roleIndex: fields[3] as int,
      passwordHash: fields[4] as String,
      createdAt: fields[11] as DateTime,
      dob: fields[5] as String?,
      citizenshipNumber: fields[6] as String?,
      district: fields[7] as String?,
      municipality: fields[8] as String?,
      ward: fields[9] as String?,
      tole: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocalUser obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.roleIndex)
      ..writeByte(4)
      ..write(obj.passwordHash)
      ..writeByte(5)
      ..write(obj.dob)
      ..writeByte(6)
      ..write(obj.citizenshipNumber)
      ..writeByte(7)
      ..write(obj.district)
      ..writeByte(8)
      ..write(obj.municipality)
      ..writeByte(9)
      ..write(obj.ward)
      ..writeByte(10)
      ..write(obj.tole)
      ..writeByte(11)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
