# timer_app

A new Flutter project.

# 计时器应用 (Timer App)

一个基于Flutter的计时应用，支持每日多次计时记录和统计功能。

## 功能特性

### 计时器功能
- 实时计时显示 (HH:MM:SS格式)
- 开始/暂停/继续/停止/重置操作
- 支持为每次计时添加任务描述

### 统计汇总
- 每日计时统计
- 总计时间显示
- 可视化数据展示

### 记录明细
- 查看所有计时记录
- 按日期筛选记录
- 删除不需要的记录
- 显示开始/结束时间和持续时间

## 技术架构

- **框架**: Flutter 3.0+
- **状态管理**: Provider
- **本地存储**: SQLite (sqflite)
- **日期处理**: intl
- **界面导航**: 底部Tab导航

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/
│   └── timer_record.dart     # 计时记录数据模型
├── providers/
│   └── timer_provider.dart   # 计时器状态管理
├── services/
│   └── database_service.dart # SQLite数据库服务
└── screens/
    ├── home_screen.dart      # 主界面导航
    ├── timer_screen.dart     # 计时器界面
    ├── statistics_screen.dart # 统计汇总界面
    └── records_screen.dart   # 记录明细界面
```

## 运行应用

1. 确保已安装Flutter SDK
2. 获取依赖包：
   ```bash
   flutter pub get
   ```
3. 运行应用：
   ```bash
   flutter run
   ```

## 测试

运行单元测试：
```bash
flutter test
```

## 依赖包

- `provider: ^6.0.5` - 状态管理
- `sqflite: ^2.3.0` - SQLite数据库
- `path: ^1.8.3` - 路径处理
- `intl: ^0.18.1` - 国际化和日期格式化
- `shared_preferences: ^2.2.2` - 本地存储偏好设置

## 使用说明

1. **开始计时**: 点击"开始"按钮开始计时
2. **暂停/继续**: 计时过程中可随时暂停和继续
3. **添加描述**: 可为计时任务添加描述信息
4. **停止计时**: 点击"停止"保存计时记录
5. **查看统计**: 在统计页面查看每日汇总
6. **管理记录**: 在记录页面查看、筛选和删除记录
