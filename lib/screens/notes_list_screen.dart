// lib/screens/notes_list_screen.dart
import 'package:flutter/material.dart';
import 'package:notes_management_app/models/note.dart';
import 'package:notes_management_app/screens/add_edit_note_screen.dart';
import 'package:notes_management_app/services/note_service.dart';
import 'package:notes_management_app/widgets/note_card.dart';
import 'package:notes_management_app/widgets/empty_state.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NoteService _noteService = NoteService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        title: const Text('My Notes'),
        centerTitle: true,
        elevation: 4,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.info_outline, size: 24),
              onPressed: _showInfoDialog,
              tooltip: 'About Notes Manager',
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Note>>(
        stream: _noteService.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Something went wrong',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        snapshot.error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => setState(() {}),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 3),
            );
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.note_add_outlined,
              title: 'No notes yet',
              subtitle: 'Create your first note to get started',
              actionLabel: 'Create Note',
              onAction: _navigateToAddNote,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 300 + (index * 50)),
                child: NoteCard(
                  note: note,
                  onTap: () => _navigateToEditNote(note.id),
                  onDelete: () => _deleteNote(note.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddNote,
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _navigateToAddNote() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditNoteScreen()),
    );
  }

  void _navigateToEditNote(String noteId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreen(noteId: noteId),
      ),
    );
  }

  Future<void> _deleteNote(String noteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text(
          'Are you sure you want to delete this note? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _noteService.deleteNote(noteId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete note: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.04),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.03),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.15),
                            Theme.of(
                              context,
                            ).colorScheme.secondary.withOpacity(0.12),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.note_alt,
                        size: 36,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notes Manager',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'A simple and secure place for your notes — professional, fast, and synced to the cloud.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildInfoItem(
                          context,
                          Icons.add_circle_outline,
                          'Create notes',
                          'Tap the "New Note" button to add a note. Provide a clear title and description, then save.',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          context,
                          Icons.edit,
                          'Edit notes',
                          'Tap any note to edit. After changes, press "Update Note" to save edits to the cloud.',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          context,
                          Icons.delete_outline,
                          'Delete safely',
                          'Use the delete icon on a note card. A confirmation prevents accidental removal.',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          context,
                          Icons.sort,
                          'Sorted by date',
                          'Notes are shown newest first. Fresh notes appear at the top for quick access.',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          context,
                          Icons.cloud_sync,
                          'Auto sync',
                          'All notes sync automatically across your devices. Internet connection required for cloud sync.',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          context,
                          Icons.lock_outline,
                          'Private & secure',
                          'Notes are tied to your account. Only you can access your notes from this device.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _openInfoFullscreen();
                        },
                        child: const Text('View Fullscreen'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openInfoFullscreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Notes Manager'), centerTitle: true),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'About Notes',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A clean, secure place for your notes. Tap any card to edit, or use the button below to create new notes.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildInfoItem(
                            context,
                            Icons.add_circle_outline,
                            'Create notes',
                            'Tap the "New Note" button to add a note. Provide a clear title and description, then save.',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoItem(
                            context,
                            Icons.edit,
                            'Edit notes',
                            'Tap any note to edit. After changes, press "Update Note" to save edits to the cloud.',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoItem(
                            context,
                            Icons.delete_outline,
                            'Delete safely',
                            'Use the delete icon on a note card. A confirmation prevents accidental removal.',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoItem(
                            context,
                            Icons.sort,
                            'Sorted by date',
                            'Notes are shown newest first. Fresh notes appear at the top for quick access.',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoItem(
                            context,
                            Icons.cloud_sync,
                            'Auto sync',
                            'All notes sync automatically across your devices. Internet connection required for cloud sync.',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoItem(
                            context,
                            Icons.lock_outline,
                            'Private & secure',
                            'Notes are tied to your account. Only you can access your notes from this device.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
