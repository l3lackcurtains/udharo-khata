import 'dart:async';

import 'package:simple_khata/database/customerRepo.dart';
import 'package:simple_khata/models/customer.dart';

class CustomerBloc {
  final _customerRepository = CustomerRepository();

  final _customersController = StreamController<List<Customer>>.broadcast();

  Stream<List<Customer>> get customers => _customersController.stream;

  CustomerBloc() {
    getCustomers();
  }

  getCustomers({String query, int page}) async {
    final List<Customer> customers =
        await _customerRepository.getAllCustomers(query: query, page: page);
    _customersController.sink.add(customers);
    return customers;
  }

  getCustomer(int id) async {
    final Customer customer = await _customerRepository.getCustomer(id);
    return customer;
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
    _customersController.close();
  }
}
