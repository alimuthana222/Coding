import 'package:equatable/equatable.dart';
import 'user_model.dart';
import 'skill_model.dart';

enum BookingStatus { pending, confirmed, completed, cancelled, rejected }

class BookingModel extends Equatable {
  final String id;
  final String skillId;
  final String learnerId;
  final String teacherId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final double hoursCost;
  final BookingStatus status;
  final String? meetingLink;
  final String? notes;
  final int? learnerRating;
  final String? learnerReview;
  final int? teacherRating;
  final String? teacherReview;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final SkillModel? skill;
  final UserModel? learner;
  final UserModel? teacher;

  const BookingModel({
    required this.id,
    required this.skillId,
    required this.learnerId,
    required this.teacherId,
    required this.scheduledAt,
    this.durationMinutes = 60,
    required this.hoursCost,
    this.status = BookingStatus.pending,
    this.meetingLink,
    this.notes,
    this.learnerRating,
    this.learnerReview,
    this.teacherRating,
    this.teacherReview,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.skill,
    this.learner,
    this.teacher,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      skillId: json['skill_id'] as String,
      learnerId: json['learner_id'] as String,
      teacherId: json['teacher_id'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at']),
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      hoursCost: (json['hours_cost'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      meetingLink: json['meeting_link'] as String?,
      notes: json['notes'] as String?,
      learnerRating: json['learner_rating'] as int?,
      learnerReview: json['learner_review'] as String?,
      teacherRating: json['teacher_rating'] as int?,
      teacherReview: json['teacher_review'] as String?,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at']) : null,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      skill: json['skills'] != null ? SkillModel.fromJson(json['skills']) : null,
      learner: json['learner'] != null ? UserModel.fromJson(json['learner']) : null,
      teacher: json['teacher'] != null ? UserModel.fromJson(json['teacher']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skill_id': skillId,
      'learner_id': learnerId,
      'teacher_id': teacherId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'hours_cost': hoursCost,
      'status': status.name,
      'meeting_link': meetingLink,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [
    id, skillId, learnerId, teacherId, scheduledAt, durationMinutes,
    hoursCost, status, meetingLink, notes, learnerRating, learnerReview,
    teacherRating, teacherReview, completedAt, cancelledAt, cancellationReason,
    createdAt, updatedAt,
  ];
}