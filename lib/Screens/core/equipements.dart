import 'package:casavia/model/categorieEquipement.dart';
import 'package:casavia/model/equipement.dart';
import 'package:casavia/services/equipementService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EquipementsPage extends StatefulWidget {
  final int id;
  const EquipementsPage({Key? key, required this.id}) : super(key: key);

  @override
  State<EquipementsPage> createState() => _EquipementsPageState();
}

class _EquipementsPageState extends State<EquipementsPage> {
  EquipementService equipementserv = EquipementService();
  late Future<List<CategorieEquipement>> futureCategories;

  @override
  void initState() {
    super.initState();
    futureCategories =
        equipementserv.getCategoriesOfEquipementsByHebergementId(widget.id);
  }

  Future<List<Equipement>> getEquipementsForCategorie(int categorieId) async {
    try {
      final equipements = await equipementserv
          .getEquipementsByCategorieHebregement(categorieId, widget.id);
      return equipements;
    } catch (e) {
      throw Exception('Failed to fetch equipements: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<CategorieEquipement>>(
        future: futureCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune catégorie trouvée.'));
          }

          var categories = snapshot.data!;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              var categorie = categories[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    dense: true,
                    leading: Icon(
                      FontAwesomeIcons.circleCheck,
                      color: Colors.blue[900],
                    ),
                    title: Text(categorie.nom,
                        style: TextStyle(
                          fontFamily: 'AbrilFatface',
                        )),
                  ),
                  FutureBuilder<List<Equipement>>(
                    future: getEquipementsForCategorie(categorie.categorieId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Aucun équipement trouvé.'));
                      }

                      var equipements = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...equipements.map((equipement) => ListTile(
                                dense: true,
                                title: Text(equipement.nom),
                              )),
                          Divider(),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
