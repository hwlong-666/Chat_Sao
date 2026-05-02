# ChatSao 聊天应用 — Flutter 前端技术文档

## 一、项目概览

| 项目 | 说明 |
|------|------|
| 项目名称 | ChatSao |
| 应用类型 | 实时 1v1 私聊 IM 应用（Web 端） |
| 框架 | Flutter (Dart) |
| SDK 版本 | ^3.12.0-320.0.dev |
| 构建目标 | Web (`flutter build web`) |

---

## 二、依赖清单与技术选型

### 2.1 第三方依赖 (`pubspec.yaml`)

| 包名 | 版本 | 用途 | 核心作用 |
|------|------|------|----------|
| **dio** | ^5.4.0 | HTTP 网络请求 | 所有 RESTful API 的发送与接收，含拦截器机制 |
| **shared_preferences** | ^2.2.2 | 本地持久化存储 | 存储 JWT Token、用户 ID、用户名等登录态信息 |
| **web_socket_channel** | ^3.0.1 | WebSocket 双向通信 | 实时消息收发，替代轮询实现即时聊天 |
| **cupertino_icons** | ^1.0.8 | iOS 风格图标库 | UI 图标补充 |
| **flutter_lints** | ^6.0.0 | 代码规范检查 | 开发阶段静态分析约束 |

### 2.2 Flutter 内置框架/组件

| 技术 | 使用场景 |
|------|----------|
| **Material Design 3** (`useMaterial3: true`) | 全局主题体系（ThemeData）、按钮、输入框、对话框等 |
| **StatefulWidget + setState** | 页面级状态管理（ChatListScreen、ChatDetailScreen 等） |
| **AnimationController** | 登录页 Logo 浮动动画、联系人页滑入动画、输入框聚焦缩放动画 |
| **StreamController / Stream** | WebSocket 消息广播分发（多页面同时监听同一数据流） |
| **StreamController.broadcast() 事件总线** | 跨页面事件通知（AppEventBus 替代 GlobalKey），降低耦合度 |
| **BackdropFilter + ImageFilter.blur()** | 毛玻璃效果（Glassmorphism）UI 组件 |
| **AnimatedSwitcher** | 页面切换过渡动画（main.dart 中屏幕切换） |
| **showGeneralDialog** | 自定义弹窗（添加好友搜索弹窗） |
| **RefreshIndicator** | 下拉刷新（Messages 列表） |
| **ListView.builder** | 高性能列表渲染（好友列表、消息列表、会话列表） |
| **TextField + TextEditingController** | 搜索框、用户名密码输入、聊天输入框 |
| **SingleTickerProviderStateMixin** | 动画控制器绑定（需要 vsync） |

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
│   ├── chat_detail_screen.dart        # 聊天详情页（1v1 对话）
│   ├── contacts_screen.dart           # 通讯录/联系人页
│   └── settings_screen.dart           # 设置页
├── services/
│   ├── api_service.dart               # Dio HTTP 客户端封装（全局单例）
│   ├── auth_service.dart              # 认证服务（登录/注册/Token 管理）
│   ├── chat_service.dart              # 聊天服务（会话列表/历史记录/标记已读）
│   ├── friend_service.dart            # 好友服务（搜索/添加/接受/拒绝）
│   └── websocket_service.dart         # WebSocket 服务（单例 + 广播流）
├── theme/
│   ├── app_colors.dart                # 全局颜色常量定义
│   └── app_theme.dart                 # Material3 主题配置
└── widgets/
    ├── app_card.dart                  # 自定义 UI 组件集合
    │   ├── GradientBackground          # 渐变背景 + 角落光晕
    │   ├── AvatarBlob                 # 有机形状头像容器
    │   ├── OrganicBubbleAi             # AI/接收方聊天气泡
    │   ├── OrganicBubbleUser           # 发送方聊天气泡
    │   ├── LiquidBadge                # 未读数角标
    │   └── OrganicInput               # 有机形状输入框（带聚焦动画）
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

