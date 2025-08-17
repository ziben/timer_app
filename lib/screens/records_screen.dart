import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/timer_record.dart';
import '../services/database_service.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<TimerRecord> _records = [];
  Map<String, List<TimerRecord>> _groupedRecords = {};
  Map<String, bool> _expandedDates = {}; // 记录每个日期的展开状态
  bool _isLoading = true;
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
    });
    
    List<TimerRecord> records;
    if (_selectedDate != null) {
      records = await _databaseService.getRecordsByDate(_selectedDate!);
    } else {
      records = await _databaseService.getAllRecords();
    }
    
    // 按日期分组
    Map<String, List<TimerRecord>> grouped = {};
    for (var record in records) {
      String date = _formatDate(record.startTime);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(record);
    }
    
    // 初始化展开状态 - 默认展开今天和昨天
    Map<String, bool> expandedStates = {};
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterday = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));
    
    for (String date in grouped.keys) {
      expandedStates[date] = date == today || date == yesterday;
    }
    
    setState(() {
      _records = records;
      _groupedRecords = grouped;
      _expandedDates = expandedStates;
      _isLoading = false;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
      _loadRecords();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
    _loadRecords();
  }

  Future<void> _deleteRecord(TimerRecord record) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条计时记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && record.id != null) {
      await _databaseService.deleteRecord(record.id!);
      _loadRecords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('记录已删除'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  String _formatDisplayDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final recordDate = DateTime(date.year, date.month, date.day);
    
    if (recordDate == today) {
      return '今天 (${DateFormat('MM-dd').format(date)})';
    } else if (recordDate == yesterday) {
      return '昨天 (${DateFormat('MM-dd').format(date)})';
    } else {
      return DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(date);
    }
  }

  int _getTotalDurationForDate(List<TimerRecord> records) {
    return records.fold(0, (sum, record) => sum + record.duration);
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}小时${minutes}分钟${secs}秒';
    } else if (minutes > 0) {
      return '${minutes}分钟${secs}秒';
    } else {
      return '${secs}秒';
    }
  }

  Widget _buildGroupedRecordList() {
    final sortedDates = _groupedRecords.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // 按日期降序排列
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final records = _groupedRecords[date]!;
        final totalDuration = _getTotalDurationForDate(records);
        final isExpanded = _expandedDates[date] ?? false;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期分组标题 - 可点击折叠/展开
            InkWell(
              onTap: () {
                setState(() {
                  _expandedDates[date] = !isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    // 折叠/展开图标
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    
                    // 日期文本
                    Expanded(
                      child: Text(
                        _formatDisplayDate(date),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    
                    // 统计信息
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${records.length}条 · ${_formatDuration(totalDuration)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 该日期的记录列表 - 根据展开状态显示
            if (isExpanded) ...[
              ...records.map((record) => _buildRecordCard(record)),
            ],
            
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildRecordList(List<TimerRecord> records) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        return _buildRecordCard(records[index]);
      },
    );
  }

  Widget _buildRecordCard(TimerRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.play_arrow, 
                         color: Colors.green.shade600, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '开始: ${_formatDateTime(record.startTime)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    if (record.endTime != null) ...[
                      Icon(Icons.stop, 
                           color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '结束: ${_formatDateTime(record.endTime!)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteRecord(record);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('删除'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: record.duration >= 15 ? Colors.green.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, 
                           color: record.duration >= 15 ? Colors.green.shade700 : Colors.orange.shade700, 
                           size: 16),
                      const SizedBox(width: 4),
                      Text(
                        record.formattedDuration,
                        style: TextStyle(
                          color: record.duration >= 15 ? Colors.green.shade700 : Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (record.description != null && record.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record.description!,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('计时记录'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearDateFilter,
              tooltip: '清除日期筛选',
            ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: '选择日期',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecords,
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选提示
          if (_selectedDate != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    '筛选日期: $_selectedDate',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          
          // 记录列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.list_alt,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedDate != null ? '该日期无计时记录' : '暂无计时记录',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '开始计时后记录会显示在这里',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadRecords,
                        child: _selectedDate != null 
                            ? _buildRecordList(_records)
                            : _buildGroupedRecordList(),
                      ),
          ),
        ],
      ),
    );
  }
}
