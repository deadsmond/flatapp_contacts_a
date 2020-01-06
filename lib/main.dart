import 'package:flutter/material.dart';
import 'resources/routes/LoginRoute.dart';
import 'resources/storages/PasswordStorage.dart';
import 'resources/storages/ContentStorage.dart';


// main app init
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlatApp: contacts',
      home: ContactsRoute(
          storageContent: ContentStorage()
      ),
    ),
  );
}
