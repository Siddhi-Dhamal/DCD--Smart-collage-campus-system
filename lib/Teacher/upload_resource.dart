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

  List<String> subjectList = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'English',
    'Marathi',
    'Hindi',
  ];

  List<String> classList = [
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
      setState(() {
        _pickedFile = result.files.first;
      });
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
      resources.add(
        _ResourceItem(
          subject: selectedSubject!,
          className: selectedClass!,
          title: _titleController.text.trim(),
          description: descriptionText.isEmpty ? null : descriptionText,
          file: _pickedFile!,
        ),
      );
      _titleController.clear();
      _descriptionController.clear();
      selectedSubject = null;
      selectedClass = null;
      _pickedFile = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Resource uploaded")));
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
      backgroundColor: const Color.fromARGB(255, 246, 243, 243),
      body: SingleChildScrollView(
        child: SafeArea(
          minimum: const EdgeInsets.only(top: 40.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      size: 25,
                      color: Colors.black54,
                    ),
                  ),
                  // const SizedBox(width: 30,),
                  Text(
                    "Upload Resource",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, size: 20, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        // icon: const SizedBox.shrink(),
                        validator: (value) {
                          if (value == null) {
                            return "Please select a Subject";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Subject",
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 40, 80, 227),
                              width: 1,
                            ),
                          ),
                        ),
                        hint: Text("Select Subject"),

                        items: subjectList.map((String subject) {
                          return DropdownMenuItem(
                            value: subject,
                            child: Text(subject),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSubject = value;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        // icon: const SizedBox.shrink(),
                        validator: (value) {
                          if (value == null) {
                            return "Please select a Class";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Class",
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 40, 80, 227),
                              width: 1,
                            ),
                          ),
                        ),
                        hint: Text("Select Class"),

                        items: classList.map((String classes) {
                          return DropdownMenuItem(
                            value: classes,
                            child: Text(classes),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedClass = value;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please give a title";
                          } else {
                            return null;
                          }
                        },
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: "Title",
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 40, 80, 227),
                              width: 1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        maxLines: 3,
                        minLines: 2,
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: "Description(Optional)",
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 40, 80, 227),
                              width: 1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Pick File
                      GestureDetector(
                        onTap: hasFile ? null : _pickFile,
                        child: Container(
                          alignment: Alignment.center,
                          transformAlignment: Alignment.center,
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            // color: const Color.fromARGB(255, 40, 80, 227),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                // color: const Color.fromARGB(255, 166, 162, 162),
                                color: hasFile
                                    ? Color.fromARGB(255, 23, 42, 215)
                                    : Color.fromARGB(255, 166, 162, 162),
                                size: 40,
                              ),
                              Text(
                                hasFile
                                    ? "File selected — tap \u00d7 to change"
                                    : "Click to upload or drag and drop",
                                style: TextStyle(
                                  color: hasFile
                                      ? Color.fromARGB(255, 9, 48, 189)
                                      : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),

                              Text(
                                "Supported formats: PDF, DOCX, PPTX, images",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (hasFile) _fileChip(),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: _uploadResource,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            40,
                            80,
                            227,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "Upload Resource",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _buildResourceList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fileChip() {
    final file = _pickedFile!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.file_copy_rounded, size: 20),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),
                Text(
                  _fileSize(file.size),
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _pickedFile = null),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: Text(
            "Uploaded Resources (${resources.length})",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: resources.length,
          itemBuilder: (context, index) => _ResourceListCard(
            item: resources[index],
            onDelete: () {
              setState(() {
                resources.removeAt(index);
                Navigator.of(context).pop();
              });
            },
          ),
        ),
      ],
    );
  }
}

// class _DashedBorderPainter extends CustomPainter {

//   @override
//   void paint(Canvas canvas, )
// }

String _fileSize(int bytes) {
  if (bytes < 1024) return "$bytes B";
  if (bytes > 1024) {
    bytes = (bytes / 1024).toInt();
    return "${bytes.toStringAsFixed(2)} KB";
  }
  if (bytes > 1024 * 1024) {
    bytes = (bytes / 1024 * 1024).toInt();
    return "${bytes.toStringAsFixed(2)} MB";
  }
  return "";
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
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.file_copy_rounded, color: Colors.black, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(110, 0, 150, 135),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.subject,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(111, 33, 149, 243),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.className,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 5),
                  Text(
                    item.description ?? "",
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  item.file.name,
                  style: TextStyle(color: Colors.black, fontSize: 11),
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
                        content: Text("File path is not available"),
                      ),
                    );
                    return;
                  }

                  final result = await OpenFilex.open(path);
                  if (result.type != ResultType.done) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Unable to open file: ${result.message}",
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Icon(
                  Icons.open_in_new_rounded,
                  color: Colors.grey,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                // onTap: onDelete,
                onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        "Delete Resource",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        "Are you sure you want to delete this file?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: onDelete,
                          child: Text(
                            "Yes",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "No",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
//     return Container(
//       padding: const EdgeInsets.all(14),
//       margin: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//       ),

//       child: Row(
//         // crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               color: Colors.purple,
//             ),
//             child: Icon(Icons.file_copy_rounded, size: 20),
//           ),
//           Column(
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Row(
//                 children: [
//                   Text(
//                     subject,
//                     style: TextStyle(
//                       color: Colors.blue,
//                     ),
//                   ),
//                   SizedBox(width: 20),

//                   Text(
//                     className,
//                     style: TextStyle(
//                       color: Colors.green.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ]
//           ),
//         ],
//       ),
//     );
//   }
// }
