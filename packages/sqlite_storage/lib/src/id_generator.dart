import 'package:uuid/uuid.dart';

abstract class IdGenerator {
  String call();
}

class UuidGenerator implements IdGenerator {
  final uuid = const Uuid();

  @override
  String call() => uuid.v4();
}
