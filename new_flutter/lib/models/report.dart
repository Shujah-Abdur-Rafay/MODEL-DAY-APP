class Report {
  final String? id;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? createdBy;
  final bool isSample;
  final String title;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? paymentStatus;
  final String? dateFilter;
  final String? exportUrl;
  final int totalJobs;
  final double totalAmount;

  Report({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    this.isSample = false,
    required this.title,
    this.dateFrom,
    this.dateTo,
    this.paymentStatus,
    this.dateFilter,
    this.exportUrl,
    this.totalJobs = 0,
    this.totalAmount = 0.0,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      createdDate: json['created_date'] != null 
          ? DateTime.parse(json['created_date']) 
          : null,
      updatedDate: json['updated_date'] != null 
          ? DateTime.parse(json['updated_date']) 
          : null,
      createdBy: json['created_by'],
      isSample: json['is_sample'] ?? false,
      title: json['title'] ?? '',
      dateFrom: json['date_from'] != null ? DateTime.parse(json['date_from']) : null,
      dateTo: json['date_to'] != null ? DateTime.parse(json['date_to']) : null,
      paymentStatus: json['payment_status'],
      dateFilter: json['date_filter'],
      exportUrl: json['export_url'],
      totalJobs: json['total_jobs'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_date': createdDate?.toIso8601String(),
      'updated_date': updatedDate?.toIso8601String(),
      'created_by': createdBy,
      'is_sample': isSample,
      'title': title,
      'date_from': dateFrom?.toIso8601String().split('T')[0],
      'date_to': dateTo?.toIso8601String().split('T')[0],
      'payment_status': paymentStatus,
      'date_filter': dateFilter,
      'export_url': exportUrl,
      'total_jobs': totalJobs,
      'total_amount': totalAmount,
    };
  }

  Report copyWith({
    String? id,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? createdBy,
    bool? isSample,
    String? title,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? paymentStatus,
    String? dateFilter,
    String? exportUrl,
    int? totalJobs,
    double? totalAmount,
  }) {
    return Report(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      createdBy: createdBy ?? this.createdBy,
      isSample: isSample ?? this.isSample,
      title: title ?? this.title,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      dateFilter: dateFilter ?? this.dateFilter,
      exportUrl: exportUrl ?? this.exportUrl,
      totalJobs: totalJobs ?? this.totalJobs,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
