import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Entry widget
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // Mock current user
  final String me = '@you';

  // Initial demo posts
  final List<Post> _posts = [
    Post(
      id: 'p1',
      username: '@mariaaah',
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
      timeAgo: '12m',
      text:
      "Today I managed to get out of bed even though all I wanted to do was sleep. Sometimes, that's progress too. 😅",
      images: const [],
    ),
    Post(
      id: 'p2',
      username: '@calm.with.andrei',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      timeAgo: '3h',
      text:
      'Reminder: 2 minutes of deep breathing can change your entire day. Try it now. Close your eyes. Inhale. Exhale.',
      images: const [
        Attachment(
            url:
            'https://images.unsplash.com/photo-1482192596544-9eb780fc7f66?q=80&w=1200&auto=format&fit=crop'),
      ],
      likeCount: 154,
      commentCount: 33,
      shareCount: 15,
    ),
    Post(
      id: 'p3',
      username: '@biancadinu',
      avatarUrl: 'https://i.pravatar.cc/150?img=32',
      timeAgo: '1h',
      text:
      "When I started drinking water regularly and getting 7 hours of sleep, my anxiety completely changed. Your body needs you.",
    ),
    Post(
      id: 'p4',
      username: '@rox.in.progress',
      avatarUrl: 'https://i.pravatar.cc/150?img=15',
      timeAgo: '6h',
      text:
      "What are your evening rituals? I listen to a guided meditation and write down 3 things I'm grateful for. 🌙✨",
      images: const [
        Attachment(
            url:
            'https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=1200&auto=format&fit=crop'),
        Attachment(
            url:
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=1200&auto=format&fit=crop'),
        Attachment(
            url:
            'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?q=80&w=1200&auto=format&fit=crop'),
      ],
      commentCount: 21,
      likeCount: 76,
      shareCount: 4,
    ),
  ];

  // Composer state
  final TextEditingController _composerCtl = TextEditingController();
  final List<Attachment> _composerImages = [];
  bool _posting = false;

  @override
  void dispose() {
    _composerCtl.dispose();
    super.dispose();
  }

  // ---------------------- Moderation ----------------------
  bool _isPositive(String text) {
    const banned = [
      'hate',
      'idiot',
      'stupid',
      'ugly',
      'dumb',
      'kill',
      'die',
      'trash',
      'loser',
      'bad word',
    ];
    final t = text.toLowerCase();
    return !banned.any((w) => t.contains(w));
  }

  // ---------------------- Composer actions ----------------------
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    try {
      final files = await picker.pickMultiImage(imageQuality: 85);
      if (files != null && files.isNotEmpty) {
        for (final f in files) {
          final bytes = await f.readAsBytes();
          _composerImages.add(Attachment(bytes: bytes));
        }
        setState(() {});
      }
    } catch (_) {}
  }

  void _removeComposerImage(int i) {
    setState(() => _composerImages.removeAt(i));
  }

  Future<void> _submitPost() async {
    final text = _composerCtl.text.trim();
    if (text.isEmpty && _composerImages.isEmpty) return;
    if (!_isPositive(text)) {
      _showSnack('We only allow kind, supportive posts.');
      return;
    }
    setState(() => _posting = true);

    final post = Post(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      username: me,
      avatarUrl: 'https://i.pravatar.cc/150?img=70',
      timeAgo: 'now',
      text: text,
      images: List<Attachment>.from(_composerImages),
    );

    setState(() {
      _posts.insert(0, post);
      _composerCtl.clear();
      _composerImages.clear();
      _posting = false;
    });

    _showSnack('Posted to Community');
  }

  // ---------------------- Helpers ----------------------
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------------- Build ----------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xFFF7F8FA),
        title: Text('Community',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.search, color: Colors.black87)),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
              child: _ComposerCard(
                controller: _composerCtl,
                images: _composerImages,
                onPickImages: _pickImages,
                onRemoveImage: _removeComposerImage,
                onPost: _submitPost,
                posting: _posting,
              )),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: _posts.length,
                  (context, i) => _PostCard(
                post: _posts[i],
                onLike: () => setState(() => _posts[i] = _posts[i].toggleLike()),
                onComment: () => _openCommentsSheet(_posts[i]),
                onShare: () => setState(() {
                  _posts[i] = _posts[i]
                      .copyWith(shareCount: _posts[i].shareCount + 1);
                  _showSnack('Post shared');
                }),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
      // bottomNavigationBar: const _PillBottomNav(current: 1), // <-- REMOVED
    );
  }

  // ---------------------- Comments Sheet ----------------------
  void _openCommentsSheet(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CommentsSheet(
        post: post,
        me: me,
        isPositive: _isPositive,
        onUpdate: () => setState(() {}),
      ),
    );
  }
}

