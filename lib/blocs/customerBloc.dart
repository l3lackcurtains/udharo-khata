import 'dart:async';

import 'package:simple_khata/database/customerRepo.dart';
import 'package:simple_khata/models/customer.dart';

class CustomerBloc {
  final _customerRepository = CustomerRepository();

  final _customerController = StreamController<List<Customer>>.broadcast();

  Stream<List<Customer>> get customers => _customerController.stream;

  CustomerBloc() {
    getCustomers();
  }

  getCustomers({String query}) async {
    final List<Customer> customers =
        await _customerRepository.getAllCustomers(query: query);
    _customerController.sink.add(customers);
    return customers;
  }

  getCustomer({String query}) async {
    final List<Customer> customers =
        await _customerRepository.getAllCustomers(query: query);
    _customerController.sink.add(customers);
  }

  addCustomer(Customer customer) async {
    await _customerRepository.insertCustomer(customer);
    getCustomers();
  }

  updateCustomer(Customer customer) async {
    await _customerRepository.updateCustomer(customer);
    getCustomers();
  }

  deleteCustomerById(int id) async {
    _customerRepository.deleteCustomerById(id);
    getCustomers();
  }

  dispose() {
    _customerController.close();
  }
}
