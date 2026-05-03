# ChatSao 聊天应用 — Flutter 前端技术文档

## 一、项目概览

| 项目 | 说明 |
|------|------|
| 项目名称 | ChatSao |
| 应用类型 | 实时 1v1 私聊 IM 应用（支持文本 + 语音消息） |
| 框架 | Flutter (Dart) |
| SDK 版本 | ^3.12.0-320.0.dev |
| 构建目标 | Web (`flutter run -d chrome --web-port=5000`) / Android / iOS |

---

## 二、依赖清单与技术选型

### 2.1 第三方依赖 (`pubspec.yaml`)

| 包名 | 版本 | 用途 | 核心作用 |
|------|------|------|----------|
| **dio** | ^5.4.0 | HTTP 网络请求 | 所有 RESTful API 的发送与接收，含拦截器机制 |
| **shared_preferences** | ^2.2.2 | 本地持久化存储 | 存储 JWT Token、用户 ID、用户名等登录态信息 |
| **web_socket_channel** | ^3.0.1 | WebSocket 双向通信 | 实时消息收发，替代轮询实现即时聊天 |
| **record** | ^5.1.2 | 音频录制 | 浏览器/移动端麦克风录音（Web 用 Opus 编码，移动端用 AAC） |
| **audioplayers** | ^6.1.0 | 音频播放 | 语音消息回放，支持 URL 远程音频流播放 |
| **path_provider** | ^2.1.5 | 文件路径获取 | 移动端临时目录路径（录音文件存储位置） |
| **cupertino_icons** | ^1.0.8 | iOS 风格图标库 | UI 图标补充 |
| **flutter_lints** | ^6.0.0 | 代码规范检查 | 开发阶段静态分析约束 |

### 2.2 Flutter 内置框架/组件

| 技术 | 使用场景 |
|------|----------|
| **Material Design 3** (`useMaterial3: true`) | 全局主题体系（ThemeData）、按钮、输入框、对话框等 |
| **StatefulWidget + setState** | 页面级状态管理（ChatListScreen、ChatDetailScreen 等） |
| **AnimationController** | 登录页 Logo 浮动动画、联系人页滑入动画、语音波形播放动画 |
| **StreamController / Stream** | WebSocket 消息广播分发（多页面同时监听同一数据流） |
| **StreamController.broadcast() 事件总线** | 跨页面事件通知（AppEventBus 替代 GlobalKey），降低耦合度 |
| **CustomPaint + CustomPainter** | 语音消息气泡中的实时波形动画绘制 |
| **BackdropFilter + ImageFilter.blur()** | 毛玻璃效果（Glassmorphism）UI 组件 |
| **AnimatedSwitcher** | 页面切换过渡动画（main.dart 中屏幕切换） |
| **showGeneralDialog** | 自定义弹窗（添加好友搜索弹窗） |
| **RefreshIndicator** | 下拉刷新（Messages 列表） |
| **ListView.builder** | 高性能列表渲染（好友列表、消息列表、会话列表） |
| **TextField + TextEditingController** | 搜索框、用户名密码输入、聊天输入框 |
| **SingleTickerProviderStateMixin** | 动画控制器绑定（需要 vsync） |
| **kIsWeb** | 编译时常量，区分 Web 和移动端平台逻辑 |

---

## 三、项目目录结构