// ============================================================================
// Models
// ============================================================================
class Attachment {
  final Uint8List? bytes; // for picked images
  final String? url; // for network images
  const Attachment({this.bytes, this.url});
}

class CommentNode {
  final String id;
  final String username;
  final String avatarUrl;
  final String text;
  final String timeAgo;
  final List<CommentNode> replies;

  CommentNode({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.text,
    required this.timeAgo,
    List<CommentNode>? replies,
  }) : replies = replies ?? [];
}

class Post {
  final String id;
  final String username;
  final String avatarUrl;
  final String timeAgo;
  final String text;
  final List<Attachment> images;
  final List<CommentNode> comments;
  final int likeCount;
  final int commentCount; // optional initial counts for mock posts
  final int shareCount;
  final bool liked;

  Post({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.timeAgo,
    required this.text,
    List<Attachment>? images,
    List<CommentNode>? comments,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.liked = false,
  })  : images = images ?? const [],
        comments = comments ?? [];

  Post toggleLike() => Post(
    id: id,
    username: username,
    avatarUrl: avatarUrl,
    timeAgo: timeAgo,
    text: text,
    images: images,
    comments: comments,
    likeCount: liked ? likeCount - 1 : likeCount + 1,
    commentCount: commentCount,
    shareCount: shareCount,
    liked: !liked,
  );

  Post copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    String? timeAgo,
    String? text,
    List<Attachment>? images,
    List<CommentNode>? comments,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? liked,
  }) {
    return Post(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      timeAgo: timeAgo ?? this.timeAgo,
      text: text ?? this.text,
      images: images ?? this.images,
      comments: comments ?? this.comments,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      liked: liked ?? this.liked,
    );
  }
}
// ============================================================================
// Composer Card (Top)
// ============================================================================
class _ComposerCard extends StatelessWidget {
  final TextEditingController controller;
  final List<Attachment> images;
  final VoidCallback onPickImages;
  final void Function(int) onRemoveImage;
  final VoidCallback onPost;
  final bool posting;

  const _ComposerCard({
    required this.controller,
    required this.images,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.onPost,
    required this.posting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: const Color(0xFFE9EDF2)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=70')),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Share your thoughts…",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            if (images.isNotEmpty) ...[
              const SizedBox(height: 8),
              _ImageGrid(
                attachments: images,
                removable: true,
                onRemove: onRemoveImage,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(onPressed: onPickImages, icon: const Icon(Icons.photo_library_outlined)),
                const Spacer(),
                ElevatedButton(
                  onPressed: posting ? null : onPost,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  child: posting
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Post'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Post Card (Feed item)
// ============================================================================
class _PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const _PostCard({
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  int _countComments(List<CommentNode> nodes) {
    int c = 0;
    for (final n in nodes) {
      c += 1 + _countComments(n.replies);
    }
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final commentsTotal = post.commentCount > 0 ? post.commentCount : _countComments(post.comments);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: const Color(0xFFE9EDF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 18, backgroundImage: NetworkImage(post.avatarUrl)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(post.username, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        // Optional little green plus badge like ref UI
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8EE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add, size: 12, color: Color(0xFF2BC866)),
                        ),
                        const Spacer(),
                        Text(post.timeAgo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(post.text),
                  ],
                ),
              ),
            ],
          ),
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ImageGrid(attachments: post.images),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              _IconStat(icon: Icons.chat_bubble_outline, label: commentsTotal.toString(), onTap: onComment),
              const SizedBox(width: 14),
              _IconStat(icon: Icons.repeat, label: post.shareCount.toString(), onTap: onShare),
              const SizedBox(width: 14),
              _IconStat(
                icon: post.liked ? Icons.favorite : Icons.favorite_border,
                label: post.likeCount.toString(),
                onTap: onLike,
                color: post.liked ? Colors.red : null,
                labelColor: post.liked ? Colors.red : null,
              ),
              const Spacer(),
              IconButton(icon: const Icon(Icons.ios_share_outlined), onPressed: onShare),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? labelColor;
  const _IconStat({required this.icon, required this.label, required this.onTap, this.color, this.labelColor});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(children: [
        Icon(icon, size: 20, color: color ?? Colors.black54),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 13, color: labelColor ?? Colors.black87)),
      ]),
    );
  }
}

