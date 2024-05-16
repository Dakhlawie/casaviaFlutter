import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:casavia/Screens/core/comments.dart';
import 'package:casavia/Screens/core/equipements.dart';
import 'package:casavia/model/language.dart';
import 'package:casavia/services/currencyService.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:casavia/Screens/core/map.dart';
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
  TextEditingController _messageController = TextEditingController();
  DateTime? _selectedDate;
  final TextEditingController checkInTextController = TextEditingController();
  bool _isChatOpen = false;

  final TextEditingController checkOutTextController = TextEditingController();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    print("hi");
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.blue[900]!,
                onPrimary: Colors.white,
                surface: Colors.blue[900]!,
                onSurface: Colors.white,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    textStyle: TextStyle(color: Colors.white)),
              ),
            ),
            child: child!,
          );
        },
      );
      print("Date picker closed");
      print(picked);
      if (picked != null) {
        setState(() {
          final DateFormat formatter = DateFormat('dd/MM/yyyy');
          String formattedDate = formatter.format(picked);

          if (isCheckIn) {
            _checkInDate = picked;
            checkInTextController.text = formattedDate;
          } else {
            _checkOutDate = picked;
            checkOutTextController.text = formattedDate;
          }
        });
      }
    } catch (e, stackTrace) {
      print("An error occurred: $e");
      print("Error picking date: $e");
      print("StackTrace: $stackTrace");
    }
  }

  final HebergementService _hebergementService = HebergementService();
  List<Equipement> equipements = [];
  _loadEquipements() async {
    try {
      int hebergementId = widget.hebergement.hebergementId;
      var fetchedEquipements =
          await _hebergementService.getEquipements(hebergementId);
      setState(() {
        equipements = fetchedEquipements.take(4).toList();
      });
    } catch (e) {
      print('Failed to load equipements: $e');
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
    _avisFuture = _avisService.fetchAvis();
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      setState(() {
        _selectedImageIndex =
            (_selectedImageIndex + 1) % widget.hebergement.images.length;
      });
    });

    _fetchUserId();
    _loadVideo();
    fetchLanguages();
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

  Future<void> _fetchUserId() async {
    AuthService authService = AuthService();
    int? userId = await authService.getUserIdFromToken();
    if (userId != null) {
      Provider.of<UserModel>(context, listen: false).setUserId(userId);
    }
    print('USERID');
    print(userId);
  }

  String? symbol;
  double? convertedPrice;
  Future<double> calculatePrice(
      String checkIn, String checkOut, double prixParNuit) async {
    DateTime startDate = DateFormat('dd/MM/yyyy').parse(checkIn);
    DateTime endDate = DateFormat('dd/MM/yyyy').parse(checkOut);
    int numberOfNights = endDate.difference(startDate).inDays;
    double totalPrice = numberOfNights * prixParNuit;

    final prefs = await SharedPreferences.getInstance();
    String? ToCurrency = prefs.getString('selectedCurrency');
    if (ToCurrency != null) {
      symbol = getCurrencySymbol(ToCurrency);
    }
    if (ToCurrency != null && ToCurrency!.isNotEmpty) {
      double rate = await CurrencyService()
          .getConversionRate(widget.hebergement.currency, ToCurrency);
      totalPrice *= rate;
    }

    return totalPrice;
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
    controller.addListener(() {
      if (controller.value.position == controller.value.duration) {
        Navigator.of(context).pop();
        controller.dispose();
      }
    });

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding:
              EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        );
      },
    );

    controller.play();
  }

  Widget build(BuildContext context) {
    final String phoneNumberWithCode =
        "+ ${widget.hebergement.country_code} ${widget.hebergement.phone}";
    final userId = Provider.of<UserModel>(context).userId;
    print("**********");
    print(userId);
    var imageList = widget.hebergement.images;
    var currentImage = imageList[_selectedImageIndex];
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
              Visibility(
                visible: _video != null,
                child: Positioned(
                  top: 20,
                  right: 20,
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
                                  child: FutureBuilder<double>(
                                    future: calculatePrice(
                                        widget.checkIn,
                                        widget.checkOut,
                                        widget.hebergement.prix),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text(
                                            "Error: ${snapshot.error.toString()}");
                                      } else if (snapshot.hasData) {
                                        return Text(
                                          "${snapshot.data!.toStringAsFixed(2)}  ${symbol ?? getCurrencySymbol(widget.hebergement.currency)}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20),
                                        );
                                      } else {
                                        return Text("Price not available");
                                      }
                                    },
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
                          SizedBox(height: 10),
                          Divider(
                            color: Colors.grey,
                            thickness: 1,
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Check In',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _selectDate(context, true),
                                    child: Text(checkInTextController.text),
                                  ),
                                ],
                              ),
                              SizedBox(width: 50),
                              Container(
                                height: 40,
                                child: VerticalDivider(
                                  width: 20,
                                  thickness: 1,
                                  color: Colors.grey[400],
                                ),
                              ),
                              SizedBox(width: 50),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Check Out',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _selectDate(context, false),
                                    child: Text(checkOutTextController.text),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                                      builder: (context) => EquipementsPage(
                                          id: widget.hebergement.hebergementId),
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
                          Wrap(
                            spacing: 100,
                            runSpacing: 30,
                            children: equipements.map((equipement) {
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
                            visible: widget.hebergement.categorie.idCat == 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("8.1",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[900])),
                                    SizedBox(width: 8),
                                    Text("Very Good",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'AbrilFatface',
                                        )),
                                  ],
                                ),
                                RatingBar(title: "Cleanliness", rating: 8.5),
                                RatingBar(title: "Comfort", rating: 8.3),
                                RatingBar(title: "Facilities", rating: 7.7),
                                RatingBar(title: "Location", rating: 9.5),
                                RatingBar(title: "Staff", rating: 9.1),
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: displayText,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (description.length > maxLength)
                                        WidgetSpan(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isExpanded = !isExpanded;
                                              });
                                            },
                                            child: Text(
                                              isExpanded
                                                  ? 'show less'
                                                  : 'show more',
                                              style: TextStyle(
                                                color: Colors.blue[900],
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                          SizedBox(height: 8),
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
                            'What guests loved the most :',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'AbrilFatface',
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: FutureBuilder<List<Avis>>(
                              future: _avisFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Erreur: ${snapshot.error}'));
                                } else {
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.take(4).length,
                                    itemBuilder: (context, index) {
                                      final Avis avis = snapshot.data![index];

                                      if (avis.hebergement.hebergementId ==
                                          widget.hebergement.hebergementId) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Column(children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                FutureBuilder<Uint8List?>(
                                                  future: UserService()
                                                      .getImageFromFS(
                                                          avis.user.id),
                                                  builder:
                                                      (context, imageSnapshot) {
                                                    if (imageSnapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
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
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${avis.user.nom} ${avis.user.prenom}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      avis.user.pays ?? '',
                                                      style: TextStyle(
                                                          color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 50),
                                              child: Text(
                                                '"${avis.avis}"',
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 50, right: 20),
                                              child: Divider(
                                                color: Colors.black,
                                                thickness: 1,
                                              ),
                                            ),
                                          ]),
                                        );
                                      } else {
                                        return SizedBox.shrink();
                                      }
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AvisList(
                                          hebergement: widget.hebergement,
                                        )),
                              );
                            },
                            child: Text('See all reviews',
                                style: TextStyle(color: Colors.blue[900])),
                          ),
                          SizedBox(height: 20),
                          Container(
                            height: 80,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                              color: AppColor.cardColor,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.shadowColor.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 1,
                                    ),
                                    child: Text(
                                      'Cancellation Policy',
                                      style: TextStyle(
                                          fontFamily: 'AbrilFatface',
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: 1,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.arrow_forward_ios),
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Container(
                                                  padding: EdgeInsets.all(20),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Cancellation Policy',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Text(
                                                        'For cancellations made at least 24 hours before arrival, a full refund is provided. Cancellations within 24 hours of arrival receive a partial refund equivalent to 50% of the total reservation amount. We aim to offer our guests optimal flexibility while maintaining a balanced and transparent approach.',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.grey),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            height: 80,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                              color: AppColor.cardColor,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.shadowColor.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 1,
                                    ),
                                    child: Text(
                                      'Contact Information',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: 1,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.arrow_forward_ios),
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Container(
                                                  width: double.infinity,
                                                  padding: EdgeInsets.all(20),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Contact Information',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Wrap(
                                                        spacing: 500,
                                                        runSpacing: 10,
                                                        children: [
                                                          if (widget.hebergement
                                                                  .website !=
                                                              '') ...[
                                                            _buildContactInfo(
                                                              icon: Icons
                                                                  .language,
                                                              text: widget
                                                                  .hebergement
                                                                  .website!,
                                                            ),
                                                          ],
                                                          if (widget.hebergement
                                                                  .instagram !=
                                                              '') ...[
                                                            _buildContactInfo(
                                                              icon:
                                                                  FontAwesomeIcons
                                                                      .instagram,
                                                              text: widget
                                                                  .hebergement
                                                                  .instagram!,
                                                            ),
                                                          ],
                                                          if (widget.hebergement
                                                                  .facebook !=
                                                              '') ...[
                                                            _buildContactInfo(
                                                              icon: Icons
                                                                  .facebook,
                                                              text: widget
                                                                  .hebergement
                                                                  .facebook!,
                                                            ),
                                                          ],
                                                          if (widget.hebergement
                                                                  .email !=
                                                              '') ...[
                                                            _buildContactInfo(
                                                              icon: Icons.email,
                                                              text: widget
                                                                  .hebergement
                                                                  .email!,
                                                            ),
                                                          ],
                                                          if (widget.hebergement
                                                                  .phone !=
                                                              '') ...[
                                                            _buildContactInfo(
                                                              icon: Icons.phone,
                                                              text: widget
                                                                  .hebergement
                                                                  .phone!,
                                                            ),
                                                          ],
                                                          if (widget.hebergement
                                                                  .fax !=
                                                              '') ...[
                                                            _buildContactInfo(
                                                              icon: Icons.print,
                                                              text: widget
                                                                  .hebergement
                                                                  .fax!,
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 300),
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
                                  builder: (context) =>
                                      Map(hebergement: widget.hebergement),
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
                                        checkIn: widget.checkIn,
                                        checkOut: widget.checkOut,
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
                              }
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
                                    MaterialPageRoute(
                                      builder: (context) => DiscussionPage (
                                       
                                      ),
                                    ),
                                  );
                            },
                            icon: Icon(
                              FontAwesomeIcons.message,
                              color: Colors.blue[900],
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

class RatingBar extends StatelessWidget {
  final String title;
  final double rating;

  RatingBar({required this.title, required this.rating});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Row(
        children: [
          Expanded(
              flex: (rating * 10).toInt(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  height: 5,
                  color: Colors.blue[900],
                ),
              )),
          Expanded(
              flex: 100 - (rating * 10).toInt(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  height: 5,
                  color: Colors.grey[300],
                ),
              )),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(rating.toString(), style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
