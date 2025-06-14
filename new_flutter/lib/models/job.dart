class Job {
  final String? id;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? createdBy;
  final bool isSample;
  final String clientName;
  final String type;
  final String location;
  final String? bookingAgent;
  final String date;
  final String? time;
  final String? endTime;
  final double rate;
  final String? currency;
  final String? files;
  final String? notes;
  final String? status;
  final String? paymentStatus;
  final String? requirements;
  final List<String>? images;
  final double? extraHours;
  final double? agencyFeePercentage;
  final double? taxPercentage;

  Job({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    this.isSample = false,
    required this.clientName,
    required this.type,
    required this.location,
    this.bookingAgent,
    required this.date,
    this.time,
    this.endTime,
    this.rate = 0,
    this.currency,
    this.files,
    this.notes,
    this.status = 'pending',
    this.paymentStatus = 'unpaid',
    this.requirements,
    this.images,
    this.extraHours,
    this.agencyFeePercentage,
    this.taxPercentage,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
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
      type: json['type'] ?? '',
      location: json['location'] ?? '',
      bookingAgent: json['booking_agent'],
      date: json['date'] ?? '',
      time: json['time'],
      endTime: json['end_time'],
      rate: (json['rate'] ?? 0).toDouble(),
      currency: json['currency'],
      files: json['files'],
      notes: json['notes'],
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      requirements: json['requirements'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      extraHours: json['extra_hours']?.toDouble(),
      agencyFeePercentage: json['agency_fee_percentage']?.toDouble(),
      taxPercentage: json['tax_percentage']?.toDouble(),
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
      'rate': rate,
      'currency': currency,
      'files': files,
      'notes': notes,
      'status': status,
      'payment_status': paymentStatus,
      'requirements': requirements,
      'images': images,
      'extra_hours': extraHours,
      'agency_fee_percentage': agencyFeePercentage,
      'tax_percentage': taxPercentage,
    };
  }

  String? formatTime() {
    if (time == null) return null;
    return time;
  }

  double calculateTotal() {
    double total = rate;
    if (extraHours != null) total += extraHours!;
    if (agencyFeePercentage != null) {
      total += total * (agencyFeePercentage! / 100);
    }
    if (taxPercentage != null) total += total * (taxPercentage! / 100);
    return total;
  }

  Job copyWith({
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
    double? rate,
    String? currency,
    String? files,
    String? notes,
    String? status,
    String? paymentStatus,
    String? requirements,
    List<String>? images,
    double? extraHours,
    double? agencyFeePercentage,
    double? taxPercentage,
  }) {
    return Job(
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
      rate: rate ?? this.rate,
      currency: currency ?? this.currency,
      files: files ?? this.files,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      requirements: requirements ?? this.requirements,
      images: images ?? this.images,
      extraHours: extraHours ?? this.extraHours,
      agencyFeePercentage: agencyFeePercentage ?? this.agencyFeePercentage,
      taxPercentage: taxPercentage ?? this.taxPercentage,
    );
  }
}