// ============================================================================
// Image Grid
// ============================================================================
class _ImageGrid extends StatelessWidget {
  final List<Attachment> attachments;
  final bool removable;
  final void Function(int index)? onRemove;
  const _ImageGrid({required this.attachments, this.removable = false, this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (attachments.length == 1) {
      return _ImageTile(att: attachments.first, removable: removable, onRemove: () => onRemove?.call(0));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: attachments.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (ctx, i) => _ImageTile(att: attachments[i], removable: removable, onRemove: () => onRemove?.call(i)),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final Attachment att;
  final bool removable;
  final VoidCallback? onRemove;
  const _ImageTile({required this.att, this.removable = false, this.onRemove});

  @override
  Widget build(BuildContext context) {
    ImageProvider provider;
    if (att.bytes != null) {
      provider = MemoryImage(att.bytes!);
    } else if (att.url != null) {
      provider = NetworkImage(att.url!);
    } else {
      provider = const AssetImage('');
    }
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image(
              image: provider,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                color: const Color(0xFFF1F2F5),
                child: const Center(child: Icon(Icons.broken_image_outlined)),
              ),
            ),
          ),
        ),
        if (removable)
          Positioned(
            top: 6,
            right: 6,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// Comments Bottom Sheet
// ============================================================================
class _CommentsSheet extends StatefulWidget {
  final Post post;
  final String me;
  final bool Function(String) isPositive;
  final VoidCallback onUpdate;
  const _CommentsSheet({required this.post, required this.me, required this.isPositive, required this.onUpdate});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _input = TextEditingController();
  CommentNode? replyingTo; // which comment is being replied to (null => replying to post)

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _addComment(String text) {
    if (text.trim().isEmpty) return;
    if (!widget.isPositive(text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Only positive, supportive comments are allowed.')));
      return;
    }
    final node = CommentNode(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      username: widget.me,
      avatarUrl: 'https://i.pravatar.cc/150?img=70',
      text: text.trim(),
      timeAgo: 'now',
    );

    setState(() {
      if (replyingTo == null) {
        widget.post.comments.add(node);
      } else {
        replyingTo!.replies.add(node);
      }
      replyingTo = null;
      _input.clear();
    });

    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.86;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFE3E5EA), borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 12),
          const Text('Comments', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const Divider(height: 22),
          Expanded(
            child: widget.post.comments.isEmpty
                ? const Center(child: Text('Be the first to comment'))
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: widget.post.comments.length,
              itemBuilder: (ctx, i) => _CommentThread(
                node: widget.post.comments[i],
                onReply: (node) => setState(() => replyingTo = node),
              ),
            ),
          ),
          if (replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: const Color(0xFFF7F8FA),
              child: Row(children: [
                const Icon(Icons.reply, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text('Replying to ${replyingTo!.username}', style: const TextStyle(fontSize: 12))),
                TextButton(onPressed: () => setState(() => replyingTo = null), child: const Text('Cancel')),
              ]),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(children: [
                const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=70')),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: const InputDecoration(
                      hintText: 'Add a supportive comment…',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.send), onPressed: () => _addComment(_input.text)),
              ]),
            ),
          )
        ],
      ),
    );
  }
}

class _CommentThread extends StatelessWidget {
  final CommentNode node;
  final void Function(CommentNode) onReply;
  const _CommentThread({required this.node, required this.onReply});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(radius: 16, backgroundImage: NetworkImage(node.avatarUrl)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(node.username, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  Text(node.timeAgo, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ]),
                const SizedBox(height: 2),
                Text(node.text),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: () => onReply(node),
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text('Reply'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                ),
              ]),
            ),
          ]),
          if (node.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Column(
                children: node.replies
                    .map((r) => _CommentThread(node: r, onReply: onReply))
                    .toList(growable: false),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// Bottom Pill Navigation (matches screenshot vibe)
// ============================================================================
class _PillBottomNav extends StatelessWidget {
  final int current; // 0..3
  const _PillBottomNav({required this.current});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_outlined, label: 'Home'),
      _NavItem(icon: Icons.groups_2_outlined, label: 'Community'),
      _NavItem(icon: Icons.favorite_outline, label: 'Care'),
      _NavItem(icon: Icons.person_outline, label: 'Profile'),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10)),
            ],
            border: Border.all(color: const Color(0xFFE9EDF2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < items.length; i++)
                _NavButton(
                  icon: items[i].icon,
                  label: items[i].label,
                  active: i == current,
                  onTap: () {},
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF11C26D) : Colors.black54;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

