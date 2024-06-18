import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/question.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/QuestionService.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
// Importez la classe User

class DiscussionPage extends StatefulWidget {
  final Hebergement hebergement;
  const DiscussionPage({
    Key? key,
    required this.hebergement,
  }) : super(key: key);
  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  late Future<List<Question>> _questionsFuture = Future.value([]);
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [
    Message("Hello Meryem, how can we help?", false)
  ];

  Future<void> _fetchUserId() async {
    AuthService authService = AuthService();
    QuestionService questionService = QuestionService();
    int? userId = await authService.getUserIdFromToken();
    if (userId != null) {
      Provider.of<UserModel>(context, listen: false).setUserId(userId);
      setState(() {
        _questionsFuture = questionService.findByUserAndHebergement(
          widget.hebergement.hebergementId,
          userId,
        );
      });
    }
    print('USERID');
    print(userId);
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final messageText = _controller.text;
      setState(() {
        _messages.add(Message(messageText, true));
      });
      _controller.clear();
      Question newQuestion = Question(
        content: messageText,
        dateAsked: DateTime.now(),
      );
      try {
        Question addedQuestion = await QuestionService().ajouterQuestion(
            newQuestion,
            Provider.of<UserModel>(context, listen: false).userId!,
            widget.hebergement.hebergementId);
        print('Question ajoutée avec succès : ${addedQuestion.id}');
        _questionsFuture.then((questions) {
          setState(() {
            _questionsFuture = Future.value([...questions, addedQuestion]);
          });
        });

        setState(() {
          _messages.add(Message(
              "Your question has been sent. We will reply soon.", false));
        });
      } catch (e) {
        print('Erreur lors de l\'ajout de la question : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserModel>(context).userId;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Center(
          child: Text(
            widget.hebergement.nom,
            style: TextStyle(
              fontFamily: 'AbrilFatface',
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Question>>(
              future: _questionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Aucune question trouvée.'));
                } else {
                  List<Question> questions = snapshot.data!;
                  return ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: questions.length +
                        1 +
                        _messages
                            .length, // Ajoutez un pour le message de bienvenue et messages existants
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Affichez le message de bienvenue
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 4.0),
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 15.0),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Hello Meryem, how can we help?",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      } else if (index <= questions.length) {
                        // Affichez les autres questions et réponses
                        final question =
                            questions[index - 1]; // Décalez l'index de 1
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 4.0),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 15.0),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[900],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  question.content,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            if (question.reponse != null &&
                                question.reponse!.content.isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 4.0),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 15.0),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    question.reponse!.content,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                          ],
                        );
                      } else {
                        // Affichez les messages de confirmation et autres messages ajoutés
                        final message = _messages[index - questions.length - 1];
                        return Align(
                          alignment: message.isUserMessage
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
                              color: message.isUserMessage
                                  ? Colors.blue[900]
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                color: message.isUserMessage
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask Question...',
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
                  onPressed: _sendMessage,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String text;
  final bool isUserMessage;

  Message(this.text, this.isUserMessage);
}
