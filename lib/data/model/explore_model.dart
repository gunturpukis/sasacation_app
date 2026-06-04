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
        id: json['id'],
        name: json['name'],
        location: json['location'],
        price: (json['price'] as num).toDouble(),
        rating: (json['rating'] as num).toDouble(),
        reviewCount: json['reviewCount'] ?? 0,
        image: json['image'] ?? '',
        images: List<String>.from(json['images'] ?? []),
        description: json['description'],
        category: json['category'] ?? '',
        type: json['type'] ?? '',
        cuisine: json['cuisine'],
        openHours: json['openHours'],
        subCategory: json['subCategory'],
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

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json['id'],
        userId: json['userId'],
        hotelId: json['hotelId'],
        hotelName: json['hotelName'],
        hotelLocation: json['hotelLocation'],
        hotelImage: json['hotelImage'] ?? '',
        checkIn: DateTime.parse(json['checkIn']),
        checkOut: DateTime.parse(json['checkOut']),
        nights: json['nights'],
        guestCount: json['guestCount'],
        pricePerNight: (json['pricePerNight'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        notes: json['notes'],
        status: json['status'],
        bookingCode: json['bookingCode'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
}
