import 'package:casavia/Screens/core/conversation.dart';
import 'package:casavia/Screens/login/login_page.dart';
import 'package:casavia/model/conversation.dart';
import 'package:casavia/model/message.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/MessageService.dart';
import 'package:casavia/services/UserService.dart';
import 'package:casavia/services/conversationService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Conversation> conversations = [];
  final MessageService messageService = MessageService();
  final ConversationService conversationServ = ConversationService();
  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    AuthService authService = AuthService();
    int? userId = await authService.getUserIdFromToken();
    print('****************************');
    print(userId);

    if (userId != null && userId != 0) {
      Provider.of<UserModel>(context, listen: false).setUserId(userId);
      await fetchConversations(userId);
    } else {
      print('Invalid userId: $userId');
    }

    print('USERID');
    print(userId);
  }

  Future<void> fetchConversations(int userId) async {
    try {
      final fetchedConversations =
          await conversationServ.getConversationsByUser(userId);
      setState(() {
        conversations = fetchedConversations;
      });
      print(conversations.length);
    } catch (e) {
      print('Failed to load conversations: $e');
    }
  }

  Future<void> _refreshConversations() async {
    final userId = Provider.of<UserModel>(context, listen: false).userId;
    if (userId != null) {
      await fetchConversations(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserModel>(context).userId;

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/conversation.svg',
                        height: 200,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Conversations',
                        style: TextStyle(
                          fontFamily: 'AbrilFatface',
                          fontSize: 30.0,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userId == null || userId == 0
                            ? 'Log in to connect with our partners and get personalized recommendations and assistance for your bookings.'
                            : 'When you start a conversation with a partner, it will be saved here.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (userId == null || userId == 0) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.all(12),
                              backgroundColor: Colors.blue[900],
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 70),
                    Text(
                      'Conversations ',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'AbrilFatface',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        suffixIcon: Icon(Icons.search, color: Colors.blue[900]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final lastMessage =
                              conversations[index].messages!.isNotEmpty
                                  ? conversations[index].messages!.last
                                  : null;

                          final subtitleText = lastMessage != null
                              ? (lastMessage.role == 'USER'
                                  ? 'You: ${lastMessage.content}'
                                  : lastMessage.content)
                              : 'No messages';

                          final subtitleStyle = lastMessage != null &&
                                  !lastMessage.seen &&
                                  lastMessage.role == 'PARTNER'
                              ? TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)
                              : TextStyle(color: Colors.grey);
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                      'http://192.168.1.17:3000/api/image/loadfromFSPerson/${conversations[index].partner!.personId}')
                                  as ImageProvider<Object>?,
                            ),
                            title: Text(
                              '${conversations[index].partner!.nom} ${conversations[index].partner!.prenom}',
                              style: TextStyle(
                                fontFamily: 'AbrilFatface',
                              ),
                            ),
                            subtitle: Text(
                              subtitleText!,
                              style: subtitleStyle,
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConversationPage(
                                    conversation: conversations[index],
                                  ),
                                ),
                              );
                              if (result == true) {
                                _refreshConversations();
                              }
                            },
                          );
                        },
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                          indent: 16,
                          endIndent: 16,
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
