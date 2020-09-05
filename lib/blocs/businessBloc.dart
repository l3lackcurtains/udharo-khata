import 'dart:async';

import 'package:udharokhata/database/businessRepo.dart';
import 'package:udharokhata/models/business.dart';

class BusinessBloc {
  final _businessRepository = BusinessRepository();

  final _businesssController = StreamController<List<Business>>.broadcast();

  Stream<List<Business>> get businesss => _businesssController.stream;

  BusinessBloc() {
    getBusinesss();
  }

  getBusinesss({String query, int page}) async {
    final List<Business> businesss =
        await _businessRepository.getAllBusinesss(query: query, page: page);
    _businesssController.sink.add(businesss);
    return businesss;
  }

  getBusiness(int id) async {
    final Business business = await _businessRepository.getBusiness(id);
    return business;
  }

  addBusiness(Business business) async {
    await _businessRepository.insertBusiness(business);
    getBusinesss();
  }

  updateBusiness(Business business) async {
    await _businessRepository.updateBusiness(business);
    getBusinesss();
  }

  deleteBusinessById(int id) async {
    _businessRepository.deleteBusinessById(id);
    getBusinesss();
  }

  dispose() {
    _businesssController.close();
  }
}
