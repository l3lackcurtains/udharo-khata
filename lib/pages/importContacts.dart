import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udharokhata/blocs/customerBloc.dart';
import 'package:udharokhata/models/UserContact.dart';
import 'package:udharokhata/models/customer.dart';

import '../main.dart';

class ImportContacts extends StatefulWidget {
  ImportContacts({Key key}) : super(key: key);
  @override
  _ImportContactsState createState() => _ImportContactsState();
}

class _ImportContactsState extends State<ImportContacts> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  bool _hasPermission = false;
  final CustomerBloc _customerBloc = CustomerBloc();

  List<UserContact> contactsList = [];

  List<int> contactsIndexToAdd = [];

  @override
  void initState() {
    super.initState();
    _askPermissions();
  }

  _loadContacts() async {
    Iterable<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: true);

    List<UserContact> contactsListTemp = [];
    contacts.forEach((contact) async {
      var mobilenum = contact.phones.toList();
      if (mobilenum.length > 0) {
        var userContact = UserContact(
            name: contact.displayName,
            phone: mobilenum[0].value.toString(),
            avatar: contact.avatar);
        contactsListTemp.add(userContact);
      }
    });

    setState(() {
      contactsList = contactsListTemp;
    });
  }

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus;
    while (permissionStatus != PermissionStatus.granted) {
      try {
        permissionStatus = await _getContactPermission();
        if (permissionStatus != PermissionStatus.granted) {
          setState(() {
            _hasPermission = false;
          });
          _hasPermission = false;
          _handleInvalidPermissions(permissionStatus);
        } else {
          setState(() {
            _hasPermission = true;
          });
        }
      } catch (e) {
        if (await showPlatformDialog(
            context: context,
            builder: (context) {
              return PlatformAlertDialog(
                title: Text('Contact Permissions'),
                content: Text(
                    'We are having problems retrieving permissions.  Would you like to '
                    'open the app settings to fix?'),
                actions: [
                  PlatformDialogAction(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  PlatformDialogAction(
                    child: Text('Settings'),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              );
            })) {
          await openAppSettings();
        }
      }
    }

    if (_hasPermission) {
      _loadContacts();
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    final status = await Permission.contacts.status;
    if (!status.isGranted) {
      final result = await Permission.contacts.request();
      return result ?? PermissionStatus.undetermined;
    } else {
      return status;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw PlatformException(
          code: 'PERMISSION_DENIED',
          message: 'Access to location data denied',
          details: null);
    } else if (permissionStatus == PermissionStatus.restricted) {
      throw PlatformException(
          code: 'PERMISSION_DISABLED',
          message: 'Location data is not available on device',
          details: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Add Company',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          importContacts();
        },
        icon: Icon(Icons.check),
        label: Text('Import Contacts'),
      ),
      body: !_hasPermission
          ? Center(child: PlatformCircularProgressIndicator())
          : Container(
              child: Form(
                key: _formKey,
                child: ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: contactsList.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext ctx, index) {
                      UserContact contact = contactsList[index];

                      return Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 4),
                        padding: EdgeInsets.all(4),
                        child: ListTile(
                          leading: Checkbox(
                            value: contactsIndexToAdd.contains(index),
                            onChanged: (bool value) {
                              setState(() {
                                if (value &&
                                    !contactsIndexToAdd.contains(index)) {
                                  contactsIndexToAdd.add(index);
                                } else {
                                  contactsIndexToAdd.remove(index);
                                }
                              });
                            },
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                child: ClipOval(
                                  child: Container(
                                    color: Colors.grey,
                                    child: Image.memory(
                                        Base64Decoder().convert(
                                            base64Encode(contact.avatar)),
                                        height: 54,
                                        width: 54,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(contact.name),
                                  SizedBox(height: 8),
                                  Text(
                                    contact.phone,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ),
    );
  }

  void importContacts() async {
    List<UserContact> selectedUserContacts = [];

    contactsList.forEach((contact) {
      int index = contactsList.indexOf(contact);
      if (contactsIndexToAdd.contains(index)) {
        selectedUserContacts.add(contact);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    int selectedBusinessId = prefs.getInt('selected_business');

    selectedUserContacts.forEach((contact) async {
      Customer customer = Customer();
      customer.name = contact.name;
      customer.phone = contact.phone;
      customer.image = base64Encode(contact.avatar);
      customer.businessId = selectedBusinessId;
      await _customerBloc.addCustomer(customer);
    });

    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
