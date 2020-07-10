import 'package:expiration_date_list/ItemModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'Database.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

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

  var dateFormat = new DateFormat.yMMMd();
  static int _cautionDate = 3;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('一覧'),
      ),
      body: FutureBuilder<List<Item>>(
        future: DBProvider.db.getAllItems(),
        builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot){
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index){
               Item item = snapshot.data[index];
              return Dismissible(
                  key: Key(index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                      alignment: Alignment.centerLeft,
                      color: Colors.redAccent[700]
                  ),
                  onDismissed: (direction){
                    setState(() {
                      DBProvider.db.deleteItem(item.id);
                      snapshot.data.removeAt(index);
                    });
                    //右から左にスワイプした時にメッセージを表示する
                    if (direction == DismissDirection.endToStart){
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text("削除しました"))
                      );}
                  },
                child: listTile(item)
                );
            },
            );
          }
            return new Center(child: Text("表示するデータがありません"));
        }
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.of(context).pushNamed('/AddPage'); //日付入力画面に遷移する
        },
      ),
    );
  }

  //背景色の表示わけメソッド
  Widget listTile(Item item){

    Color _backgroundColor = Colors.white; //通常は白

    //賞味期限が今日より前だったら背景をグレーにする
    if(item.expirationDate.isBefore(DateTime.now())){
      _backgroundColor = Colors.grey;

      //賞味期限が今日から3日以内だったら背景を黄色にする
    } else if(betweenCautionDate(item.expirationDate)){
      _backgroundColor = Colors.yellow;
    }
    return new Container(
        decoration: new BoxDecoration(
            color: _backgroundColor
        ),
        child: new ListTile(
          title: Text(item.itemName),
          leading: Text(dateFormat.format(item.expirationDate)),
        )
    );
  }

  //協調すべき日付か判定するメソッド
  bool betweenCautionDate(DateTime expirationDate){
    return expirationDate.subtract(new Duration(days: _cautionDate)).isBefore(DateTime.now());
  }

}

/*
 *日付入力画面。
 */
class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {

  // Formウィジェット内の各フォームを識別するためのキーを設定
  final _formKey = GlobalKey<FormState>();

  String _itemName;
  DateTime _expirationDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('日付入力'),
      ),
      body: new Form(
        key: _formKey,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            new TextFormField(
                decoration: InputDecoration(
                    labelText: "登録名称",
                    hintText: "例：ツナ缶",
                    icon: Icon(Icons.fastfood)
            ),
              validator: (value){
                if (value.isEmpty) { //必須精査
                  return '入力してください';
                } else if(value.length > 25) { //文字数精査
                  return '25字以内で入力してください';
                }
                return null;
              },
              onChanged: (value){ //25文字以上入力された時点で警告文を出す
                  if(value.length > 25) {
                    _formKey.currentState.validate();
                  }
              },
              onSaved: (value){
                  _itemName = value;
              },
            ),
            new SizedBox(
              width: 400,
              height: 50,
              child: new FlatButton(
                onPressed: (){
                  DatePicker.showDatePicker(
                      context,
                      showTitleActions: true,
                      onConfirm: (date){
                        setState(() {
                          _expirationDate = date;
                        });
                      }
                      );
                  },
                child: new Text(
                    DateFormat.yMMMd().format(_expirationDate),
                  style: TextStyle(fontSize: 25.0),
                ),
              ),
            ),
          new RaisedButton(
            onPressed: (){
              if (_formKey.currentState.validate()) {
                _submission();
              }
              },
            child: Text('登録'),
          )
          ],
        ),
      )
    );
  }

  void _submission() {
    this._formKey.currentState.save(); //onSaved内に記述された処理が実行される

    if((_expirationDate != null) && (_itemName.isNotEmpty )) {
      Item item = Item(
          id: null, itemName: _itemName, expirationDate: _expirationDate);
      DBProvider.db.createItem(item); // SQliteへの登録処理
      Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false); //一覧遷移時にbackさせない
    }
  }
}
