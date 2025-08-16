import 'package:json_annotation/json_annotation.dart';

enum EventType {
  workshop,
  seminar,
  networking,
  conference,
  other,
}

@JsonSerializable()
class EventModel {
  final String id;
  final String organizerId;
  final String title;
  final String description;
  final EventType type;
  final DateTime startDate;
  final DateTime endDate;
  final String? location;
  final String? imageUrl;
  final int maxAttendees;
  final int currentAttendees;
  final bool isOnline;
  final String? meetingLink;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Organizer info (joined)
  final String? organizerName;
  final String? organizerAvatar;

  const EventModel({
    required this.id,
    required this.organizerId,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.location,
    this.imageUrl,
    this.maxAttendees = 50,
    this.currentAttendees = 0,
    this.isOnline = false,
    this.meetingLink,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.organizerName,
    this.organizerAvatar,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      organizerId: json['organizer_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: EventType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => EventType.other,
      ),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      location: json['location'] as String?,
      imageUrl: json['image_url'] as String?,
      maxAttendees: json['max_attendees'] as int? ?? 50,
      currentAttendees: json['current_attendees'] as int? ?? 0,
      isOnline: json['is_online'] as bool? ?? false,
      meetingLink: json['meeting_link'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      organizerName: json['organizer_name'] as String?,
      organizerAvatar: json['organizer_avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizer_id': organizerId,
      'title': title,
      'description': description,
      'type': type.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'location': location,
      'image_url': imageUrl,
      'max_attendees': maxAttendees,
      'current_attendees': currentAttendees,
      'is_online': isOnline,
      'meeting_link': meetingLink,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'organizer_name': organizerName,
      'organizer_avatar': organizerAvatar,
    };
  }
}