```
lib/
├── main.dart                          # 应用入口 + 导航路由管理
├── models/
│   ├── user.dart                      # 用户模型（Mock 数据，已废弃）
│   ├── chat_thread.dart               # 聊天线程模型
│   └── message.dart                   # 消息模型
├── screens/
│   ├── login_screen.dart              # 登录/注册页
│   ├── chat_list_screen.dart          # 消息会话列表页（首页）
│   ├── chat_detail_screen.dart        # 聊天详情页（1v1 对话 + 录音 + 播放）
│   ├── contacts_screen.dart           # 通讯录/联系人页
│   └── settings_screen.dart           # 设置页
├── services/
│   ├── api_service.dart               # Dio HTTP 客户端封装（全局单例 + JWT 拦截器）
│   ├── auth_service.dart              # 认证服务（登录/注册/Token 管理）
│   ├── chat_service.dart              # 聊天服务（会话列表/历史记录/标记已读）
│   ├── friend_service.dart            # 好友服务（搜索/添加/接受/拒绝）
│   ├── websocket_service.dart         # WebSocket 服务（单例 + 广播流 + 心跳 + 重连 + 事件总线）
│   └── file_upload_service.dart       # 文件上传服务（音频 Multipart 上传，Web/移动端双兼容）
├── theme/
│   ├── app_colors.dart                # 全局颜色常量定义
│   └── app_theme.dart                 # Material3 主题配置
└── widgets/
    ├── app_card.dart                  # 自定义 UI 组件集合
    │   ├── GradientBackground          # 渐变背景 + 角落光晕
    │   ├── AvatarBlob                 # 有机形状头像容器
    │   ├── OrganicBubbleAi             # AI/接收方聊天气泡（含语音气泡支持）
    │   ├── OrganicBubbleUser           # 发送方聊天气泡（含语音气泡支持）
    │   ├── LiquidBadge                # 未读数角标
    │   └── OrganicInput               # 有机形状输入框（带聚焦动画 + 麦克风按钮）
    └── glassmorphism/
        └── glassmorphism_container.dart  # 毛玻璃容器（三种工厂模式）
```

---

## 四、核心功能模块详解

### 4.1 用户认证系统

**涉及文件**: [auth_service.dart](lib/services/auth_service.dart), [api_service.dart](lib/services/api_service.dart)

#### 技术方案：JWT Token + SharedPreferences 持久化

```
用户输入账号密码
       ↓
AuthService.login() → ApiService.post('/api/user/login')
       ↓
后端返回 { token, userId, username }
       ↓
SharedPreferences 本地存储（4 个 key）
       ↓
后续所有请求 → Dio 拦截器自动附加 Header:
  Authorization: Bearer <token>
```

#### 关键实现细节：

**1）Token 存储层** ([auth_service.dart](lib/services/auth_service.dart))
```dart
static const _tokenKey = 'jwt_token';
static const _userIdKey = 'user_id';
static const _usernameKey = 'username';

// 内存缓存 + getter 快速访问
static String? get token => _cachedToken;
static int? get userId => _cachedUserId;
```

**2）HTTP 拦截器自动鉴权** ([api_service.dart](lib/services/api_service.dart))
```dart
static final Dio _dio = Dio(BaseOptions(...))
  ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = AuthService.token;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
```
→ **效果**：所有 API 请求无需手动传 Token，拦截器统一处理。

**3）401 自动登出**
```dart
if (e.response?.statusCode == 401) {
  await AuthService.logout();  // 清除本地存储
  throw ApiException('登录已过期，请重新登录');
}
```

---

### 4.2 WebSocket 实时通信

**涉及文件**: [websocket_service.dart](lib/services/websocket_service.dart)

#### 技术方案：单例模式 + StreamController 广播

```
                    ┌─────────────────────┐
                    │  WebSocketService   │
                    │    （全局单例）      │
                    │                     │
  connect() ──────► │  _channel ◄───────┼── ws://localhost:8081/ws/chat?token=xxx
                    │                     │
  sendMessage() ──► │  _channel.sink     │
                    │         │           │
                    │         ▼           │
                    │  jsonDecode(data)   │
                    │         │           │
                    │         ▼           │
                    │  _messageController  │◄── StreamController.broadcast()
                    │         │           │
                    │         ▼           │
     messageStream ─┼────────┼───────────┼──► ChatListScreen 监听（实时更新会话）
                    │         │           │
                    │         ├───────────┼──► ChatDetailScreen 监听（实时显示消息）
                    │                     │
                    └─────────────────────┘
```

