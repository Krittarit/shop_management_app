import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shop_management_app/models/member.dart';
import 'package:shop_management_app/screens/member/member_form.dart';
import 'package:shop_management_app/screens/member/member_detail.dart';
import 'package:shop_management_app/services/member_service.dart';
import 'package:intl/intl.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // เช็คว่ามีการส่งพารามิเตอร์มาให้แสดงไดอะล็อกเพิ่มสมาชิกหรือไม่
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map<String, dynamic>? args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['showAddDialog'] == true) {
        _showAddMemberDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final memberService = Provider.of<MemberService>(context);
    final members = memberService.members;

    // กรองรายการสมาชิกตามคำค้นหา
    final filteredMembers = members.where((member) {
      final name = member.name.toLowerCase();
      final phone = member.phone.toLowerCase();
      final search = _searchQuery.toLowerCase();
      return name.contains(search) || phone.contains(search);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการสมาชิก'),
        actions: [
          // ปุ่มค้นหา
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _MemberSearchDelegate(
                  members,
                  (member) => _navigateToMemberDetail(member),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ช่องค้นหา
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'ค้นหาสมาชิก',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // รายการสมาชิก
          Expanded(
            child: filteredMembers.isEmpty
                ? const Center(
                    child: Text('ไม่พบสมาชิก'),
                  )
                : ListView.builder(
                    itemCount: filteredMembers.length,
                    itemBuilder: (context, index) {
                      final member = filteredMembers[index];
                      return _buildMemberListItem(context, member);
                    },
                  ),
          ),
        ],
      ),
      // ปุ่มเพิ่มสมาชิก
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemberDialog,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  // สร้างรายการแสดงข้อมูลสมาชิก
  Widget _buildMemberListItem(BuildContext context, Member member) {
    final memberService = Provider.of<MemberService>(context, listen: false);

    return Slidable(
      // ปุ่มลูกศรซ้าย (แก้ไข)
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showEditMemberDialog(member),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'แก้ไข',
          ),
        ],
      ),
      // ปุ่มลูกศรขวา (ลบ)
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showDeleteMemberDialog(member),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'ลบ',
          ),
        ],
      ),
      // รายการสมาชิก
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(member.name),
        subtitle: Text(member.phone),
        trailing: Text(
          '${member.point} คะแนน',
          style: TextStyle(
            color: member.point > 0 ? Colors.green : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => _navigateToMemberDetail(member),
      ),
    );
  }

  // นำทางไปยังหน้ารายละเอียดสมาชิก
  void _navigateToMemberDetail(Member member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDetailScreen(member: member),
      ),
    );
  }

  // แสดงไดอะล็อกเพิ่มสมาชิก
  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: MemberFormScreen(
          onSave: (Member newMember) async {
            final memberService =
                Provider.of<MemberService>(context, listen: false);
            await memberService.addMember(newMember);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('เพิ่มสมาชิกเรียบร้อยแล้ว'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // แสดงไดอะล็อกแก้ไขสมาชิก
  void _showEditMemberDialog(Member member) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: MemberFormScreen(
          member: member,
          onSave: (Member updatedMember) async {
            final memberService =
                Provider.of<MemberService>(context, listen: false);
            await memberService.updateMember(updatedMember);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('อัปเดตสมาชิกเรียบร้อยแล้ว'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // แสดงไดอะล็อกลบสมาชิก
  void _showDeleteMemberDialog(Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบสมาชิก'),
        content: Text('คุณต้องการลบ ${member.name} หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              final memberService =
                  Provider.of<MemberService>(context, listen: false);
              await memberService.deleteMember(member.id!);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ลบสมาชิกเรียบร้อยแล้ว'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// คลาสสำหรับการค้นหาสมาชิกแบบเต็มหน้าจอ
class _MemberSearchDelegate extends SearchDelegate<Member?> {
  final List<Member> members;
  final Function(Member) onMemberSelected;

  _MemberSearchDelegate(this.members, this.onMemberSelected);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = members.where((member) {
      final name = member.name.toLowerCase();
      final phone = member.phone.toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || phone.contains(searchQuery);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final member = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(member.name),
          subtitle: Text(member.phone),
          onTap: () {
            close(context, member);
            onMemberSelected(member);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = members.where((member) {
      final name = member.name.toLowerCase();
      final phone = member.phone.toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || phone.contains(searchQuery);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final member = suggestions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(member.name),
          subtitle: Text(member.phone),
          onTap: () {
            close(context, member);
            onMemberSelected(member);
          },
        );
      },
    );
  }
}
