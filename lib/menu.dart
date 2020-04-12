import 'package:flutter/material.dart';
import 'note.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:flame/util.dart';
import 'package:flame/flame.dart';
import 'dart:io';
import 'dart:collection';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_document_picker/flutter_document_picker.dart';
//import 'package:file_picker/file_picker.dart';
import 'package:file_picker/file_picker.dart';
//import 'package:clone_hero_mobile/main.dart';
import 'package:clone_hero_mobile/game.dart';


class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainScreenState();
  }
}

class MainScreenState extends State<StatefulWidget> {

  SharedPreferences prefs;
  double musicOffset;
  double noteSpeedDivider;
  String folderPath;

  //int difficultyIndex = 3;
  List<String> difficultyOptions = ["Easy", "Medium", "Hard", "Expert"]; // TODO make these constant case? CONSTANT_VAL
  String difficultyChoice = "Expert";
  //int instrumentIndex = 0;
  List<String> instrumentOptions = ["Guitar", "DoubleBass"];
  String instrumentChoice = "Guitar";

  @override
  void initState() {
    super.initState();
    _setInitialValues();
  }

  Future<Null> _setInitialValues() async { // no return type? from https://flutter.dev/docs/cookbook/persistence/key-value
    print("_setInitialValues()");
    //SharedPreferences prefs = sp;//await SharedPreferences.getInstance(); // TODO does this usage of sp work?
    prefs = await SharedPreferences.getInstance();
    setState((){
      musicOffset = prefs.getDouble("musicOffset") ?? 0; // Set to default values if no pref value has been set
      noteSpeedDivider = prefs.getDouble("noteSpeedDivider") ?? 0;
      difficultyChoice = prefs.getString("difficultyChoice") ?? difficultyOptions[3];
      instrumentChoice = prefs.getString("instrumentChoice") ?? instrumentOptions[0];
      folderPath = prefs.getString("folderPath") ?? "none";
    });
//    musicOffset = await _getDoublePref("musicOffset", prefs);
//    noteSpeedDivider = await _getDoublePref("noteSpeedDivider", prefs);
//    difficultyIndex = (await _getDoublePref("difficulty", prefs)).toInt();

//    String s = prefs.getString("folderPath");
//    if(s == null){
//      folderDisplay = "none";
//    } else {
//      folderDisplay = s;
//    }

  }

  @override
  Widget build(BuildContext context) {
//    return new FutureBuilder<Null>(
//      future: _setInitialValues(), // async work
//      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
//        switch (snapshot.connectionState) {
//          case ConnectionState.waiting:
//          //return new Text('Loading....');
//            return new CircularProgressIndicator();
//          default:
//            if (snapshot.hasError)
//              return new Text('Error: ${snapshot.error}');
//            else
//              //return new Text('Result: ${snapshot.data}');
//              return _mainScreen(context);
//        }
//      },
//    );
    return _mainScreen(context);
  }

  Widget _doubleEditor(String key, TextEditingController con){
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            key,
            style: TextStyle(color: Colors.black),
          ),
          Padding(padding: EdgeInsets.all(8.0),),
          //Spacer(), // TODO is spacer good?
          Flexible(
            child: TextField(
              maxLength: 10,
              keyboardType: TextInputType.number,
              style: new TextStyle(color: Colors.black),
//              decoration: InputDecoration(
//                hintText: key,
//                fillColor: Colors.redAccent,
//              ),
              controller: con,
              onChanged: (val) {
              //_setDoublePref(key, double.parse(val), prefs);
                setState(() {
                  // does the local variable need to be updated here?
                  prefs.setDouble(key, double.parse(val));
                });

              },
            ),
          ),

        ],
      )
    );
  }

