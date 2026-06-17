import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket.dart';

class TicketService {
  final supabase = Supabase.instance.client;
  
  static const String _ticketsTable = 'tickets';
  static const String _bucketName = 'tickets';

  /// 上传PDF门票
  Future<Ticket> uploadTicket({
    required File file,
    required String name,
    required String category,
    String? description,
    String? location,
    DateTime? eventDate,
  }) async {
    try {
      // 获取当前用户ID或使用默认值
      final userId = supabase.auth.currentUser?.id ?? 'anonymous';
      
      // 上传文件到Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final filePath = '$userId/$fileName';

      await supabase.storage
          .from(_bucketName)
          .upload(filePath, file);

      // 获取公共URL
      final fileUrl = supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      // 保存门票元数据到数据库
      final response = await supabase
          .from(_ticketsTable)
          .insert({
            'name': name,
            'category': category,
            'file_url': fileUrl,
            'user_id': userId,
            'description': description,
            'location': location,
            'event_date': eventDate?.toIso8601String(),
            'uploaded_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Ticket.fromJson(response);
    } catch (e) {
      throw Exception('上传门票失败: $e');
    }
  }

  /// 获取所有门票
  Future<List<Ticket>> getTickets() async {
    try {
      final userId = supabase.auth.currentUser?.id ?? 'anonymous';
      
      final response = await supabase
          .from(_ticketsTable)
          .select()
          .eq('user_id', userId)
          .order('uploaded_at', ascending: false);

      return (response as List)
          .map((item) => Ticket.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('获取门票失败: $e');
    }
  }

  /// 根据分类获取门票
  Future<List<Ticket>> getTicketsByCategory(String category) async {
    try {
      final userId = supabase.auth.currentUser?.id ?? 'anonymous';
      
      final response = await supabase
          .from(_ticketsTable)
          .select()
          .eq('user_id', userId)
          .eq('category', category)
          .order('uploaded_at', ascending: false);

      return (response as List)
          .map((item) => Ticket.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('获取门票失败: $e');
    }
  }

  /// 搜索门票
  Future<List<Ticket>> searchTickets(String query) async {
    try {
      final userId = supabase.auth.currentUser?.id ?? 'anonymous';
      
      final response = await supabase
          .from(_ticketsTable)
          .select()
          .eq('user_id', userId)
          .ilike('name', '%$query%')
          .order('uploaded_at', ascending: false);

      final tickets = (response as List)
          .map((item) => Ticket.fromJson(item))
          .toList();

      // 客户端过滤：按地点和描述搜索
      return tickets.where((ticket) {
        final query_lower = query.toLowerCase();
        return ticket.name.toLowerCase().contains(query_lower) ||
            ticket.description?.toLowerCase().contains(query_lower) ?? false ||
            ticket.location?.toLowerCase().contains(query_lower) ?? false;
      }).toList();
    } catch (e) {
      throw Exception('搜索失败: $e');
    }
  }

  /// 删除门票
  Future<void> deleteTicket(String ticketId, String fileUrl) async {
    try {
      // 从Storage删除文件
      final userId = supabase.auth.currentUser?.id ?? 'anonymous';
      final fileName = fileUrl.split('/').last;
      final filePath = '$userId/$fileName';

      await supabase.storage
          .from(_bucketName)
          .remove([filePath]);

      // 从数据库删除记录
      await supabase
          .from(_ticketsTable)
          .delete()
          .eq('id', ticketId);
    } catch (e) {
      throw Exception('删除门票失败: $e');
    }
  }

  /// 更新门票信息
  Future<void> updateTicket(String ticketId, Ticket ticket) async {
    try {
      await supabase
          .from(_ticketsTable)
          .update(ticket.toJson())
          .eq('id', ticketId);
    } catch (e) {
      throw Exception('更新门票失败: $e');
    }
  }

  /// 实时监听门票变化
  Stream<List<Ticket>> watchTickets() {
    final userId = supabase.auth.currentUser?.id ?? 'anonymous';
    
    return supabase
        .from(_ticketsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('uploaded_at')
        .map((data) => (data as List)
            .map((item) => Ticket.fromJson(item))
            .toList());
  }
}
