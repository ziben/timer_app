import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/timer_record.dart';
import '../services/database_service.dart';

class TimerProvider extends ChangeNotifier {
  Timer? _timer;
  DateTime? _startTime;
  int _elapsedMilliseconds = 0;
  bool _isRunning = false;
  String _description = '';
  
  final DatabaseService _databaseService = DatabaseService.instance;

  bool get isRunning => _isRunning;
  int get elapsedSeconds => _elapsedMilliseconds ~/ 1000;
  String get description => _description;
  DateTime? get startTime => _startTime;

  String get formattedTime {
    final totalSeconds = _elapsedMilliseconds ~/ 1000;
    final milliseconds = _elapsedMilliseconds % 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    if (hours > 0) {
      // 当计时达到1小时时，显示完整的时:分:秒.毫秒格式
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(3, '0')}';
    } else {
      // 初始时不显示小时
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(3, '0')}';
    }
  }

  void setDescription(String desc) {
    _description = desc;
    notifyListeners();
  }

  void startTimer() {
    if (_isRunning) return;
    
    _startTime = DateTime.now();
    _isRunning = true;
    _elapsedMilliseconds = 0;
    
    _timer = Timer.periodic(const Duration(milliseconds: 5), (timer) {
      _elapsedMilliseconds += 5;
      notifyListeners();
    });
    
    notifyListeners();
  }

  void pauseTimer() {
    if (!_isRunning) return;
    
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resumeTimer() {
    if (_isRunning || _startTime == null) return;
    
    _isRunning = true;
    _timer = Timer.periodic(const Duration(milliseconds: 5), (timer) {
      _elapsedMilliseconds += 5;
      notifyListeners();
    });
    
    notifyListeners();
  }

  Future<void> stopTimer() async {
    if (_startTime == null) return;
    
    _timer?.cancel();
    final endTime = DateTime.now();
    
    final record = TimerRecord(
      startTime: _startTime!,
      endTime: endTime,
      duration: _elapsedMilliseconds ~/ 1000,
      description: _description.isEmpty ? null : _description,
      date: DateFormat('yyyy-MM-dd').format(_startTime!),
    );
    
    await _databaseService.insertRecord(record);
    
    _reset();
  }

  void _reset() {
    _timer?.cancel();
    _startTime = null;
    _elapsedMilliseconds = 0;
    _isRunning = false;
    _description = '';
    notifyListeners();
  }

  void resetTimer() {
    _reset();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
