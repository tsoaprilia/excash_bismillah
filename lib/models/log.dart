const String tableLogActivity = 'log_activity';

class LogActivityFields {
  static const String id_log = 'id_log';
  static const String date = 'date';
  static const String type = 'type';
  static const String user = 'user';
  static const String username = 'username';
  static const String operation = 'operation';
  static const String oldValue = 'oldValue';  // Field for old value
  static const String newValue = 'newValue';  // Field for new value
}

class LogActivity {
  final int? id_log;
  final String date;
  final String type;
  final String user;
  final String username;
  final String operation;
  final String? oldValue;
  final String? newValue;

  LogActivity({
    this.id_log,
    required this.date,
    required this.type,
    required this.user,
    required this.username,
    required this.operation,
    this.oldValue,
    this.newValue,
  });

  LogActivity copy({
    int? id_log,
    String? date,
    String? type,
    String? user,
    String? username,
    String? operation,
    String? oldValue,
    String? newValue,
  }) =>
      LogActivity(
        id_log: id_log ?? this.id_log,
        date: date ?? this.date,
        type: type ?? this.type,
        user: user ?? this.user,
        username: username ?? this.username,
        operation: operation ?? this.operation,
        oldValue: oldValue ?? this.oldValue,
        newValue: newValue ?? this.newValue,
      );

  static LogActivity fromJson(Map<String, Object?> json) => LogActivity(
        id_log: json[LogActivityFields.id_log] as int?,
        date: json[LogActivityFields.date] as String,
        type: json[LogActivityFields.type] as String,
        user: json[LogActivityFields.user] as String,
        username: json[LogActivityFields.username] as String,
        operation: json[LogActivityFields.operation] as String,
        oldValue: json[LogActivityFields.oldValue] as String?,
        newValue: json[LogActivityFields.newValue] as String?,
      );

  Map<String, Object?> toJson() => {
        LogActivityFields.id_log: id_log,
        LogActivityFields.date: date,
        LogActivityFields.type: type,
        LogActivityFields.user: user,
        LogActivityFields.username: username,
        LogActivityFields.operation: operation,
        LogActivityFields.oldValue: oldValue,
        LogActivityFields.newValue: newValue,
      };
}

