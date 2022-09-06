import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:corra/services/auth/bloc/auth_bloc.dart';
import 'package:corra/services/auth/bloc/auth_event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.verifyEmail),
      ),
      body: Column(
        children: [
          Text(AppLocalizations.of(context)!.sendEmail),
          Text(AppLocalizations.of(context)!.emailWasNotSent),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                    const AuthEventSendEmailVerification(),
                  );
            },
            child: Text(AppLocalizations.of(context)!.sendEmailVerification),
          ),
          TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(
                      const AuthEventLogOut(),
                    );
              },
              child: Text(AppLocalizations.of(context)!.back))
        ],
      ),
    );
  }
}
