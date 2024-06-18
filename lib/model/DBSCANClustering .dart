import 'dart:math';
import 'hebergement.dart';

class DBSCANClustering {
  late List<Hebergement> _data;
  late double _epsilon;
  late int _minPoints;
  late List<int> _clusterAssignments;

  DBSCANClustering({
    required List<Hebergement> data,
    required double epsilon,
    required int minPoints,
  }) {
    _data = data;
    _epsilon = epsilon;
    _minPoints = minPoints;
    _clusterAssignments = List.filled(_data.length, -1);
  }

  void run() {
    int clusterId = 0;
    for (int i = 0; i < _data.length; i++) {
      if (_clusterAssignments[i] == -1) {
        List<Hebergement> neighbors = _getNeighbors(_data[i]);
        if (neighbors.length < _minPoints) {
          _clusterAssignments[i] = 0; // Marquer comme bruit
        } else {
          clusterId++;
          _expandCluster(_data[i], neighbors, clusterId);
        }
      }
    }
  }

  List<Hebergement> _getNeighbors(Hebergement hebergement) {
    List<Hebergement> neighbors = [];
    for (int i = 0; i < _data.length; i++) {
      if (_calculateDistance(hebergement, _data[i]) <= _epsilon) {
        neighbors.add(_data[i]);
      }
    }
    return neighbors;
  }

  void _expandCluster(
      Hebergement hebergement, List<Hebergement> neighbors, int clusterId) {
    _clusterAssignments[_data.indexOf(hebergement)] = clusterId;
    for (Hebergement neighbor in neighbors) {
      int neighborIndex = _data.indexOf(neighbor);
      if (_clusterAssignments[neighborIndex] == -1) {
        _clusterAssignments[neighborIndex] = clusterId;
        List<Hebergement> neighborNeighbors = _getNeighbors(neighbor);
        if (neighborNeighbors.length >= _minPoints) {
          _expandCluster(neighbor, neighborNeighbors, clusterId);
        }
      }
    }
  }

  double _calculateDistance(Hebergement h1, Hebergement h2) {
    double etoile1 = double.tryParse(h1.nbEtoile) ?? 0.0;
    double etoile2 = double.tryParse(h2.nbEtoile) ?? 0.0;

    double nbEtoileDiff = (etoile1 - etoile2).abs();
    double nbChambresDiff = (h1.nbChambres.toDouble() - h2.nbChambres.toDouble()).abs();
    double nbSallesDeBainsDiff =
        (h1.nbSallesDeBains.toDouble() - h2.nbSallesDeBains.toDouble()).abs();

    return nbEtoileDiff + nbChambresDiff + nbSallesDeBainsDiff;
  }

  List<int> get clusterAssignments => _clusterAssignments;
  List<Hebergement> getCluster(int clusterId) {
    List<Hebergement> clusterHebergements = [];
    for (int i = 0; i < _data.length; i++) {
      if (_clusterAssignments[i] == clusterId) {
        clusterHebergements.add(_data[i]);
      }
    }
    return clusterHebergements;
  }

  int predict(Hebergement hebergement) {
    List<Hebergement> neighbors = _getNeighbors(hebergement);
    if (neighbors.length >= _minPoints) {
      for (Hebergement neighbor in neighbors) {
        int neighborIndex = _data.indexOf(neighbor);
        if (_clusterAssignments[neighborIndex] != -1) {
          return _clusterAssignments[neighborIndex];
        }
      }
    }
    return 0; 
  }
}