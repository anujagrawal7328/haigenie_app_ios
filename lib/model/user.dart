class User {
  String? name;
  String? email;
  String? organisation;
  String? whatsappNo;
  String? department;
  String? district;
  String? state;
  bool? paid;
  String? userType;
  int? availableAttempts;

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
        availableAttempts: json['recordingsRemaining']);
  }
  Map<String, dynamic> toJson() {
    return {
      'user_name': name,
      'email': email,
      'user_organization': organisation,
      'user_number': whatsappNo,
      'user_department': department,
      'user_district': district,
      'user_state': state,
      'paid': paid,
      'user_type': userType,
      'recordingsRemaining': availableAttempts,
    };
  }
}
