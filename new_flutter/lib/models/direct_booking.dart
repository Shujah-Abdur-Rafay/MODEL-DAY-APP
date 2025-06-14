class DirectBooking {
  final String? id;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? createdBy;
  final bool isSample;
  final String clientName;
  final String? bookingType;
  final String? location;
  final String? bookingAgent;
  final DateTime? date;
  final String? time;
  final String? endTime;
  final double? rate;
  final String? currency;
  final String? extraHours;
  final String? agencyFeePercentage;
  final String? taxPercentage;
  final String? additionalFees;
  final String? phone;
  final String? email;
  final String? status;
  final String? paymentStatus;
  final Map<String, dynamic>? files;
  final String? notes;

  DirectBooking({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    this.isSample = false,
    required this.clientName,
    this.bookingType,
    this.location,
    this.bookingAgent,
    this.date,
    this.time,
    this.endTime,
    this.rate,
    this.currency = 'USD',
    this.extraHours,
    this.agencyFeePercentage,
    this.taxPercentage,
    this.additionalFees,
    this.phone,
    this.email,
    this.status = 'scheduled',
    this.paymentStatus = 'unpaid',
    this.files,
    this.notes,
  });

  factory DirectBooking.fromJson(Map<String, dynamic> json) {
    try {
      return DirectBooking(
        id: json['id']?.toString(),
        createdDate: _parseDateTime(json['created_date']),
        updatedDate: _parseDateTime(json['updated_date']),
        createdBy: json['created_by']?.toString(),
        isSample: json['is_sample'] == true,
        clientName: json['client_name']?.toString() ?? '',
        bookingType: json['booking_type']?.toString(),
        location: json['location']?.toString(),
        bookingAgent: json['booking_agent']?.toString(),
        date: _parseDateTime(json['date']),
        time: json['time']?.toString(),
        endTime: json['end_time']?.toString(),
        rate: _parseDouble(json['rate']),
        currency: json['currency']?.toString() ?? 'USD',
        extraHours: json['extra_hours']?.toString(),
        agencyFeePercentage: json['agency_fee_percentage']?.toString(),
        taxPercentage: json['tax_percentage']?.toString(),
        additionalFees: json['additional_fees']?.toString(),
        phone: json['phone']?.toString(),
        email: json['email']?.toString(),
        status: json['status']?.toString() ?? 'scheduled',
        paymentStatus: json['payment_status']?.toString() ?? 'unpaid',
        files: json['files'] is Map<String, dynamic> ? json['files'] : null,
        notes: json['notes']?.toString(),
      );
    } catch (e) {
      throw FormatException('Error parsing DirectBooking from JSON: $e. JSON: $json');
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_date': createdDate?.toIso8601String(),
      'updated_date': updatedDate?.toIso8601String(),
      'created_by': createdBy,
      'is_sample': isSample,
      'client_name': clientName,
      'booking_type': bookingType,
      'location': location,
      'booking_agent': bookingAgent,
      'date': date?.toIso8601String().split('T')[0],
      'time': time,
      'end_time': endTime,
      'rate': rate,
      'currency': currency,
      'extra_hours': extraHours,
      'agency_fee_percentage': agencyFeePercentage,
      'tax_percentage': taxPercentage,
      'additional_fees': additionalFees,
      'phone': phone,
      'email': email,
      'status': status,
      'payment_status': paymentStatus,
      'files': files,
      'notes': notes,
    };
  }

  DirectBooking copyWith({
    String? id,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? createdBy,
    bool? isSample,
    String? clientName,
    String? bookingType,
    String? location,
    String? bookingAgent,
    DateTime? date,
    String? time,
    String? endTime,
    double? rate,
    String? currency,
    String? extraHours,
    String? agencyFeePercentage,
    String? taxPercentage,
    String? additionalFees,
    String? phone,
    String? email,
    String? status,
    String? paymentStatus,
    Map<String, dynamic>? files,
    String? notes,
  }) {
    return DirectBooking(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      createdBy: createdBy ?? this.createdBy,
      isSample: isSample ?? this.isSample,
      clientName: clientName ?? this.clientName,
      bookingType: bookingType ?? this.bookingType,
      location: location ?? this.location,
      bookingAgent: bookingAgent ?? this.bookingAgent,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      rate: rate ?? this.rate,
      currency: currency ?? this.currency,
      extraHours: extraHours ?? this.extraHours,
      agencyFeePercentage: agencyFeePercentage ?? this.agencyFeePercentage,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      additionalFees: additionalFees ?? this.additionalFees,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      files: files ?? this.files,
      notes: notes ?? this.notes,
    );
  }
}
