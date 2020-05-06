// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final typeId = 0;

  @override
  User read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as int,
      guid: fields[1] as String,
      password: fields[2] as String,
      firstName: fields[3] as String,
      lastName: fields[4] as String,
      photo: fields[5] as String,
      email: fields[6] as String,
      isRemembered: fields[7] as bool,
      isAuthenticated: fields[8] as bool,
      accessToken: fields[9] as String,
      validity: fields[10] as int,
      companyID: fields[11] as int,
      companyGUID: fields[12] as String,
      companyName: fields[13] as String,
      companyEmail: fields[14] as String,
      companyLogo: fields[15] as String,
      companyPhone: fields[16] as String,
      companyFax: fields[17] as String,
      companyStreet: fields[18] as String,
      companyCity: fields[19] as String,
      companyState: fields[20] as String,
      companyZipCode: fields[21] as String,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.guid)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.firstName)
      ..writeByte(4)
      ..write(obj.lastName)
      ..writeByte(5)
      ..write(obj.photo)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.isRemembered)
      ..writeByte(8)
      ..write(obj.isAuthenticated)
      ..writeByte(9)
      ..write(obj.accessToken)
      ..writeByte(10)
      ..write(obj.validity)
      ..writeByte(11)
      ..write(obj.companyID)
      ..writeByte(12)
      ..write(obj.companyGUID)
      ..writeByte(13)
      ..write(obj.companyName)
      ..writeByte(14)
      ..write(obj.companyEmail)
      ..writeByte(15)
      ..write(obj.companyLogo)
      ..writeByte(16)
      ..write(obj.companyPhone)
      ..writeByte(17)
      ..write(obj.companyFax)
      ..writeByte(18)
      ..write(obj.companyStreet)
      ..writeByte(19)
      ..write(obj.companyCity)
      ..writeByte(20)
      ..write(obj.companyState)
      ..writeByte(21)
      ..write(obj.companyZipCode);
  }
}
