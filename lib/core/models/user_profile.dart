import 'dart:convert';

class UserProfile {
  final String agentName;
  final String projectName;
  final String projectSlug;
  final String company;
  final String techStack;
  final List<String> customModules;
  final bool isConfigured;

  const UserProfile({
    this.agentName = '',
    this.projectName = '',
    this.projectSlug = '',
    this.company = '',
    this.techStack = 'python',
    this.customModules = const [],
    this.isConfigured = false,
  });

  UserProfile copyWith({
    String? agentName, String? projectName, String? projectSlug,
    String? company, String? techStack, List<String>? customModules,
    bool? isConfigured,
  }) {
    return UserProfile(
      agentName: agentName ?? this.agentName,
      projectName: projectName ?? this.projectName,
      projectSlug: projectSlug ?? this.projectSlug,
      company: company ?? this.company,
      techStack: techStack ?? this.techStack,
      customModules: customModules ?? this.customModules,
      isConfigured: isConfigured ?? this.isConfigured,
    );
  }

  static String slugify(String name) {
    return name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').trim().replaceAll(RegExp(r'\s+'), '-');
  }

  Map<String, dynamic> toJson() => {
    'agentName': agentName, 'projectName': projectName, 'projectSlug': projectSlug,
    'company': company, 'techStack': techStack, 'customModules': customModules,
    'isConfigured': isConfigured,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    agentName: json['agentName'] ?? '', projectName: json['projectName'] ?? '',
    projectSlug: json['projectSlug'] ?? '', company: json['company'] ?? '',
    techStack: json['techStack'] ?? 'python',
    customModules: List<String>.from(json['customModules'] ?? []),
    isConfigured: json['isConfigured'] ?? false,
  );

  String encode() => jsonEncode(toJson());
  static UserProfile decode(String json) => UserProfile.fromJson(jsonDecode(json));
}
