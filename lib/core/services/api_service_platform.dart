export 'api_service.dart';

// Conditional export based on platform
export 'api_service_web.dart'
  if (dart.library.io) 'api_service_io.dart';

// This line tells the analyzer to ignore the URI warning since the conditional import will handle it
// ignore: uri_does_not_exist