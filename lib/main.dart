import 'package:expiration_date_list/ItemModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'Database.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    //DB登録テスト用のsetterたち
//    Item item = new Item();
//    item.catId = 1;
//    item.catItemName = "apple";
//    //item.catExpirationDate = "7月8日";
//    DBProvider.db.createItem(item);

    //不要データ消す用
    //DBProvider.db.deleteTable();

    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [
        const Locale("en"),
        const Locale("ja"),
      ],

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

  var format = new DateFormat.yMMMd();

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
                      print("${item.id}を消す");
                      snapshot.data.removeAt(index);
                    });

                    if (direction == DismissDirection.endToStart){
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text("削除しました"))
                      );}
                  },
                child: list(item)
                );
            },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).pushNamed('/AddPage');
        },
      ),
    );
  }

  Widget list(Item item){
    if(item.expirationDate.isBefore(DateTime.now())){
      return new Container(
        decoration: new BoxDecoration(
          color: Colors.grey
        ),
        child: new ListTile(
          title: Text(item.itemName),
          leading: Text(format.format(item.expirationDate)),
        )
      );
    } else if(item.expirationDate.subtract(new Duration(days: 3)).isBefore(DateTime.now())){
      return new Container(
          decoration: new BoxDecoration(
              color: Colors.yellow
          ),
          child: new ListTile(
            title: Text(item.itemName!=null?item.itemName:"登録名称の初期値"),
            subtitle: Text(item.id!=null?item.id.toString():"idないよ"),
            leading: Text(item.expirationDate!=null?format.format(item.expirationDate).toString():"日付の初期値"),
          )
      );
    }
    return new Container(
       child: new ListTile(
         title: Text(item.itemName!=null?item.itemName:"登録名称の初期値"),
         subtitle: Text(item.id!=null?item.id.toString():"idないよ"),
         leading: Text(item.expirationDate!=null?format.format(item.expirationDate).toString():"日付の初期値"),
    )
    );
  }
}

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
                  print(value);
              },
            ),
            new FlatButton(
              onPressed: (){
                DatePicker.showDatePicker(
                  context,
//                  locale: const Locale("ja","JP"),
                  showTitleActions: true,
                  onConfirm: (date){
                    setState(() {
                      _expirationDate = date;
                    });
                  }
                );
              },
              child: Text(DateFormat.yMMMd().format(_expirationDate)),
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
      Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false); //遷移時にbackさせない
    }
  }
}



