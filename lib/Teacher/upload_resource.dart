import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';

class UploadResource extends StatefulWidget {
  const UploadResource({super.key});

  @override
  State<UploadResource> createState() => _UploadResourceState();
}

class _UploadResourceState extends State<UploadResource> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? selectedSubject;
  String? selectedClass;
  PlatformFile? _pickedFile;

  final List<_ResourceItem> resources = [];

  final List<String> subjectList = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'English',
    'Marathi',
    'Hindi',
  ];

  final List<String> classList = [
    '11th Science',
    '12th Science',
    '11th Commerce',
    '12th Commerce',
    '11th Arts',
    '12th Arts',
  ];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  void _uploadResource() {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a file to upload")),
      );
      return;
    }
    final descriptionText = _descriptionController.text.trim();
    setState(() {
      resources.add(_ResourceItem(
        subject: selectedSubject!,
        className: selectedClass!,
        title: _titleController.text.trim(),
        description: descriptionText.isEmpty ? null : descriptionText,
        file: _pickedFile!,
      ));
      _titleController.clear();
      _descriptionController.clear();
      selectedSubject = null;
      selectedClass = null;
      _pickedFile = null;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Resource uploaded")));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _pickedFile != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: Color(0xFF1A3DB5),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Upload Resource',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A3DB5),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1B4B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable Body ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Hero Text ────────────────────────────────────────────
                    const Text(
                      'RESOURCE MANAGEMENT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9098A3),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0D1B4B),
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                        children: [
                          TextSpan(text: 'Share Resources with\nyour '),
                          TextSpan(
                            text: 'Students.',
                            style: TextStyle(color: Color(0xFF1A3DB5)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Form ─────────────────────────────────────────────────
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Select Subject
                          _fieldLabel('Select Subject'),
                          const SizedBox(height: 8),
                          _styledDropdown<String>(
                            value: selectedSubject,
                            hint: 'Mathematics',
                            items: subjectList,
                            validator: (v) =>
                            v == null ? 'Please select a subject' : null,
                            onChanged: (v) =>
                                setState(() => selectedSubject = v),
                          ),

                          const SizedBox(height: 20),

                          // Select Class
                          _fieldLabel('Select Class'),
                          const SizedBox(height: 8),
                          _styledDropdown<String>(
                            value: selectedClass,
                            hint: 'Section A',
                            items: classList,
                            validator: (v) =>
                            v == null ? 'Please select a class' : null,
                            onChanged: (v) =>
                                setState(() => selectedClass = v),
                          ),

                          const SizedBox(height: 20),

                          // Resource Title
                          _fieldLabel('Resource Title'),
                          const SizedBox(height: 8),
                          _styledTextField(
                            controller: _titleController,
                            hint: 'e.g., Week 4: Neural Networks Fu...',
                            validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Please give a title'
                                : null,
                          ),

                          const SizedBox(height: 20),

                          // Description
                          _fieldLabel('Description'),
                          const SizedBox(height: 8),
                          _styledTextField(
                            controller: _descriptionController,
                            hint: 'Briefly describe what this resource covers...',
                            maxLines: 4,
                          ),

                          const SizedBox(height: 20),

                          // Upload File
                          _fieldLabel('Upload File'),
                          const SizedBox(height: 8),

                          GestureDetector(
                            onTap: _pickFile,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 32, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: hasFile
                                      ? const Color(0xFF1A3DB5)
                                      : Colors.transparent,
                                  width: 1.5,
                                  style: BorderStyle.solid,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8EFFE),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.cloud_upload_rounded,
                                      color: hasFile
                                          ? const Color(0xFF1A3DB5)
                                          : const Color(0xFF1A3DB5),
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    hasFile
                                        ? _pickedFile!.name
                                        : 'Tap to upload or drag and drop',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: hasFile
                                          ? const Color(0xFF1A3DB5)
                                          : const Color(0xFF0D1B4B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    hasFile
                                        ? _fileSize(_pickedFile!.size)
                                        : 'PDF, DOC, or ZIP (Max 50MB)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9098A3),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (hasFile) ...[
                                    const SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () =>
                                          setState(() => _pickedFile = null),
                                      child: const Text(
                                        'Remove file',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFE53E3E),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Upload Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _uploadResource,
                              icon: const Icon(
                                Icons.upload_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              label: const Text(
                                'Upload Resource',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A3DB5),
                                elevation: 4,
                                shadowColor:
                                const Color(0xFF1A3DB5).withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),


                          // ── Uploaded Resources List ──────────────────────
                          if (resources.isNotEmpty) ...[
                            Text(
                              'Uploaded Resources (${resources.length})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0D1B4B),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: resources.length,
                              separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                              itemBuilder: (context, index) =>
                                  _ResourceListCard(
                                    item: resources[index],
                                    onDelete: () {
                                      setState(() {
                                        resources.removeAt(index);
                                        Navigator.of(context).pop();
                                      });
                                    },
                                  ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home_rounded, 'HOME', false),
                _navItem(Icons.calendar_month_rounded, 'SCHEDULE', false),
                _navItem(Icons.upload_rounded, 'UPLOAD', true),
                _navItem(Icons.menu_book_rounded, 'LIBRARY', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF374151),
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _styledDropdown<T>({
    required T? value,
    required String hint,
    required List<String> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      validator: validator,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF6B7280)),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A3DB5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFE53E3E), width: 1.5),
        ),
      ),
      hint: Text(
        hint,
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
      ),
      items: items
          .map((s) => DropdownMenuItem<T>(
        value: s as T,
        child: Text(s,
            style: const TextStyle(
                fontSize: 14, color: Color(0xFF0D1B4B))),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _styledTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Color(0xFF0D1B4B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        const TextStyle(color: Color(0xFF9098A3), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A3DB5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFE53E3E), width: 1.5),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            color: isSelected
                ? const Color(0xFF1A3DB5)
                : const Color(0xFF9098A3),
            size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? const Color(0xFF1A3DB5)
                : const Color(0xFF9098A3),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

String _fileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

class _ResourceItem {
  final String subject;
  final String className;
  final String title;
  final String? description;
  final PlatformFile file;

  _ResourceItem({
    required this.subject,
    required this.className,
    required this.title,
    this.description,
    required this.file,
  });
}

class _ResourceListCard extends StatelessWidget {
  final _ResourceItem item;
  final VoidCallback onDelete;

  const _ResourceListCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EFFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.insert_drive_file_rounded,
                color: Color(0xFF1A3DB5), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF0D1B4B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _tag(item.subject, const Color(0xFFE8EFFE),
                        const Color(0xFF1A3DB5)),
                    const SizedBox(width: 6),
                    _tag(item.className, const Color(0xFFD1FAE5),
                        const Color(0xFF059669)),
                  ],
                ),
                if (item.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: const TextStyle(
                        color: Color(0xFF9098A3), fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  item.file.name,
                  style: const TextStyle(
                      color: Color(0xFF6B7280), fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final path = item.file.path;
                  if (path == null || path.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('File path is not available')),
                    );
                    return;
                  }
                  final result = await OpenFilex.open(path);
                  if (result.type != ResultType.done && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                          Text('Unable to open file: ${result.message}')),
                    );
                  }
                },
                child: const Icon(Icons.open_in_new_rounded,
                    color: Color(0xFF9098A3), size: 20),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Resource',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    content: const Text(
                        'Are you sure you want to delete this file?'),
                    actions: [
                      TextButton(
                        onPressed: onDelete,
                        child: const Text('Yes',
                            style: TextStyle(color: Color(0xFFE53E3E))),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('No',
                            style: TextStyle(color: Color(0xFF1A3DB5))),
                      ),
                    ],
                  ),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFE53E3E), size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}