import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await sessionProvider.loadSessions();
        },
        child: sessionProvider.isLoading && sessionProvider.sessions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : sessionProvider.sessions.isEmpty
                ? _buildEmptyState(context)
                : _buildSessionList(context, sessionProvider),
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
                backgroundColor: Theme.of(context).primaryColor.withAlpha(50),
                child: Text(
                  session.themeKey.substring(0, 1).toUpperCase(),
                  style: TextStyle(color: Theme.of(context).primaryColor),
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
