import 'dart:math';

class OtpGenerator {
  static String generate() {
    final random = Random();

    return (100000 + random.nextInt(900000)).toString();
  }
}