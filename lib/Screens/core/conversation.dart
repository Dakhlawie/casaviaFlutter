import 'dart:convert';
import 'package:casavia/model/conversation.dart';
import 'package:casavia/model/note.dart';
import 'package:casavia/services/MessageService.dart';
import 'package:casavia/services/conversationService.dart';
import 'package:casavia/services/pusher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class ConversationPage extends StatefulWidget {
  final Conversation conversation;

  const ConversationPage({super.key, required this.conversation});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late PusherService pusherService;

  MessageService messageserv = MessageService();
  final TextEditingController _controller = TextEditingController();
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchConversation();
    _initPusher();
  }

  Future<void> _initPusher() async {
    var pusher = PusherChannelsFlutter.getInstance();

    await pusher.init(
      apiKey: "8fc7ac37b7848dcbc3a9",
      cluster: "mt1",
      onEvent: onEvent,
    );

    await pusher.connect();

    var channel = await pusher.subscribe(
      channelName: "partner-user-messages",
      onEvent: onEvent,
    );
  }

  void onEvent(dynamic event) {
    print("Received event: ${event.data}");
    final data = json.decode(event.data);
    final newMessage = Message(
      senderId: data['sender'],
      content: data['message'],
      role: data['role'],
    );

    bool messageExists = _messages.any((msg) =>
        msg.senderId == newMessage.senderId &&
        msg.content == newMessage.content &&
        msg.role == newMessage.role);

    if (!messageExists) {
      setState(() {
        _messages.add(newMessage);
      });
    }
  }

  ConversationService conversationServ = ConversationService();
  Future<void> _fetchConversation() async {
    try {
      List<Message> messages = widget.conversation.messages!;

      //  messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      await conversationServ.markMessagesAsSeen(widget.conversation);

      setState(() {
        _messages = messages;
      });
    } catch (e) {
      print('Failed to load conversation: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    Message newMessage = Message(
      senderId: widget.conversation.user!.id,
      content: _controller.text,
      role: 'USER',
    );

    try {
      Message sentMessage = await conversationServ.addMessage(
          widget.conversation.id!, newMessage);
      setState(() {
        _messages.add(sentMessage);
        _controller.clear();
      });
    } catch (e) {
      print('Failed to send message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_outlined,
                        color: Colors.black),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                            'http://192.168.1.17:3000/api/image/loadfromFSPerson/${widget.conversation.partner!.personId}')
                        as ImageProvider<Object>?,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.conversation.partner!.nom} ${widget.conversation.partner!.prenom} ',
                          style: TextStyle(
                            fontFamily: 'AbrilFatface',
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Partner',
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  bool isUserMessage = message.role == 'USER';
                  return Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4.0),
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isUserMessage ? Colors.blue[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        message.content!,
                        style: TextStyle(
                          color: isUserMessage ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Ask...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.blue[900]!,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send, color: Colors.blue[900]),
                    onPressed: () {
                      _sendMessage();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
