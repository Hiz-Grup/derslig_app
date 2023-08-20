class LoginResponseModel {
  final String xsrfToken;
  final String dersligCookie;
  final DateTime expireDate;

  LoginResponseModel({
    required this.xsrfToken,
    required this.dersligCookie,
    required this.expireDate,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      xsrfToken: json['xsrfToken'],
      dersligCookie: json['dersligCookie'],
      expireDate: DateTime.parse(json['expireDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xsrfToken': xsrfToken,
      'dersligCookie': dersligCookie,
      'expireDate': expireDate.toIso8601String(),
    };
  }
}
