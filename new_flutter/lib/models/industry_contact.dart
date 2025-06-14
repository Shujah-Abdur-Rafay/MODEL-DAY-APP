class IndustryContact {
  final String? id;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? createdBy;
  final bool isSample;
  final String name;
  final String? jobTitle;
  final String? company;
  final String? instagram;
  final String? mobile;
  final String? email;
  final String? city;
  final String? country;
  final String? notes;

  IndustryContact({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    this.isSample = false,
    required this.name,
    this.jobTitle,
    this.company,
    this.instagram,
    this.mobile,
    this.email,
    this.city,
    this.country,
    this.notes,
  });

  factory IndustryContact.fromJson(Map<String, dynamic> json) {
    return IndustryContact(
      id: json['id']?.toString(), // Ensure ID is a string
      createdDate: json['created_date'] != null
          ? DateTime.parse(json['created_date'])
          : json['createdAt'] != null
              ? (json['createdAt'] as dynamic).toDate()
              : null,
      updatedDate: json['updated_date'] != null
          ? DateTime.parse(json['updated_date'])
          : json['updatedAt'] != null
              ? (json['updatedAt'] as dynamic).toDate()
              : null,
      createdBy: json['created_by'] ?? json['userId'],
      isSample: json['is_sample'] ?? false,
      name: json['name']?.toString() ?? '',
      jobTitle: json['job_title']?.toString(),
      company: json['company']?.toString(),
      instagram: json['instagram']?.toString(),
      mobile: json['mobile']?.toString(),
      email: json['email']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_date': createdDate?.toIso8601String(),
      'updated_date': updatedDate?.toIso8601String(),
      'created_by': createdBy,
      'is_sample': isSample,
      'name': name,
      'job_title': jobTitle,
      'company': company,
      'instagram': instagram,
      'mobile': mobile,
      'email': email,
      'city': city,
      'country': country,
      'notes': notes,
    };
  }

  IndustryContact copyWith({
    String? id,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? createdBy,
    bool? isSample,
    String? name,
    String? jobTitle,
    String? company,
    String? instagram,
    String? mobile,
    String? email,
    String? city,
    String? country,
    String? notes,
  }) {
    return IndustryContact(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      createdBy: createdBy ?? this.createdBy,
      isSample: isSample ?? this.isSample,
      name: name ?? this.name,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      instagram: instagram ?? this.instagram,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      city: city ?? this.city,
      country: country ?? this.country,
      notes: notes ?? this.notes,
    );
  }

  /// Check if this contact has a valid ID for operations like delete/update
  bool get hasValidId => id != null && id!.isNotEmpty;

  /// Get display name for the contact
  String get displayName => name.isNotEmpty ? name : 'Unnamed Contact';

  /// Get display company info
  String get displayCompanyInfo {
    final parts = <String>[];
    if (jobTitle != null && jobTitle!.isNotEmpty) {
      parts.add(jobTitle!);
    }
    if (company != null && company!.isNotEmpty) {
      parts.add(company!);
    }
    return parts.join(' at ');
  }
}
