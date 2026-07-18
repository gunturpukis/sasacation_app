// import 'package:intl/number_symbols.dart';
import 'package:sasacation/utils/json_helper.dart';

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
  final double? latitude;
  final double? longitude;
  /// Jarak dari lokasi user dalam kilometer. Hanya terisi kalau hotel ini
  /// datang dari endpoint GET /hotels/nearby (fitur geolocation).
  final double? distanceKm;

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
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) => HotelModel(
        id: json['id'],
        name: json['name'],
        location: json['location'],
        address: json['address'],
        // price: (json['price'] as num).toDouble(),
        // rating: (json['rating'] as num).toDouble(),
          price: parseDouble(json['price']),
        rating: parseDouble(json['rating']),
        // FIX: backend (SELECT * FROM hotels) mengembalikan kolom apa
        // adanya dari PostgreSQL yaitu `review_count` (snake_case), BUKAN
        // `reviewCount`. Sebelumnya hanya membaca json['reviewCount'] yang
        // selalu null dari API asli, sehingga jumlah review selalu tampil 0.
        reviewCount: parseInt(json['reviewCount'] ?? json['review_count']),
        image: json['image'] ?? '',
        images: List<String>.from(json['images'] ?? []),
        description: json['description'],
        amenities: List<String>.from(json['amenities'] ?? []),
        featured: json['featured'] ?? false,
        available: json['available'] ?? true,
        latitude: json['latitude'] != null ? parseDouble(json['latitude']) : null,
        longitude: json['longitude'] != null ? parseDouble(json['longitude']) : null,
        distanceKm: json['distance_km'] != null ? parseDouble(json['distance_km']) : null,
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
        'latitude': latitude,
        'longitude': longitude,
      };
}
