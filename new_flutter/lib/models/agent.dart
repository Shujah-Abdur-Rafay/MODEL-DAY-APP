class Agent {
  final String? id;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? createdBy;
  final bool isSample;
  final String name;
  final String? email;
  final String? phone;
  final String? agency;
  final String? city;
  final String? country;
  final String? instagram;
  final String? notes;

  Agent({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    this.isSample = false,
    required this.name,
    this.email,
    this.phone,
    this.agency,
    this.city,
    this.country,
    this.instagram,
    this.notes,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'],
      createdDate: json['created_date'] != null
          ? DateTime.parse(json['created_date'])
          : null,
      updatedDate: json['updated_date'] != null
          ? DateTime.parse(json['updated_date'])
          : null,
      createdBy: json['created_by'],
      isSample: json['is_sample'] ?? false,
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      agency: json['agency'],
      city: json['city'],
      country: json['country'],
      instagram: json['instagram'],
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
      'name': name,
      'email': email,
      'phone': phone,
      'agency': agency,
      'city': city,
      'country': country,
      'instagram': instagram,
      'notes': notes,
    };
  }

  Agent copyWith({
    String? id,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? createdBy,
    bool? isSample,
    String? name,
    String? email,
    String? phone,
    String? agency,
    String? city,
    String? country,
    String? instagram,
    String? notes,
  }) {
    return Agent(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      createdBy: createdBy ?? this.createdBy,
      isSample: isSample ?? this.isSample,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      agency: agency ?? this.agency,
      city: city ?? this.city,
      country: country ?? this.country,
      instagram: instagram ?? this.instagram,
      notes: notes ?? this.notes,
    );
  }
}
