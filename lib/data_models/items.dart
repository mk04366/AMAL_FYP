class ItemData {
  final String itemId;
  final String name;
  final int price;
  final String imageUrl;
  final String description;
  final String category;
  int quantity;

  ItemData(
    this.quantity,
      {required this.itemId,
      required this.name,
      required this.price,
      required this.imageUrl,
      required this.description,
      required this.category,});
  ItemData.fromJson(Map<dynamic, dynamic> json, this.quantity)
      : name = json['name'] as String,
        price = json['price'] as int,
        imageUrl = json['imageUrl'] as String,
        itemId = json['itemId'] as String,
        description = json['description'] as String,
        category = json['category'] as String;
  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'itemId': itemId,
        'description': description,
        'category': category,
      };
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
      'quantity': quantity,
    };
  }
}
