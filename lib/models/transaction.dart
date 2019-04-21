class Transaction {
  int id;
  int uid;
  String ttype;
  String amount;
  String comment;

  Transaction({this.id, this.uid, this.ttype, this.amount, this.comment});

  factory Transaction.fromDatabaseJson(Map<String, dynamic> data) =>
      Transaction(
          id: data['id'],
          uid: data['uid'],
          ttype: data['ttype'],
          amount: data['amount'],
          comment: data['comment']);

  Map<String, dynamic> toDatabaseJson() => {
        'id': this.id,
        'uid': this.uid,
        'ttype': this.ttype,
        'amount': this.amount,
        'comment': this.comment,
      };
}
