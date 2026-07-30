/// App settings model stored in Hive.
class SettingsModel {
  const SettingsModel({
    this.isDarkMode = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.animationsEnabled = true,
    this.autoReconnect = true,
    this.language = 'ar',
  });

  final bool isDarkMode;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool animationsEnabled;
  final bool autoReconnect;
  final String language;

  SettingsModel copyWith({
    bool? isDarkMode,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? animationsEnabled,
    bool? autoReconnect,
    String? language,
  }) {
    return SettingsModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() => {
        'isDarkMode': isDarkMode,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        'animationsEnabled': animationsEnabled,
        'autoReconnect': autoReconnect,
        'language': language,
      };

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        isDarkMode: json['isDarkMode'] as bool? ?? true,
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
        animationsEnabled: json['animationsEnabled'] as bool? ?? true,
        autoReconnect: json['autoReconnect'] as bool? ?? true,
        language: json['language'] as String? ?? 'ar',
      );

  static const SettingsModel defaults = SettingsModel();
}

/// Local user profile stored in Hive.
class ProfileModel {
  const ProfileModel({
    required this.id,
    this.lastTeamName = '',
    this.lastTeamColor = 0xFF6C63FF,
    this.lastAvatar = 'lion',
    this.isFirstLaunch = true,
  });

  final String id;
  final String lastTeamName;
  final int lastTeamColor;
  final String lastAvatar;
  final bool isFirstLaunch;

  ProfileModel copyWith({
    String? id,
    String? lastTeamName,
    int? lastTeamColor,
    String? lastAvatar,
    bool? isFirstLaunch,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      lastTeamName: lastTeamName ?? this.lastTeamName,
      lastTeamColor: lastTeamColor ?? this.lastTeamColor,
      lastAvatar: lastAvatar ?? this.lastAvatar,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lastTeamName': lastTeamName,
        'lastTeamColor': lastTeamColor,
        'lastAvatar': lastAvatar,
        'isFirstLaunch': isFirstLaunch,
      };

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        lastTeamName: json['lastTeamName'] as String? ?? '',
        lastTeamColor: json['lastTeamColor'] as int? ?? 0xFF6C63FF,
        lastAvatar: json['lastAvatar'] as String? ?? 'lion',
        isFirstLaunch: json['isFirstLaunch'] as bool? ?? true,
      );
}
