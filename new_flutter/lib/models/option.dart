class Option {
  final String id;
  final String clientName;
  final String type;
  final String date;
  final String? time;
  final String? endTime;
  final String? location;
  final String? agentId;
  final double? rate;
  final String? currency;
  final double? extraHours;
  final double? agencyFeePercentage;
  final double? taxPercentage;
  final String status;
  final String paymentStatus;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Option({
    required this.id,
    required this.clientName,
    required this.type,
    required this.date,
    this.time,
    this.endTime,
    this.location,
    this.agentId,
    this.rate,
    this.currency,
    this.extraHours,
    this.agencyFeePercentage,
    this.taxPercentage,
    required this.status,
    required this.paymentStatus,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] ?? '',
      clientName: json['client_name'] ?? '',
      type: json['type'] ?? '',
      date: json['date'] ?? '',
      time: json['time'],
      endTime: json['end_time'],
      location: json['location'],
      agentId: json['agent_id'],
      rate: json['rate']?.toDouble(),
      currency: json['currency'],
      extraHours: json['extra_hours']?.toDouble(),
      agencyFeePercentage: json['agency_fee_percentage']?.toDouble(),
      taxPercentage: json['tax_percentage']?.toDouble(),
      status: json['status'] ?? 'Pending',
      paymentStatus: json['payment_status'] ?? 'Unpaid',
      notes: json['notes'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_name': clientName,
      'type': type,
      'date': date,
      'time': time,
      'end_time': endTime,
      'location': location,
      'agent_id': agentId,
      'rate': rate,
      'currency': currency,
      'extra_hours': extraHours,
      'agency_fee_percentage': agencyFeePercentage,
      'tax_percentage': taxPercentage,
      'status': status,
      'payment_status': paymentStatus,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Option copyWith({
    String? id,
    String? clientName,
    String? type,
    String? date,
    String? time,
    String? endTime,
    String? location,
    String? agentId,
    double? rate,
    String? currency,
    double? extraHours,
    double? agencyFeePercentage,
    double? taxPercentage,
    String? status,
    String? paymentStatus,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Option(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      agentId: agentId ?? this.agentId,
      rate: rate ?? this.rate,
      currency: currency ?? this.currency,
      extraHours: extraHours ?? this.extraHours,
      agencyFeePercentage: agencyFeePercentage ?? this.agencyFeePercentage,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Option(id: $id, clientName: $clientName, type: $type, date: $date, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Option && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
