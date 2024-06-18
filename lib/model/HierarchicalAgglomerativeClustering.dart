import 'dart:math';
import 'hebergement.dart';

class HierarchicalAgglomerativeClustering {
  late List<Hebergement> _data;
  late int _k;
  late List<List<double>> _dataPoints;
  late List<List<int>> _clusters;

  HierarchicalAgglomerativeClustering({
    required List<Hebergement> data,
    required int k,
  }) {
    _data = data;
    _k = k;
    _dataPoints = [];
    _clusters = [];
    _initializeDataPoints();
    _initializeClusters();
  }

  void _initializeDataPoints() {
    for (var h in _data) {
      double etoile = double.tryParse(h.nbEtoile) ?? 0.0;
      _dataPoints.add([etoile, h.nbChambres.toDouble(), h.nbSallesDeBains.toDouble()]);
    }
  }

  void _initializeClusters() {
    for (int i = 0; i < _data.length; i++) {
      _clusters.add([i]);
    }
  }

  void run() {
    while (_clusters.length > _k) {
      _mergeClosestClusters();
    }
  }

  void _mergeClosestClusters() {
    double minDistance = double.infinity;
    int mergeIndex1 = -1;
    int mergeIndex2 = -1;

    for (int i = 0; i < _clusters.length; i++) {
      for (int j = i + 1; j < _clusters.length; j++) {
        double distance = _calculateClusterDistance(_clusters[i], _clusters[j]);
        if (distance < minDistance) {
          minDistance = distance;
          mergeIndex1 = i;
          mergeIndex2 = j;
        }
      }
    }

    _clusters[mergeIndex1].addAll(_clusters[mergeIndex2]);
    _clusters.removeAt(mergeIndex2);
  }

  double _calculateClusterDistance(List<int> cluster1, List<int> cluster2) {
    double minDistance = double.infinity;
    for (int i in cluster1) {
      for (int j in cluster2) {
        double distance = _calculateDistance(_dataPoints[i], _dataPoints[j]);
        if (distance < minDistance) {
          minDistance = distance;
        }
      }
    }
    return minDistance;
  }

  double _calculateDistance(List<double> point1, List<double> point2) {
    double nbEtoileDiff = (point1[0] - point2[0]).abs();
    double nbChambresDiff = (point1[1] - point2[1]).abs();
    double nbSallesDeBainsDiff = (point1[2] - point2[2]).abs();
    return nbEtoileDiff + nbChambresDiff + nbSallesDeBainsDiff;
  }

  int predict(Hebergement hebergement) {
    double etoile = double.tryParse(hebergement.nbEtoile) ?? 0.0;
    List<double> point = [etoile, hebergement.nbChambres.toDouble(), hebergement.nbSallesDeBains.toDouble()];

    double minDistance = double.infinity;
    int closestClusterIndex = -1;
    for (int i = 0; i < _clusters.length; i++) {
      for (int index in _clusters[i]) {
        double distance = _calculateDistance(_dataPoints[index], point);
        if (distance < minDistance) {
          minDistance = distance;
          closestClusterIndex = i;
        }
      }
    }
    return closestClusterIndex;
  }

  List<Hebergement> getCluster(int clusterIndex) {
    List<Hebergement> clusterHebergements = [];
    for (int index in _clusters[clusterIndex]) {
      clusterHebergements.add(_data[index]);
    }
    return clusterHebergements;
  }
}
