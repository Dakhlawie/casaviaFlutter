import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'dart:io';
import 'dart:typed_data';
import 'package:casavia/Screens/core/ReservationEtape2.dart';
import 'package:casavia/Screens/core/VideoPlayerPage%20.dart';
import 'package:casavia/Screens/core/comments.dart';
import 'package:casavia/Screens/core/conversation.dart';
import 'package:casavia/Screens/core/equipements.dart';
import 'package:casavia/Screens/core/facilities.dart';
import 'package:casavia/Screens/core/openstreetMap.dart';
import 'package:casavia/Screens/core/position.dart';
import 'package:casavia/Screens/core/reservationEtape1.dart';
import 'package:casavia/model/conversation.dart';
import 'package:casavia/model/language.dart';
import 'package:casavia/model/user.dart';
import 'package:casavia/services/conversationService.dart';
import 'package:casavia/services/currencyService.dart';
import 'package:casavia/widgets/custom_button.dart';
import 'package:casavia/widgets/custom_text_field.dart';
import 'package:device_apps/device_apps.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:casavia/Screens/core/avis.dart';
import 'package:casavia/Screens/core/chambrelist.dart';
import 'package:casavia/Screens/login/login_page.dart';
import 'package:casavia/model/avis.dart';
import 'package:casavia/model/equipement.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/model/video.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/AvisService.dart';
import 'package:casavia/services/HebergementService.dart';
import 'package:casavia/services/LikeSerice.dart';
import 'package:casavia/services/UserService.dart';
import 'package:casavia/services/videoService.dart';
import 'package:casavia/theme/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:casavia/Screens/core/location_map.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AcommodationPage extends StatefulWidget {
  final Hebergement hebergement;
  final String checkIn;
  final String checkOut;
  const AcommodationPage(
      {Key? key,
      required this.hebergement,
      required this.checkIn,
      required this.checkOut})
      : super(key: key);

  @override
  State<AcommodationPage> createState() => _AcommodationPageState();
}

