import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tasks';

  // Lấy stream danh sách tasks realtime
  Stream<List<Task>> getTasks() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Thêm task mới
  Future<void> addTask(String title) async {
    await _firestore.collection(_collection).add({
      'title': title,
      'isDone': false,
      'createdAt': Timestamp.now(),
    });
  }

  // Cập nhật trạng thái isDone
  Future<void> updateTaskStatus(String id, bool isDone) async {
    await _firestore.collection(_collection).doc(id).update({
      'isDone': isDone,
    });
  }

  // Xóa task
  Future<void> deleteTask(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Cập nhật tiêu đề task
  Future<void> updateTaskTitle(String id, String title) async {
    await _firestore.collection(_collection).doc(id).update({
      'title': title,
    });
  }
}