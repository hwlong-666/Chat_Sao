import 'user.dart';

enum MessageType {
  text,
  voice,
  aiConcept,
}

class Message {
  final String id;
  final String chatThreadId;
  final User sender;
  final MessageType type;
  final String? text;
  final String? voiceDuration;
  final List<int>? waveformHeights;
  final int? waveformPlayedCount;
  final String? conceptTitle;
  final String? conceptDescription;
  final DateTime timestamp;
  final bool isRead;

  const Message({
    required this.id,
    required this.chatThreadId,
    required this.sender,
    required this.type,
    this.text,
    this.voiceDuration,
    this.waveformHeights,
    this.waveformPlayedCount,
    this.conceptTitle,
    this.conceptDescription,
    required this.timestamp,
    this.isRead = true,
  });

  bool get isFromMe => sender.id == 'me';
  bool get isVoice => type == MessageType.voice;
  bool get isAiConcept => type == MessageType.aiConcept;

  static List<Message> sampleThread1() {
    final now = DateTime.now();
    return [
      Message(
        id: 'm1',
        chatThreadId: 't1',
        sender: User.smith,
        type: MessageType.text,
        text: "Hello! How are you today? Hope you're having a magic morning! ✨",
        timestamp: now.subtract(const Duration(minutes: 30)),
      ),
      Message(
        id: 'm2',
        chatThreadId: 't1',
        sender: User.currentUser,
        type: MessageType.voice,
        voiceDuration: '0:24',
        waveformHeights: [3, 5, 2, 6, 4, 7, 5, 8, 4, 6, 3, 5, 4, 6],
        waveformPlayedCount: 5,
        timestamp: now.subtract(const Duration(minutes: 25)),
        isRead: true,
      ),
      Message(
        id: 'm3',
        chatThreadId: 't1',
        sender: User.smith,
        type: MessageType.text,
        text: 'Could you suggest some interior colors and materials for my new studio, please? 🎨',
        timestamp: now.subtract(const Duration(minutes: 20)),
      ),
      Message(
        id: 'm4',
        chatThreadId: 't1',
        sender: User.aiAssistant,
        type: MessageType.aiConcept,
        conceptTitle: 'AI CONCEPT',
        conceptDescription: 'I recommend a mix of terracotta wood and soft linen. It creates a breathable, warm workspace.',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: true,
      ),
    ];
  }
}
