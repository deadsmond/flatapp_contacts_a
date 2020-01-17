import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';


//==============================================================================
// class containing storage procedures
class SharedStorage {
  SharedPreferences prefs;



  void removeShared(String key) async {
    checkIfIs(key).then((check){
      if(check){
        //Remove String
        prefs.remove(key);
      }
    });
  }

  Future<bool> checkIfIs(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
}
//==============================================================================