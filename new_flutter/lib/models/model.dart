import '../services/models_service.dart';

class Model {
  final String? id;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? createdBy;
  final String name;
  final String? email;
  final String? phone;
  final String? agency;
  final String? height;
  final String? measurements;
  final String? hairColor;
  final String? eyeColor;
  final String? location;
  final String? experience;
  final String? specialties;
  final String? portfolio;
  final String? notes;
  final bool isActive;

  Model({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    required this.name,
    this.email,
    this.phone,
    this.agency,
    this.height,
    this.measurements,
    this.hairColor,
    this.eyeColor,
    this.location,
    this.experience,
    this.specialties,
    this.portfolio,
    this.notes,
    this.isActive = true,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['id'],
      createdDate: json['created_date'] != null 
          ? DateTime.parse(json['created_date']) 
          : null,
      updatedDate: json['updated_date'] != null 
          ? DateTime.parse(json['updated_date']) 
          : null,
      createdBy: json['created_by'],
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      agency: json['agency'],
      height: json['height'],
      measurements: json['measurements'],
      hairColor: json['hair_color'],
      eyeColor: json['eye_color'],
      location: json['location'],
      experience: json['experience'],
      specialties: json['specialties'],
      portfolio: json['portfolio'],
      notes: json['notes'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_date': createdDate?.toIso8601String(),
      'updated_date': updatedDate?.toIso8601String(),
      'created_by': createdBy,
      'name': name,
      'email': email,
      'phone': phone,
      'agency': agency,
      'height': height,
      'measurements': measurements,
      'hair_color': hairColor,
      'eye_color': eyeColor,
      'location': location,
      'experience': experience,
      'specialties': specialties,
      'portfolio': portfolio,
      'notes': notes,
      'is_active': isActive,
    };
  }

  static Future<List<Model>> list() async {
    return await ModelsService.list();
  }

  static Future<Model?> create(Map<String, dynamic> data) async {
    return await ModelsService.create(data);
  }

  static Future<Model?> update(String id, Map<String, dynamic> data) async {
    return await ModelsService.update(id, data);
  }

  static Future<bool> delete(String id) async {
    return await ModelsService.delete(id);
  }

  static Future<Model?> getById(String id) async {
    return await ModelsService.getById(id);
  }

  Model copyWith({
    String? id,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? createdBy,
    String? name,
    String? email,
    String? phone,
    String? agency,
    String? height,
    String? measurements,
    String? hairColor,
    String? eyeColor,
    String? location,
    String? experience,
    String? specialties,
    String? portfolio,
    String? notes,
    bool? isActive,
  }) {
    return Model(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      createdBy: createdBy ?? this.createdBy,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      agency: agency ?? this.agency,
      height: height ?? this.height,
      measurements: measurements ?? this.measurements,
      hairColor: hairColor ?? this.hairColor,
      eyeColor: eyeColor ?? this.eyeColor,
      location: location ?? this.location,
      experience: experience ?? this.experience,
      specialties: specialties ?? this.specialties,
      portfolio: portfolio ?? this.portfolio,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }
}
