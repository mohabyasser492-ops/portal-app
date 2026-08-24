enum NetworkStatus { online, offline }

abstract interface class ConnectivityService {
  Future<NetworkStatus> getCurrentStatus();

  Stream<NetworkStatus> watchStatus();
}
