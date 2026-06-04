class HotelModel {
  final String id;
  final String name;
  final String location;
  final String? address;
  final double price;
  final double rating;
  final int reviewCount;
  final String image;
  final List<String> images;
  final String? description;
  final List<String> amenities;
  final bool featured;
  final bool available;

  const HotelModel({
    required this.id,
    required this.name,
    required this.location,
    this.address,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.image,
    this.images = const [],
    this.description,
    this.amenities = const [],
    this.featured = false,
    this.available = true,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) => HotelModel(
        id: json['id'],
        name: json['name'],
        location: json['location'],
        address: json['address'],
        price: (json['price'] as num).toDouble(),
        rating: (json['rating'] as num).toDouble(),
        reviewCount: json['reviewCount'] ?? 0,
        image: json['image'] ?? '',
        images: List<String>.from(json['images'] ?? []),
        description: json['description'],
        amenities: List<String>.from(json['amenities'] ?? []),
        featured: json['featured'] ?? false,
        available: json['available'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'address': address,
        'price': price,
        'rating': rating,
        'reviewCount': reviewCount,
        'image': image,
        'images': images,
        'description': description,
        'amenities': amenities,
        'featured': featured,
        'available': available,
      };
}
