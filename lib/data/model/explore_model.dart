// class ExploreItemModel {
//   final String id;
//   final String name;
//   final String location;
//   final double price;
//   final double rating;
//   final int reviewCount;
//   final String image;
//   final List<String> images;
//   final String? description;
//   final String category;
//   final String type; // hotel | destination | restaurant

//   // Restaurant-specific fields
//   final String? cuisine;
//   final String? openHours;

//   // Destination-specific fields
//   final String? subCategory; // Beaches | Islands | Adventure | Culture

//   const ExploreItemModel({
//     required this.id,
//     required this.name,
//     required this.location,
//     required this.price,
//     required this.rating,
//     required this.reviewCount,
//     required this.image,
//     this.images = const [],
//     this.description,
//     required this.category,
//     required this.type,
//     this.cuisine,
//     this.openHours,
//     this.subCategory,
//   });

//   factory ExploreItemModel.fromJson(Map<String, dynamic> json) => ExploreItemModel(
//         id: json['id'],
//         name: json['name'],
//         location: json['location'],
//         price: (json['price'] as num).toDouble(),
//         rating: (json['rating'] as num).toDouble(),
//         reviewCount: json['reviewCount'] ?? 0,
//         image: json['image'] ?? '',
//         images: List<String>.from(json['images'] ?? []),
//         description: json['description'],
//         category: json['category'] ?? '',
//         type: json['type'] ?? '',
//         cuisine: json['cuisine'],
//         openHours: json['openHours'],
//         subCategory: json['subCategory'],
//       );
// }

// class BookingModel {
//   final String id;
//   final String userId;
//   final String hotelId;
//   final String hotelName;
//   final String hotelLocation;
//   final String hotelImage;
//   final DateTime checkIn;
//   final DateTime checkOut;
//   final int nights;
//   final int guestCount;
//   final double pricePerNight;
//   final double totalPrice;
//   final String? notes;
//   final String status;
//   final String bookingCode;
//   final DateTime createdAt;

//   const BookingModel({
//     required this.id,
//     required this.userId,
//     required this.hotelId,
//     required this.hotelName,
//     required this.hotelLocation,
//     required this.hotelImage,
//     required this.checkIn,
//     required this.checkOut,
//     required this.nights,
//     required this.guestCount,
//     required this.pricePerNight,
//     required this.totalPrice,
//     this.notes,
//     required this.status,
//     required this.bookingCode,
//     required this.createdAt,
//   });

//   factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
//         id: json['id'],
//         userId: json['userId'],
//         hotelId: json['hotelId'],
//         hotelName: json['hotelName'],
//         hotelLocation: json['hotelLocation'],
//         hotelImage: json['hotelImage'] ?? '',
//         checkIn: DateTime.parse(json['checkIn']),
//         checkOut: DateTime.parse(json['checkOut']),
//         nights: json['nights'],
//         guestCount: json['guestCount'],
//         pricePerNight: (json['pricePerNight'] as num).toDouble(),
//         totalPrice: (json['totalPrice'] as num).toDouble(),
//         notes: json['notes'],
//         status: json['status'],
//         bookingCode: json['bookingCode'],
//         createdAt: DateTime.parse(json['createdAt']),
//       );

//   bool get isConfirmed => status == 'confirmed';
//   bool get isCancelled => status == 'cancelled';
//   bool get isCompleted => status == 'completed';
// }
import 'package:sasacation/utils/json_helper.dart';

class ExploreItemModel {
  final String id;
  final String name;
  final String location;
  final double price;
  final double rating;
  final int reviewCount;
  final String image;
  final List<String> images;
  final String? description;
  final String category;
  final String type; // hotel | destination | restaurant

  // Restaurant-specific fields
  final String? cuisine;
  final String? openHours;

  // Destination-specific fields
  final String? subCategory; // Beaches | Islands | Adventure | Culture

  const ExploreItemModel({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.image,
    this.images = const [],
    this.description,
    required this.category,
    required this.type,
    this.cuisine,
    this.openHours,
    this.subCategory,
  });

  factory ExploreItemModel.fromJson(Map<String, dynamic> json) => ExploreItemModel(
        id: json['id'].toString(),
        name: json['name'] ?? '',
        location: json['location'] ?? '',
        // FIX: pakai parseDouble/parseInt — aman menerima String dari
        // PostgreSQL NUMERIC (mis. "15.00") maupun num biasa.
        price: parseDouble(json['price']),
        rating: parseDouble(json['rating']),
        reviewCount: parseInt(json['reviewCount'] ?? json['review_count']),
        image: json['image'] ?? '',
        images: List<String>.from(json['images'] ?? []),
        description: json['description'],
        category: json['category'] ?? '',
        type: json['type'] ?? '',
        cuisine: json['cuisine'],
        openHours: json['openHours'] ?? json['open_hours'],
        subCategory: json['subCategory'] ?? json['sub_category'],
      );
}

class BookingModel {
  final String id;
  final String userId;
  final String hotelId;
  final String hotelName;
  final String hotelLocation;
  final String hotelImage;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final int guestCount;
  final double pricePerNight;
  final double totalPrice;
  final String? notes;
  final String status;
  final String bookingCode;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.hotelName,
    required this.hotelLocation,
    required this.hotelImage,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.guestCount,
    required this.pricePerNight,
    required this.totalPrice,
    this.notes,
    required this.status,
    required this.bookingCode,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Backend PostgreSQL versi RAG mengembalikan booking dengan struktur nested
    // `hotel: { id, name, location, image }` hasil JOIN, bukan field flat
    // seperti hotelName/hotelLocation langsung. Baca dari nested jika ada,
    // fallback ke flat field untuk kompatibilitas dengan versi backend lama.
    final hotel = json['hotel'] as Map<String, dynamic>?;

    return BookingModel(
      id: json['id'].toString(),
      userId: (json['userId'] ?? json['user_id']).toString(),
      hotelId: (json['hotelId'] ?? json['hotel_id']).toString(),
      hotelName: json['hotelName'] ?? hotel?['name'] ?? '',
      hotelLocation: json['hotelLocation'] ?? hotel?['location'] ?? '',
      hotelImage: json['hotelImage'] ?? hotel?['image'] ?? '',
      checkIn: DateTime.parse(json['checkIn'] ?? json['check_in']),
      checkOut: DateTime.parse(json['checkOut'] ?? json['check_out']),
      nights: parseInt(json['nights']),
      guestCount: parseInt(json['guestCount'] ?? json['guest_count']),
      // FIX: harga dari PostgreSQL NUMERIC selalu String, wajib parseDouble
      pricePerNight: parseDouble(json['pricePerNight'] ?? json['price_per_night']),
      totalPrice: parseDouble(json['totalPrice'] ?? json['total_price']),
      notes: json['notes'],
      status: json['status'] ?? 'confirmed',
      bookingCode: json['bookingCode'] ?? json['booking_code'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
    );
  }

  bool get isConfirmed => status.toLowerCase() == 'confirmed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isCompleted => status.toLowerCase() == 'completed';
}