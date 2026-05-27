class Item {
  final int id;
  final String name;
  final String description;

  Item({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}