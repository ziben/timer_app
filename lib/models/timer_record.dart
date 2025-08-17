class TimerRecord {
  final int? id;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration; // 持续时间（秒）
  final String? description;
  final String date; // YYYY-MM-DD格式

  TimerRecord({
    this.id,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'duration': duration,
      'description': description,
      'date': date,
    };
  }

  factory TimerRecord.fromMap(Map<String, dynamic> map) {
    return TimerRecord(
      id: map['id'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: map['endTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime'])
          : null,
      duration: map['duration'],
      description: map['description'],
      date: map['date'],
    );
  }

  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
