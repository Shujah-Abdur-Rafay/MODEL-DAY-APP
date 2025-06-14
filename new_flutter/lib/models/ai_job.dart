class AiJob {
  final String? id;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? createdBy;
  final bool isSample;
  final String clientName;
  final String? type;
  final String? description;
  final String? location;
  final String? bookingAgent;
  final DateTime? date;
  final String? time;
  final double? rate;
  final String? currency;
  final Map<String, dynamic>? aiAssets;
  final String? status;
  final String? paymentStatus;
  final String? notes;

  AiJob({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    this.isSample = false,
    required this.clientName,
    this.type,
    this.description,
    this.location,
    this.bookingAgent,
    this.date,
    this.time,
    this.rate,
    this.currency = 'USD',
    this.aiAssets,
    this.status = 'pending',
    this.paymentStatus = 'unpaid',
    this.notes,
  });

  factory AiJob.fromJson(Map<String, dynamic> json) {
    return AiJob(
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
      description: json['description'],
      location: json['location'],
      bookingAgent: json['booking_agent'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      time: json['time'],
      rate: json['rate']?.toDouble(),
      currency: json['currency'] ?? 'USD',
      aiAssets: json['ai_assets'],
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'unpaid',
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
      'type': type,
      'description': description,
      'location': location,
      'booking_agent': bookingAgent,
      'date': date?.toIso8601String().split('T')[0],
      'time': time,
      'rate': rate,
      'currency': currency,
      'ai_assets': aiAssets,
      'status': status,
      'payment_status': paymentStatus,
      'notes': notes,
    };
  }

  AiJob copyWith({
    String? id,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? createdBy,
    bool? isSample,
    String? clientName,
    String? type,
    String? description,
    String? location,
    String? bookingAgent,
    DateTime? date,
    String? time,
    double? rate,
    String? currency,
    Map<String, dynamic>? aiAssets,
    String? status,
    String? paymentStatus,
    String? notes,
  }) {
    return AiJob(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      createdBy: createdBy ?? this.createdBy,
      isSample: isSample ?? this.isSample,
      clientName: clientName ?? this.clientName,
      type: type ?? this.type,
      description: description ?? this.description,
      location: location ?? this.location,
      bookingAgent: bookingAgent ?? this.bookingAgent,
      date: date ?? this.date,
      time: time ?? this.time,
      rate: rate ?? this.rate,
      currency: currency ?? this.currency,
      aiAssets: aiAssets ?? this.aiAssets,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
    );
  }
}
