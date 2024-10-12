class UserModel {
  int? id;
  int? type;
  String? name;
  String? surname;
  String? email;
  String? phone;
  int? isPremium;
  int? schoolLevelId;
  int? gradeId;
  int? branchId;
  int? schoolId;

  UserModel({
    this.id,
    this.type,
    this.name,
    this.surname,
    this.email,
    this.phone,
    this.isPremium,
    this.schoolLevelId,
    this.gradeId,
    this.branchId,
    this.schoolId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      phone: json['phone'],
      isPremium: json['is_premium'],
      schoolLevelId: json['school_level_id'],
      gradeId: json['grade_id'],
      branchId: json['branch_id'],
      schoolId: json['school_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'is_premium': isPremium,
      'school_level_id': schoolLevelId,
      'grade_id': gradeId,
      'branch_id': branchId,
      'school_id': schoolId,
    };
  }

  Map<String, dynamic> toJsonForOneSignal() {
    return {
      'id': id ?? 0,
      'type': type ?? 0,
      'name': name ?? '-',
      'surname': surname ?? '-',
      'email': email ?? '-',
      'phone': phone ?? '-',
      'is_premium': isPremium ?? 0,
      'school_level_id': schoolLevelId ?? 0,
      'grade_id': gradeId ?? 0,
      'branch_id': branchId ?? 0,
      'school_id': schoolId ?? 0,
    };
  }
}
