// lib/core/network/client_request_id.dart
import 'package:uuid/uuid.dart';

class ClientRequestIdGenerator {
  ClientRequestIdGenerator._();

  static const _uuid = Uuid();

  static String next() => _uuid.v4();
}
