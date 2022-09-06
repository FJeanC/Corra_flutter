import 'package:flutter/material.dart';
import 'package:corra/utilities/dialogs/generic_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: AppLocalizations.of(context)!.logout,
    content: AppLocalizations.of(context)!.sureLogout,
    optionsBuilder: () => {
      AppLocalizations.of(context)!.cancel: false,
      AppLocalizations.of(context)!.logout: true,
    },
  ).then(
    (value) =>
        value ??
        false, // case where the user press the back button w/ selecting
  );
}
