
class LoginResponse {
  final String userEmployeeId;
  final String username;
  final String company;
  final String token;
  final String role;

  LoginResponse({required this.userEmployeeId, required this.username, required this.company, required this.token, required this.role});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userEmployeeId: json['userEmployeeId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}