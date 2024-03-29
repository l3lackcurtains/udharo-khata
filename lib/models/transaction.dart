import 'package:udharokhata/models/customer.dart';

class Transaction {
  int id;
  int businessId;
  int uid;
  String ttype;
  double amount;
  String comment;
  Customer customer;
  DateTime date;
  String attachment;

  Transaction(
      {this.id,
      this.businessId,
      this.uid,
      this.ttype,
      this.amount,
      this.comment,
      this.customer,
      this.date,
      this.attachment});

  factory Transaction.fromDatabaseJson(Map<String, dynamic> data) =>
      Transaction(
          id: data['id'],
          businessId: data['businessId'],
          uid: data['uid'],
          ttype: data['ttype'],
          amount: data['amount'],
          comment: data['comment'],
          date: DateTime.parse(data['date']),
          attachment: data['attachment']);

  Map<String, dynamic> toDatabaseJson() => {
        'id': this.id,
        'businessId': this.businessId,
        'uid': this.uid,
        'ttype': this.ttype,
        'amount': this.amount,
        'comment': this.comment,
        'date': this.date.toString(),
        'attachment': this.attachment
      };
}
