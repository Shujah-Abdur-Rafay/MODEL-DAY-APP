class JobGallery {
  final String? id;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? createdBy;
  final bool isSample;
  final String name;
  final String? photographerName;
  final String? location;
  final String? hairMakeup;
  final String? stylist;
  final DateTime? date;
  final String? description;
  final String? images;

  JobGallery({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    this.isSample = false,
    required this.name,
    this.photographerName,
    this.location,
    this.hairMakeup,
    this.stylist,
    this.date,
    this.description,
    this.images,
  });

  factory JobGallery.fromJson(Map<String, dynamic> json) {
    return JobGallery(
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
      photographerName: json['photographer_name'],
      location: json['location'],
      hairMakeup: json['hair_makeup'],
      stylist: json['stylist'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      description: json['description'],
      images: json['images'],
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
      'photographer_name': photographerName,
      'location': location,
      'hair_makeup': hairMakeup,
      'stylist': stylist,
      'date': date?.toIso8601String().split('T')[0],
      'description': description,
      'images': images,
    };
  }

  JobGallery copyWith({
    String? id,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? createdBy,
    bool? isSample,
    String? name,
    String? photographerName,
    String? location,
    String? hairMakeup,
    String? stylist,
    DateTime? date,
    String? description,
    String? images,
  }) {
    return JobGallery(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      createdBy: createdBy ?? this.createdBy,
      isSample: isSample ?? this.isSample,
      name: name ?? this.name,
      photographerName: photographerName ?? this.photographerName,
      location: location ?? this.location,
      hairMakeup: hairMakeup ?? this.hairMakeup,
      stylist: stylist ?? this.stylist,
      date: date ?? this.date,
      description: description ?? this.description,
      images: images ?? this.images,
    );
  }
}
