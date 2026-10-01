import 'package:envied/envied.dart';

// part 'env.g.dart';

/// Secrets read from `.env` at build time and compiled in obfuscated form.
/// After editing `.env`, regenerate with:
///   dart run build_runner build --delete-conflicting-outputs
@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'GOOGLEMAP_KEY', defaultValue: '')
  static final String googleMapKey = "";

  @EnviedField(varName: 'RAZORPAY_KEY', defaultValue: '')
  static final String razorpayKey = "";
}
