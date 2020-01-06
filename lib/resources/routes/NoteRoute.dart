import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../storages/ContentStorage.dart';
import 'package:flushbar/flushbar.dart';


//==============================================================================
//--------------------------- INITIALIZATION -----------------------------------
// FlatApp class object, operating algorithms and behaviour
class FlatApp extends StatefulWidget {
  //---------------------------- VARIABLES -------------------------------------

  // content storage object
  final ContentStorage storageContent;

  FlatApp({Key key,
    @required this.storageContent
  }) : super(key: key);

  @override
  _FlatAppMainState createState() => _FlatAppMainState();
}

//==============================================================================
//---------------------------- WIDGET ------------------------------------------
class _FlatAppMainState extends State<FlatApp> {

  //---------------------------- VARIABLES -------------------------------------
  // var to store text from notes
  String _content;

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final _textController = TextEditingController();

  //--------------------------- INITIALIZATION ---------------------------------
  // application init
  @override
  void initState() {
    super.initState();

    // load content to _content var
    _loadContent();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the listeners.
    _textController.dispose();
    super.dispose();
  }

  // change content var, but not file
  void _changeContent() {
    setState(() {
      _content = _textController.text;
    });
  }

  //-------------------------- FILE CONTENT ------------------------------------
  // load content from file
  void _loadContent(){
    try {
      widget.storageContent.readContent('note_content').then((String value) {
          setState(() {
              _content = value;
              _textController.text = value;
            }
          );
        }
      );
    } catch (e){
      print("error during file loading\n$e");
    }
  }

  // save content to file
  void _saveContent() {
    // save to content var
    _changeContent();

    // save content to file
    widget.storageContent.writeContent('note_content', _content);
  }

  //---------------------------- MAIN WIDGET -----------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlatApp: note editor'),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () =>
                SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: new SingleChildScrollView(
          scrollDirection: Axis.vertical,
          reverse: true,
          child: Column(
            children: <Widget>[
              Text(
                'Note content:',
              ),
              Text(
                '$_content',
                softWrap: true,
              ),
              Text(
                'Edit note:',
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                // add multiline text field, with no max lines
                // (change null to value if needed)
                maxLines: null,
                controller: _textController,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.file_download),
            title: Text('Load'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            title: Text('Password'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            title: Text('Save'),
          ),
        ], // operate NavigationBar
        onTap: (index) {
          // operate NavigationBar
          switch (index) {
            case 0:
              // LOAD CONTENT --------------------------------------------------
              _loadContent();
              Flushbar(
                title: "Loaded",
                message: "Content loaded successfully.",
                duration: Duration(seconds: 5),
              )
                ..show(context);
              break;
            case 1:
            // PASSWORD ROUTE --------------------------------------------------
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PasswordRoute(
                    passwordStorage: PasswordStorage()
                  )
                ),
              );
              break;
            case 2:
              // SAVE CONTENT --------------------------------------------------
              _saveContent();
              Flushbar(
                title: "Saved",
                message: "Content saved successfully.",
                duration: Duration(seconds: 5),
              )
                ..show(context);
              break;
          // -------------------------------------------------------------------
          }
        }
      ),
    );
  }
}
//==============================================================================