#### 关键实现细节：

**1）单例模式**
```dart
static final WebSocketService _instance = WebSocketService._internal();
factory WebSocketService() => _instance;
WebSocketService._internal();
```

**2）广播流（Broadcast Stream）**
```dart
final StreamController<Map<String, dynamic>> _messageController =
    StreamController<Map<String, dynamic>>.broadcast();
```
→ 一个消息可以被多个 Listener 同时消费。ChatListScreen 和 ChatDetailScreen 可以同时监听同一条消息流。

**3）连接状态机（防并发重连风暴）**
```dart
bool _connected = false;     // 连接就绪标志
bool _connecting = false;    // 正在连接中标志
bool _intentionalClose = false; // 主动关闭标志（区别于异常断开）
```
- `connect()` 时检查 `_connected || _connecting` 防止重复发起连接
- 断线时仅当 `_intentionalClose == false` 才触发重连
- `disconnect()` 设置 `_intentionalClose = true` 停止自动重连

**4）指数退避重连**
```dart
int _reconnectDelay = 3;          // 初始 3 秒
static const int _maxReconnectDelay = 60;  // 最大 60 秒

void _scheduleReconnect() {
  _reconnectDelay = (_reconnectDelay * 2).clamp(3, _maxReconnectDelay);
  // 3s → 6s → 12s → 24s → 48s → 60s → 60s → ...
}
```

**5）心跳保活机制**
```dart
static const Duration _heartbeatInterval = Duration(seconds: 30);

void _startHeartbeat() {
  _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
    _channel!.sink.add(jsonEncode({'type': 'PING'}));
  });
}
```
→ 每 30s 发送 PING，后端回复 PONG。前端收到 PONG 不透传给 UI（直接 return），避免污染消息流。

**6）JWT 握手认证**
```dart
Uri.parse('ws://localhost:8081/ws/chat?token=$token'),
```

**7）AppEventBus 事件总线**
```dart
class AppEventBus {
  static final StreamController<String> _controller =
      StreamController<String>.broadcast();
  static Stream<String> get stream => _controller.stream;
  static void emit(String event) { _controller.add(event); }
  static const String refreshSessions = 'refresh_sessions';
}
```
→ ChatListScreen 订阅此 stream，从 chat 返回时触发刷新。完全替代 GlobalKey 方案。

---

### 4.3 消息会话列表（Messages 首页）

**涉及文件**: [chat_list_screen.dart](lib/screens/chat_list_screen.dart), [chat_service.dart](lib/services/chat_service.dart)

#### 功能对标微信：
- ✅ 显示每个好友的最后一条消息内容（**智能识别消息类型**：文本原文 / 语音显示"🎤 语音消息"）
- ✅ 显示最后一条消息的时间戳（今天 HH:MM AM/PM / Yesterday / Mon）
- ✅ 显示未读消息数量（红色角标）
- ✅ 收到新消息时**实时更新**（WebSocket 推送 + setState 刷新）
- ✅ 点击进入聊天时清除小红点并标记已读（乐观更新 + 异步通知后端）
- ✅ 支持按用户名搜索过滤
- ✅ 下拉刷新

#### 数据流向：

```
┌──────────────┐     GET /api/chat/sessions     ┌──────────────┐
│  后端 Spring  │ ◄──────────────────────────── │ ChatListScreen│
│    Boot       │ ─────────────────────────────► │   initState  │
│              │  返回 List<ChatSessionVO>      │              │
│              │  - friendId                    │  _sessions   │
│              │  - friendUsername              │  _filteredSessions
│              │  - lastMessage                 │              │
│              │  - lastMsgType ← 新增！         │              │
│              │  - unreadCount                 │              │
│              │  - lastTime                    │              │
└──────────────┘                                └──────┬───────┘
                                                       │
                       WebSocket messageStream 监听      │
                                                       ▼
                                              _onWsMessage(data):
                                                1. 解析 msgType 字段
                                                2. 找到对应 session
                                                3. 更新 lastMessage + lastMsgType
                                                4. 更新 lastTime
                                                5. unreadCount++ (对方发的)
                                                6. 移到列表顶部
                                                7. setState 刷新 UI
```

