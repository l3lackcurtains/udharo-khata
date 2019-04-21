import 'package:simple_khata/database/customerDao.dart';
import 'package:simple_khata/models/customer.dart';

class CustomerRepository {
  final customerDao = CustomerDao();

  Future getAllCustomers({String query}) =>
      customerDao.getCustomers(query: query);

  Future insertCustomer(Customer customer) =>
      customerDao.createCustomer(customer);

  Future updateCustomer(Customer customer) =>
      customerDao.updateCustomer(customer);

  Future deleteCustomerById(int id) => customerDao.deleteCustomer(id);
}
