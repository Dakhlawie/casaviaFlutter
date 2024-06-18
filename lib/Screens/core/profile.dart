import 'dart:io';

import 'package:casavia/Screens/core/editProfile.dart';
import 'package:casavia/model/user.dart';
import 'package:casavia/model/userData.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/UserService.dart';
import 'package:casavia/theme/color.dart';
import 'package:casavia/widgets/icon_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController firstnameController = TextEditingController();
  late File? _image = null;
  String? selectedCountryName;
  TextEditingController PhoneController = TextEditingController();
  String? selectedCountryCode = '216';
  late final UserService _userService;
  String firstname = '';
  String lastname = '';
  String phone = '';
  String country = '';
  UserData? data;
  String? flagemoji;
  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _userService = UserService();
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

  Future<void> _getImageFromGallery(int id) async {
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _userService.uploadImageToServer(id, await _image!.readAsBytes());
    }
  }

  final imagePicker = ImagePicker();
  Future getImageFromCamera(int id) async {
    final XFile? image =
        await imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
      await _userService.uploadImageToServer(id, await _image!.readAsBytes());
    } else {
      print('Aucune image sélectionnée.');
    }
  }

  void _showImagePickerBottomSheet(int id) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.blue[900]),
                title: Text("Choose from Gallery"),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImageFromGallery(id);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue[900]),
                title: Text("Take a Photo"),
                onTap: () {
                  Navigator.of(context).pop();
                  getImageFromCamera(id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserModel>(context).userId;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(
                FontAwesomeIcons.penToSquare,
                size: 18,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditProfilePage(
                            id: userId,
                            firstname: firstname,
                            lastname: lastname,
                            phone: phone,
                            country: country,
                            emoji: flagemoji!,
                          )),
                ).then((result) {
                  if (result != null) {
                    setState(() {
                      data = result;
                      firstname = data?.firstName ?? '';
                      lastname = data?.lastName ?? '';
                      phone = data?.phone ?? '';
                      country = data?.country ?? '';
                    });
                  }
                });
              },
            ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                  onTap: () {
                    _showImagePickerBottomSheet(userId);
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : NetworkImage(
                                    'http://192.168.1.17:3000/api/image/loadfromFS/$userId')
                                as ImageProvider<Object>?,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              height: 80,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
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
              child: FutureBuilder<User?>(
                future: _userService.getUserById(userId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (userSnapshot.hasError) {
                    return Center(
                        child: Text("Erreur lors du chargement des données."));
                  } else if (userSnapshot.hasData) {
                    User? user = userSnapshot.data;
                    firstname = user?.prenom ?? '';
                    return Row(
                      children: [
                        SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'First Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(firstname),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: Text("Aucune donnée disponible."));
                  }
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 80,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
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
              child: FutureBuilder<User?>(
                future: _userService.getUserById(userId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (userSnapshot.hasError) {
                    return Center(
                        child: Text("Erreur lors du chargement des données."));
                  } else if (userSnapshot.hasData) {
                    User? user = userSnapshot.data;
                    lastname = user?.nom ?? '';
                    return Row(
                      children: [
                        SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Last Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(lastname),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: Text("Aucune donnée disponible."));
                  }
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 80,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
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
              child: FutureBuilder<User?>(
                future: _userService.getUserById(userId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (userSnapshot.hasError) {
                    return Center(
                        child: Text("Erreur lors du chargement des données."));
                  } else if (userSnapshot.hasData) {
                    User? user = userSnapshot.data;
                    String email = user?.email ?? '';
                    flagemoji = user?.flag ?? '';

                    return Row(
                      children: [
                        SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(email),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: Text("Aucune donnée disponible."));
                  }
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 80,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
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
              child: FutureBuilder<User?>(
                future: _userService.getUserById(userId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (userSnapshot.hasError) {
                    return Center(
                        child: Text("Erreur lors du chargement des données."));
                  } else if (userSnapshot.hasData) {
                    User? user = userSnapshot.data;
                    phone = user?.tlf ?? '';
                    return Row(
                      children: [
                        SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Phone',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(phone),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: Text("Aucune donnée disponible."));
                  }
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 80,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
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
              child: FutureBuilder<User?>(
                future: _userService.getUserById(userId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (userSnapshot.hasError) {
                    return Center(
                        child: Text("Erreur lors du chargement des données."));
                  } else if (userSnapshot.hasData) {
                    User? user = userSnapshot.data;
                    country = user?.pays ?? '';
                    return Row(
                      children: [
                        SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Country',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(country),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: Text("Aucune donnée disponible."));
                  }
                },
              ),
            ),
          ],
        ));
  }
}
