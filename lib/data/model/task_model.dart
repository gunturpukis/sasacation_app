/// F10: travel task. Kontrak backend (FLUTTER_HANDOFF.md):
/// task { id, kind: flight_checkin|reminder|payment|document|other,
/// title, detail?, due_at?, payload? (mis. { flight_no, seats[] }),
/// done, booking_id? }.
class TaskModel {
  final String id;
  final String kind;
  final String title;
  final String? detail;
  final DateTime? dueAt;
  final Map<String, dynamic> payload;
  final bool done;
  final String? bookingId;

  const TaskModel({
    required this.id,
    required this.kind,
    required this.title,
    this.detail,
    this.dueAt,
    required this.payload,
    required this.done,
    this.bookingId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    DateTime? due;
    final raw = json['due_at'];
    if (raw is String) due = DateTime.tryParse(raw);
    final rawPayload = json['payload'];
    return TaskModel(
      id: (json['id'] ?? '').toString(),
      kind: (json['kind'] ?? 'other').toString(),
      title: (json['title'] ?? '').toString(),
      detail: json['detail']?.toString(),
      dueAt: due,
      payload: rawPayload is Map
          ? Map<String, dynamic>.from(rawPayload)
          : const {},
      done: json['done'] == true,
      bookingId: json['booking_id']?.toString(),
    );
  }

  List<String> get seats {
    final s = payload['seats'];
    if (s is List) return s.map((e) => e.toString()).toList();
    return const [];
  }

  String? get flightNo => payload['flight_no']?.toString();
}
