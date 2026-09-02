import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The active AMOC Portal locale.
///
/// Arabic is the default locale. Updating this provider rebuilds the root
/// MaterialApp and changes Flutter's text direction automatically.
final portalLocaleProvider = StateProvider<Locale>((ref) {
  return const Locale('ar');
});
