import 'package:flutter/material.dart';
import '../../../domain/repositories/auth_repository.dart';

class AdminViewModel
    extends
        ChangeNotifier {
  final AuthRepository repository;
  AdminViewModel(
    this.repository,
  );

  Future<
    void
  >
  createUser({
    required String email,
    required String role,
    required Map<
      String,
      dynamic
    >
    data,
  }) async {
    await repository.createUserByAdmin(
      email: email,
      password: '123456',
      role: role,
      data: data,
    );
  }
}
