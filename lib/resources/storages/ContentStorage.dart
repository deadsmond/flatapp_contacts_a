import 'SecureStorage.dart';
import 'dart:async';


//==============================================================================
// class containing storage procedures
class ContentStorage {

  // Initialize storage access
  static final _storage = new SecureStorage();

  // read some data from the file
  Future<String> readContent(String _key) async {
    // get content from storage
    return await _storage.readKey(_key);
  }

  // write some data to the file
  Future<void> writeContent(String _key, String content) async {
    try {
      _storage.write(_key, content);
    } catch (e) {
      // If encountering an error, return error
      print("error occurred during writing content in Content Storage");
      return e;
    }
  }

  // clear file content - separate function for cleaner flow
  Future<void> clear(String _key) async {
    try {
      writeContent(_key, '');
    } catch (e) {
      // If encountering an error, return error
      return e;
    }
  }
}
//==============================================================================
