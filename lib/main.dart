import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

void main() => runApp(MaterialApp(
      home: Home(),
    ));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  var _newTodoController = TextEditingController();
  List _todoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: Text("Todo App"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            buildTopAction(),
            Expanded(
                child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                        padding: EdgeInsets.only(top: 10),
                        itemCount: _todoList.length,
                        itemBuilder: buildItem))),
          ],
        ),
      ),
    );
  }


  void _addTodo() {
    if (_newTodoController.text.trim().isEmpty) return;

    setState(() {
      _todoList.add({"title": _newTodoController.text, "ok": false});
      _newTodoController.text = "";
    });

    _saveFile();
  }

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _todoList = jsonDecode(data);
      });
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _todoList.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });

      _saveFile();
    });
  }

  Widget buildTopAction() {
    return Container(
      padding: EdgeInsets.fromLTRB(7, 1, 7, 1),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _newTodoController,
              decoration: InputDecoration(
                  labelText: "Nova tarefa",
                  labelStyle: TextStyle(color: Colors.blueAccent)),
            ),
          ),
          RaisedButton(
            color: Colors.blueAccent,
            child: Text(
              "ADD",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _addTodo,
          )
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        onChanged: (state) {
          setState(() {
            _todoList[index]["ok"] = state;
            _saveFile();
          });
        },
        value: _todoList[index]["ok"],
        title: Text(_todoList[index]["title"]),
        secondary: CircleAvatar(
          child: Icon(_todoList[index]["ok"] ? Icons.check : Icons.error),
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_todoList[index]);
          _lastRemovedPos = index;
          _todoList.removeAt(index);

          _saveFile();

          showSnackbar(context);
        });
      },
    );
  }

  void showSnackbar(BuildContext context) {
    
    var snack = SnackBar(
      content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
      action: SnackBarAction(
        label: "Desfazer",
        onPressed: () {
          setState(() {
            _todoList.insert(_lastRemovedPos, _lastRemoved);
            _saveFile();
          });
        },
      ),
      duration: Duration(seconds: 3),
    );
    Scaffold.of(context).removeCurrentSnackBar();
    Scaffold.of(context).showSnackBar(snack);
  }

  Future<File> _getFile() async {
    var directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveFile() async {
    var data = jsonEncode(_todoList);
    final file = await _getFile();

    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return "[]";
    }
  }
}
