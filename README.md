# 学習の流れ
Flutterに触ったことがなかったので、以下の順序で学習してみました。<br>
学んだこともあわせてまとめてみます。

## 1.環境構築、ハンズオン
公式の[導入手順・ハンズオン](https://flutter.dev/docs/get-started/install)（英語）を実施してみました。（part1まで）<br>
<br>
非公式ですが、[翻訳版](https://qiita.com/kainos/items/1700bf245c72b6b2487d)もありました。<br>
<br>
ハンズオンでなんとなくFlutterやDartについて学べたので、これ以降はやりたいことベースで実装方法を調べたいと思います。

## 2．画面遷移
[参考サイト](https://www.isoroot.jp/blog/2475/)<br>
Navigatorを使います。<br>

routes記述し、どのルートを呼び出したら、どのクラスを実行するのか設定します。<br>
AppBar（Webアプリのヘッダーみたいなもの）を持つと、前の画面への遷移ボタンが自動でついてきます。

<br>
routes設定

```
//main.dart

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/AddPage':(_) => new AddPage(),
      },
    );
  }
}
```
呼び出し（前画面への遷移付き）<br>
`Navigator.of(context).pushNamed('{routesで設定した値}')`を使う
```
//MyAppクラス

floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).pushNamed('/AddPage'); //日付入力画面に遷移する
        },
      )
```

呼び出し（前画面への遷移なし）<br>
`Navigator.pushNamedAndRemoveUntil(context, "{routesで設定した値}", (_) => false)`を使う

```
//AddPageクラス

void _submission() {
    this._formKey.currentState.save(); //onSaved内に記述された処理が実行される

    if((_expirationDate != null) && (_itemName.isNotEmpty )) {
      Item item = Item(
          id: null, itemName: _itemName, expirationDate: _expirationDate);
      DBProvider.db.createItem(item); // SQliteへの登録処理
      Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false); //一覧遷移時にbackさせない
    }
  }
```

## 画面項目（Widget）

Flutterでの開発は基本的に、画面のスペースをどんなWidget（部品）で埋めますか、というものみたいだ。<br>
どのようなWidgetがあるかは[こちら](https://qiita.com/matsukatsu/items/e289e30231fffb1e4502#layout)を参照すると一覧がまとまっている。<br>
[Layout](https://qiita.com/matsukatsu/items/e289e30231fffb1e4502#layout-1)にまとめられてあるような基礎となるWidgetが`child属性`や`children属性`の中に他のWidget（ボタンなど）を持つ構造になっている。

1. [AppBar](https://api.flutter.dev/flutter/material/AppBar-class.html)

Webアプリケーションでいうヘッダーみたいなもの。<br>
ページタイトルを設定する以外はデフォルトの設定にした。<br>

※Text()はprint()みたいなもの

```
//MyApp
Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('一覧'),
      )
    )
}
```

1. [FloatingActionButton](https://api.flutter.dev/flutter/material/FloatingActionButton-class.html)<br>
公式のハンズオンでも出てくる。onPressed属性遷移先を設定して、クリックした際に日付入力画面へ遷移するために使った。<br>

```
//MyAppクラス

floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).pushNamed('/AddPage'); //日付入力画面に遷移する
        },
      )
```

1. [TextField](https://api.flutter.dev/flutter/material/TextField-class.html)　※最終的な実装では不使用

超基本的なテキスト入力部品。`onChanged属性`や`onSubmitted属性`に処理を記述することで入力変更時の挙動や入力確定時の挙動を設定できる。<br>（使用しなかった理由は[Formクラス](#入力値の登録（Formクラス）)で記述します。）

1. [FlatButton](https://api.flutter.dev/flutter/material/FlatButton-class.html)

名前通りフラットなボタン。今回は`onPressed属性`にShowDatePickerを埋め込んだ。<br>
ボタン上に初期表示する日付はText()で実装している。

1. [ShowDatePicker](https://api.flutter.dev/flutter/material/showDatePicker.html)

FlatButtonをクリックした時に呼び出すように実装した。
日付入力するWidget。上下にスライドさせて年・月・日が選べるもの。`onConfirm属性`内でメンバ変数に入力値を詰め込む実装にしている。
<br>

FlatButtonからShowDatePickerまで
```
new FlatButton(
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
        )
)
```

1. [RaisedButton](https://api.flutter.dev/flutter/material/RaisedButton-class.html)

少しふくらみのあるボタン。<br>
登録処理を実行する登録ボタンに使用した。

```
new RaisedButton(
            onPressed: (){
              if (_formKey.currentState.validate()) {
                _submission(); //登録処理をするメソッド
              }
            },
            child: Text('登録'), //ボタンに表示する文字
)
```
※_submission()は[2. 画面遷移](#2．画面遷移)で遷移時に前画面に遷移させない実装の紹介で出してます。

## DBアクセス（SQlite3）

今回はSQliteを選びました。<br>
APIがあったのと、実装を参考にしたサイトでSQLiteを使っているものが多かったからです。

DBアクセスをするために主に以下のサイトを参照しました。

* [Using SQLite in Flutter](https://medium.com/flutter-community/using-sqlite-in-flutter-187c1a82e8b)　※英語
* [Flutterでsqliteを使ったTodoアプリを作る](https://qiita.com/popy1017/items/7ada79b07281f4a8e544)　※ほぼ↑の日本語版

詳細は上記のサイトを見ていただくのが良いですが、ざっくりまとめると<br>
DB接続用の`DBクラス`とDB上のテーブルに対応する`Modelクラス`を作ります。<br>
<br>
それぞれのクラスには以下の処理を実施しました。

DBクラス

* Databaseのgetter

  * すでに存在すれば存在するDBを返し、なければinitメソッドを定義して返しています
* 入力値を登録するメソッド
* 一覧に表示するレコードを全件取得するメソッド
* 指定したIDのレコードを削除するメソッド

Modelクラス

* メンバ変数
* JSONからMapへ変換するメソッド
* MapからJSONへ変換するメソッド

※Dart自体はJSON形式でインスタンスを保持しているようですが、Database内はMap形式で持っているので変換するメソッドが必要とのこと。

！！！注意点！！！
今回、以下のデータ型で値を保持していました。

|  項目名  |  Model(Flutter)  |  Table(SQlite3)  |
| ---- | ---- | ---- |
|  ID  |  int  |  INTEGER PRIMARY KEY  |
|  itemName  |  String  |  TEXT  |
|  expirationDate  |  DateTime  |  TEXT  |

* `INTEGER PRIMARY KEY `を設定したカラムがNullの時、自動採番されます。
* SQlite3には日付と対応するデータ型がありません。（そもそもデータ型少ないです⇒[参考](https://www.sqlite.org/datatype3.html)）<br>
DBに格納するときはDateTimeからTEXT、DBから取得する時はTEXTからDateTimeに変換しました。<br>

```
  Map<String, dynamic> toMap() => {
    "id": id,
    "item_name": itemName,

    //DateTimeからTEXT
    "expiration_date": expirationDate.toUtc().toIso8601String(),
  };

factory Item.fromMap(Map<String, dynamic> json) => new Item(
    id: json["id"],
    itemName: json["item_name"],

    //TEXTからDateTim
    expirationDate: DateTime.parse(json["expiration_date"]),
  );
```
また、DB上で日付はText型で保持されているため、そのままではソートできません。ソートしたい場合はDBから全権取得しDateTime型に変換された後にソートする必要があります。（[DartのAPI](https://api.flutter.dev/flutter/dart-core/List/sort.html)を参照）

```
  //一覧表示用に全権取得するメソッド
  Future<List<Item>> getAllItems() async {
    final db = await database;
    var res = await db.query(_tableName);
    List<Item> list =
    res.isNotEmpty ? res.map((c) => Item.fromMap(c)).toList() : [];

    //日付の昇順でソート
    if (list != null){
      list.sort((a,b) => a.expirationDate.compareTo(b.expirationDate));
    }

    return list;
  }
```


* SQlite3のALTER構文ではリネームかカラムの追加のみできます。（[参考](https://www.sqlite.org/lang_altertable.html)）
&nbsp;間違えたデータ型でテーブルを作成した場合はテーブルをDropして正しいデータ型のテーブルを新規作成する必要があります。<br>
対処としては以下です。<br>
<br>
1. DBクラスにあるinitメソッド内の`version属性`の値を1つ以上大きくする。<br>
2. initメソッド内に`onUpgrade属性`を追加し、`_onUpgradeメソッド`が呼び出されるように記述する。<br>（例：onUpgrade: _onUpgrade）<br>
3. DBクラス内に以下を追加する。executeメソッドの引数に実行したいSQLを記述する。<br>
1度目はDropTableの構文を記述しアプリをRunし、再度手順1を実行した後CreateTableの構文を記述してアプリをRunする。

```
※dbはDatabaseクラスのインスタンス
void _onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < newVersion) {
      db.execute(

        //実行したいSQLを記述
        // SQL文に適切な空白を入れないとエラーになる
          "CREATE TABLE ITEM ( "
              "id INTEGER PRIMARY KEY AUTOINCREMENT,"
              "item_name TEXT,"
              "expiration_date TEXT "
              ")"
      );
    }
  }
```

## 入力値の登録（Formクラス）とバリデーション

[参考](https://flutter.dev/docs/cookbook/forms/validation)<br>
Fromを使うとバリデーションの処理ができるようになります。FromのWidgetが持つformKeyがポイントです。<br>
名前に`Form`とついているWidgetはFormクラスを継承したWidgetのようです。

Formを持つWidgetの`validator属性`にバリデーションの処理を記述します。

```
※valueは入力値

validator: (value){
                if (value.isEmpty) { //必須バリデーション
                  return '入力してください';
                } else if(value.length > 25) { //文字数バリデーション
                  return '25字以内で入力してください';
                }
                return null;
              }

```

onChanged属性やonSubmitted属性などの処理内で`_formKey.currentState.validate()`が実行された時、validator内の処理を実施します。

今回の実装では登録ボタンがクリックされた時にバリデーションが働くようにしています。

```
new RaisedButton(
            onPressed: (){
              if (_formKey.currentState.validate()) {
                _submission();
              }
              },
            child: Text('登録'),
          )
```

DBへの登録は登録ボタンをクリックした際にModelクラス内の登録メソッドを呼び出すようにしています。<br>

```
//登録ボタン

new RaisedButton(
            onPressed: (){
              if (_formKey.currentState.validate()) {
                _submission();
              }
              },
            child: Text('登録'),
          )
```

```
//_submission()メソッド（登録メソッド）

void _submission() {
    this._formKey.currentState.save(); //onSaved内に記述された処理が実行される

    if((_expirationDate != null) && (_itemName.isNotEmpty )) {
      Item item = Item(
          id: null, itemName: _itemName, expirationDate: _expirationDate);
      DBProvider.db.createItem(item); // SQliteへの登録処理
      Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false); //一覧遷移時にbackさせない
    }
  }
```

登録メソッド内で`this._formKey.currentState.save()`を実行することでTextFormFieldが持つ`onSaved属性`内の処理を実行します。<br>
実装ではすでにバリデーションが実施されているので、変数に入力値を詰める処理だけをしています。

```
onSaved: (value){
                  _itemName = value;
              }
```

```
//DBProvider.db.createItem(item)

createItem(Item item) async {
　final db = await database;
　  var res = await db.insert(_tableName, item.toMap());
  return res;
}
```

## 一覧表示

公式のハンズオンでも紹介されている[FutureBuilder](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)を使いました。<br>

ListViewやFuture型が良くわかっていないので今後調べます。

## 削除実装

削除処理自体はDBクラス内の`deleteItemメソッド`で実施しています。

```
//DBクラス
  deleteItem(int id) async {
    final db = await database;
    var res = db.delete(
        _tableName,
        where: "id = ?",
        whereArgs: [id]
    );
    return res;
  }
```

今回は一覧表示で生成されたListTile１つに対して、右から左へスライドした場合に削除処理が実施されるようにするため、[Dissmisible](https://api.flutter.dev/flutter/widgets/Dismissible-class.html)を持つListTileを実装しました。（[参考](https://medium.com/flutter-community/using-sqlite-in-flutter-187c1a82e8b)）<br>

```
Dismissible(
    key: Key(index.toString()),
    direction: DismissDirection.endToStart, //endToStartで右to左
    background: Container(
        alignment: Alignment.centerLeft,
        color: Colors.redAccent[700]
    ),
    onDismissed: (direction){
        setState(() {
            DBProvider.db.deleteItem(item.id);
            snapshot.data.removeAt(index);
        });
　　},
　  child: list(item)
)
```

`onDismissed属性`に処理を記述することでListTileをスライドした際に実施する内容を決めています。ここではスライドしたListTileのDB上のデータ削除の処理（`DBProvider.db.deleteItemメソッド`）と、デバイス上での表示をさせない処理（`snapshot.data.removeAt`）を実施しています。<br>
ここで`snapshot.data.removeAt`を実施しないとエラーになります。<br>

`listTileメソッド`では表示するデータのうち、賞味期限の項目を現在の日付と比較し、その条件によって背景色を変えたListTileを返すような実装にしています。

## 細かい修正

* 日にちによって背景色を変える

getAllItemsメソッドを実施することでDBから登録されているデータを全て取得し、Listで返却されています。Listの配列1つ1つに対してListView.builderがDissmisibleのラップされたListTileを生成しています。<br>

そこで、生成されるListTileに対してさらにContainerでラップしたうえで背景色の表示分けをすれば良いのではないかと考えました。

ListTileをラップするContainerの`color属性`の中身を変化させています。

```
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
```

* 25文字以上入力されたら警告文

TextFormFieldに対して何か入力された時、指定した文字数を超えた時点で警告メッセージが出れば、もっと便利だなと思いました。<br>
`onChanged属性`に`printメソッド`を記述してRunしてみると、文字が入力されるとすぐに標準出力されることがわかったので、以下のような実装をすることで文字入力の途中に警告文が出るようになりました。

```
//TextFormField内
onChanged: (value){ //25文字以上入力された時点で警告文を出す
                  if(value.length > 25) {
                    _formKey.currentState.validate();
                  }
              }
```

入力された値をすぐに参照できるようなので、入力した文字が25文字以上に到達した時点でValidatorを呼び出しています。

## わかったこと

* 基本的な実装の仕方、構文
* 他の人が書いたソースコードが読めるようになった

## わかっていないこと

表面的な理解にとどまったので、内部の動きをより追いたい

* Future型とは何か
* `_formKey.currentState.save()`って内部でなにしてるんだろう
* SQlite3ってどんな特徴があるのか

などなど
