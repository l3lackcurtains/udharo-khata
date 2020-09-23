class Customer {
  int id;
  int businessId;
  String name;
  String phone;
  String address;
  String image;

  Customer(
      {this.id,
      this.businessId,
      this.name,
      this.phone,
      this.address,
      this.image});

  factory Customer.fromDatabaseJson(Map<String, dynamic> data) => Customer(
      id: data['id'],
      businessId: data['businessId'],
      name: data['name'],
      phone: data['phone'],
      address: data['address'],
      image: data['image']);

  Map<String, dynamic> toDatabaseJson() => {
        'id': this.id,
        'businessId': this.businessId,
        'name': this.name,
        'phone': this.phone,
        'address': this.address,
        'image': this.image
      };
}
