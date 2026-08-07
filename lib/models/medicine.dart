class Medicine {
  int? id;
  String name;
  String company;
  String category;
  double price;
  int quantity;
  String expiryDate;
  String? imageUrl;

  Medicine({
    this.id,
    required this.name,
    required this.company,
    required this.category,
    required this.price,
    required this.quantity,
    required this.expiryDate,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'category': category,
      'price': price,
      'quantity': quantity,
      'expiryDate': expiryDate,
      'imageUrl': imageUrl,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      company: map['company'],
      category: map['category'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'],
      expiryDate: map['expiryDate'],
      imageUrl: map['imageUrl'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Medicine &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          company == other.company &&
          category == other.category &&
          price == other.price &&
          quantity == other.quantity &&
          expiryDate == other.expiryDate &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      company.hashCode ^
      category.hashCode ^
      price.hashCode ^
      quantity.hashCode ^
      expiryDate.hashCode ^
      imageUrl.hashCode;
}
