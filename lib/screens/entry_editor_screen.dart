// lib/screens/entry_editor_screen.dart
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:mindmeld_ai/extentions.dart';

class EntryEditorScreen extends StatefulWidget {
  final JournalEntry? entryToEdit;
  const EntryEditorScreen({super.key, this.entryToEdit});

  @override
  State<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends State<EntryEditorScreen> {
  // Controllers & Services
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final AIService _aiService = AIService();
  bool _isSaving = false;

  // State for Image Picking
  final _imagePicker = ImagePicker();
  List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.entryToEdit != null) {
      _titleController.text = widget.entryToEdit!.title;
      _bodyController.text = widget.entryToEdit!.body;
      if (widget.entryToEdit!.imagePaths != null) {
        _selectedImages =
            widget.entryToEdit!.imagePaths!.map((path) => XFile(path)).toList();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  // --- LOGIC METHODS ---

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles =
        await _imagePicker.pickMultiImage(imageQuality: 85);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _saveEntry() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and body cannot be empty.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final entryTextForAI =
        "${_titleController.text}\n\n${_bodyController.text}";
    final analysis = await _aiService.analyzeEntry(entryTextForAI);

    final imagePaths = _selectedImages.map((file) => file.path).toList();

    if (widget.entryToEdit == null) {
      final newEntry = JournalEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        body: _bodyController.text,
        date: DateTime.now(),
        analysis: analysis,
        imagePaths: imagePaths,
      );
      Hive.box<JournalEntry>('journal_entries').add(newEntry);
    } else {
      widget.entryToEdit!.title = _titleController.text;
      widget.entryToEdit!.body = _bodyController.text;
      widget.entryToEdit!.analysis = analysis;
      widget.entryToEdit!.imagePaths = imagePaths;
      await widget.entryToEdit!.save();
    }

    if (mounted) {
      setState(() => _isSaving = false);
      int popCount = widget.entryToEdit == null ? 1 : 2;
      for (int i = 0; i < popCount; i++) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      }
    }
  }

  // --- UI BUILDER METHODS ---

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entryToEdit != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Entry' : 'New Entry'),
        actions: [
          if (_isSaving)
            const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.0)))
          else
            IconButton(
                icon: const Icon(Icons.save_outlined),
                onPressed: _saveEntry,
                tooltip: "Save Entry"),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                  labelText: 'Tell me about your day...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
              maxLines: 8, // Give a good default size
              minLines: 3,
            ),
            const SizedBox(height: 20),
            _buildMediaPreviews(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Add Photos'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Colors.white.withOpacity(0.05),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPreviews() {
    if (_selectedImages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Photos", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 4, bottom: 4),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(_selectedImages[index].path),
                          height: 100, width: 100, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Transform.translate(
                        offset: const Offset(8, -8),
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: const CircleAvatar(
                              backgroundColor: Colors.black,
                              radius: 14,
                              child: Icon(Icons.close_rounded,
                                  size: 18, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
