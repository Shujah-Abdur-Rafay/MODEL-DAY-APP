import 'dart:convert';

class Contact {
  final String name;
  final String email;
  final String phone;

  Contact({
    required this.name,
    required this.email,
    required this.phone,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}

class Agency {
  final String? id;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? createdBy;
  final bool isSample;
  final String name;
  final String? agencyType;
  final String? website;
  final String? address;
  final String? city;
  final String? country;
  final Contact? mainBooker;
  final Contact? financeContact;
  final List<Contact> additionalContacts;
  final double commissionRate;
  final String? contract;
  final DateTime? contractSigned;
  final DateTime? contractExpired;
  final String? notes;
  final String? status;

  Agency({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    this.isSample = false,
    required this.name,
    this.agencyType,
    this.website,
    this.address,
    this.city,
    this.country,
    this.mainBooker,
    this.financeContact,
    this.additionalContacts = const [],
    this.commissionRate = 0.0,
    this.contract,
    this.contractSigned,
    this.contractExpired,
    this.notes,
    this.status,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
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
      agencyType: json['agency_type'],
      website: json['website'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      mainBooker: _parseContact(json['main_booker']),
      financeContact: _parseContact(json['finance_contact']),
      additionalContacts: _parseContactList(json['additional_contacts']),
      commissionRate: (json['commission_rate'] ?? 0).toDouble(),
      contract: json['contract'],
      contractSigned: json['contract_signed'] != null
          ? DateTime.parse(json['contract_signed'])
          : null,
      contractExpired: json['contract_expired'] != null
          ? DateTime.parse(json['contract_expired'])
          : null,
      notes: json['notes'],
      status: json['status'],
    );
  }

  static Contact? _parseContact(dynamic contactData) {
    if (contactData == null) return null;

    Map<String, dynamic> contactMap;
    if (contactData is String) {
      try {
        contactMap = jsonDecode(contactData);
      } catch (e) {
        return null;
      }
    } else if (contactData is Map<String, dynamic>) {
      contactMap = contactData;
    } else {
      return null;
    }

    return Contact.fromJson(contactMap);
  }

  static List<Contact> _parseContactList(dynamic contactsData) {
    if (contactsData == null) return [];

    List<dynamic> contactsList;
    if (contactsData is String) {
      try {
        contactsList = jsonDecode(contactsData);
      } catch (e) {
        return [];
      }
    } else if (contactsData is List) {
      contactsList = contactsData;
    } else {
      return [];
    }

    return contactsList
        .map((contact) => Contact.fromJson(contact as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_date': createdDate?.toIso8601String(),
      'updated_date': updatedDate?.toIso8601String(),
      'created_by': createdBy,
      'is_sample': isSample,
      'name': name,
      'agency_type': agencyType,
      'website': website,
      'address': address,
      'city': city,
      'country': country,
      'main_booker':
          mainBooker != null ? jsonEncode(mainBooker!.toJson()) : null,
      'finance_contact':
          financeContact != null ? jsonEncode(financeContact!.toJson()) : null,
      'additional_contacts': additionalContacts.isNotEmpty
          ? jsonEncode(additionalContacts.map((c) => c.toJson()).toList())
          : null,
      'commission_rate': commissionRate,
      'contract': contract,
      'contract_signed': contractSigned?.toIso8601String(),
      'contract_expired': contractExpired?.toIso8601String(),
      'notes': notes,
      'status': status,
    };
  }

  Agency copyWith({
    String? id,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? createdBy,
    bool? isSample,
    String? name,
    String? agencyType,
    String? website,
    String? address,
    String? city,
    String? country,
    Contact? mainBooker,
    Contact? financeContact,
    List<Contact>? additionalContacts,
    double? commissionRate,
    String? contract,
    DateTime? contractSigned,
    DateTime? contractExpired,
    String? notes,
    String? status,
  }) {
    return Agency(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      createdBy: createdBy ?? this.createdBy,
      isSample: isSample ?? this.isSample,
      name: name ?? this.name,
      agencyType: agencyType ?? this.agencyType,
      website: website ?? this.website,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      mainBooker: mainBooker ?? this.mainBooker,
      financeContact: financeContact ?? this.financeContact,
      additionalContacts: additionalContacts ?? this.additionalContacts,
      commissionRate: commissionRate ?? this.commissionRate,
      contract: contract ?? this.contract,
      contractSigned: contractSigned ?? this.contractSigned,
      contractExpired: contractExpired ?? this.contractExpired,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}
