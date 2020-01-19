import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';


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
  String _contact;

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
      PermissionStatus permissionStatusWRITE = await _getPermissionWRITE();
      if (permissionStatus == PermissionStatus.granted
          && permissionStatusWRITE == PermissionStatus.granted) {
        print("Loading contacts...");
        var contacts = await ContactsService.getContacts(withThumbnails: false);
        setState(() {
          _contacts = contacts;
        });
        print('Contacts loaded successfully.\nIterating through contacts...');
        iterateThroughContacts();
        print('Iteration completed.\nSaving contact...');

        saveShared();

        print('Saving contact completed.');
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

  Future<PermissionStatus> _getPermissionWRITE() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.disabled) {
      Map<PermissionGroup, PermissionStatus> permisionStatus =
      await PermissionHandler()
          .requestPermissions([PermissionGroup.storage]);
      return permisionStatus[PermissionGroup.storage] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  //-------------------------- FILE CONTENT ------------------------------------

  void processingFunc(var element){
    //processing or transformation on the element

    String name = element.displayName;
    String temp = element.toMap()['phones'].toList()[0]['value'];

    _contact = '$name $temp';
    print(_contact);
  }

  void iterateThroughContacts(){
    _contacts.forEach((i) =>
        processingFunc(i)
    );
  }

  Future<File> getFile() async {
    String path = '/storage/emulated/0/exported_data.txt';
    print(path);
    return File(path);
  }

  void readShared() async {
    // Read the file
    File file = await getFile();
    _contact = await file.readAsString();
  }

  void saveShared() async {
    // Save to the file
    File file = await getFile();
    file.writeAsString(_contact);
  }

  void removeShared() async {
    // Save to the file
    File file = await getFile();
    file.writeAsString('');
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
              title: Text('Remove shared'),
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
                print("Removing contact...");
                removeShared();
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
