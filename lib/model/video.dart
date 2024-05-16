import 'dart:convert';
import 'dart:typed_data';

class Video {
  final int videoId;
  final Uint8List videoContent;

  Video({
    required this.videoId,
    required this.videoContent,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    Uint8List video = base64.decode(json['videoContent']);

    return Video(
      videoId: json['video_id'],
      videoContent: video,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'videoContent': base64.encode(videoContent),
    };
  }
}