#### 关键实现：消息类型感知显示

```dart
String _getDisplayText(ChatSessionVO session) {
  if (session.lastMessage.isEmpty) return '';
  if (session.lastMsgType == 3) return '🎤 语音消息';  // 语音不显示 URL
  return session.lastMessage;                           // 文本显示原文
}
```

→ **效果**：语音消息在会话列表中显示为 `🎤 语音消息`，而非一串 `http://...webm` URL。

#### 关键实现：点击标记已读
```dart
void _onChatTap(int friendId, String friendName) async {
  // 1. 立即清零本地小红点（乐观更新）
  final idx = _sessions.indexWhere((s) => s.friendId == friendId);
  if (idx != -1) {
    setState(() {
      _sessions[idx].unreadCount = 0;
      _applyFilter();
    });
  }

  // 2. 异步通知后端标记已读
  try {
    await ChatService.markAsRead(friendId);  // PUT /api/chat/read?friendId=x
  } catch (_) {}

  // 3. 跳转到聊天详情页
  widget.onChatSelect(friendId, friendName);
}
```

---

### 4.4 聊天详情页（1v1 对话 + 语音消息）

**涉及文件**: [chat_detail_screen.dart](lib/screens/chat_detail_screen.dart)

#### 功能全景：
- 文本消息发送与接收
- **语音消息录制、上传、发送、播放**
- 历史消息加载（含语音消息渲染）
- 消息去重（按 msgId）
- 自动滚动到底部
- 在线状态指示灯

#### 页面生命周期流程：

```
进入页面 initState()
   ↓
1. 创建 AudioRecorder + AudioPlayer 实例
2. 创建播放动画 AnimationController（1200ms 循环）
3. 监听 audioPlayer.onPlayerComplete（播放结束停止动画）
4. _wsService.connect() — 确保 WebSocket 已连接
5. 订阅 messageStream → _onMessageReceived
6. PUT /api/chat/read?friendId=x — 标记已读
7. GET /api/chat/history?friendId=x — 加载历史记录
8. 渲染消息列表（根据 msgType 区分文本/语音气泡）
   ↓
【用户操作分支】
   ├─ 输入文本 → 点击发送 → sendMessage({msgType:0})
   ├─ 点击麦克风 → 开始录音 → 再次点击 → 停止+上传+发送({msgType:3})
   ├─ 点击语音气泡 → playVoice() → 播放音频 + 波形动画
   └─ 收到新消息 → 去重 → 插入列表 → 滚动到底部
```

#### 4.4.1 语音消息完整链路

```
用户点击麦克风按钮
       ↓
_toggleRecording() → _startRecording()
       ↓
平台判断:
  ├─ Web (kIsWeb=true):  path=''，encoder=AudioEncoder.opus
  └─ Mobile:            path=tempDir/voice_xxx.m4a，encoder=AudioEncoder.aacLc
       ↓
_audioRecorder.start(config, path: path)
       ↓
Timer.periodic 每秒更新 _recordingDuration → UI 显示 "录音中 0:05"
       ↓
用户再次点击麦克风
       ↓
_toggleRecording() → _stopRecordingAndSend()
       ↓
_audioRecorder.stop() → 返回 pathOrUrl
       ↓
FileUploadService.uploadAudio(pathOrUrl)
  ├─ Web: Dio GET blob URL → bytes → MultipartFile.fromBytes
  └─ Mobile: MultipartFile.fromFile(pathOrUrl)
       ↓
POST /api/file/upload (Multipart, Bearer Token)
       ↓
返回 URL: http://localhost:8081/uploads/xxx.webm
       ↓
_sendVoiceMessage(url)
  → _wsService.sendMessage({ receiverId, content: url, msgType: 3 })
       ↓
后端持久化 + WebSocket 推送给对端
       ↓
对端收到 msgType==3 → 渲染语音气泡 → 点击可播放
```

