class Meeting {
  final String? id;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? createdBy;
  final bool isSample;
  final String clientName;
  final String? type;
  final String? location;
  final String? bookingAgent;
  final String date;
  final String? time;
  final String? endTime;
  final String? email;
  final String? phone;
  final String? rate;
  final String? currency;
  final String? notes;
  final String? status;

  Meeting({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    this.isSample = false,
    required this.clientName,
    this.type,
    this.location,
    this.bookingAgent,
    required this.date,
    this.time,
    this.endTime,
    this.email,
    this.phone,
    this.rate,
    this.currency = 'USD',
    this.notes,
    this.status = 'scheduled',
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'],
      createdDate: json['created_date'] != null
          ? DateTime.parse(json['created_date'])
          : null,
      updatedDate: json['updated_date'] != null
          ? DateTime.parse(json['updated_date'])
          : null,
      createdBy: json['created_by'],
      isSample: json['is_sample'] ?? false,
      clientName: json['client_name'] ?? '',
      type: json['type'],
      location: json['location'],
      bookingAgent: json['booking_agent'],
      date: json['date'] ?? '',
      time: json['time'],
      endTime: json['end_time'],
      email: json['email'],
      phone: json['phone'],
      rate: json['rate'],
      currency: json['currency'] ?? 'USD',
      notes: json['notes'],
      status: json['status'] ?? 'scheduled',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_date': createdDate?.toIso8601String(),
      'updated_date': updatedDate?.toIso8601String(),
      'created_by': createdBy,
      'is_sample': isSample,
      'client_name': clientName,
      'type': type,
      'location': location,
      'booking_agent': bookingAgent,
      'date': date,
      'time': time,
      'end_time': endTime,
      'email': email,
      'phone': phone,
      'rate': rate,
      'currency': currency,
      'notes': notes,
      'status': status,
    };
  }

  Meeting copyWith({
    String? id,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? createdBy,
    bool? isSample,
    String? clientName,
    String? type,
    String? location,
    String? bookingAgent,
    String? date,
    String? time,
    String? endTime,
    String? email,
    String? phone,
    String? rate,
    String? currency,
    String? notes,
    String? status,
  }) {
    return Meeting(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      createdBy: createdBy ?? this.createdBy,
      isSample: isSample ?? this.isSample,
      clientName: clientName ?? this.clientName,
      type: type ?? this.type,
      location: location ?? this.location,
      bookingAgent: bookingAgent ?? this.bookingAgent,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      rate: rate ?? this.rate,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}
