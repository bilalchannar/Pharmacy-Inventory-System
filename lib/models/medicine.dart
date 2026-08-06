class Medicine {
  int? id;
  String name;
  String company;
  String category;
  double price;
  int quantity;
  String expiryDate;

  Medicine({
    this.id,
    required this.name,
    required this.company,
    required this.category,
    required this.price,
    required this.quantity,
    required this.expiryDate,
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
    );
  }
}