//  Widget _dropdownEditor(List<String> options){
//    return new DropdownButton<String>(
//      items: options.map((String value) {
//        return new DropdownMenuItem<String>(
//          value: value,
//          child: new Text(value),
//        );
//      }).toList(),
//      onChanged: (String newValue) {
//        setState(() {
//          int index = options.indexOf(newValue);
//          print("dropdown changed to index $index");
//        });
//
//
//      },
//    );
//  }

  Widget _mainScreen(BuildContext context) {
    //print("build. mo: $musicOffset nsd: $noteSpeedDivider diff: $difficulty");
    TextEditingController moc = TextEditingController(text: musicOffset.toString());
    TextEditingController nsdc = TextEditingController(text: noteSpeedDivider.toString());
    //TextEditingController ssmc = TextEditingController(text: songSpeedMultiplier.toString());
    //TextEditingController dc = TextEditingController(text: difficulty.toString());

    return MaterialApp(
      title: "CloneHeroMobile",
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("CloneHeroMobile"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RaisedButton(
              child: Text("Pick a file"),
              onPressed: () {
                _pickFile();
                setState(() {});
              },
            ),
            Text(folderPath ?? "none178"),

            _doubleEditor("musicOffset", moc),
            //_valueEditor("songSpeedMultiplier", ssmc),
            _doubleEditor("noteSpeedDivider", nsdc),
            //_valueEditor("difficulty", dc),

            DropdownButton<String>(
              value: difficultyChoice,
              items: difficultyOptions.map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              onChanged: (String val) {
                setState(() {
//                  int index = difficultyOptions.indexOf(newValue);
//                  print("dropdown changed to index $index");
                    difficultyChoice = val;
                    prefs.setString("difficultyChoice", val);
                });
              },
            ),
            DropdownButton<String>(
              value: instrumentChoice,
              items: instrumentOptions.map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              onChanged: (String val) {
                setState(() {
//                  int index = difficultyOptions.indexOf(newValue);
//                  print("dropdown changed to index $index");
                  instrumentChoice = val;
                  prefs.setString("instrumentChoice", val);
                });
              },
            ),
            //_dropdownEditor(<String>["Easy", "Medium", "Hard", "Expert"]),
            //_dropdownEditor(<String>["Guitar", "Bass"]),

            Divider(),
            RaisedButton(
              child: Text("Start game"),
              onPressed: () {
                _startGame();
              },
            ),
          ],
        ),
      )
    );

  }

