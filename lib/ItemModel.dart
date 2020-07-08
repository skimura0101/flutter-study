
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
  int id;
  String itemName;
  String expirationDate;

  Item({
    this.id,
    this.itemName,
    this.expirationDate,
  });

  factory Item.fromMap(Map<String, dynamic> json) => new Item(
    id: json["id"],
    itemName: json["item_name"],
    expirationDate: json["expiration_date"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "item_name": itemName,
    "expiration_date": expirationDate,
  };

  set catId(int Id){this.id = id;}
  set catItemName(String itemName){this.itemName = itemName;}
  set catExpirationName(String expirationDate){this.expirationDate = expirationDate;}

}