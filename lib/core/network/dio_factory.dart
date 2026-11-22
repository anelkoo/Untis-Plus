import 'package:dio/dio.dart';

/// The app's HTTP client settings, shared by the UI and the background job.
Dio createDio() => Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ));
