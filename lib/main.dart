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
            Container(
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
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemCount: _todoList.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    onChanged: (state) {
                      setState(() {
                        _todoList[index]["ok"] = state;
                        _saveFile();
                      });
                    },
                    value: _todoList[index]["ok"],
                    title: Text(_todoList[index]["title"]),
                    secondary: CircleAvatar(
                      child: Icon(
                          _todoList[index]["ok"] ? Icons.check : Icons.error),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
