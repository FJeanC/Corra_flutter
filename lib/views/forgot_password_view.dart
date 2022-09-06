import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:corra/services/auth/bloc/auth_bloc.dart';
import 'package:corra/services/auth/bloc/auth_event.dart';
import 'package:corra/services/auth/bloc/auth_state.dart';
import 'package:corra/utilities/dialogs/error_dialog.dart';
import 'package:corra/utilities/dialogs/password_reset_email_sent_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSendDialog(context);
          }
          if (!mounted) return;
          if (state.exception != null) {
            await showErrorDialog(
              context,
              AppLocalizations.of(context)!.couldNotProcesssRequest,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.forgotPassword),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(AppLocalizations.of(context)!.forgotPasswordText),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.enterEmail,
                ),
              ),
              TextButton(
                onPressed: () {
                  final email = _controller.text;
                  context
                      .read<AuthBloc>()
                      .add(AuthEventSForgotPassword(email: email));
                },
                child:
                    Text(AppLocalizations.of(context)!.sendPasswordResetLink),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                },
                child: Text(AppLocalizations.of(context)!.backToLoginPage),
              )
            ],
          ),
        ),
      ),
    );
  }
}
