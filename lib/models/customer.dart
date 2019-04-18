class Customer {
  int id;
  String name;
  String phone;

  Customer({this.id, this.name, this.phone});

  factory Customer.fromDatabaseJson(Map<String, dynamic> data) =>
      Customer(id: data['id'], name: data['name'], phone: data['phone']);

  Map<String, dynamic> toDatabaseJson() => {
        'id': this.id,
        'name': this.name,
        'phone': this.phone,
      };
}
