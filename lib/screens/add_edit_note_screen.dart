// lib/screens/add_edit_note_screen.dart
import 'package:flutter/material.dart';
import 'package:notes_management_app/services/note_service.dart';

class AddEditNoteScreen extends StatefulWidget {
  final String? noteId;

  const AddEditNoteScreen({super.key, this.noteId});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final NoteService _noteService = NoteService();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.noteId != null;
    if (_isEditing) {
      _loadNote();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    setState(() => _isLoading = true);
    try {
      final note = await _noteService.getNoteById(widget.noteId!);
      if (note != null && mounted) {
        _titleController.text = note.title;
        _descriptionController.text = note.description;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        await _noteService.updateNote(
          widget.noteId!,
          _titleController.text.trim(),
          _descriptionController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await _noteService.createNote(
          _titleController.text.trim(),
          _descriptionController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'New Note'),
        centerTitle: true,
        elevation: 4,
      ),
      body: _isLoading && _isEditing
          ? const Center(child: CircularProgressIndicator(strokeWidth: 3))
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFFFAFBFC), const Color(0xFFF8F9FD)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Text(
                        'Title',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Enter note title',
                          prefixIcon: const Icon(Icons.edit_note_rounded),
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          if (value.trim().length < 3) {
                            return 'Title must be at least 3 characters';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        maxLength: 100,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Enter note description',
                          alignLabelWithHint: true,
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          if (value.trim().length < 5) {
                            return 'Description must be at least 5 characters';
                          }
                          return null;
                        },
                        maxLines: 6,
                        maxLength: 500,
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveNote,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(
                            _isLoading
                                ? 'Saving...'
                                : (_isEditing ? 'Update Note' : 'Save Note'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
