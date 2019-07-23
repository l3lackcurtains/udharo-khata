import 'dart:io';

class Customer {
  int id;
  String name;
  String phone;
  String address;
  File image;

  Customer({this.id, this.name, this.phone, this.address, this.image});

  factory Customer.fromDatabaseJson(Map<String, dynamic> data) => Customer(
      id: data['id'],
      name: data['name'],
      phone: data['phone'],
      address: data['address']);

  Map<String, dynamic> toDatabaseJson() => {
        'id': this.id,
        'name': this.name,
        'phone': this.phone,
        'address': this.address
      };
}
