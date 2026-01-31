import 'package:equatable/equatable.dart';
import 'user_model.dart';

enum EventType { job, workshop, conference, webinar, training, meetup, other }
enum EventStatus { draft, published, cancelled, completed }

class EventModel extends Equatable {
  final String id;
  final String userId;
  final String titleAr;
  final String? titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final EventType type;
  final EventStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final String? location;
  final bool isOnline;
  final String? meetingLink;
  final String? imageUrl;
  final bool isFree;
  final double? price;
  final String? currency;
  final int? maxAttendees;
  final int currentAttendees;
  final DateTime? registrationDeadline;

  // Job specific
  final String? companyName;
  final String? jobType;
  final String? salaryRange;
  final List<String> requirements;
  final List<String> benefits;

  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final UserModel? user;
  final bool? isRegisteredByMe;

  const EventModel({
    required this.id,
    required this.userId,
    required this.titleAr,
    this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.type,
    this.status = EventStatus.published,
    required this.startDate,
    this.endDate,
    this.location,
    this.isOnline = false,
    this.meetingLink,
    this.imageUrl,
    this.isFree = true,
    this.price,
    this.currency = 'USD',
    this.maxAttendees,
    this.currentAttendees = 0,
    this.registrationDeadline,
    this.companyName,
    this.jobType,
    this.salaryRange,
    this.requirements = const [],
    this.benefits = const [],
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.isRegisteredByMe,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      type: EventType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => EventType.other,
      ),
      status: EventStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => EventStatus.published,
      ),
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      location: json['location'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      meetingLink: json['meeting_link'] as String?,
      imageUrl: json['image_url'] as String?,
      isFree: json['is_free'] as bool? ?? true,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      maxAttendees: json['max_attendees'] as int?,
      currentAttendees: json['current_attendees'] as int? ?? 0,
      registrationDeadline: json['registration_deadline'] != null
          ? DateTime.parse(json['registration_deadline'])
          : null,
      companyName: json['company_name'] as String?,
      jobType: json['job_type'] as String?,
      salaryRange: json['salary_range'] as String?,
      requirements: List<String>.from(json['requirements'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: json['profiles'] != null ? UserModel.fromJson(json['profiles']) : null,
      isRegisteredByMe: json['is_registered_by_me'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title_ar': titleAr,
      'title_en': titleEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'type': type.name,
      'status': status.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'location': location,
      'is_online': isOnline,
      'meeting_link': meetingLink,
      'image_url': imageUrl,
      'is_free': isFree,
      'price': price,
      'currency': currency,
      'max_attendees': maxAttendees,
      'registration_deadline': registrationDeadline?.toIso8601String(),
      'company_name': companyName,
      'job_type': jobType,
      'salary_range': salaryRange,
      'requirements': requirements,
      'benefits': benefits,
    };
  }

  // Helpers
  String getTitle(bool isArabic) => isArabic ? titleAr : (titleEn ?? titleAr);
  String? getDescription(bool isArabic) => isArabic ? descriptionAr : (descriptionEn ?? descriptionAr);
  bool get isUpcoming => startDate.isAfter(DateTime.now());
  int? get seatsLeft => maxAttendees != null ? maxAttendees! - currentAttendees : null;

  @override
  List<Object?> get props => [
    id, userId, titleAr, titleEn, descriptionAr, descriptionEn, type, status,
    startDate, endDate, location, isOnline, meetingLink, imageUrl, isFree,
    price, currency, maxAttendees, currentAttendees, registrationDeadline,
    companyName, jobType, salaryRange, requirements, benefits, createdAt, updatedAt,
  ];
}