#### 4.4.2 录音状态管理

```dart
bool _isRecording = false;        // 是否正在录音
bool _isUploading = false;        // 是否正在上传（阻止重复操作）
Duration _recordingDuration;       // 录音时长计时
Timer? _recordingTimer;            // 计时器引用
```

交互方式：**点击切换**（非长按），适配 Web 平台触摸操作：
- 第 1 次点击 → 开始录音（按钮变红色 + 显示录音条）
- 第 2 次点击 → 停止录音 + 上传 + 发送
- 录音中点击 X 按钮 → 取消录音（丢弃）

#### 4.4.3 语音气泡 UI

```
┌─────────────────────────────────────┐
│  ▰▰▰▰  ▶  语音消息          ▰▰▰▰  │  ← 发送方（蓝色气泡）
└─────────────────────────────────────┘

  👤  ▰▰▰▰  ▶  语音消息                ← 接收方（暖色气泡 + 头像）
```

组件构成：
- **播放/暂停图标**: `Icons.play_circle_fill` / `Icons.pause_circle`（28px）
- **文字标签**: `"语音消息"`（13px 半透明）
- **波形动画**: `CustomPaint` + `_WaveformPainter`，播放时动态波动

#### 4.4.4 语音播放控制

```dart
int? _playingMsgId;              // 当前正在播放的消息 ID（null=未播放）
late AnimationController _playAnimController;  // 波形动画控制器

Future<void> _playVoice(ChatMessageItem msg) async {
  if (_playingMsgId == msg.msgId) {
    // 正在播放 → 停止
    await _audioPlayer.stop();
    setState(() => _playingMsgId = null);
    _playAnimController.stop();
    return;
  }

  // 切换到新消息播放
  setState(() => _playingMsgId = msg.msgId);
  _playAnimController.repeat();  // 启动循环波形动画
  await _audioPlayer.play(UrlSource(msg.content));  // 播放远程 URL 音频
}

// 播放完成回调
_audioPlayer.onPlayerComplete.listen((_) {
  setState(() => _playingMsgId = null);
  _playAnimController.stop();
});
```

#### 4.4.5 消息去重机制
```dart
void _onMessageReceived(Map<String, dynamic> data) {
  final msg = ChatMessageItem(msgId: data['msgId'] as int, ...);

  final exists = _messages.any((m) => m.msgId == msg.msgId);
  if (exists) return;  // 按 msgId 去重，防止重连导致重复推送

  setState(() => _messages.add(msg));
  _scrollToBottom();
}
```

#### 4.4.6 气泡区分逻辑
- **自己发的** → 右对齐 `OrganicBubbleUser`（蓝色渐变气泡）
- **对方发的** → 左对齐 `OrganicBubbleAi`（暖色渐变气泡 + 头像）
- **msgType == 3** → 渲染 `_buildVoiceBubble()`（带播放图标和波形动画）
- **msgType == 0** → 渲染文本气泡

---

### 4.5 文件上传服务

**涉及文件**: [file_upload_service.dart](lib/services/file_upload_service.dart)

#### 技术方案：Dio Multipart + Web/Mobile 双兼容

```dart
class FileUploadService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8081',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  static Future<String?> uploadAudio(String pathOrUrl) async {
    FormData formData;

    if (kIsWeb) {
      // Web 平台：stop() 返回 blob URL，需要先下载为 bytes 再上传
      final blobResponse = await Dio().get<List<int>>(
        pathOrUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(blobResponse.data!, filename: 'voice.webm'),
      });
    } else {
      // 移动平台：stop() 返回本地文件路径，直接读取
      formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(pathOrUrl),
      });
    }

    final response = await _dio.post('/api/file/upload', data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}));

    return response.data['data'];  // 返回可访问的 URL
  }
}
```

