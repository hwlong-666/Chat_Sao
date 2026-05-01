import 'user.dart';

class ChatThread {
  final String id;
  final User peer;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;

  const ChatThread({
    required this.id,
    required this.peer,
    required this.lastMessage,
    required this.timeLabel,
    this.unreadCount = 0,
  });

  static const sampleThreads = [
    ChatThread(
      id: 't1',
      peer: User.smith,
      lastMessage: "Here's the concept for your home design.",
      timeLabel: '9:41 AM',
      unreadCount: 2,
    ),
    ChatThread(
      id: 't2',
      peer: User.designInspiration,
      lastMessage: "Alice: Love this color palette!",
      timeLabel: '8:22 AM',
      unreadCount: 5,
    ),
    ChatThread(
      id: 't3',
      peer: User.aiAssistant,
      lastMessage: "Daily tip: Take a deep breath...",
      timeLabel: '7:15 AM',
      unreadCount: 0,
    ),
    ChatThread(
      id: 't4',
      peer: User.emily,
      lastMessage: "Let's catch up this weekend!",
      timeLabel: 'Yesterday',
      unreadCount: 0,
    ),
    ChatThread(
      id: 't5',
      peer: User.projectTeam,
      lastMessage: "Mike: Updated the project timeline.",
      timeLabel: 'Yesterday',
      unreadCount: 0,
    ),
    ChatThread(
      id: 't6',
      peer: User.mom,
      lastMessage: "Don't forget to take care!",
      timeLabel: 'Mon',
      unreadCount: 0,
    ),
  ];
}
