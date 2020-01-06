import 'package:flutter_secure_storage/flutter_secure_storage.dart';


//==============================================================================
// Class containing password keys manipulation procedures
class SecureStorage{

  // Create storage
  final _storage = new FlutterSecureStorage();

  // Read key value - REPAIR - NEEDS TO RETURN STRING, NOT FUTURE STRING
  Future<String> readKey(key) async {
    try {
      // Read value
      return await _storage.read(key: key);

    } catch (e) {
      // If encountering an error, return 0
      return "error while getting key: $key";
    }
  }

  // Write value
  void write(key, value) async {
    await _storage.write(key: key, value: value);
  }
}
//==============================================================================
