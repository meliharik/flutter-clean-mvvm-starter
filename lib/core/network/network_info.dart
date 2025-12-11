import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

/// Interface for network connectivity checks
///
/// WHY ABSTRACT CLASS:
/// 1. Can be mocked easily in tests
/// 2. Repository can depend on abstraction, not implementation
/// 3. Can swap connectivity implementation if needed
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

/// Implementation of NetworkInfo using connectivity_plus
@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_isConnected);
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }
}
