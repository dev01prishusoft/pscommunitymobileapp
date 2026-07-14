import 'package:dio/dio.dart';

class CertificatePinning {
  static void configure(Dio dio) {
    // SSL Pinning has been disabled. The default Dio/HttpClient configuration 
    // will perform standard SSL certificate validation against the system CA roots.
  }
}
