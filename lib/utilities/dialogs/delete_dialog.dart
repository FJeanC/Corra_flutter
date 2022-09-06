import 'package:flutter/material.dart';
import 'package:corra/utilities/dialogs/generic_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: AppLocalizations.of(context)!.delete,
    content: AppLocalizations.of(context)!.deleteItem,
    optionsBuilder: () => {
      AppLocalizations.of(context)!.cancel: false,
      AppLocalizations.of(context)!.yes: true,
    },
  ).then(
    (value) =>
        value ??
        false, // case where the user press the back button w/ selecting
  );
}
