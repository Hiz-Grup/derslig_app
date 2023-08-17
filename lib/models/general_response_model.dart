class GeneralResponseModel {
  final String message;
  final bool success;

  GeneralResponseModel({required this.message, required this.success});

  factory GeneralResponseModel.fromJson(Map<String, dynamic> json) {
    return GeneralResponseModel(
      message: json['message'] != null ? json['message'] : "",
      success: json['success'] != null ? json['success'] : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "success": success,
    };
  }
}
