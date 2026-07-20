// // ─── Chat Message ────────────────────────────────────────────────────────────
// class ChatMessage {
//   final String role; // 'user' | 'assistant'
//   final String content;
//   final DateTime timestamp;

//   const ChatMessage({
//     required this.role,
//     required this.content,
//     required this.timestamp,
//   });

//   factory ChatMessage.user(String content) => ChatMessage(
//         role: 'user',
//         content: content,
//         timestamp: DateTime.now(),
//       );

//   factory ChatMessage.assistant(String content) => ChatMessage(
//         role: 'assistant',
//         content: content,
//         timestamp: DateTime.now(),
//       );

//   Map<String, dynamic> toJson() => {'role': role, 'content': content};

//   bool get isUser => role == 'user';
//   bool get isAssistant => role == 'assistant';
// }

// // ─── Smart Search Result ─────────────────────────────────────────────────────
// class SmartSearchResult {
//   final String interpretation;
//   final String category;
//   final List<String> suggestions;
//   final List<Map<String, dynamic>> results;
//   final int totalResults;

//   const SmartSearchResult({
//     required this.interpretation,
//     required this.category,
//     required this.suggestions,
//     required this.results,
//     required this.totalResults,
//   });

//   factory SmartSearchResult.fromJson(Map<String, dynamic> json) =>
//       SmartSearchResult(
//         interpretation: json['interpretation'] ?? '',
//         category: json['category'] ?? 'All',
//         suggestions: List<String>.from(json['suggestions'] ?? []),
//         results: List<Map<String, dynamic>>.from(json['results'] ?? []),
//         totalResults: json['totalResults'] ?? 0,
//       );
// }

// // ─── Trip Plan ────────────────────────────────────────────────────────────────
// class TripActivity {
//   final String time;
//   final String name;
//   final String type;
//   final String location;
//   final String duration;
//   final double estimatedCost;
//   final String notes;
//   final String? itemId;

//   const TripActivity({
//     required this.time,
//     required this.name,
//     required this.type,
//     required this.location,
//     required this.duration,
//     required this.estimatedCost,
//     required this.notes,
//     this.itemId,
//   });

//   factory TripActivity.fromJson(Map<String, dynamic> json) => TripActivity(
//         time: json['time'] ?? '',
//         name: json['name'] ?? '',
//         type: json['type'] ?? '',
//         location: json['location'] ?? '',
//         duration: json['duration'] ?? '',
//         estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0,
//         notes: json['notes'] ?? '',
//         itemId: json['itemId'],
//       );
// }

// class TripDay {
//   final int day;
//   final String? date;
//   final String title;
//   final List<TripActivity> activities;
//   final double dailyCost;

//   const TripDay({
//     required this.day,
//     this.date,
//     required this.title,
//     required this.activities,
//     required this.dailyCost,
//   });

//   factory TripDay.fromJson(Map<String, dynamic> json) => TripDay(
//         day: json['day'] ?? 1,
//         date: json['date'],
//         title: json['title'] ?? 'Day ${json['day']}',
//         activities: (json['activities'] as List? ?? [])
//             .map((a) => TripActivity.fromJson(a))
//             .toList(),
//         dailyCost: (json['dailyCost'] as num?)?.toDouble() ?? 0,
//       );
// }

// class TripPlan {
//   final String title;
//   final String summary;
//   final double totalEstimatedCost;
//   final List<TripDay> days;
//   final List<String> tips;
//   final String bestTimeToVisit;

//   const TripPlan({
//     required this.title,
//     required this.summary,
//     required this.totalEstimatedCost,
//     required this.days,
//     required this.tips,
//     required this.bestTimeToVisit,
//   });

//   factory TripPlan.fromJson(Map<String, dynamic> json) => TripPlan(
//         title: json['title'] ?? 'Lombok Trip',
//         summary: json['summary'] ?? '',
//         totalEstimatedCost:
//             (json['totalEstimatedCost'] as num?)?.toDouble() ?? 0,
//         days: (json['days'] as List? ?? [])
//             .map((d) => TripDay.fromJson(d))
//             .toList(),
//         tips: List<String>.from(json['tips'] ?? []),
//         bestTimeToVisit: json['bestTimeToVisit'] ?? '',
//       );
// }
import 'package:sasacation/utils/json_helper.dart';

