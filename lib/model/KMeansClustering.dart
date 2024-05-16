import 'dart:math';
import 'hebergement.dart';

class KMeansClustering {
  late List<Hebergement> _data;
  late int _k;
  late List<List<double>> _centroids; // Centroïdes comme liste de doubles
  late List<int> _clusterAssignments;

  KMeansClustering({
    required List<Hebergement> data,
    required int k,
  }) {
    _data = data;
    _k = k;
    _centroids = [];
    _clusterAssignments = [];
  }

  void run() {
    _initializeCentroids();
    for (int i = 0; i < 100; i++) {
      _assignClusters();
      _updateCentroids();
      if (_hasConverged()) {
        break;
      }
    }
  }

void _initializeCentroids() {
    Set<int> chosenIndexes = {};
    while (_centroids.length < _k) {
        int randomIndex = Random().nextInt(_data.length);
        if (!chosenIndexes.contains(randomIndex)) {
            chosenIndexes.add(randomIndex);
            Hebergement selected = _data[randomIndex];
            
     
            double etoile = double.tryParse(selected.nbEtoile) ?? 0.0;

          
            _centroids.add([
                etoile,
                selected.nbChambres.toDouble(), 
                selected.nbSallesDeBains.toDouble()
            ]);
        }
    }
}


  void _assignClusters() {
    _clusterAssignments = List.filled(_data.length, -1);
    for (int i = 0; i < _data.length; i++) {
      double minDistance = double.infinity;
      int closestCentroidIndex = -1;
      for (int j = 0; j < _centroids.length; j++) {
        double distance = _calculateDistance(_centroids[j], _data[i]);
        if (distance < minDistance) {
          minDistance = distance;
          closestCentroidIndex = j;
        }
      }
      _clusterAssignments[i] = closestCentroidIndex;
    }
  }

  void _updateCentroids() {
    List<List<double>> newCentroids = List.generate(_k, (_) => [0.0, 0.0, 0.0]);
    List<int> counts = List.filled(_k, 0);

    for (int i = 0; i < _data.length; i++) {
        int clusterIndex = _clusterAssignments[i];
        List<double> centroid = newCentroids[clusterIndex];
        Hebergement h = _data[i];

       
        double etoile = double.tryParse(h.nbEtoile) ?? 0.0;

        
        centroid[0] += etoile; 
        centroid[1] += h.nbChambres.toDouble();  
        centroid[2] += h.nbSallesDeBains.toDouble();  

        counts[clusterIndex]++;
    }

    for (int i = 0; i < _k; i++) {
        if (counts[i] > 0) {
            newCentroids[i] = newCentroids[i].map((x) => x / counts[i]).toList();
        }
    }

    _centroids = newCentroids;
}

  bool _hasConverged() {
    
    return true; // Placeholder
  }

  double _calculateDistance(List<double> centroid, Hebergement h) {
  
  double hebergementEtoile = double.tryParse(h.nbEtoile) ?? 0.0;

  double nbEtoileDiff = (centroid[0] - hebergementEtoile).abs();
  double nbChambresDiff = (centroid[1] - h.nbChambres).abs();
  double nbSallesDeBainsDiff = (centroid[2] - h.nbSallesDeBains).abs();

  return nbEtoileDiff + nbChambresDiff + nbSallesDeBainsDiff; 
}


  int predict(Hebergement hebergement) {
    double minDistance = double.infinity;
    int closestCentroidIndex = -1;
    for (int j = 0; j < _centroids.length; j++) {
      double distance = _calculateDistance(_centroids[j], hebergement);
      if (distance < minDistance) {
        minDistance = distance;
        closestCentroidIndex = j;
      }
    }
    return closestCentroidIndex;
  }

  List<Hebergement> getCluster(int clusterIndex) {
    List<Hebergement> clusterHebergements = [];
    for (int i = 0; i < _data.length; i++) {
      if (_clusterAssignments[i] == clusterIndex) {
        clusterHebergements.add(_data[i]);
      }
    }
    return clusterHebergements;
  }
}