class _AcommodationPageState extends State<AcommodationPage> {
  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.blue[900]),
                    SizedBox(width: 20),
                    Expanded(
                      child: CustomTextField(
                        readOnly: true,
                        label: 'Check In',
                        controller: checkInTextController,
                        onTap: () {
                          _showCalendarDialog(
                              context, checkInTextController, true);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.blue[900]),
                    SizedBox(width: 20),
                    Expanded(
                      child: CustomTextField(
                        readOnly: true,
                        label: 'Check Out',
                        controller: checkOutTextController,
                        onTap: () {
                          _showCalendarDialog(
                              context, checkOutTextController, false);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  buttonText: 'Apply',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  TextEditingController _messageController = TextEditingController();
  String? ratingText;
  DateTime? _selectedDate;
  final TextEditingController checkInTextController = TextEditingController();
  final TextEditingController checkOutTextController = TextEditingController();
  Map<int, bool> showMore = {};
  Map<int, bool> _isExpandedMap = {};
  String _getShortText(String text) {
    if (text.length > 100) {
      return text.substring(0, 100) + '...';
    } else {
      return text;
    }
  }

  bool _isChatOpen = false;
  List<Avis> _avisList = [];
  List<Avis> _meilleurAvisList = [];
  bool _isLoading = true;
  List<Avis> getMeilleurAvis(List<Avis> avisList) {
    return avisList.where((avis) {
      if (avis.moyenne == null) {
        return false;
      }

      double? moyenne = double.tryParse(avis.moyenne!);
      if (moyenne == null) {
        return false;
      }

      return moyenne >= 4 &&
          moyenne <= 5 &&
          (avis.avisNegative == null || avis.avisNegative!.isEmpty);
    }).toList();
  }

  Future<void> _fetchAvis(int hebergementId) async {
    try {
      List<Avis> avisList =
          await _avisService.fetchAvisByHebergement(hebergementId);
      List<Avis> meilleurAvisList = getMeilleurAvis(avisList);

      avisList.sort((a, b) => b.date.compareTo(a.date));
      meilleurAvisList.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _avisList = avisList;
        _meilleurAvisList = meilleurAvisList;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to load avis: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ShareBottomSheet();
      },
    );
  }

  ConversationService conversationserv = ConversationService();

  double? prix;
  Map<String, IconData> equipementIcons = {
    'Pool': FontAwesomeIcons.swimmingPool,
    'Parking': FontAwesomeIcons.parking,
    'Air Conditioning': FontAwesomeIcons.snowflake,
    'Breakfast': FontAwesomeIcons.utensils,
    'Restaurant': FontAwesomeIcons.conciergeBell,
    'Wi-Fi': FontAwesomeIcons.wifi,
  };

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  void _showCalendarDialog(
      BuildContext context, TextEditingController controller, bool isCheckIn) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  isCheckIn ? 'Check In' : 'Check Out',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'AbrilFatface',
                  ),
                ),
              ),
              TableCalendar(
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    controller.text =
                        DateFormat('dd/MM/yyyy').format(selectedDay);

                    if (isCheckIn) {
                      // Logique pour Check In
                    } else {
                      // Logique pour Check Out
                    }
                  });
                  Navigator.pop(context);
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue[900],
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue[900],
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                  ),
                  child: Center(
                    child: Text('Apply'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  final HebergementService _hebergementService = HebergementService();
  List<Equipement>? equipements = [];
  List<Equipement>? allEquipements = [];
  bool isLoading = true;
  Future<void> _loadEquipements() async {
    try {
      int hebergementId = widget.hebergement.hebergementId;
      var fetchedEquipements =
          await _hebergementService.getEquipements(hebergementId);
      setState(() {
        allEquipements = fetchedEquipements;
        equipements = fetchedEquipements.take(4).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Failed to load equipements: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String description = '';
  int maxLength = 100;
  bool isExpanded = false;

  String trimmedDescription = '';
  String remainingDescription = '';

  final AvisService _avisService = AvisService();
  late Future<List<Avis>> _avisFuture;
  @override
  void initState() {
    super.initState();
    _loadEquipements();
    checkInTextController.text = widget.checkIn;
    checkOutTextController.text = widget.checkOut;
    _avisFuture =
        _avisService.fetchAvisByHebergement(widget.hebergement.hebergementId);
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      setState(() {
        _selectedImageIndex =
            (_selectedImageIndex + 1) % widget.hebergement.images.length;
      });
    });
    _fetchAvis(widget.hebergement.hebergementId);
    _fetchUserId();
    _loadVideo();
    fetchLanguages();

    calculateAndSetPrice();
    didChangeDependencies();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  List<Language> languages = [];
  void fetchLanguages() async {
    try {
      languages = await HebergementService()
          .getLanguagesByHebergementId(widget.hebergement.hebergementId);
      print(languages);
    } catch (e) {
      print('Error: $e');
    }
  }

  User? user;
  Future<void> _fetchUserId() async {
    AuthService authService = AuthService();
    int? userId = await authService.getUserIdFromToken();
    if (userId != null) {
      Provider.of<UserModel>(context, listen: false).setUserId(userId);
      user = await UserService().getUserById(userId);
    }
    print('USERID');
    print(userId);
  }

  int? numberOfNights;
  String? symbol;
  double? convertedPrice;
  late double? discountedPrice;
  late bool hasOffers = false;
  double calculatePrice(String checkIn, String checkOut, double prixParNuit) {
    DateTime startDate = DateFormat('dd/MM/yyyy').parse(checkIn);
    DateTime endDate = DateFormat('dd/MM/yyyy').parse(checkOut);
    numberOfNights = endDate.difference(startDate).inDays;
    return numberOfNights! * prixParNuit;
  }

  String getNightsText() {
    if (numberOfNights == null) {
      return '';
    } else if (numberOfNights == 1) {
      return 'per night';
    } else {
      return 'per $numberOfNights nights';
    }
  }

  void calculateAndSetPrice() {
    prix = calculatePrice(
        widget.checkIn, widget.checkOut, widget.hebergement.prix);
    hasOffers = widget.hebergement.offres != null &&
        widget.hebergement.offres!.isNotEmpty;
    discountedPrice = hasOffers
        ? prix! -
            (prix! *
                (double.parse(widget.hebergement.offres![0].discount) / 100))
        : prix;
    setState(() {});
  }
  // Future<double> calculatePrice(
  //     String checkIn, String checkOut, double prixParNuit) async {
  //   DateTime startDate = DateFormat('dd/MM/yyyy').parse(checkIn);
  //   DateTime endDate = DateFormat('dd/MM/yyyy').parse(checkOut);
  //   numberOfNights = endDate.difference(startDate).inDays;
  //   double totalPrice = numberOfNights! * prixParNuit;

  //   final prefs = await SharedPreferences.getInstance();
  //   String? ToCurrency = prefs.getString('selectedCurrency');
  //   if (ToCurrency != null) {
  //     symbol = getCurrencySymbol(ToCurrency);
  //   }
  //   /* if (ToCurrency != null && ToCurrency!.isNotEmpty) {
  //     double rate = await CurrencyService()
  //         .getConversionRate(widget.hebergement.currency, ToCurrency);
  //     totalPrice *= rate;
  //   }*/

  //   return totalPrice;
  // }

  String getRatingText(double rating) {
    if (rating >= 5) {
      return "Excellent";
    } else if (rating >= 4) {
      return "Very Good";
    } else if (rating >= 3) {
      return "Good";
    } else if (rating >= 2) {
      return "Fair";
    } else {
      return "Poor";
    }
  }

  String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      case 'CAD':
        return 'CA\$';
      case 'CHF':
        return 'CHF';
      case 'AUD':
        return 'A\$';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'SEK':
        return 'kr';
      case 'BRL':
        return 'R\$';
      case 'TRY':
        return '₺';
      case 'AED':
        return 'د.إ';
      case 'AFN':
        return '؋';
      case 'ALL':
        return 'Lek';
      case 'TND':
        return 'DT';
      case 'AMD':
        return '֏';

      default:
        return '';
    }
  }

  @override
  int _selectedImageIndex = 0;
  final PageController _pageController = PageController();
  Timer? _timer;
  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_selectedImageIndex < widget.hebergement.images.length - 1) {
        _selectedImageIndex++;
      } else {
        _selectedImageIndex = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _selectedImageIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  bool isFavorite = false;
  Future<void> _checkIfLiked() async {
    final userId = Provider.of<UserModel>(context, listen: false).userId;
    print(userId);
    try {
      bool liked = await likeService.checkLikeForUserAndHebergement(
          userId, widget.hebergement.hebergementId);

      setState(() {
        isFavorite = liked;
      });
      print('_checkIfLiked');
      print(isFavorite);
    } catch (e) {
      print('Erreur lors de la vérification du like : $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _checkIfLiked();
    print('didChangeDependencies()');
    print(isFavorite);
  }

  LikeService likeService = LikeService();
  VideoService videoService = VideoService();
  Video? _video;
  Future<void> _loadVideo() async {
    try {
      final video = await VideoService()
          .getVideoByHebergementId(widget.hebergement.hebergementId);
      setState(() {
        _video = video;
      });
      print("VIDEO");
      print(_video);
    } catch (e) {
      print('Erreur lors du chargement de la vidéo: $e');
    }
  }

  void _showVideo(BuildContext context) async {
    if (_video == null) {
      print("Vidéo non chargée");
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final tempVideoFile = File('${tempDir.path}/temp_video.mp4');
    await tempVideoFile.writeAsBytes(_video!.videoContent);

    VideoPlayerController controller =
        VideoPlayerController.file(tempVideoFile);

    await controller.initialize();

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => VideoPlayerPage(controller: controller),
    ));
  }

  Widget build(BuildContext context) {
    String cancellationPolicy;

    if (widget.hebergement.politiqueAnnulation == 'free cancellation') {
      cancellationPolicy = 'Free Cancellation';
    } else if (widget.hebergement.politiqueAnnulation == 'non refundable') {
      cancellationPolicy = 'Non Refundable';
    } else {
      cancellationPolicy =
          'our cancellation policy requires ${widget.hebergement.politiqueAnnulation} hours,  If you cancel your booking less than ${widget.hebergement.politiqueAnnulation} hours before the scheduled arrival time, cancellation fees may apply.';
    }

    final String phoneNumberWithCode =
        "+ ${widget.hebergement.country_code} ${widget.hebergement.phone}";
    final userId = Provider.of<UserModel>(context).userId;
    Future<void> handleConversation() async {
      try {
        if (widget.hebergement.person == null ||
            widget.hebergement.person.personId == null) {
          throw Exception('Partner information is missing.');
        }

        bool exists = await conversationserv.checkConversationExists(
            userId, widget.hebergement.person.personId!);

        Conversation conversation;
        if (exists) {
          conversation = await conversationserv.findByUserAndPartner(
              userId, widget.hebergement.person.personId!);
        } else {
          print("hello");
          Conversation newConversation = new Conversation();
          print("hello**********************");
          print(widget.hebergement.person.personId!);
          print(userId);
          conversation = await conversationserv.addConversation(
              newConversation, userId, widget.hebergement.person.personId!);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationPage(conversation: conversation),
          ),
        );
      } catch (error) {
        print('Error: $error');
      }
    }

    print("**********");
    print(userId);
    // var imageList = widget.hebergement.images;
    // var currentImage = imageList[_selectedImageIndex];
    var images = widget.hebergement.images ?? [];
    description = widget.hebergement.description;
    trimmedDescription = description.substring(0, maxLength);
    remainingDescription = description.substring(maxLength);
    String displayText = isExpanded
        ? description
        : (description.length > maxLength
            ? description.substring(0, maxLength) + '...'
            : description);
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                child: Stack(
                  children: [
                    Container(
                      height: 350,
                      child: AnimatedSwitcher(
                        duration: Duration(seconds: 1),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                        child: images.isNotEmpty
                            ? Container(
                                key: ValueKey<int>(_selectedImageIndex),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(70),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  child: Image.memory(
                                    images[_selectedImageIndex].image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 350,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 10,
                top: 20,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (_video != null)
                Positioned(
                  top: 20,
                  right: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    child: IconButton(
                      onPressed: () {
                        _showVideo(context);
                      },
                      icon: Icon(
                        FontAwesomeIcons.video,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: IconButton(
                    onPressed: () => _showShareOptions(context),
                    icon: Icon(
                      FontAwesomeIcons.share,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 70,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: IconButton(
                    onPressed: () => showSearchDialog(context),
                    icon: Icon(
                      FontAwesomeIcons.pencil,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 320,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 500,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.hebergement.nom,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'AbrilFatface',
                                ),
                              ),
                              Visibility(
                                visible:
                                    widget.hebergement.categorie.idCat != 1,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${prix!.toStringAsFixed(2)} ${getCurrencySymbol(widget.hebergement.currency)}',
                                        style: TextStyle(
                                          decoration: hasOffers
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          color: hasOffers
                                              ? Colors.grey
                                              : Colors.black,
                                          fontSize: hasOffers ? 16 : 20,
                                          fontWeight: hasOffers
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                        ),
                                      ),
                                      if (hasOffers)
                                        Text(
                                          '${discountedPrice!.toStringAsFixed(2)} ${getCurrencySymbol(widget.hebergement.currency)}',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      Text(
                                        '/${getNightsText()}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.blue[900]),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${widget.hebergement.pays}, ${widget.hebergement.ville}',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Visibility(
                            visible: widget.hebergement.categorie.idCat == 1,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (index) {
                                return Icon(
                                  widget.hebergement.nbEtoile != '' &&
                                          index <
                                              int.parse(
                                                  widget.hebergement.nbEtoile)
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.orange,
                                );
                              }),
                            ),
                          ),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 500,
                            runSpacing: 10,
                            children: [
                              if (widget.hebergement.website != '') ...[
                                _buildContactInfo(
                                  icon: Icons.language,
                                  text: 'Website',
                                  onTap: () {
                                    launch(widget.hebergement.website!);
                                  },
                                ),
                              ],
                              if (widget.hebergement.instagram != '') ...[
                                _buildContactInfo(
                                  icon: FontAwesomeIcons.instagram,
                                  text: 'Instagram',
                                  onTap: () {
                                    launch(widget.hebergement.instagram!);
                                  },
                                ),
                              ],
                              if (widget.hebergement.facebook != '') ...[
                                _buildContactInfo(
                                  icon: Icons.facebook,
                                  text: 'Facebook',
                                  onTap: () {
                                    launch(widget.hebergement.facebook!);
                                  },
                                ),
                              ],
                              if (widget.hebergement.email != '') ...[
                                _buildContactInfo(
                                  icon: Icons.email,
                                  text: 'Mail',
                                  onTap: () {
                                    launch(
                                        'mailto:${widget.hebergement.email}');
                                  },
                                ),
                              ],
                              if (widget.hebergement.phone != '') ...[
                                _buildContactInfo(
                                  icon: Icons.phone,
                                  text: 'Phone',
                                  onTap: () {
                                    launch('tel:${widget.hebergement.phone}');
                                  },
                                ),
                              ],
                              if (widget.hebergement.fax != '') ...[
                                _buildContactInfo(
                                  icon: Icons.print,
                                  text: widget.hebergement.fax!,
                                  onTap: () {},
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 10),
                          Visibility(
                              visible: widget.hebergement.categorie.idCat != 1,
                              child: Text(
                                '${widget.hebergement.nbChambres} bedrooms, ${widget.hebergement.nbSallesDeBains} bathrooms',
                                style: TextStyle(color: Colors.grey),
                              )),
                          SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Services & Facilities',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'AbrilFatface',
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EquipementList(
                                          listAvis: allEquipements!),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      'View all',
                                      style: TextStyle(
                                        color: Colors.blue[900],
                                        fontSize: 14,
                                        fontFamily: 'AbrilFatface',
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward_ios_outlined,
                                        color: Colors.blue[900], size: 14),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          isLoading
                              ? Center(child: CircularProgressIndicator())
                              : Wrap(
                                  spacing: 100,
                                  runSpacing: 30,
                                  children: equipements!.map((equipement) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(FontAwesomeIcons.check,
                                            color: Colors.blue[900]),
                                        SizedBox(width: 5),
                                        Text(
                                          equipement.nom,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                          SizedBox(height: 30),
                          Visibility(
                            visible: widget.hebergement.nbAvis != 0,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                        widget.hebergement.moyenne!
                                                .toStringAsFixed(1) ??
                                            '',
                                        style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[900])),
                                    SizedBox(width: 8),
                                    Text(
                                        getRatingText(
                                                widget.hebergement.moyenne!) ??
                                            '',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'AbrilFatface',
                                        )),
                                  ],
                                ),
                                RatingBar(
                                    title: widget.hebergement.staff != 0
                                        ? "Staff"
                                        : "Security",
                                    rating: widget.hebergement.staff! ??
                                        widget.hebergement.security!,
                                    color: Colors.orange[900]!),
                                RatingBar(
                                    title: "Comfort",
                                    rating: widget.hebergement.comfort!,
                                    color: Colors.green[900]!),
                                RatingBar(
                                    title: "Facilities",
                                    rating: widget.hebergement.facilities!,
                                    color: Colors.red[900]!),
                                RatingBar(
                                    title: "Location",
                                    rating: widget.hebergement.location!,
                                    color: Colors.purple[900]!),
                                RatingBar(
                                    title: "Cleanliness",
                                    rating: widget.hebergement.cleanliness!,
                                    color: Colors.blue[900]!),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Description',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'AbrilFatface',
                            ),
                          ),
                          SizedBox(height: 5),
                          ExpandableTextWidget(
                              text: widget.hebergement.description ?? ''),
                          SizedBox(height: 20),
                          Visibility(
                            visible: widget.hebergement.categorie.idCat == 1,
                            child: Text(
                              'Languages',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'AbrilFatface',
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Visibility(
                            visible: widget.hebergement.categorie.idCat == 1,
                            child: Wrap(
                              spacing: 100,
                              runSpacing: 30,
                              children: languages.map((language) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(FontAwesomeIcons.check,
                                        color: Colors.blue[900]),
                                    SizedBox(width: 5),
                                    Text(
                                      language.language,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Cancellation Policy',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'AbrilFatface',
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            cancellationPolicy,
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Reviews',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'AbrilFatface',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AvisList(
                                          listAvis: _avisList,
                                          checkIn: checkInTextController.text,
                                          checkOut: checkOutTextController.text,
                                          hebergement: widget.hebergement,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        'See all reviews',
                                        style: TextStyle(
                                          color: Colors.blue[900],
                                          fontSize: 14,
                                          fontFamily: 'AbrilFatface',
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_ios_outlined,
                                          color: Colors.blue[900], size: 14),
                                    ],
                                  ),
                                ),
                              ]),
                          SizedBox(height: 20),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _meilleurAvisList.length,
                            separatorBuilder: (context, index) =>
                                Divider(color: Colors.grey),
                            itemBuilder: (context, index) {
                              final Avis avis = _meilleurAvisList[index];

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                      topLeft: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                    ),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              FutureBuilder<Uint8List?>(
                                                future: UserService()
                                                    .getImageFromFS(
                                                        avis.user!.id),
                                                builder:
                                                    (context, imageSnapshot) {
                                                  if (imageSnapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return CircularProgressIndicator();
                                                  } else if (imageSnapshot
                                                      .hasError) {
                                                    return Text(
                                                        'Erreur: ${imageSnapshot.error}');
                                                  } else if (imageSnapshot
                                                          .hasData &&
                                                      imageSnapshot.data !=
                                                          null) {
                                                    return CircleAvatar(
                                                      backgroundImage:
                                                          MemoryImage(
                                                              imageSnapshot
                                                                  .data!),
                                                    );
                                                  } else {
                                                    return SizedBox.shrink();
                                                  }
                                                },
                                              ),
                                              SizedBox(width: 10),
                                              Column(children: [
                                                Text(
                                                  '${avis.user!.nom} ${avis.user!.prenom} ${avis.user!.flag}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text('')
                                              ]),
                                            ],
                                          ),
                                          Text(
                                            avis.moyenne!,
                                            style: TextStyle(
                                                color: Colors.blue[900],
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Padding(
                                        padding: EdgeInsets.only(left: 40),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.sentiment_satisfied,
                                                  color: Colors.blue[900],
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        isExpanded
                                                            ? avis.avis
                                                            : _getShortText(
                                                                avis.avis),
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[500]),
                                                      ),
                                                      if (!isExpanded &&
                                                          avis.avis.length >
                                                              100)
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              _isExpandedMap[
                                                                  index] = true;
                                                            });
                                                          },
                                                          child: Text(
                                                            'Show more',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .blue[900],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      if (isExpanded)
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              _isExpandedMap[
                                                                      index] =
                                                                  false;
                                                            });
                                                          },
                                                          child: Text(
                                                            'Show less',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .blue[900],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (avis.avisNegative != null)
                                              SizedBox(height: 4),
                                            if (avis.avisNegative != null)
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .sentiment_dissatisfied,
                                                    color: Colors.blue[900],
                                                  ),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          isExpanded
                                                              ? avis
                                                                  .avisNegative!
                                                              : _getShortText(avis
                                                                  .avisNegative!),
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[500]),
                                                        ),
                                                        if (!isExpanded &&
                                                            avis.avisNegative!
                                                                    .length >
                                                                100)
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                _isExpandedMap[
                                                                        index] =
                                                                    true;
                                                              });
                                                            },
                                                            child: Text(
                                                              'Show more',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .blue[900],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        if (isExpanded)
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                _isExpandedMap[
                                                                        index] =
                                                                    false;
                                                              });
                                                            },
                                                            child: Text(
                                                              'Show less',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .blue[900],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Color.fromARGB(255, 5, 2, 151)),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => PositionPage(
                                    hebergement: widget.hebergement,
                                    rating: ratingText ?? '',
                                    checkIn: checkInTextController.text,
                                    checkOut: checkOutTextController.text,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.location_on,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 4,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue[900],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextButton(
                            onPressed: () {
                              if (widget.hebergement.categorie.idCat == 1) {
                                DateTime? checkInDate = DateFormat('dd/MM/yyyy')
                                    .parse(checkInTextController.text!);
                                DateTime? checkOutDate =
                                    DateFormat('dd/MM/yyyy')
                                        .parse(checkOutTextController.text!);

                                if (checkOutDate != null &&
                                    checkInDate != null &&
                                    checkOutDate.isAfter(checkInDate)) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChambreListPage(
                                        hebergement: widget.hebergement,
                                        checkIn: checkInTextController.text,
                                        checkOut: checkOutTextController.text,
                                      ),
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("select a valid date "),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.blue[900]),
                                              foregroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.white),
                                            ),
                                            child: Text("OK"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              } else {
                                if (user == null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReservationSecondStep(
                                        hebergement: widget.hebergement,
                                        checkIn: widget.checkIn,
                                        checkOut: widget.checkOut,
                                        prix: (hasOffers &&
                                                discountedPrice != null)
                                            ? discountedPrice!
                                            : prix!,
                                        currency: widget.hebergement.currency,
                                        user: user!,
                                        nbRooms: 0,
                                        roomIds: [],
                                      ),
                                    ),
                                  );
                                }
                              }
                              ;
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 5),
                                Text(
                                  widget.hebergement.categorie.idCat == 1
                                      ? 'Select Room'
                                      : 'Book Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'AbrilFatface',
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Visibility(
                        visible: userId != null && userId != 0,
                        child: Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Color.fromARGB(255, 162, 162, 165)),
                            ),
                            child: IconButton(
                              onPressed: () {
                                handleConversation();
                              },
                              icon: Icon(
                                FontAwesomeIcons.message,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 320,
                right: 0,
                top: 290,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () async {
                      final userId =
                          Provider.of<UserModel>(context, listen: false).userId;
                      print(userId);
                      if (userId == 0) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('You need to sign in'),
                              content: Text(
                                  'Sign in to add this acommodation to your wishlist.'),
                              actions: <Widget>[
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.blue[900]),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                  ),
                                  child: Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginPage()),
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.blue[900]),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                  ),
                                  child: Text('Sign in'),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }

                      try {
                        if (!isFavorite) {
                          await likeService.addLike(
                              userId, widget.hebergement.hebergementId);
                          setState(() {
                            isFavorite = true;
                          });
                        } else {
                          await likeService.deleteLikeByUserAndHebergement(
                              userId, widget.hebergement.hebergementId);
                          setState(() {
                            isFavorite = false;
                          });
                        }
                      } catch (e) {
                        print('Erreur lors de la bascule du like : $e');
                      }
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
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

