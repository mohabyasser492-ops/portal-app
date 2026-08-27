import 'package:flutter/material.dart';

/// Displays a Portal App dialog using the active navigator.
///
/// The [dialog] parameter may be a [Dialog] or a directionality wrapper
/// containing a dialog.
Future<T?> showPortalDialog<T>({
  required BuildContext context,
  required Widget dialog,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      return dialog;
    },
  );
}
