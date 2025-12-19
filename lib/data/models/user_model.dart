import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.uid,
    required super.nama,
    required super.username,
    required super.nim,
    required super.programStudi,
    required super.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nama': nama,
      'username': username,
      'nim': nim,
      'program_studi': programStudi,
      'email': email,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      nama: json['nama'],
      username: json['username'],
      nim: json['nim'],
      programStudi: json['program_studi'],
      email: json['email'],
    );
  }
}
