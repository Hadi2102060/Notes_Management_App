import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_management_app/models/note.dart';

class NoteService {
  final CollectionReference _notesCollection = FirebaseFirestore.instance
      .collection('notes');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  void _ensureAuthenticated() {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
  }

  Future<void> createNote(String title, String description) async {
    _ensureAuthenticated();
    try {
      final now = DateTime.now().toIso8601String();
      await _notesCollection.add({
        'userId': _userId,
        'title': title,
        'description': description,
        'createdAt': now,
        'updatedAt': now,
      });
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  Stream<List<Note>> getNotes() {
    _ensureAuthenticated();
    return _notesCollection.where('userId', isEqualTo: _userId).snapshots().map(
      (snapshot) {
        final notes = snapshot.docs.map((doc) {
          return Note.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();
        notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return notes;
      },
    );
  }

  Future<void> updateNote(String id, String title, String description) async {
    _ensureAuthenticated();
    try {
      await _notesCollection.doc(id).update({
        'title': title,
        'description': description,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    _ensureAuthenticated();
    try {
      await _notesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  Future<Note?> getNoteById(String id) async {
    _ensureAuthenticated();
    try {
      final doc = await _notesCollection.doc(id).get();
      if (doc.exists) {
        return Note.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get note: $e');
    }
  }
}
