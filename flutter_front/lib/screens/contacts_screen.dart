import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/friend_service.dart';
import '../widgets/app_card.dart';
import '../widgets/glassmorphism/glassmorphism_container.dart';

class ContactsScreen extends StatefulWidget {
  final VoidCallback? onNavigateBack;

  const ContactsScreen({super.key, this.onNavigateBack});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> with SingleTickerProviderStateMixin {
  List<FriendInfo> _friends = [];
  List<FriendInfo> _requests = [];
  bool _isLoading = true;
  bool _showRequests = false;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadData();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final friends = await FriendService.getFriendList();
      final requests = await FriendService.getFriendRequests();
      setState(() {
        _friends = friends;
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showSearchDialog() async {
    final controller = TextEditingController();
    List<FriendInfo> searchResults = [];
    bool isSearching = false;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Search',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 380,
              constraints: const BoxConstraints(maxHeight: 500),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFF8F0), Color(0xFFF0F4FF)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: StatefulBuilder(
                  builder: (ctx, setDialogState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.brandPrimary.withValues(alpha: 0.1), AppColors.orange200.withValues(alpha: 0.1)],
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [AppColors.orange200, AppColors.redPink]),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.search, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                '搜索用户',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => Navigator.pop(ctx),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.close, size: 16, color: AppColors.textLight),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.15)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Icon(Icons.search, size: 20, color: AppColors.textLight.withValues(alpha: 0.6)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: controller,
                                    style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                                    decoration: InputDecoration(
                                      hintText: '输入用户名搜索...',
                                      hintStyle: TextStyle(fontSize: 15, color: AppColors.textLight.withValues(alpha: 0.5)),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    onSubmitted: (_) => _doSearch(controller, () => setDialogState(() {}), (results) {
                                      setDialogState(() {
                                        searchResults = results;
                                        isSearching = false;
                                      });
                                    }, () => setDialogState(() => isSearching = true)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _doSearch(controller, () => setDialogState(() {}), (results) {
                                    setDialogState(() {
                                      searchResults = results;
                                      isSearching = false;
                                    });
                                  }, () => setDialogState(() => isSearching = true)),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [AppColors.orange200, AppColors.redPink]),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Text(
                                      '搜索',
                                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isSearching)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandPrimary))),
                          )
                        else if (searchResults.isNotEmpty)
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                              itemCount: searchResults.length,
                              itemBuilder: (_, index) {
                                final user = searchResults[index];
                                final colors = [const Color(0xFF8B5CF6), const Color(0xFF3B82F6), const Color(0xFFEC4899), const Color(0xFFF59E0B), const Color(0xFF10B981)];
                                final color = colors[index % colors.length];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Center(
                                          child: Text(
                                            user.username[0].toUpperCase(),
                                            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(user.username, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                                            Text('ID: ${user.userId}', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          try {
                                            await FriendService.addFriend(user.userId);
                                            if (!ctx.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('已向 ${user.username} 发送好友请求'),
                                                backgroundColor: AppColors.brandPrimary,
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                            );
                                            _loadData();
                                          } catch (e) {
                                            if (!ctx.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(e.toString()),
                                                backgroundColor: AppColors.redBadge,
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(colors: [AppColors.brandPrimary, Color(0xFF6366F1)]),
                                            borderRadius: BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(color: AppColors.brandPrimary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3)),
                                            ],
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.person_add, color: Colors.white, size: 14),
                                              SizedBox(width: 4),
                                              Text('添加', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(Icons.search, size: 40, color: AppColors.textLight.withValues(alpha: 0.3)),
                                const SizedBox(height: 8),
                                Text('输入用户名开始搜索', style: TextStyle(fontSize: 13, color: AppColors.textLight.withValues(alpha: 0.5))),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
    controller.dispose();
  }

  void _doSearch(TextEditingController controller, VoidCallback setState, Function(List<FriendInfo>) onResult, VoidCallback onSearching) {
    final query = controller.text.trim();
    if (query.isEmpty) return;
    onSearching();
    FriendService.searchUser(query).then((results) {
      onResult(results);
    }).catchError((e) {
      onResult([]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.redBadge),
        );
      }
    });
  }

  Color _avatarColor(int index) {
    const colors = [
      Color(0xFF8B5CF6), Color(0xFF3B82F6), Color(0xFFEC4899),
      Color(0xFFF59E0B), Color(0xFF10B981), Color(0xFFEF4444), Color(0xFF06B6D4),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Contacts',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: AppColors.textPrimary),
                ),
                Row(
                  children: [
                    if (_requests.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() {
                          _showRequests = !_showRequests;
                          if (_showRequests) {
                            _slideController.forward();
                          } else {
                            _slideController.reverse();
                          }
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _showRequests ? AppColors.brandPrimary : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(Icons.inbox, color: _showRequests ? Colors.white : AppColors.textPrimary, size: 20),
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B6B),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${_requests.length}',
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: _showSearchDialog,
                      child: AvatarBlob(
                        size: 44,
                        backgroundColor: Colors.white,
                        border: Border.all(color: Colors.white, width: 0),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                        child: const Icon(Icons.add, color: AppColors.textPrimary, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary))
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _showRequests
                        ? _buildRequestsList()
                        : _buildFriendList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    return Column(
      key: const ValueKey('requests'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          child: Row(
            children: [
              const Icon(Icons.inbox, size: 18, color: AppColors.brandPrimary),
              const SizedBox(width: 8),
              Text(
                '好友请求 (${_requests.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  _slideController.reverse();
                  setState(() => _showRequests = false);
                },
                child: Text('返回好友列表', style: TextStyle(fontSize: 13, color: AppColors.brandPrimary, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        Expanded(
          child: _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.inbox_outlined, size: 64, color: AppColors.textLight),
                      const SizedBox(height: 16),
                      const Text('暂无好友请求', style: TextStyle(fontSize: 16, color: AppColors.textLight)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final req = _requests[index];
                    final color = _avatarColor(index);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassmorphismContainer.glass(
                        borderRadius: 32,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            AvatarBlob(
                              size: 52,
                              backgroundColor: color.withValues(alpha: 0.15),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 3)),
                              ],
                              child: Center(
                                child: Text(
                                  req.username[0].toUpperCase(),
                                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(req.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text('请求添加你为好友', style: TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    try {
                                      await FriendService.acceptFriend(req.userId);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('已接受 ${req.username} 的好友请求'),
                                          backgroundColor: const Color(0xFF4ADE80),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                      _loadData();
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [Color(0xFF4ADE80), Color(0xFF22C55E)]),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(color: const Color(0xFF4ADE80).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3)),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check, color: Colors.white, size: 14),
                                        SizedBox(width: 3),
                                        Text('接受', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    try {
                                      await FriendService.rejectFriend(req.userId);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('已拒绝 ${req.username} 的好友请求'),
                                          backgroundColor: AppColors.redBadge,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                      _loadData();
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.3)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.close, color: Color(0xFFFF6B6B), size: 14),
                                        SizedBox(width: 3),
                                        Text('拒绝', style: TextStyle(color: Color(0xFFFF6B6B), fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFriendList() {
    return Column(
      key: const ValueKey('friends'),
      children: [
        Expanded(
          child: _friends.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_outline, size: 64, color: AppColors.textLight),
                      const SizedBox(height: 16),
                      const Text('暂无好友', style: TextStyle(fontSize: 16, color: AppColors.textLight)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _showSearchDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('添加好友'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                    itemCount: _friends.length,
                    itemBuilder: (context, index) {
                      final friend = _friends[index];
                      final color = _avatarColor(index);
                      final offsetX = index.isEven ? -4.0 : 4.0;
                      return Padding(
                        padding: EdgeInsets.only(
                          left: offsetX > 0 ? offsetX : 0,
                          right: offsetX < 0 ? offsetX.abs() : 0,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassmorphismContainer.glass(
                            borderRadius: 32,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                AvatarBlob(
                                  size: 56,
                                  backgroundColor: color.withValues(alpha: 0.15),
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 3)),
                                  ],
                                  child: Center(
                                    child: friend.avatarUrl != null && friend.avatarUrl!.isNotEmpty
                                        ? ClipOval(
                                            child: Image.network(
                                              friend.avatarUrl!,
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Text(
                                                friend.username[0].toUpperCase(),
                                                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            friend.username[0].toUpperCase(),
                                            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(friend.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                                      const SizedBox(height: 2),
                                      Text('ID: ${friend.userId}', style: TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2D2D2D),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(40 * 0.4),
                                      topRight: Radius.circular(40 * 0.6),
                                      bottomLeft: Radius.circular(40 * 0.55),
                                      bottomRight: Radius.circular(40 * 0.45),
                                    ),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3)),
                                    ],
                                  ),
                                  child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
