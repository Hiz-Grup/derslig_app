class UserModel {
  int? id;
  int? type;
  String? name;
  String? surname;
  String? email;
  String? phone;
  int? isPremium;

  UserModel(
      {this.id,
      this.type,
      this.name,
      this.surname,
      this.email,
      this.phone,
      this.isPremium = 0});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    name = json['name'];
    surname = json['surname'];
    email = json['email'];
    phone = json['phone'];
    isPremium = json['is_premium'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['name'] = name;
    data['surname'] = surname;
    data['email'] = email;
    data['phone'] = phone;
    data['is_premium'] = isPremium;
    return data;
  }
}
