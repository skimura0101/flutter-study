import 'package:expiration_date_list/ItemModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'Database.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    Item item = new Item();
    item.catId = 1;
    item.catItemName = "egg";

    DBProvider.db.createItem(item);
    //DBに値を入れる


    //DBから値を取る
    var res;
    res = DBProvider.db.getItem(1);
    print("ああああ");
    print(res);
    print("いいいい");

    return MaterialApp(
      title: '賞味期限一覧',
      routes: <String, WidgetBuilder>{
        '/AddPage':(_) => new AddPage(),
      },
      home: ExpirationList(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class ExpirationList extends StatefulWidget {
  @override
  _ExpirationListState createState() => _ExpirationListState();
}

class _ExpirationListState extends State<ExpirationList> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('一覧'),
      ),
      body: new Center(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).pushNamed('/AddPage');
        },
      ),
    );
  }
}

class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {

  String _date = "未入力";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('日付入力'),
      ),
      body: new Column(
        children: <Widget>[
          new Container(
            width: MediaQuery.of(context).size.width,
            child: new TextField(
              decoration: InputDecoration(
                  labelText: "登録名称",
                  hintText: "例：ツナ缶",
                  icon: Icon(Icons.fastfood),
              ),
            ),
          ),
          new Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20.0),
            child: new FlatButton(
              child: Text(
                '${_date}'
              ),
              color: Colors.blue,
                textColor: Colors.white,
                onPressed: (){
                  DatePicker.showDatePicker(
                  context,
                  showTitleActions: true,
                  onChanged: (date) {},
                  onConfirm: (date) {
                    _date = DateFormat.yMMMd().format(date);
                    setState(() {
                    });
                    },
              );
            }
            ),
          ),
          new RaisedButton(
              onPressed: (){
                Navigator.of(context).pushNamed('/');
              },
              child: Text('登録'),
              )
        ],
      ),
      );
  }
}



