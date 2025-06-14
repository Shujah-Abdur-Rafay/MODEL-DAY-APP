import '../services/tests_service.dart';

class Test {
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

  Test({
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

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      requirements: json['requirements'],
      status: json['status'],
      clientName: json['client_name'],
      rate: json['rate']?.toDouble(),
      currency: json['currency'],
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

  static Future<List<Test>> list() async {
    return await TestsService.list();
  }

  static Future<Test?> get(String id) async {
    return await TestsService.get(id);
  }

  static Future<Test?> create(Map<String, dynamic> data) async {
    return await TestsService.create(data);
  }

  static Future<Test?> update(String id, Map<String, dynamic> data) async {
    return await TestsService.update(id, data);
  }

  static Future<bool> delete(String id) async {
    return await TestsService.delete(id);
  }
}
