class DirectOptions {
  final String? id;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? createdBy;
  final bool isSample;
  final String clientName;
  final String? optionType;
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

  DirectOptions({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    this.isSample = false,
    required this.clientName,
    this.optionType,
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
    this.status = 'option',
    this.paymentStatus = 'unpaid',
    this.files,
    this.notes,
  });

  factory DirectOptions.fromJson(Map<String, dynamic> json) {
    return DirectOptions(
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
      optionType: json['option_type'],
      location: json['location'],
      bookingAgent: json['booking_agent'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      time: json['time'],
      endTime: json['end_time'],
      rate: json['rate']?.toDouble(),
      currency: json['currency'] ?? 'USD',
      extraHours: json['extra_hours'],
      agencyFeePercentage: json['agency_fee_percentage'],
      taxPercentage: json['tax_percentage'],
      additionalFees: json['additional_fees'],
      phone: json['phone'],
      email: json['email'],
      status: json['status'] ?? 'option',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      files: json['files'],
      notes: json['notes'],
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
      'option_type': optionType,
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

  DirectOptions copyWith({
    String? id,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? createdBy,
    bool? isSample,
    String? clientName,
    String? optionType,
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
    return DirectOptions(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      createdBy: createdBy ?? this.createdBy,
      isSample: isSample ?? this.isSample,
      clientName: clientName ?? this.clientName,
      optionType: optionType ?? this.optionType,
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
