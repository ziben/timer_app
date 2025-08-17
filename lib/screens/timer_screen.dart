import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/timer_provider.dart';
import '../models/timer_record.dart';
import '../services/database_service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService.instance;
  List<TimerRecord> _todayRecords = [];
  bool _isLoadingRecords = false;

  @override
  void initState() {
    super.initState();
    _loadTodayRecords();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayRecords() async {
    setState(() {
      _isLoadingRecords = true;
    });
    
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final records = await _databaseService.getRecordsByDate(today);
    
    setState(() {
      _todayRecords = records;
      _isLoadingRecords = false;
    });
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('计时器'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<TimerProvider>(
        builder: (context, timerProvider, child) {
          return Column(
            children: [
              // 计时器主界面 - 使用Expanded
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 计时显示
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade200, width: 2),
                      ),
                      child: Text(
                        timerProvider.formattedTime,
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                      
                    // 描述输入框
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: '任务描述（可选）',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      onChanged: (value) {
                        timerProvider.setDescription(value);
                      },
                      enabled: !timerProvider.isRunning,
                    ),
                    const SizedBox(height: 24),
                      
                    // 控制按钮
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        // 开始/暂停按钮
                        ElevatedButton.icon(
                          onPressed: () {
                            if (!timerProvider.isRunning && timerProvider.elapsedSeconds == 0) {
                              timerProvider.startTimer();
                            } else if (timerProvider.isRunning) {
                              timerProvider.pauseTimer();
                            } else {
                              timerProvider.resumeTimer();
                            }
                          },
                          icon: Icon(
                            timerProvider.isRunning 
                                ? Icons.pause 
                                : Icons.play_arrow,
                          ),
                          label: Text(
                            timerProvider.isRunning 
                                ? '暂停' 
                                : (timerProvider.elapsedSeconds > 0 ? '继续' : '开始'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: timerProvider.isRunning 
                                ? Colors.orange 
                                : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20, 
                              vertical: 12,
                            ),
                          ),
                        ),
                        
                        // 停止按钮
                        ElevatedButton.icon(
                          onPressed: timerProvider.elapsedSeconds > 0
                              ? () async {
                                  await timerProvider.stopTimer();
                                  _descriptionController.clear();
                                  _loadTodayRecords(); // 刷新当天记录
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('计时记录已保存'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.stop),
                          label: const Text('停止'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20, 
                              vertical: 12,
                            ),
                          ),
                        ),
                        
                        // 重置按钮
                        ElevatedButton.icon(
                          onPressed: timerProvider.elapsedSeconds > 0 && !timerProvider.isRunning
                              ? () {
                                  timerProvider.resetTimer();
                                  _descriptionController.clear();
                                }
                              : null,
                          icon: const Icon(Icons.refresh),
                          label: const Text('重置'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20, 
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
              
              // 当天记录显示区域
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Column(
                    children: [
                      // 标题栏
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.today, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              '今日计时记录',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const Spacer(),
                            if (!_isLoadingRecords)
                              Text(
                                '共 ${_todayRecords.length} 条',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // 记录列表
                      Expanded(
                        child: _isLoadingRecords
                            ? const Center(child: CircularProgressIndicator())
                            : _todayRecords.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.timer_off,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '今天还没有计时记录',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: _todayRecords.length,
                                    itemBuilder: (context, index) {
                                      final record = _todayRecords[index];
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // 时间和持续时间信息
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      '${_formatTime(record.startTime)} - ${record.endTime != null ? _formatTime(record.endTime!) : "进行中"}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: record.duration >= 15 ? Colors.green.shade100 : Colors.orange.shade100,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      record.formattedDuration,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: record.duration >= 15 ? Colors.green.shade700 : Colors.orange.shade700,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              
                                              // 描述信息
                                              if (record.description != null && record.description!.isNotEmpty) ...[
                                                const SizedBox(height: 8),
                                                Text(
                                                  record.description!,
                                                  style: const TextStyle(fontSize: 14),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ] else ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  '无描述',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade500,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
