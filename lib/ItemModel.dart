
import 'dart:convert';

Item itemFromJson(String str) {
  final jsonData = json.decode(str);
  return Item.fromMap(jsonData);
}

String itemToJson(Item data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Item {
  String id;
  String itemName;
  DateTime expirationDate;

  Item({
    this.id,
    this.itemName,
    this.expirationDate,
  });

  factory Item.fromMap(Map<String, dynamic> json) => new Item(
    id: json["id"],
    itemName: json["item_name"],
    expirationDate: DateTime.parse(json["expiration_date"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "item_name": itemName,
    "expiration_date": expirationDate.toUtc().toIso8601String(),
  };

  //表示テスト用のsetter
//  set catId(String id){this.id = id;}
//  set catItemName(String itemName){this.itemName = itemName;}
//  set catExpirationDate(DateTime expirationDate){this.expirationDate = expirationDate;}

}