#### 关键设计决策：

| 问题 | 解决方案 | 原因 |
|------|----------|------|
| Web 端 `dart:io.File` 不可用 | 使用 `MultipartFile.fromBytes` | Web 没有 File System API |
| Web 端 stop() 返回 blob URL 而非文件路径 | 先通过 Dio GET 下载为 bytes | record 包在 Web 端使用 Blob 存储 |
| 移动端 stop() 返回真实文件路径 | 直接使用 `MultipartFile.fromFile` | 性能最优，无需内存拷贝 |
| 上传超时 | connectTimeout/receiveTimeout 各 30s | 音频文件可能较大 |

---

### 4.6 好友关系管理

**涉及文件**: [friend_service.dart](lib/services/friend_service.dart), [contacts_screen.dart](lib/screens/contacts_screen.dart)

#### API 映射表：

| 前端方法 | HTTP 方法 | 后端接口 | 功能 |
|----------|-----------|----------|------|
| `FriendService.searchUser(query)` | GET | `/api/friend/search?username=xx` | 模糊搜索用户 |
| `FriendService.addFriend(friendId)` | POST | `/api/friend/add` | 发送好友请求 |
| `FriendService.getFriendList()` | GET | `/api/friend/list` | 获取好友列表 |
| `FriendService.getFriendRequests()` | GET | `/api/friend/requests` | 获取待处理的好友请求 |
| `FriendService.acceptFriend(requesterId)` | POST | `/api/friend/accept` | 接受好友请求 |
| `FriendService.rejectFriend(requesterId)` | POST | `/api/friend/reject` | 拒绝好友请求 |

#### 搜索弹窗实现：
使用 `showGeneralDialog` 创建自定义模态弹窗，包含：
- 渐变背景头部
- 输入框 + 搜索按钮
- 搜索结果列表（每个用户带"添加"按钮）
- 缩放 + 淡入动画过渡效果

---

### 4.7 导航路由系统

**涉及文件**: [main.dart](lib/main.dart)

#### 方案：状态驱动导航（非 Navigator 2.0）

```dart
class _AppNavigatorState extends State<AppNavigator> {
  String? _currentScreen;          // 当前页面标识符
  int? _chatFriendId;              // 聊天对象 ID
  String? _chatFriendName;         // 聊天对象名称

  void _navigateTo(String screen, {int? friendId, String? friendName}) {
    setState(() {
      _currentScreen = screen;
    });
    if (screen == 'chatList') {
      AppEventBus.emit(AppEventBus.refreshSessions);  // 事件总线通知刷新
    }
  }
}
```

页面映射：
| _currentScreen | Widget | 底部导航栏 |
|---------------|--------|-----------|
| `'login'` | LoginScreen | ❌ |
| `'chatList'` | ChatListScreen | ✅ |
| `'chat'` | ChatDetailScreen | ❌ |
| `'contacts'` | ContactsScreen | ✅ |
| `'settings'` | SettingsScreen | ✅ |

**页面切换方式**：`AnimatedSwitcher` + `ValueKey(_currentScreen)`，300ms 交叉淡入淡出。

**认证流程**：
```
initState → _checkAuthState()
  → SharedPreferences 读取 token
  → 有 token → _currentScreen='chatList' + WebSocket.connect()
  → 无 token → _currentScreen='login'
```

**登出流程**：
```
_handleLogout()
  → WebSocket.disconnect()  (设置 intentionalClose=true)
  → AuthService.logout()    (清除 SharedPreferences)
  → _navigateTo('login')
```

---

## 五、UI 设计体系

### 5.1 设计风格：有机玻璃拟态（Organic Glassmorphism）

