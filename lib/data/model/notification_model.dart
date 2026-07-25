
/// Model: NotificationModel
/// Merepresentasikan satu baris dari tabel `notifications` backend.
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;
 
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.readAt,
    required this.createdAt,
  });
 
  bool get isRead => readAt != null;
 
  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        type: json['type'] as String? ?? 'general',
        data: (json['data'] as Map<String, dynamic>?) ?? const {},
        readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
 