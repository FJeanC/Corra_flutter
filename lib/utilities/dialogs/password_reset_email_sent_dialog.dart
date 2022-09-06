import 'package:flutter/material.dart';
import 'package:corra/utilities/dialogs/generic_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> showPasswordResetSendDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: AppLocalizations.of(context)!.passwordReset,
    content: AppLocalizations.of(context)!.linkEmailForInformation,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
