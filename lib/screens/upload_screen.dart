import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/ticket_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TicketService _ticketService = TicketService();
  final _formKey = GlobalKey<FormState>();

  String? _selectedFilePath;
  String? _selectedCategory;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _selectedEventDate;
  bool _isUploading = false;

  final List<String> categories = [
    '演唱会',
    '飞机',
    '火车',
    '电影',
    '展览',
    '其他'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择文件失败: $e')),
      );
    }
  }

  Future<void> _selectEventDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedEventDate = picked;
      });
    }
  }

  Future<void> _uploadTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFilePath == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择文件和分类')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await _ticketService.uploadTicket(
        file: File(_selectedFilePath!),
        name: _nameController.text,
        category: _selectedCategory!,
        description:
            _descriptionController.text.isEmpty ? null : _descriptionController.text,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        eventDate: _selectedEventDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('门票上传成功')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('上传失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加门票'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 文件选择
              Card(
                child: ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: Text(
                    _selectedFilePath == null
                        ? '选择PDF文件'
                        : _selectedFilePath!.split('/').last,
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: _isUploading ? null : _pickFile,
                ),
              ),
              const SizedBox(height: 16),

              // 门票名称
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '门票名称',
                  hintText: '例如: 演唱会票',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return '请输入门票名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 分类选择
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: '分类',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: _isUploading
                    ? null
                    : (value) {
                        setState(() => _selectedCategory = value);
                      },
                validator: (value) {
                  if (value == null) {
                    return '请选择分类';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 描述
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: '描述 (可选)',
                  hintText: '例如: 演唱会简介',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 16),

              // 地点
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: '地点 (可选)',
                  hintText: '例如: 国家体育馆',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 活动日期
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    _selectedEventDate == null
                        ? '选择活动日期 (可选)'
                        : '活动日期: ${_selectedEventDate.toString().split(' ')[0]}',
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: _isUploading ? null : _selectEventDate,
                ),
              ),
              const SizedBox(height: 24),

              // 上传按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadTicket,
                  child: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          '上传门票',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
