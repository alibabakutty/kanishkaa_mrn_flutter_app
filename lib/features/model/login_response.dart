
class LoginResponse {
  final String username;
  final String token;
  final String role;

  LoginResponse({required this.username, required this.token, required this.role});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      username: json['username']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}