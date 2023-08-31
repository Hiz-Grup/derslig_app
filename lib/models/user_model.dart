class UserModel {
  bool? isPremium;
  String? name;
  String? surname;
  String? email;
  String? phone;
  String? schoolName;
  String? schoolLevel;
  String? schoolClass;
  String? schoolBranch;

  UserModel({
    this.isPremium,
    this.name,
    this.surname,
    this.email,
    this.phone,
    this.schoolName,
    this.schoolLevel,
    this.schoolClass,
    this.schoolBranch,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      isPremium: json['is_premium'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      phone: json['phone'],
      schoolName: json['school_name'],
      schoolLevel: json['school_level'],
      schoolClass: json['school_class'],
      schoolBranch: json['school_branch'],
    );
  }

  Map<String, dynamic> toJson() => {
        'is_premium': isPremium,
        'name': name,
        'surname': surname,
        'email': email,
        'phone': phone,
        'school_name': schoolName,
        'school_level': schoolLevel,
        'school_class': schoolClass,
        'school_branch': schoolBranch,
      };
}
