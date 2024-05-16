import 'dart:convert';
import 'dart:typed_data';

class ImageHebergement {
  int idImage;
  String name;
  String type;
  Uint8List image;

  ImageHebergement({
    required this.idImage,
    required this.name,
    required this.type,
    required this.image,
  });

  factory ImageHebergement.fromJson(Map<String, dynamic> json) {
    Uint8List imageData = base64.decode(json['image']);

    return ImageHebergement(
      idImage: json['idImage'],
      name: json['name'],
      type: json['type'],
      image: imageData,
    );
  }

  Map<String, dynamic> toJson() => {
        'idImage': idImage,
        'name': name,
        'type': type,
        'image': base64.encode(image),
      };
}
