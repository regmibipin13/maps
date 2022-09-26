class Detail {
  final int? id;
  final String latitude;
  final String longitude;
  final String type;
  final String price;
  final String details;
  Detail({
    this.id,
    this.latitude = '',
    this.longitude = '',
    required this.type,
    required this.price,
    required this.details,
  });
  factory Detail.fromMap(Map<String, dynamic> json) => Detail(
        id: json['id'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        type: json['type'],
        price: json['price'],
        details: json['details'] ?? '',
      );
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'price': price,
      'details': details,
    };
  }
}

class Photo {
  final int? id;
  final int detailId;
  final String name;

  Photo({this.id, required this.detailId, required this.name});

  factory Photo.fromMap(Map<String, dynamic> json) => Photo(
        id: json['id'],
        detailId: json['detailId'],
        name: json['name'],
      );
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'detailId': detailId,
      'name': name,
    };
  }
}
