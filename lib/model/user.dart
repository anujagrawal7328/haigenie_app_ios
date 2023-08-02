class User {
  String? name;
  String? email;
  String? organisation;
  String? whatsappNo;
  String? department;
  String? district;
  String? state;
  String? device_type;
  bool? paid;
  String? userType;
  int? availableAttempts;
  int? certificationAttempts;
  String? userRole;

  User({
    this.name,
    this.email,
    this.organisation,
    this.whatsappNo,
    this.department,
    this.district,
    this.state,
    this.paid,
    this.userType,
    this.availableAttempts,
    this.certificationAttempts,
    this.device_type,
    this.userRole
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        name: json['user_name'],
        email: json['user_email'],
        organisation: json['user_organization'],
        whatsappNo: json['user_number'],
        department: json['user_department'],
        district: json['user_district'],
        state: json['user_state'],
        userType: json['user_type'],
        paid:json['paid'],
        availableAttempts: json['recordingsRemaining'],
        certificationAttempts:json['certificationAttemptsRemaining'],
        device_type:json['device_type'],
        userRole:json['user_role']);
  }
  Map<String, dynamic> toJson() {
    return {
      'user_name': name,
      'email': email,
      'organization_name': organisation,
      'contact_no': whatsappNo,
      'user_department': department,
      'user_district': district,
      'user_state': state,
      'paid': paid,
      'user_type': userType,
      'recordingsRemaining': availableAttempts,
      'certificationAttemptsRemaining': certificationAttempts,
      'device_type':device_type,
      'user_role':userRole
    };
  }
}