核心视觉特征：
- **渐变背景**：四色线性渐变（暖黄 → 暖粉 → 淡紫 → 天蓝）+ 四角光晕圆
- **毛玻璃容器**：`BackdropFilter` + `ImageFilter.blur(sigmaX/Y: 20)` + 半透明白色底
- **有机形状（Blob）**：四角不同圆角的容器（非标准圆形/矩形），模拟自然流动感
- **柔和阴影**：多层 BoxShadow 营造悬浮感

### 5.2 组件工厂模式

[GlassmorphismContainer](lib/widgets/glassmorphism/glassmorphism_container.dart) 提供 3 种预设工厂：

| 工厂方法 | 用途 | 圆角 | 模糊强度 |
|----------|------|------|----------|
| `.glass()` | 会话卡片、搜索框 | 32px | 20 |
| `.bottomNav()` | 底部导航栏 | 48px | 24 |
| `.messageInput()` | 聊天输入框（含麦克风按钮） | 不对称圆角 | 20 |

### 5.3 颜色体系 ([app_colors.dart](lib/theme/app_colors.dart))

| 类别 | 色值 | 用途 |
|------|------|------|
| 品牌主色 | `#2D2D2D` | 主文字、深色元素 |
| 奶油背景 | `#FDFAF5` | 全局页面底色 |
| 橙色系 | `#FFB86C ~ #FF8A50` | 按钮、强调色、渐变 |
| 红粉色 | `#FF7A7A ~ #FF5E5E` | 错误提示、未读角标、录音状态 |
| 蓝色系 | `#3B82F6` | 发送方气泡、语音播放图标 |
| 暖橙 | `#E8A87C` | 接收方语音图标 |
| 在线绿 | `#22C55E` | WebSocket 连接状态指示 |

### 5.4 动画体系

| 位置 | 动画类型 | 效果 |
|------|----------|------|
| LoginScreen Logo | 正弦波浮动 | `_floatController` 6s 周期上下浮动 |
| LoginScreen 输入框 | 聚焦缩放 | `ScaleAnimation` 1.0 ↔ 1.01 |
| ContactsScreen 请求面板 | 滑入/滑出 | `_slideController` 300ms |
| 搜索弹窗 | 缩放+淡入 | `ScaleTransition` + `FadeTransition` + `easeOutBack` |
| 页面切换 | 交叉淡入淡出 | `AnimatedSwitcher` 300ms |
| 聊天气泡列表 | 滚动到底部 | `_scrollController.animateTo` 300ms easeOut |
| **语音波形播放** | CustomPaint 动态绘制 | `_playAnimController.repeat()` 1200ms 周期，5 条竖线随正弦波起伏 |
| **录音时长计时** | 数字递增 | `Timer.periodic(1s)` 更新 MM:SS 格式 |

---

## 六、数据模型定义

### 6.1 ChatSessionVO（会话视图对象）

```dart
class ChatSessionVO {
  int friendId;           // 好友用户 ID
  String friendUsername;  // 好友用户名
  String lastMessage;     // 最后一条消息内容（文本原文 或 音频URL）
  int? lastMsgType;       // 最后一条消息类型（null/0=文本, 3=语音）← 新增字段
  int unreadCount;        // 未读消息数
  String lastTime;        // 最后一条消息时间（ISO 格式）
}
```
> 注意：字段为非 final，因为需要在 WebSocket 回调中实时修改。
> `lastMsgType` 用于 Messages 首页区分显示："🎤 语音消息" vs 文本原文。

### 6.2 ChatMessageItem（聊天消息项）

```dart
class ChatMessageItem {
  final int msgId;        // 消息唯一 ID（用于去重）
  final int senderId;     // 发送者 ID
  final int receiverId;   // 接收者 ID
  final String content;   // 消息内容（文本 或 音频 URL）
  final String sendTime;  // 发送时间（ISO 格式）
  final bool isFromMe;    // 是否为自己发送
  final int msgType;      // 消息类型（0=文本, 3=语音）
}
```

### 6.3 ChatMessageVO（API 返回的消息视图对象）

