import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
  late PusherChannelsFlutter pusher;

  PusherService() {
    pusher = PusherChannelsFlutter.getInstance();
  }

  Future<void> initPusher() async {
    await pusher.init(
      apiKey: "8fc7ac37b7848dcbc3a9",
      cluster: "mt1",
      onEvent: onEvent,
    );
    await pusher.connect();
  }

Future<void> subscribeToChannel(String channelName) async {
  await pusher.subscribe(
    channelName: channelName,
    onEvent: (dynamic event) => onEvent(event),
  );
}


  void onEvent(PusherEvent event) {
    print("Received event: ${event.data}");
    // Handle the event data here
  }

  void disconnect() {
    pusher.disconnect();
  }
}
