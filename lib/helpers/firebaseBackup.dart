import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:udharokhata/blocs/businessBloc.dart';
import 'package:udharokhata/blocs/customerBloc.dart';
import 'package:udharokhata/blocs/transactionBloc.dart';
import 'package:udharokhata/models/business.dart';
import 'package:udharokhata/models/customer.dart';
import 'package:udharokhata/models/transaction.dart' as TransactionModel;

final firestoreInstance = Firestore.instance;

class FirebaseBackup {
  final CustomerBloc customerBloc = CustomerBloc();
  final TransactionBloc transactionBloc = TransactionBloc();
  final BusinessBloc businessBloc = BusinessBloc();

  void backupAllData() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    List<Customer> customersList = await customerBloc.getCustomers();
    List<TransactionModel.Transaction> transactionsList =
        await transactionBloc.getTransactions();
    Business businessInfo = await businessBloc.getBusiness(0);

    firestoreInstance
        .collection("udharoKhata")
        .document(firebaseUser.uid)
        .collection("business")
        .document(businessInfo.id.toString())
        .setData(businessInfo.toDatabaseJson())
        .then((value) {
      print("Backed up business Info.");
    });

    customersList.forEach((customer) {
      firestoreInstance
          .collection("udharoKhata")
          .document(firebaseUser.uid)
          .collection("customers")
          .document(customer.id.toString())
          .setData(customer.toDatabaseJson())
          .then((value) {
        print("Customer backup");
      });
    });

    transactionsList.forEach((transcation) {
      firestoreInstance
          .collection("udharoKhata")
          .document(firebaseUser.uid)
          .collection("transactions")
          .document(transcation.id.toString())
          .setData(transcation.toDatabaseJson())
          .then((value) {
        print("Transaction backup");
      });
    });
  }

  void restoreAllData() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    List<Customer> customersList = await customerBloc.getCustomers();
    List<TransactionModel.Transaction> transactionsList =
        await transactionBloc.getTransactions();
    // Delete all customers
    customersList.forEach((customer) async {
      await customerBloc.deleteCustomerById(customer.id);
    });

    // Delete all transactions
    transactionsList.forEach((transaction) async {
      await transactionBloc.deleteTransactionById(transaction.id);
    });

    firestoreInstance
        .collection("udharoKhata")
        .document(firebaseUser.uid)
        .collection("business")
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((result) async {
        Business business = Business.fromDatabaseJson(result.data);
        await businessBloc.updateBusiness(business);
      });
      print("Business restored");
    });

    firestoreInstance
        .collection("udharoKhata")
        .document(firebaseUser.uid)
        .collection("customers")
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((result) async {
        Customer customer = Customer.fromDatabaseJson(result.data);
        await customerBloc.addCustomer(customer);
      });
      print("Customers restored");
    });

    firestoreInstance
        .collection("udharoKhata")
        .document(firebaseUser.uid)
        .collection("transactions")
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((result) async {
        TransactionModel.Transaction transaction =
            TransactionModel.Transaction.fromDatabaseJson(result.data);
        await transactionBloc.addTransaction(transaction);
      });
      print("Transactions restored");
    });
  }
}
