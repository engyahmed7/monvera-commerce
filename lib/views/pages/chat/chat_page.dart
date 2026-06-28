import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/realtime/chat_events.dart';
import 'provider/chat_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _roomIdController = TextEditingController();
  final TextEditingController _rentalIdController = TextEditingController();
  String? _lastReadSnackKey;

  @override
  void dispose() {
    _roomIdController.dispose();
    _rentalIdController.dispose();
    super.dispose();
  }

  Future<void> _subscribeRoom() async {
    final roomId = int.tryParse(_roomIdController.text.trim());
    if (roomId == null || roomId <= 0) {
      _showSnack('Enter a valid room ID.');
      return;
    }
    print('roomId: $roomId');
    
    await context.read<ChatProvider>().openRoomById(roomId);
  }

  Future<void> _openByRental() async {
    final rentalId = int.tryParse(_rentalIdController.text.trim());
    if (rentalId == null || rentalId <= 0) {
      _showSnack('Enter a valid rental ID.');
      return;
    }
    await context.read<ChatProvider>().openRoomFromRental(rentalId);
  }

  void _showSnack(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  String _readEventKey(ChatMessageReadEvent event) {
    return '${event.readerId}:${event.messageIds.join(',')}';
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final error = chat.error;
    if (error != null && error.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showSnack(error);
        context.read<ChatProvider>().clearError();
      });
    }

    final readEvent = chat.lastReadEvent;
    if (readEvent != null) {
      final readKey = _readEventKey(readEvent);
      if (readKey != _lastReadSnackKey) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _lastReadSnackKey = readKey;
          _showSnack(
            'Last read update: reader=${readEvent.readerId}, '
            'messageIds=${readEvent.messageIds.join(", ")}',
          );
        });
      }
    }

    return Scaffold(
      body: Column(
        children: [
          _buildConnectionCard(chat),
          const Divider(height: 1),
          Expanded(
            child: chat.messages.isEmpty
                ? const Center(
                    child: Text('No messages yet. Subscribe to a room first.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: chat.messages.length,
                    itemBuilder: (context, index) {
                      final event = chat.messages[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(event.user.name.isEmpty ? '?' : event.user.name[0]),
                          ),
                          title: Text(event.user.name.isEmpty ? 'User ${event.userId}' : event.user.name),
                          subtitle: Text(event.message),
                          trailing: Text(
                            event.isRead ? 'Read' : 'Sent',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard(ChatProvider chat) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    chat.isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: chat.isConnected ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(chat.isConnected ? 'Socket connected' : 'Socket disconnected'),
                  const Spacer(),
                  if (chat.roomId != null) Text('Room ${chat.roomId}'),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _roomIdController,
                enabled: !chat.isBusy,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Room ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: chat.isBusy ? null : _subscribeRoom,
                  child: chat.isBusy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Subscribe by Room ID'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _rentalIdController,
                enabled: !chat.isBusy,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Rental ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: chat.isBusy ? null : _openByRental,
                      child: const Text('Open via Rental'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: chat.isBusy ? null : context.read<ChatProvider>().leaveCurrentRoom,
                      child: const Text('Leave Room'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