Widget _buildChatInterface() {
  TextEditingController _messageController = TextEditingController();

  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          blurRadius: 10,
          color: Colors.black.withOpacity(0.1),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: "Type a message...",
              border: InputBorder.none,
            ),
          ),
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.paperPlane, color: Colors.blue[900]),
          onPressed: () {
            // Implement sending functionality
            print("Message Sent: ${_messageController.text}");
            _messageController.clear();
          },
        ),
      ],
    ),
  );
}

Widget _buildContactInfo(
    {required IconData icon, required String text, VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.blue[900],
        ),
        SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    ),
  );
}

class ExpandableTextWidget extends StatefulWidget {
  final String text;
  const ExpandableTextWidget({Key? key, required this.text}) : super(key: key);

  @override
  _ExpandableTextWidgetState createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Text(
            widget.text,
            maxLines: isExpanded ? null : 2,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(
                isExpanded ? 'show less' : 'show more',
                style: TextStyle(color: Colors.blue[900], fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class RatingBar extends StatelessWidget {
  final String title;
  final double rating;
  final Color color;

  RatingBar({required this.title, required this.rating, required this.color});

  @override
  Widget build(BuildContext context) {
    int flexRating = (rating * 10).round();
    int flexRemaining = (5 * 10 - flexRating);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(title, style: TextStyle(fontSize: 16)),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  flex: flexRating,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      height: 5,
                      color: color,
                    ),
                  ),
                ),
                Expanded(
                  flex: flexRemaining,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      height: 5,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(rating.toString(), style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class ShareBottomSheet extends StatefulWidget {
  @override
  _ShareBottomSheetState createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  List<Application> _apps = [];

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  void _loadApps() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeSystemApps: true,
    );
    setState(() {
      _apps = apps;
    });
  }

  void _share(BuildContext context, String text) {
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Share',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: _apps.length,
              itemBuilder: (context, index) {
                Application app = _apps[index];
                return GestureDetector(
                  onTap: () => _share(context, 'Check this out!'),
                  child: Column(
                    children: [
                      app is ApplicationWithIcon
                          ? Image.memory(
                              app.icon,
                              width: 40,
                              height: 40,
                            )
                          : Icon(Icons.android),
                      Text(
                        app.appName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Search contacts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        NetworkImage('https://example.com/user1.jpg'),
                  ),
                  title: Text('Meriem Dakhlawie'),
                  subtitle: Text('@mdakhlawie'),
                  trailing: ElevatedButton(
                    child: Text('Send'),
                    onPressed: () {},
                  ),
                ),
                // Ajoutez plus de contacts ici
              ],
            ),
          ),
        ],
      ),
    );
  }
}