class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.user(String content) => ChatMessage(
        role: 'user',
        content: content,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.assistant(String content) => ChatMessage(
        role: 'assistant',
        content: content,
        timestamp: DateTime.now(),
      );

  // Dipakai untuk restore riwayat chat dari backend (chat_messages row:
  // {role, content, created_at}). Beda dari toJson() yang cuma kirim
  // {role, content} — created_at cuma dipakai saat baca, tidak pernah dikirim.
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role'] as String,
        content: json['content'] as String,
        timestamp: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}

// ─── Smart Search Result ─────────────────────────────────────────────────────
class SmartSearchResult {
  final String interpretation;
  final String category;
  final List<String> suggestions;
  final List<Map<String, dynamic>> results;
  final int totalResults;

  const SmartSearchResult({
    required this.interpretation,
    required this.category,
    required this.suggestions,
    required this.results,
    required this.totalResults,
  });

  factory SmartSearchResult.fromJson(Map<String, dynamic> json) => SmartSearchResult(
        interpretation: json['interpretation'] ?? '',
        category: json['category'] ?? 'All',
        suggestions: List<String>.from(json['suggestions'] ?? []),
        results: List<Map<String, dynamic>>.from(json['results'] ?? []),
        // FIX: totalResults dari backend RAG mungkin String, aman pakai parseInt
        totalResults: parseInt(json['totalResults']),
      );
}

// ─── Trip Plan ────────────────────────────────────────────────────────────────
class TripActivity {
  final String time;
  final String name;
  final String type;
  final String location;
  final String duration;
  final double estimatedCost;
  final String notes;
  final String? itemId;

  const TripActivity({
    required this.time,
    required this.name,
    required this.type,
    required this.location,
    required this.duration,
    required this.estimatedCost,
    required this.notes,
    this.itemId,
  });

  factory TripActivity.fromJson(Map<String, dynamic> json) => TripActivity(
        time: json['time'] ?? '',
        name: json['name'] ?? '',
        type: json['type'] ?? '',
        location: json['location'] ?? '',
        duration: json['duration'] ?? '',
        // FIX: LLM lokal (llama3.1/qwen via Ollama) kadang generate angka
        // sebagai String dalam JSON-nya (mis. "150" bukan 150). parseDouble
        // aman menerima keduanya, tidak seperti (json[...] as num?)?.toDouble()
        // yang akan crash kalau valuenya String.
        estimatedCost: parseDouble(json['estimatedCost']),
        notes: json['notes'] ?? '',
        itemId: json['itemId']?.toString(),
      );
}

class TripDay {
  final int day;
  final String? date;
  final String title;
  final List<TripActivity> activities;
  final double dailyCost;

  const TripDay({
    required this.day,
    this.date,
    required this.title,
    required this.activities,
    required this.dailyCost,
  });

  factory TripDay.fromJson(Map<String, dynamic> json) => TripDay(
        day: parseInt(json['day'], 1),
        date: json['date'],
        title: json['title'] ?? 'Day ${json['day']}',
        activities: (json['activities'] as List? ?? [])
            .map((a) => TripActivity.fromJson(a))
            .toList(),
        dailyCost: parseDouble(json['dailyCost']),
      );
}

class TripPlan {
  final String title;
  final String summary;
  final double totalEstimatedCost;
  final List<TripDay> days;
  final List<String> tips;
  final String bestTimeToVisit;

  const TripPlan({
    required this.title,
    required this.summary,
    required this.totalEstimatedCost,
    required this.days,
    required this.tips,
    required this.bestTimeToVisit,
  });

  factory TripPlan.fromJson(Map<String, dynamic> json) => TripPlan(
        title: json['title'] ?? 'Lombok Trip',
        summary: json['summary'] ?? '',
        totalEstimatedCost: parseDouble(json['totalEstimatedCost']),
        days: (json['days'] as List? ?? [])
            .map((d) => TripDay.fromJson(d))
            .toList(),
        tips: List<String>.from(json['tips'] ?? []),
        bestTimeToVisit: json['bestTimeToVisit'] ?? '',
      );
}
