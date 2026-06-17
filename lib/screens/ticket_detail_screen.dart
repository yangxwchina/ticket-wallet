import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ticket.dart';

class TicketDetailScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailScreen({
    Key? key,
    required this.ticket,
  }) : super(key: key);

  void _openPDF() async {
    try {
      if (await canLaunchUrl(Uri.parse(ticket.fileUrl))) {
        await launchUrl(Uri.parse(ticket.fileUrl));
      } else {
        throw '无法打开PDF';
      }
    } catch (e) {
      print('打开PDF失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('门票详情'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 门票名称
            Text(
              ticket.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),

            // 分类标签
            Chip(label: Text(ticket.category)),
            const SizedBox(height: 24),

            // 详细信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow('分类', ticket.category),
                    const Divider(),
                    _buildDetailRow(
                      '上传时间',
                      ticket.uploadedDate.toString().split('.')[0],
                    ),
                    if (ticket.eventDate != null) ...[const Divider(),
                    _buildDetailRow(
                      '活动日期',
                      ticket.eventDate.toString().split(' ')[0],
                    ),
                    ],
                    if (ticket.location != null && ticket.location!.isNotEmpty) ...[const Divider(),
                    _buildDetailRow('地点', ticket.location ?? ''),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 描述
            if (ticket.description != null && ticket.description!.isNotEmpty) ...[const Text(
              '描述',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(ticket.description ?? ''),
              ),
            ),
            const SizedBox(height: 16),
            ],

            // 打开PDF按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _openPDF,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('打开PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        Text(value),
      ],
    );
  }
}
