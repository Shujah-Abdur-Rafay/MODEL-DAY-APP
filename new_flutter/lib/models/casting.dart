import '../services/castings_service.dart';

class Casting {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final String? location;
  final String? requirements;
  final String status;
  final String? clientName;
  final double? rate;
  final String? currency;
  final List<String>? images;

  Casting({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.location,
    this.requirements,
    required this.status,
    this.clientName,
    this.rate,
    this.currency,
    this.images,
  });

  factory Casting.fromJson(Map<String, dynamic> json) {
    return Casting(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      location: json['location'],
      requirements: json['requirements'],
      status: json['status'] ?? 'pending',
      clientName: json['client_name'],
      rate: json['rate']?.toDouble(),
      currency: json['currency'] ?? 'USD',
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'requirements': requirements,
      'status': status,
      'client_name': clientName,
      'rate': rate,
      'currency': currency,
      'images': images,
    };
  }

  static Future<List<Casting>> list() async {
    return await CastingsService.list();
  }

  static Future<Casting?> get(String id) async {
    return await CastingsService.get(id);
  }

  static Future<Casting?> create(Map<String, dynamic> data) async {
    return await CastingsService.create(data);
  }

  static Future<Casting?> update(String id, Map<String, dynamic> data) async {
    return await CastingsService.update(id, data);
  }

  static Future<bool> delete(String id) async {
    return await CastingsService.delete(id);
  }
}
