import 'package:another_flushbar/flushbar.dart';
import 'package:casavia/model/avis.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/notification.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/AvisService.dart';
import 'package:casavia/services/HebergementService.dart';
import 'package:casavia/services/notificationService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class RatePage extends StatefulWidget {
  final Hebergement hebergement;
  final String startDate;
  final String endDate;
  const RatePage(
      {super.key,
      required this.hebergement,
      required this.startDate,
      required this.endDate});

  @override
  State<RatePage> createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  AvisService avisService = AvisService();
  HebergementService hebergementServ = HebergementService();
  final TextEditingController _likeController = TextEditingController();
  final TextEditingController _dislikeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _submitAvis(int userId) async {
    String? validationMessage = _validateFields();
    if (validationMessage != null) {
      _showFlushbar(validationMessage);
      return;
    }

    int staffRating = widget.hebergement.categorie.idCat == 1 ? ratings[0] : 0;
    int securityRating =
        widget.hebergement.categorie.idCat != 1 ? ratings[0] : 0;
    int totalRatings =
        staffRating + ratings[1] + ratings[2] + ratings[3] + ratings[4];
    double averageRating = totalRatings / 5.0;

    Avis avis = Avis(
      avis: _likeController.text,
      avisNegative: _dislikeController.text,
      moyenne: averageRating.toString(),
      staff: widget.hebergement.categorie.idCat == 1 ? ratings[0] : 0,
      location: ratings[4],
      comfort: ratings[3],
      facilities: ratings[1],
      cleanliness: ratings[2],
      security: widget.hebergement.categorie.idCat != 1 ? ratings[0] : 0,
      date: DateTime.now(),
    );

    try {
      Avis newAvis = await avisService.ajouterAvis(
          avis, widget.hebergement.hebergementId, userId);

      int newNbAvis = (widget.hebergement.nbAvis ?? 0) + 1;

      double newMoyenne =
          (widget.hebergement.moyenne! + averageRating) / newNbAvis;

      int newStaff = (widget.hebergement.categorie.idCat == 1)
          ? (((widget.hebergement.staff ?? 0) + ratings[0]) / newNbAvis).round()
          : (widget.hebergement.staff ?? 0).round();

      int newSecurity = (widget.hebergement.categorie.idCat != 1)
          ? (((widget.hebergement.security ?? 0) + ratings[0]) / newNbAvis)
              .round()
          : (widget.hebergement.security ?? 0).round();

      int newLocation =
          (((widget.hebergement.location ?? 0) + ratings[4]) / newNbAvis)
              .round();
      int newComfort =
          (((widget.hebergement.comfort ?? 0) + ratings[3]) / newNbAvis)
              .round();
      int newFacilities =
          (((widget.hebergement.facilities ?? 0) + ratings[1]) / newNbAvis)
              .round();
      int newCleanliness =
          (((widget.hebergement.cleanliness ?? 0) + ratings[2]) / newNbAvis)
              .round();

      await hebergementServ.updateHebergementMoyenne(
        id: widget.hebergement.hebergementId,
        staff: newStaff,
        location: newLocation,
        comfort: newComfort,
        facilities: newFacilities,
        cleanliness: newCleanliness,
        security: newSecurity,
        moyenne: newMoyenne,
        nbAvis: newNbAvis,
      );
      NotificationMessage newNotification = NotificationMessage(
        title: "You have a new review",
        date: DateTime.now(),
        seen: false,
        type: NotificationType.REVIEW,
      );

      try {
        await NotificationService().sendNotificationToPerson(
            newNotification, widget.hebergement!.person.personId!);
      } catch (e) {
        print('Failed to send notification: $e');
      }

      _showFlushbar(
          'Thank you for taking the time to share your feedback with us!');
    } catch (e) {
      _showFlushbar('Failed to submit your review. Please try again.');
    }
  }

  String? _validateFields() {
    if (_likeController.text.isEmpty) {
      return "All fields must be filled.";
    }
    if (ratings[4] == 0 ||
        ratings[2] == 0 ||
        ratings[1] == 0 ||
        ratings[3] == 0) {
      return "Please rate all required fields.";
    }
    if (widget.hebergement.categorie.idCat != 1 && ratings[0] == 0) {
      return "Please rate the security.";
    }
    if (widget.hebergement.categorie.idCat == 1 && ratings[0] == 0) {
      return "Please rate the staff.";
    }
    return null;
  }

  void _showFlushbar(String message) {
    Flushbar(
      message: message,
      backgroundColor: Colors.blue[900]!,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  Future<void> _fetchUserId() async {
    AuthService authService = AuthService();
    int? userId = await authService.getUserIdFromToken();
    if (userId != null) {
      Provider.of<UserModel>(context, listen: false).setUserId(userId);
    }
    print('USERID');
    print(userId);
  }

  List<int> ratings = List.filled(5, 0);
  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserModel>(context).userId;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Image.memory(
                  widget.hebergement.images[0].image,
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 16,
                  left: 10,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    padding: EdgeInsets.zero,
                    iconSize: 24,
                    constraints: BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    splashRadius: 24,
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.transparent,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hebergement.nom, // Hotel name
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${widget.startDate} - ${widget.endDate}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
                padding: EdgeInsets.all(8.0), child: buildRatingQuestions()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.sentiment_satisfied,
                              color: Colors.blue[900], size: 20),
                        ),
                        WidgetSpan(
                          child: SizedBox(width: 8),
                        ),
                        TextSpan(
                          text: 'What did you like? ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _likeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue[900]!,
                          width: 0.5,
                        ),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.sentiment_dissatisfied,
                              color: Colors.blue[900], size: 20),
                        ),
                        WidgetSpan(
                          child: SizedBox(width: 8),
                        ),
                        TextSpan(
                          text: 'What didn\'t you like?  ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        TextSpan(
                          text: '(optionnel)',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _dislikeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue[900]!,
                          width: 0.5,
                        ),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              _submitAvis(userId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text(
              'FINISH',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeaderImage() {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Image.memory(
          widget.hebergement.images[0].image,
          width: MediaQuery.of(context).size.width,
          height: 250,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 16,
          left: 10,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            padding: EdgeInsets.zero,
            iconSize: 24,
            constraints: BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            splashRadius: 24,
            color: Colors.grey.withOpacity(0.7),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.hebergement.nom, // Hotel name
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${widget.startDate} - ${widget.endDate}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildRatingQuestions() {
    return Column(
      children: [
        widget.hebergement.categorie.idCat == 1
            ? buildRatingQuestion("How were the staff?", 0)
            : buildRatingQuestion("Is it secure?", 0),
        buildRatingQuestion("How were the facilities?", 1),
        buildRatingQuestion("Was it clean?", 2),
        buildRatingQuestion("Was it comfortable?", 3),
        buildRatingQuestion("How was the location?", 4),
      ],
    );
  }

  Widget buildRatingQuestion(String question, int questionIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(question,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Wrap(
          spacing: 0,
          runSpacing: 0,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                size: 25,
                ratings[questionIndex] > index ? Icons.star : Icons.star_border,
                color: ratings[questionIndex] > index
                    ? Colors.blue[900]
                    : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  ratings[questionIndex] = index + 1;
                });
              },
            );
          }),
        ),
      ],
    );
  }
}
