enum EventType {
  option,
  job,
  directOption,
  directBooking,
  casting,
  onStay,
  test,
  polaroids,
  meeting,
  other,
}

extension EventTypeExtension on EventType {
  String get displayName {
    switch (this) {
      case EventType.option:
        return 'Option';
      case EventType.job:
        return 'Job';
      case EventType.directOption:
        return 'Direct Option';
      case EventType.directBooking:
        return 'Direct Booking';
      case EventType.casting:
        return 'Casting';
      case EventType.onStay:
        return 'On Stay';
      case EventType.test:
        return 'Test';
      case EventType.polaroids:
        return 'Polaroids';
      case EventType.meeting:
        return 'Meeting';
      case EventType.other:
        return 'Other';
    }
  }

  int get sortOrder {
    switch (this) {
      case EventType.option:
        return 1;
      case EventType.job:
        return 2;
      case EventType.directOption:
        return 3;
      case EventType.directBooking:
        return 4;
      case EventType.casting:
        return 5;
      case EventType.onStay:
        return 6;
      case EventType.test:
        return 7;
      case EventType.polaroids:
        return 8;
      case EventType.meeting:
        return 9;
      case EventType.other:
        return 10;
    }
  }
}

enum EventStatus {
  scheduled,
  inProgress,
  completed,
  canceled,
  declined,
  postponed,
}

enum PaymentStatus {
  unpaid,
  partiallyPaid,
  paid,
}

enum OptionStatus {
  pending,
  clientCanceled,
  iDeclined,
  postponed,
  declined,
}

extension OptionStatusExtension on OptionStatus {
  String get displayName {
    switch (this) {
      case OptionStatus.pending:
        return 'Pending';
      case OptionStatus.clientCanceled:
        return 'Client Canceled';
      case OptionStatus.iDeclined:
        return 'I Declined';
      case OptionStatus.postponed:
        return 'Postponed';
      case OptionStatus.declined:
        return 'Declined';
    }
  }
}

class Event {
  final String? id;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? createdBy;
  final EventType type;
  final String? clientName;
  final DateTime? date;
  final DateTime? endDate;
  final String? startTime;
  final String? endTime;
  final String? location;
  final String? agentId;
  final double? dayRate;
  final double? usageRate;
  final String? currency;
  final EventStatus? status;
  final PaymentStatus? paymentStatus;
  final OptionStatus? optionStatus;
  final String? notes;
  final Map<String, dynamic>? files;
  final Map<String, dynamic>? additionalData;

  Event({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    required this.type,
    this.clientName,
    this.date,
    this.endDate,
    this.startTime,
    this.endTime,
    this.location,
    this.agentId,
    this.dayRate,
    this.usageRate,
    this.currency = 'USD',
    this.status,
    this.paymentStatus,
    this.optionStatus,
    this.notes,
    this.files,
    this.additionalData,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      createdDate: json['created_date'] != null
          ? DateTime.parse(json['created_date'])
          : null,
      updatedDate: json['updated_date'] != null
          ? DateTime.parse(json['updated_date'])
          : null,
      createdBy: json['created_by'],
      type: EventType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => EventType.other,
      ),
      clientName: json['client_name'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      startTime: json['start_time'],
      endTime: json['end_time'],
      location: json['location'],
      agentId: json['agent_id'],
      dayRate: json['day_rate']?.toDouble(),
      usageRate: json['usage_rate']?.toDouble(),
      currency: json['currency'] ?? 'USD',
      status: json['status'] != null
          ? EventStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['status'],
              orElse: () => EventStatus.scheduled,
            )
          : null,
      paymentStatus: json['payment_status'] != null
          ? PaymentStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['payment_status'],
              orElse: () => PaymentStatus.unpaid,
            )
          : null,
      optionStatus: json['option_status'] != null
          ? OptionStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['option_status'],
              orElse: () => OptionStatus.pending,
            )
          : null,
      notes: json['notes'],
      files: json['files'],
      additionalData: json['additional_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_date': createdDate?.toIso8601String(),
      'updated_date': updatedDate?.toIso8601String(),
      'created_by': createdBy,
      'type': type.toString().split('.').last,
      'client_name': clientName,
      'date': date?.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'location': location,
      'agent_id': agentId,
      'day_rate': dayRate,
      'usage_rate': usageRate,
      'currency': currency,
      'status': status?.toString().split('.').last,
      'payment_status': paymentStatus?.toString().split('.').last,
      'option_status': optionStatus?.toString().split('.').last,
      'notes': notes,
      'files': files,
      'additional_data': additionalData,
    };
  }



  Event copyWith({
    String? id,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? createdBy,
    EventType? type,
    String? clientName,
    DateTime? date,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    String? location,
    String? agentId,
    double? dayRate,
    double? usageRate,
    String? currency,
    EventStatus? status,
    PaymentStatus? paymentStatus,
    OptionStatus? optionStatus,
    String? notes,
    Map<String, dynamic>? files,
    Map<String, dynamic>? additionalData,
  }) {
    return Event(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      createdBy: createdBy ?? this.createdBy,
      type: type ?? this.type,
      clientName: clientName ?? this.clientName,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      agentId: agentId ?? this.agentId,
      dayRate: dayRate ?? this.dayRate,
      usageRate: usageRate ?? this.usageRate,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      optionStatus: optionStatus ?? this.optionStatus,
      notes: notes ?? this.notes,
      files: files ?? this.files,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
