import 'package:casavia/Screens/login/login_page.dart';
import 'package:casavia/model/notification.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/notificationService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_svg/flutter_svg.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  NotificationService notificationServ = NotificationService();

  List<NotificationMessage> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    AuthService authService = AuthService();
    int? userId = await authService.getUserIdFromToken();
    if (userId != null && userId != 0) {
      Provider.of<UserModel>(context, listen: false).setUserId(userId);
      await _fetchNotifications(userId);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
    print('USERID');
    print(userId);
  }

  Future<void> _fetchNotifications(int userId) async {
    try {
      List<NotificationMessage> notifications =
          await notificationServ.fetchNotificationsByUserId(userId);
      for (var notification in notifications) {
        if (!notification.seen) {
          await notificationServ
              .markNotificationAsSeen(notification.notificationId!);
        }
      }
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to load notifications: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserModel>(context).userId;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : userId == null || userId == 0
                ? Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/notification.svg',
                            height: 200,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications',
                            style: TextStyle(
                              fontFamily: 'AbrilFatface',
                              fontSize: 30.0,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Connect to receive notifications about our offers, recommendations, and more.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
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
                      ),
                    ),
                  )
                : _notifications.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/notification.svg',
                                height: 200,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No notifications',
                                style: TextStyle(
                                  fontFamily: 'AbrilFatface',
                                  fontSize: 30.0,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You currently have no notifications.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Your Notifications',
                              style: TextStyle(
                                fontFamily: 'AbrilFatface',
                                fontSize: 24,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.all(10),
                              itemCount: _notifications.length,
                              separatorBuilder: (context, index) => Divider(
                                color: Colors.grey[200],
                                height: 1,
                                thickness: 1,
                              ),
                              itemBuilder: (context, index) {
                                NotificationMessage notification =
                                    _notifications[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/notification.png'),
                                    radius: 24,
                                  ),
                                  title: Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontFamily: 'AbrilFatface',
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Seize the day and book the stay – at a property that meets your travel needs.',
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        _getRelativeTime(notification.date),
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }

  String _getRelativeTime(DateTime date) {
    return timeago.format(date);
  }
}
