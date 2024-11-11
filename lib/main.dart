import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'models/note.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotesPage(toggleTheme: _toggleTheme),
      themeMode: _themeMode,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotesPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  NotesPage({required this.toggleTheme});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(_filterNotes);
  }

  Future<void> _loadNotes() async {
    List<Map<String, dynamic>> notesMap = await DBHelper.getNotes();
    setState(() {
      _notes = notesMap.map((noteMap) => Note.fromMap(noteMap)).toList();
      _filteredNotes = _notes;
    });
  }

  void _filterNotes() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _notes.where((note) {
        return note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _createNote() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Create a New Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(hintText: 'Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: InputDecoration(hintText: 'Content', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  Note newNote = Note(
                    title: titleController.text,
                    content: contentController.text,
                  );
                  await DBHelper.insertNote(newNote.toMap());
                  _loadNotes();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Title and content cannot be empty')));
                }
              },
              child: Text('Save'),
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNote(int id) async {
    await DBHelper.deleteNote(id);
    _loadNotes();
  }

  Future<void> _editNote(int id) async {
    Note note = _notes.firstWhere((note) => note.id == id);
    TextEditingController titleController = TextEditingController(text: note.title);
    TextEditingController contentController = TextEditingController(text: note.content);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(hintText: 'Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: InputDecoration(hintText: 'Content', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  Map<String, dynamic> updatedNote = {
                    'title': titleController.text,
                    'content': contentController.text,
                  };
                  await DBHelper.updateNote(id, updatedNote);
                  _loadNotes();
                  Navigator.pop(context);
                }
              },
              child: Text('Update'),
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _viewNote(int id) async {
    Note note = _notes.firstWhere((note) => note.id == id);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(note.title),
          content: Text(note.content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Simple Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: _filteredNotes.length,
        itemBuilder: (context, index) {
          Note note = _filteredNotes[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            child: ListTile(
              title: Text(note.title, style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(note.content, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editNote(note.id!),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteNote(note.id!),
                  ),
                  IconButton(
                    icon: Icon(Icons.visibility),
                    onPressed: () => _viewNote(note.id!),
                  ),
                ],
              ),
              onTap: () => _viewNote(note.id!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNote,
        child: Icon(Icons.add),
      ),
    );
  }
}
