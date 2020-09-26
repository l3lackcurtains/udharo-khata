import 'dart:typed_data';

class UserContact {
  int id;
  String name;
  Uint8List avatar;
  String phone;

  UserContact({
    this.id,
    this.name,
    this.avatar,
    this.phone,
  });
}
