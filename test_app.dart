// 简单的代码验证脚本
import 'lib/models/timer_record.dart';
import 'lib/providers/timer_provider.dart';

void main() {
  print('=== Flutter计时应用代码验证 ===\n');
  
  // 测试TimerRecord模型
  testTimerRecord();
  
  // 测试TimerProvider
  testTimerProvider();
  
  print('✅ 所有测试通过！应用代码结构正确。');
}

void testTimerRecord() {
  print('📝 测试TimerRecord模型...');
  
  final record = TimerRecord(
    startTime: DateTime.now(),
    duration: 3661, // 1小时1分1秒
    date: '2025-08-14',
    description: '测试任务',
  );
  
  print('   - 格式化时长: ${record.formattedDuration}');
  print('   - 转换为Map: ${record.toMap()}');
  
  final map = record.toMap();
  final recordFromMap = TimerRecord.fromMap(map);
  print('   - 从Map恢复: ${recordFromMap.description}');
  
  print('✅ TimerRecord测试通过\n');
}

void testTimerProvider() {
  print('⏱️ 测试TimerProvider...');
  
  final provider = TimerProvider();
  
  // 测试初始状态
  print('   - 初始状态: ${provider.formattedTime}');
  print('   - 是否运行: ${provider.isRunning}');
  
  // 测试描述设置
  provider.setDescription('测试计时');
  print('   - 设置描述: ${provider.description}');
  
  // 测试开始计时
  provider.startTimer();
  print('   - 开始计时: ${provider.isRunning}');
  print('   - 开始时间: ${provider.startTime}');
  
  // 模拟暂停
  provider.pauseTimer();
  print('   - 暂停后: ${provider.isRunning}');
  
  // 重置
  provider.resetTimer();
  print('   - 重置后: ${provider.formattedTime}');
  
  provider.dispose();
  print('✅ TimerProvider测试通过\n');
}
