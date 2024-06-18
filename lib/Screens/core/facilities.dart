import 'package:casavia/model/categorieEquipement.dart';
import 'package:casavia/model/equipement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EquipementList extends StatefulWidget {
  final List<Equipement> listAvis;

  const EquipementList({Key? key, required this.listAvis}) : super(key: key);

  @override
  State<EquipementList> createState() => _EquipementListState();
}

class _EquipementListState extends State<EquipementList> {
  late Map<String, List<Equipement>> categorizedEquipments;

  @override
  void initState() {
    super.initState();
    categorizedEquipments = organizeEquipmentsByCategory(widget.listAvis);
  }

  Map<String, List<Equipement>> organizeEquipmentsByCategory(
      List<Equipement> equipements) {
    Map<String, List<Equipement>> categorizedEquipments = {};

    for (var equipement in equipements) {
      var categoryName = equipement.categorie.nom;
      if (!categorizedEquipments.containsKey(categoryName)) {
        categorizedEquipments[categoryName] = [];
      }
      // Eviter les doublons
      if (!categorizedEquipments[categoryName]!.contains(equipement)) {
        categorizedEquipments[categoryName]!.add(equipement);
      }
    }

    return categorizedEquipments;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categorizedEquipments.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'AbrilFatface',
                      ),
                    ),
                    SizedBox(height: 10),
                    ...entry.value.map((equipement) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
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
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
