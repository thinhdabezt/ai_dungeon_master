import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/theme_utils.dart';
import '../providers/session_provider.dart';
import '../../auth/providers/auth_provider.dart';

class SessionsListScreen extends StatefulWidget {
  const SessionsListScreen({super.key});

  @override
  State<SessionsListScreen> createState() => _SessionsListScreenState();
}

class _SessionsListScreenState extends State<SessionsListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch sessions when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionProvider>().loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only rebuild if the list of sessions or loading state changes
    final sessionProvider = context.watch<SessionProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Adventures',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              authProvider.currentUser?.username ?? 'Traveller',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book, color: Colors.amber),
            tooltip: 'The Grimoire',
            onPressed: () {
              context.push('/grimoire');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Daily Quota Bar
          if (sessionProvider.sessions.isNotEmpty)
            _buildDailyQuota(context, sessionProvider.sessions.first),
            
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await sessionProvider.loadSessions();
              },
              child: sessionProvider.isLoading && sessionProvider.sessions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : sessionProvider.sessions.isEmpty
                      ? _buildEmptyState(context)
                      : _buildSessionList(context, sessionProvider),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/sessions/new');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Adventure'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book_outlined, size: 80, color: Colors.white24)
              .animate()
              .fade(duration: 600.ms)
              .scale(),
          const SizedBox(height: 16),
          Text(
            'No stories yet.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a new journey below.',
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList(BuildContext context, SessionProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.sessions.length,
      itemBuilder: (context, index) {
        final session = provider.sessions[index];
        final DateFormat formatter = DateFormat('MMM d, y • h:mm a');

        return Dismissible(
          key: Key(session.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red.withAlpha(200), // Updated to use withAlpha or withValues if needed, relying on Colors.red for now
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Adventure?'),
                content: Text('Are you sure you want to delete "${session.title}"?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red))),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            provider.deleteSession(session.id);
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: ThemeUtils.getThemeColor(session.themeKey, context), // Solid color
                child: Icon(
                  ThemeUtils.getThemeIcon(session.themeKey),
                  color: Colors.white, // White icon for better contrast
                  size: 20,
                ),
              ),
              title: Text(
                session.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'rename') {
                      _showRenameDialog(context, session, provider);
                  } else if (value == 'delete') {
                    // Trigger dismiss logic or separate delete implementation if requested
                    // For now, swipe is main delete, but we can allow menu delete.
                    // Let's implement menu delete confirm.
                    showDialog(
                      context: context,
                       builder: (ctx) => AlertDialog(
                        title: const Text('Delete Adventure?'),
                        content: Text('Are you sure you want to delete "${session.title}"?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                provider.deleteSession(session.id);
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                   const PopupMenuItem(
                    value: 'rename',
                    child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Rename')]),
                   ),
                   const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))]),
                   ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    session.themeKey.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last played: ${formatter.format(session.lastUpdated.toLocal())}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              onTap: () {
                context.push(
                  '/sessions/${session.id}',
                  extra: session.title,
                );
              },
            ),
          ).animate().fadeIn(duration: 400.ms, delay: (50 * index).ms).slideX(),
        );
      },
    );
  }


  Widget _buildDailyQuota(BuildContext context, dynamic session) {
    // SessionModel session
    final double progress = (session.dailyTokensUsed / session.maxTokens).clamp(0.0, 1.0);
    final bool isNearLimit = progress > 0.9;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Daily Power (Tokens)', style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      // Simple confirmation
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Reset Quota?'),
                          content: const Text('This will reset your daily usage to 0. Use only for testing.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
                          ],
                        ),
                      );

                      if (confirm == true) {
                         // ignore: use_build_context_synchronously
                        await context.read<SessionProvider>().resetDailyQuota();
                      }
                    },
                    child: Icon(Icons.refresh, size: 14, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
              Text(
                '${(session.dailyTokensUsed / 1000).toStringAsFixed(1)}k / ${(session.maxTokens / 1000).toStringAsFixed(0)}k',
                 style: TextStyle(
                   color: isNearLimit ? Colors.red : Theme.of(context).textTheme.bodySmall?.color,
                   fontWeight: FontWeight.bold
                 )
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).dividerColor.withAlpha(50),
              color: isNearLimit ? Colors.red : Theme.of(context).primaryColor,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, dynamic session, SessionProvider provider) {
    final controller = TextEditingController(text: session.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Adventure'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Title'),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != session.title) {
                Navigator.of(ctx).pop();
                await provider.renameSession(session.id, newTitle);
              } else {
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