**1）Token 存储层** ([auth_service.dart](lib/services/auth_service.dart#L13-L18))
```dart
static const _tokenKey = 'jwt_token';
static const _userIdKey = 'user_id';
static const _usernameKey = 'username';
static const _avatarUrlKey = 'avatar_url';

// 内存缓存 + getter 快速访问
static String? get token => _cachedToken;
static int? get userId => _cachedUserId;
```

**2）HTTP 拦截器自动鉴权** ([api_service.dart](lib/services/api_service.dart#L10-L17))
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

**1）单例模式** ([websocket_service.dart](lib/services/websocket_service.dart#L6-L8))
```dart
static final WebSocketService _instance = WebSocketService._internal();
factory WebSocketService() => _instance;
WebSocketService._internal();
```
→ **效果**：全应用共享同一个 WebSocket 连接，避免重复连接。

**2）广播流（Broadcast Stream）** ([websocket_service.dart](lib/services/websocket_service.dart#L11-L12))
```dart
final StreamController<Map<String, dynamic>> _messageController =
    StreamController<Map<String, dynamic>>.broadcast();

Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
```
→ **效果**：一个消息可以被多个 Listener 同时消费。ChatListScreen 和 ChatDetailScreen 可以同时监听同一条消息流。

**3）指数退避重连** ([websocket_service.dart](lib/services/websocket_service.dart#L80-L88))
```dart
void _scheduleReconnect() {
  _reconnectTimer?.cancel();
  _reconnectTimer = Timer(Duration(seconds: _reconnectDelay), () {
    if (!_connected) connect();
  });
  _reconnectDelay = (_reconnectDelay * 2).clamp(3, _maxReconnectDelay);  // 3s → 6s → 12s → 24s → ... → 60s
}
```
→ **效果**：断线后按 3s, 6s, 12s, 24s, 48s, 60s 间隔重连，避免频繁重连导致服务器压力过大；连接成功后重置为 3s。

**4）心跳保活机制** ([websocket_service.dart](lib/services/websocket_service.dart#L66-L73))
```dart
void _startHeartbeat() {
  _heartbeatTimer?.cancel();
  _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
    if (_connected && _channel != null) {
      _channel!.sink.add(jsonEncode({'type': 'PING'}));
    }
  });
}
```
→ **效果**：每 30 秒发送 `{"type":"PING"}`，后端收到后回复 `{"type":"PONG"}` 并刷新 Redis 在线状态 TTL，防止连接被中间件/代理超时断开。

**5）JWT 握手认证**
```dart
Uri.parse('ws://localhost:8081/ws/chat?token=$token'),
```
→ 连接时将 JWT Token 作为 URL 参数传递，后端 HandshakeInterceptor 校验通过才建立连接。

---

### 4.3 消息会话列表（Messages 首页）

**涉及文件**: [chat_list_screen.dart](lib/screens/chat_list_screen.dart), [chat_service.dart](lib/services/chat_service.dart)

#### 功能需求对标微信：
- ✅ 显示每个好友的最后一条消息内容
- ✅ 显示最后一条消息的时间戳（今天 HH:MM AM/PM / Yesterday / Mon）
- ✅ 显示未读消息数量（红色角标）
- ✅ 收到新消息时**实时更新**（不需要刷新页面）
- ✅ 点击进入聊天时清除小红点并标记已读
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
│              │  - unreadCount                 │              │
│              │  - lastTime                    │              │
└──────────────┘                                └──────┬───────┘
                                                       │
                       WebSocket messageStream 监听      │
                                                       ▼
                                              _onWsMessage(data):
                                                1. 找到对应 session
                                                2. 更新 lastMessage
                                                3. 更新 lastTime
                                                4. unreadCount++ (对方发的)
                                                5. 移到列表顶部
                                                6. setState 刷新 UI
```

#### 关键实现：实时更新逻辑 ([chat_list_screen.dart](lib/screens/chat_list_screen.dart#L44-L67))

```dart
void _onWsMessage(Map<String, dynamic> data) {
  final senderId = data['senderId'] as int?;
  final receiverId = data['receiverId'] as int?;
  // ...

  final isFromMe = senderId == _currentUserId;  // 判断是自己发还是别人发
  final otherId = isFromMe ? receiverId : senderId;

  setState(() {
    final idx = _sessions.indexWhere((s) => s.friendId == otherId);
    if (idx != -1) {
      final session = _sessions[idx];
      session.lastMessage = content ?? '';
      session.lastTime = sendTime ?? '';
      if (!isFromMe) {
        session.unreadCount += 1;  // 别人发的消息 → 未读+1
      }
      _sessions.removeAt(idx);
      _sessions.insert(0, session);  // 置顶该会话
    }
    _applyFilter();  // 同步更新筛选结果
  });
}
```

#### 关键实现：点击标记已读 ([chat_list_screen.dart](lib/screens/chat_list_screen.dart#L96-L109))

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

### 4.4 聊天详情页（1v1 对话）

**涉及文件**: [chat_detail_screen.dart](lib/screens/chat_detail_screen.dart)

#### 功能流程：

```
进入页面
   ↓
1. 确保 WebSocket 已连接 (_wsService.connect())
2. 订阅 messageStream (_wsService.messageStream.listen)
3. 调用 PUT /api/chat/read 标记已读 ← 新增！解决小红点问题
4. 调用 GET /api/chat/history 加载历史消息
5. 渲染消息气泡列表
   ↓
用户点击发送
   ↓
_wsService.sendMessage({ receiverId, content })
   ↓
WebSocket 推送到后端 → 后端持久化 → 推送给对方
   ↓
收到新消息 (_onMessageReceived)
   ↓
判断是否属于当前对话 (senderId/receiverId 匹配)
   ↓
去重 (msgId 是否已存在) → 追加到列表 → 自动滚动到底部
```

#### 消息去重机制 ([chat_detail_screen.dart](lib/screens/chat_detail_screen.dart#L125-L129))
```dart
void _onMessageReceived(Map<String, dynamic> data) {
  // ...
  final msg = ChatMessageItem(msgId: data['msgId'] as int, ...);
  
  final exists = _messages.any((m) => m.msgId == msg.msgId);  // 按 msgId 去重
  if (exists) return;  // 已存在则跳过，防止重复渲染
  
  setState(() => _messages.add(msg));
  _scrollToBottom();
}
```
→ **效果**：当 WebSocket 因网络抖动或重连导致同一条消息被推送两次时，前端根据 `msgId` 去重，避免消息重复显示。

#### 气泡区分逻辑：
- **自己发的** → 右对齐 `OrganicBubbleUser`（蓝色渐变气泡）
- **对方发的** → 左对齐 `OrganicBubbleAi`（暖色渐变气泡 + 头像）

---

### 4.5 好友关系管理

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

### 4.6 导航路由系统

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
      // ...
    });
    if (screen == 'chatList') {
      AppEventBus.emit(AppEventBus.refreshSessions);  // 事件总线通知刷新！
    }
  }
}
```

**AppEventBus 事件总线** ([websocket_service.dart](lib/services/websocket_service.dart#L106-L116))
```dart
class AppEventBus {
  static final StreamController<String> _controller = StreamController<String>.broadcast();
  static Stream<String> get stream => _controller.stream;
  static void emit(String event) { _controller.add(event); }
  static const String refreshSessions = 'refresh_sessions';
}
```
→ **效果**：ChatListScreen 在 initState 中订阅 `AppEventBus.stream`，当收到 `refreshSessions` 事件时自动调用 `loadSessions()`。完全解耦，无需 GlobalKey。

**页面切换方式**：`AnimatedSwitcher` + `ValueKey(_currentScreen)`
- 从 chat 返回 chatList 时自动触发 `loadSessions()` 刷新会话列表
- 底部导航栏仅在 chatList / contacts / settings 页面显示

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
| `.messageInput()` | 聊天输入框 | 不对称圆角 | 20 |

### 5.3 颜色体系 ([app_colors.dart](lib/theme/app_colors.dart))

| 类别 | 色值 | 用途 |
|------|------|------|
| 品牌主色 | `#2D2D2D` | 主文字、深色元素 |
| 奶油背景 | `#FDFAF5` | 全局页面底色 |
| 橙色系 | `#FFB86C ~ #FF8A50` | 按钮、强调色、渐变 |
| 红粉色 | `#FF7A7A ~ #FF5E5E` | 错误提示、未读角标 |
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

---

## 六、数据模型定义

### 6.1 ChatSessionVO（会话视图对象）

```dart
class ChatSessionVO {
  int friendId;           // 好友用户 ID
  String friendUsername;  // 好友用户名
  String lastMessage;     // 最后一条消息内容
  int unreadCount;        // 未读消息数
  String lastTime;        // 最后一条消息时间（ISO 格式）
}
```
> 注意：字段为非 final，因为需要在 WebSocket 回调中实时修改。

### 6.2 ChatMessageVO（消息视图对象）

```dart
class ChatMessageVO {
  final int msgId;        // 消息唯一 ID
  final int senderId;     // 发送者 ID
  final int receiverId;   // 接收者 ID
  final int chatType;     // 聊天类型（0=私聊）
  final int msgType;      // 消息类型（0=文本）
  final String content;   // 消息内容
  final int isRead;       // 是否已读（0/1）
  final String sendTime;  // 发送时间（ISO 格式）
}
```

### 6.3 FriendInfo（好友信息）

```dart
class FriendInfo {
  final int userId;
  final String username;
  final String? avatarUrl;
}
```

---

## 七、前后端交互总览

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter 前端                              │
│                                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  Login   │  │ Messages │  │  Chat    │  │Contacts  │       │
│  │  Screen  │  │  Screen  │  │ Detail   │  │  Screen  │       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
│       │             │             │             │              │
│  ┌────▼─────────────▼─────────────▼─────────────▼────┐        │
│  │              Services 层                            │        │
│  │  AuthService  │  ChatService  │  FriendService     │        │
│  │               │               │                    │        │
│  │  ┌──────────────────────────────────────────┐      │        │
│  │  │         ApiService (Dio 单例)             │      │        │
│  │  │  ┌────────────────────────────────────┐  │      │        │
│  │  │  │  JwtInterceptor (自动附加 Token)    │  │      │        │
│  │  │  └────────────────────────────────────┘  │      │        │
│  │  └──────────────────────────────────────────┘      │        │
│  │                                                    │        │
│  │  ┌──────────────────────────────────────────┐      │        │
│  │  │    WebSocketService (全局单例)             │      │        │
│  │  │  BroadcastStream ← 多页面同时监听          │      │        │
│  │  └──────────────────────────────────────────┘      │        │
│  └────────────────────────────────────────────────────┘        │
│                                                                 │
└───────────────────────────┬─────────────────────────────────────┘
                            │
              ┌─────────────┼─────────────┐
              │ REST HTTP   │ WebSocket    │
              │ :8081       │ :8081/ws/chat│
              ▼             ▼              │
┌─────────────────────────────────────────────────────────────────┐
│                     Spring Boot 后端                             │
│                                                                 │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐                │
│  │UserController│  │ChatController│  │FriendController│          │
│  │  /api/user  │  │  /api/chat  │  │ /api/friend   │          │
│  └──────┬─────┘  └──────┬─────┘  └──────┬─────┘                │
│         │               │               │                       │
│  ┌──────▼───────────────▼───────────────▼──────┐               │
│  │              Service 层                      │               │
│  │  UserService │ ChatMessageService │ FriendRelationService │  │
│  └──────┬──────────────────┬───────────────────┘               │
│         │                  │                                    │
│  ┌──────▼──────────────────▼──────────────┐                    │
│  │         MyBatis-Plus Mapper 层          │                    │
│  │  user_info │ chat_message │ friend_relation │               │
│  └──────────────────────────────────────────┘                    │
│                                                                 │
│  ┌──────────────────────────────────────────┐                   │
│  │     WebSocket 层                          │                   │
│  │  JwtHandshakeInterceptor (握手鉴权)       │                   │
│  │  SessionManager (ConcurrentHashMap)       │                   │
│  │  ChatWebSocketHandler (消息处理+推送)     │                   │
│  └──────────────────────────────────────────┘                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                            │
              ┌─────────────┴─────────────┐
              ▼                           ▼
       ┌──────────┐               ┌──────────┐
       │  MySQL   │               │  Redis   │
       │ Database │               │ (可选)   │
       └──────────┘               └──────────┘
```

---

## 八、API 接口清单

### 认证相关

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/user/register` | 用户注册（username + password） |
| POST | `/api/user/login` | 用户登录（返回 JWT Token） |

### 好友相关

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/friend/search?username=xx` | 模糊搜索用户 |
| POST | `/api/friend/add` | 发送好友请求 |
| GET | `/api/friend/list` | 获取好友列表 |
| GET | `/api/friend/requests` | 获取好友请求列表 |
| POST | `/api/friend/accept` | 接受好友请求 |
| POST | `/api/friend/reject` | 拒绝好友请求 |

### 聊天相关

| 方法 | 路径 | 说明 |
|------|------|------|
| WS | `/ws/chat?token=xxx` | WebSocket 长连接（实时消息） |
| GET | `/api/chat/sessions` | 获取会话列表（含最后消息+未读数） |
| GET | `/api/chat/history?friendId=x&limit=50&offset=0` | 获取聊天历史记录 |
| PUT | `/api/chat/read?friendId=x` | 标记某好友的消息为已读 |

---

## 九、关键技术决策总结

| 决策点 | 选择 | 原因 |
|--------|------|------|
| HTTP 客户端 | **Dio** | 支持拦截器、取消请求、错误处理，比原生 http 更强大 |
| 本地存储 | **SharedPreferences** | 轻量键值对存储，适合存 Token/UserID 这类小数据 |
| 实时通信 | **WebSocket (web_socket_channel)** | 双向低延迟，适合 IM 场景；比轮询节省资源 |
| 消息分发 | **Broadcast StreamController** | 一条消息多页面消费（ChatListScreen + ChatDetailScreen 同时监听） |
| WebSocket 管理 | **单例模式** | 全应用只维护一个连接，避免重复连接浪费资源 |
| 状态管理 | **setState + AppEventBus** | 项目规模适中，AppEventBus 替代 GlobalKey 实现跨页面事件通知，降低耦合度 |
| 导航方案 | **状态变量 + AnimatedSwitcher** | 比 Navigator 2.0 更简单，满足当前需求 |
| UI 风格 | **毛玻璃拟态** | 现代化设计语言，视觉层次丰富 |
| 断线处理 | **指数退避重连** | 3s → 6s → 12s → 24s → 48s → 60s，避免频繁重连导致服务器压力过大 |
| 心跳保活 | **PING/PONG 30s 间隔** | 防止连接被中间件/代理超时断开，同时刷新 Redis 在线状态 TTL |
| 消息去重 | **msgId 判重** | 防止网络抖动/重连导致消息重复渲染 |
| 在线状态缓存 | **Redis String** | `user_online:{userId}` 带 300s TTL，高频读写性能优于数据库 |
| 未读数缓存 | **Redis Hash** | `im:unread:{receiverId}` → `{senderId: count}`，支持 HINCRBY 原子递增 |

---

## 十、后端 Redis 缓存架构

### 10.1 Redis 数据结构设计

| 业务 | Redis Key | 结构 | 操作 | TTL |
|------|-----------|------|------|-----|
| 在线状态 | `user_online:{userId}` | String | `SET` / `DEL` / `GET` + `EXPIRE` | 300s（心跳续期） |
| 未读消息数 | `im:unread:{receiverId}` | Hash | `HINCRBY` / `HGET` / `HDEL` / `HGETALL` | 无（手动清除） |

### 10.2 缓存读取策略（未读数）

```
/api/chat/sessions 请求
       ↓
1. 先查 Redis: HGETALL im:unread:{userId}
2. 如果 Redis 有值 → 直接使用（O(1) 高性能）
3. 如果 Redis 无值 → 回退查数据库 COUNT(*)
4. 数据库有值 → 回填 Redis（HINCRBY 补偿）
```

### 10.3 缓存写入策略

| 操作 | Redis 动作 | 数据库动作 |
|------|-----------|-----------|
| 发送消息 | `HINCRBY im:unread:{receiverId} {senderId} 1` | INSERT INTO chat_message |
| 标记已读 | `HDEL im:unread:{userId} {friendId}` | UPDATE chat_message SET is_read=1 |
| WebSocket 连接 | `SET user_online:{userId} 1 EX 300` | — |
| WebSocket 断开 | `DEL user_online:{userId}` | — |
| 心跳 PING | `EXPIRE user_online:{userId} 300` | — |