//  Future<double> _getDoublePref(String key, SharedPreferences sp) async {
//    //SharedPreferences prefs = await SharedPreferences.getInstance();
//    double d = sp.getDouble(key);
//    if(d == null){
//      return -1;
//    }
//    return d;
//  }
//
//  void _setDoublePref(String key, double val, SharedPreferences sp) async {
//    //SharedPreferences prefs = await SharedPreferences.getInstance();
//    sp.setDouble(key, val);
//    print("setting prefval $key to $val");
//  }

  /// Updates [folderPath] and the [folderPath] preference value based on user selection.
  void _pickFile() async {
//    Scaffold.of(context).showSnackBar(new SnackBar(
//      content: new Text("Pick a .chart file"),
//    ));

    String path = await FilePicker.getFilePath(type: FileType.any);
    if(!path.contains(".chart")){
      print("ERROR: did not pick a .chart file"); // TODO add proper error catching, make the user pick again? Use a while loop?
    }

    setState(() {
      String p = path.replaceAll(RegExp(r"[a-zA-Z0-9]+.chart$"), "");
      prefs.setString("folderPath", p);
      folderPath = p;
    });

    print("folderPath: ${prefs.getString("folderPath")}");
  }

  /// Returns a list of sound files in the given folder. They all get played at the same time to create the full audio.
  Future<List<String>> _getSoundNames(folderPath) async {
    //SharedPreferences prefs = sp; //await SharedPreferences.getInstance();
    //String folderPath = prefs.getString("folderPath");

    List<String> names = List<String>();
    for(String s in ["guitar", "rhythm", "song"]){
      //Flame.audio.load("$folderPath/$s.ogg");
      String name = "$folderPath$s.ogg";
      if(File(name).existsSync())
        names.add(name);
    }
    return names;
  }

  /// Returns a [Map] with each entry corresponding to a section in the song's .chart file.
  Future<Map<String, List<String>>> _getChartMap(String folderPath) async {
    //SharedPreferences prefs = sp;//await SharedPreferences.getInstance();
    //String folderPath = prefs.getString("folderPath");
    //String notesPath = folderPath + "/" + prefs.getString("difficulty") + ".csv";
    String notesPath = folderPath + "/notes.chart";

    //int difficultyInt = prefs.getDouble("difficulty") as int;
    //String difficultyString = ["Easy", "Medium", "Hard", "Expert"][difficultyInt] + "Single"; // TODO add bass functionality ("EasyDoubleBass")

    //print("@@reading notes from file: $notesPath");
    File f = File(notesPath);
    String read = await f.readAsString();
    List<String> lines = read.split("\n");
    //print("@@read ${lines.length} lines from file");

    //List<Note> allNotes = List<Note>();
    Map<String, List<String>> chartMap = HashMap();
    String addName = null;
    List<String> addList = null;

    for(String lineRaw in lines) {
      String line = lineRaw.trim();
      if (line.contains("{") || line.contains("}")) { // This line is empty except for a curly bracket indicating a new section in the file
        continue;
      } else if (line.contains("[")) {
        if (addName != null) {
          chartMap[addName] = addList;
//          print("adding to map:");
//          print("an: $addName");
//          print("al: $addList");
        }
        addName = line.replaceAll("[", "").replaceAll("]", "");
        addList = List<String>();
      } else {
        addList.add(line);
      }
    }
    chartMap[addName] = addList;
    //print("cm: ${chartMap["Song"]}");

    return chartMap;
  }

  /// Returns the "Song" section from the map of the song's .chart file in a dictionary split by the equals signs.
  Map<String, String> _getSongInfo(Map<String, List<String>> chartMap){
    Map<String, String> ret = Map();
    for(String lineRaw in chartMap["Song"]){
      String line = lineRaw.trim();
      List<String> l = line.split("="); // Split keys and values by equals signs
      ret[l[0].trim()] = l[1].trim();
    }
    return ret;
  }

  /// Returns either tempo changes or time changes found in the map of the song's .chart file (B for tempo change, TS for time change)
  List<List<int>> _getSyncTrackInfo(Map<String, List<String>> chartMap, String lineTargetType){
    List<List<int>> ret = List();
    for(String lineRaw in chartMap["SyncTrack"]){
      String line = lineRaw.trim();
      if(line.contains(lineTargetType)){ // lineTargetType is either B or TS (tempo change or time change)
        List<String> l = line.split(" ");
        ret.add( [int.parse(l[0]), int.parse(l[3])]);
      }
    }
    return ret;
  }

  /// Returns a list of notes from a song's .chart file according to the difficulty and instrument
  List<Note> _getNotes(Map<String, List<String>> chartMap, String diffString, String instString, int resolution){ // TODO remove resolution
    List<Note> ret = List();
    String chartSectionString = (diffString+instString).replaceAll("Guitar", "Single");
    for(String lineRaw in chartMap[chartSectionString]){
      String line = lineRaw.trim();
      if(line.contains("N")){
        List<String> l = line.split(" ");
        if(int.parse(l[3]) < 5)
          ret.add(Note(int.parse(l[0]), int.parse(l[3]), int.parse(l[4]), resolution));
      }
    }
    return ret;
  }


  void _startGame() async {
    var d = await Util().initialDimensions();
    var dimensions = Size(d.width, d.height + 30);

    MyGame.dimensions = dimensions; // TODO move this down or will it break?
    MyGame.columnWidth = dimensions.width ~/ 5;

    Map<String, List<String>> chartMap = await _getChartMap(folderPath);
    Map<String, String> songInfo = _getSongInfo(chartMap);
    List<List<int>> tempoChanges = _getSyncTrackInfo(chartMap, "B");
    List<List<int>> timeChanges = _getSyncTrackInfo(chartMap, "TS");

    int resolution = int.parse(songInfo["Resolution"]);
    int offset = int.parse(songInfo["Offset"]);
    //int difficultyInt = prefs.getDouble("difficulty").toInt();
    //String difficultyString = ["Easy", "Medium", "Hard", "Expert"][difficultyInt] + "Single" FIX;
    List<Note> allNotes = _getNotes(chartMap, difficultyChoice, instrumentChoice, resolution); // TODO add star power parsing. Does skipping star power notes leave out real notes in the song?
    List<String> allSounds = await _getSoundNames(folderPath);

    //MyGame.noteSpeed = dimensions.height/1100;
    MyGame.noteSpeed = 0.45;// / resolution; //0.0004; //prefs.getDouble("noteSpeedDivider"); // should be around 1.5 - pixels per beat
    //MyGame.heightBeats = dimensions.height * MyGame.noteSpeed * resolution;
    MyGame.heightBeats = (dimensions.height / MyGame.noteSpeed); // Height of the full screen in beats

    double targetScreenPercentage = 0.8;
    MyGame.targetHeight = (MyGame.dimensions.height * targetScreenPercentage).toInt();
    MyGame.targetBeats = MyGame.heightBeats * targetScreenPercentage;
    //MyGame.targetBeats = MyGame.targetHeight * MyGame.noteSpeed * resolution;

    //print("heightBeats/res: ${MyGame.heightBeats/resolution}, targetBeats/res: ${MyGame.targetBeats/resolution}, res: $resolution");
    //MyGame.startOffsetMusic = prefs.getDouble("musicOffset"); //-1100
    //MyGame.songSpeedMultiplier = prefs.getDouble("songSpeedMultiplier");
    //MyGame.startOffsetTargetDist = (dimensions.height-MyGame.targetOffset)/MyGame.noteSpeed;

    Flame.util.fullScreen(); // can this go in game.dart?
    runApp(MyGame(allSounds, allNotes, tempoChanges, timeChanges, resolution, offset).widget);
  }
}
