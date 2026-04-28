import 'package:flutter/material.dart';
import '../data/models/task.dart';
import '../data/repository/task_repository.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TaskRepository _taskRepository = TaskRepository();
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // Hiển thị dialog thêm công việc mới
  void _showAddTaskDialog() {
    _titleController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Thêm công việc mới',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _titleController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nhập tiêu đề công việc...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.indigo, width: 2),
            ),
          ),
          onSubmitted: (_) => _addTask(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: _addTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  // Thêm task mới vào Firestore
  Future<void> _addTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề công việc!')),
      );
      return;
    }
    await _taskRepository.addTask(title);
    if (mounted) Navigator.pop(context);
  }

  // Cập nhật trạng thái isDone
  Future<void> _toggleTask(Task task) async {
    await _taskRepository.updateTaskStatus(task.id, !task.isDone);
  }

  // Xóa task
  Future<void> _deleteTask(String id) async {
    await _taskRepository.deleteTask(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã xóa công việc'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  // Hiển thị dialog sửa công việc
  void _showEditTaskDialog(Task task) {
    _titleController.text = task.title;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sửa công việc',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _titleController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nhập tiêu đề mới...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.indigo, width: 2),
            ),
          ),
          onSubmitted: (_) => _editTask(task.id),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => _editTask(task.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // Lưu tiêu đề đã sửa lên Firestore
  Future<void> _editTask(String id) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tiêu đề không được để trống!')),
      );
      return;
    }
    await _taskRepository.updateTaskTitle(id, title);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật công việc')),
      );
    }
  }

  // Hiển thị dialog xác nhận xóa
  void _showDeleteConfirm(String id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa công việc'),
        content: Text('Bạn có chắc muốn xóa "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTask(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
            const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text(
          'Công việc của tôi\nNguyễn Bình Minh - 6451071047',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          StreamBuilder<List<Task>>(
            stream: _taskRepository.getTasks(),
            builder: (context, snapshot) {
              final tasks = snapshot.data ?? [];
              final done = tasks.where((t) => t.isDone).length;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '$done/${tasks.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Task>>(
        stream: _taskRepository.getTasks(),
        builder: (context, snapshot) {
          // Đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          }

          // Lỗi
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Đã xảy ra lỗi: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          final tasks = snapshot.data ?? [];

          // Danh sách trống
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.checklist_rounded,
                      size: 80, color: Colors.indigo.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có công việc nào!\nNhấn + để thêm mới.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskItem(task);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => _deleteTask(task.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CheckboxListTile(
          value: task.isDone,
          onChanged: (_) => _toggleTask(task),
          title: Text(
            task.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              decoration:
              task.isDone ? TextDecoration.lineThrough : null,
              color: task.isDone ? Colors.grey : Colors.black87,
            ),
          ),
          subtitle: Text(
            _formatDate(task.createdAt.toDate()),
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          secondary: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.indigo),
                onPressed: () => _showEditTaskDialog(task),
                tooltip: 'Sửa',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _showDeleteConfirm(task.id, task.title),
                tooltip: 'Xóa',
              ),
            ],
          ),
          activeColor: Colors.indigo,
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}