```dart
class ChatMessageVO {
  final int msgId;
  final int senderId;
  final int receiverId;
  final int chatType;     // 聊天类型（0=私聊）
  final int msgType;      // 消息类型（0=文本, 3=语音）
  final String content;
  final int isRead;       // 是否已读（0/1）
  final String sendTime;
}
```

### 6.4 FriendInfo（好友信息）

```dart
class FriendInfo {
  final int userId;
  final String username;
  final String? avatarUrl;
}
```

---

## 七、Web 平台兼容性专题

本项目以 Web（浏览器）为主要运行目标，以下是在开发过程中遇到的关键兼容性问题和解决方案：

### 7.1 音频录音

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| `AudioEncoder.opusWebM` 不存在 | record v5.2.1 枚举中没有该值 | 改用 `AudioEncoder.opus`（底层自动选择 `audio/webm;codecs=opus`） |
| `dart:io.File` 类不可用 | Web 没有 File System API | 通过 Dio GET 将 blob URL 下载为 `List<int>` 字节，再用 `MultipartFile.fromBytes` 上传 |
| `hasPermission()` 可能静默失败 | 浏览器权限检查行为不一致 | Web 端跳过权限检查（`kIsWeb` 分支），由 record 包内部在 `start()` 时自动弹出授权对话框 |
| `record.js` 外部脚本不需要 | record_web v1.3.0 使用 `dart:js_interop` 原生实现 | 从 `index.html` 中移除 `<script src="...record.js">` 引用 |
| 录音交互方式 | 浏览器不支持长按手势 | 从"长按录音"改为"点击切换"（第 1 次点击开始，第 2 次点击停止） |

### 7.2 编码器选择策略

```dart
final config = kIsWeb
    ? const RecordConfig(encoder: AudioEncoder.opus)    // Web: Opus/WebM
    : const RecordConfig(encoder: AudioEncoder.aacLc);  // Mobile: AAC/LC
```

| 平台 | 编码器 | 容器格式 | MIME Type |
|------|--------|----------|-----------|
| Web (Chrome/Firefox/Safari) | Opus | WebM | `audio/webm;codecs=opus` |
| Android/iOS | AAC LC | M4A | `audio/mp4` |

### 7.3 音频播放

使用 `audioplayers` 包的 `UrlSource` 直接播放远程 URL：
```dart
await _audioPlayer.play(UrlSource(msg.content));  // content 为 http://.../uploads/xxx.webm
```
→ 浏览器原生支持 WebM/Opus 格式播放，无需额外转码。

---

## 八、性能优化与健壮性设计

### 8.1 前端优化清单

| 优化项 | 实现位置 | 效果 |
|--------|----------|------|
| **心跳保活** | WebSocketService._startHeartbeat() | 每 30s PING-PONG，防止 NAT/代理超时断连 |
| **指数退避重连** | WebSocketService._scheduleReconnect() | 3→6→12→...→60s，避免断线风暴 |
| **消息去重** | ChatDetailScreen._onMessageReceived() | 按 msgId 判断，防止重连导致重复渲染 |
| **事件总线** | AppEventBus (StreamController.broadcast) | 替代 GlobalKey，跨组件解耦通信 |
| **连接状态机** | WebSocketService._connected/_connecting | 双标志位防并发连接 |
| **乐观更新** | ChatListScreen._onChatTap() | 先清零本地红点再异步调 API，体验更流畅 |
| **mounted 检查** | 所有 async 回调中的 setState 前 | 防止组件销毁后调用 setState 导致异常 |
| **错误反馈 SnackBar** | 录音/上传失败时 | 用户可见的错误提示，而非静默失败 |

### 8.2 错误处理策略

```dart
// 典型模式：async 操作后的 mounted 检查
Future<void> _someAsyncOp() async {
  try {
    final result = await someNetworkCall();
    if (mounted) { setState(() { ... }); }  // ← 必须检查 mounted
  } catch (e) {
    debugPrint('error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失败: $e')));
    }
  }
}
```
