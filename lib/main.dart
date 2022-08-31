import 'package:corra/views/intervalada/intervalada_view.dart';
import 'package:corra/views/main_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:corra/constants/routes.dart';
import 'package:corra/helpers/loading/loading_screen.dart';
import 'package:corra/services/auth/bloc/auth_bloc.dart';
import 'package:corra/services/auth/bloc/auth_event.dart';
import 'package:corra/services/auth/bloc/auth_state.dart';
import 'package:corra/services/auth/firebase_auth_provider.dart';
import 'package:corra/views/forgot_password_view.dart';
import 'package:corra/views/login_view.dart';
import 'package:corra/views/register_view.dart';
import 'package:corra/views/verify_email_view.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

Future<void> main() async {
  // Placeholder Splash Screen Material App.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NoPermissionApp(hasCheckedPermissions: false));
  WidgetsFlutterBinding.ensureInitialized();

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.unableToDetermine) {
    permission = await GeolocatorPlatform.instance.requestPermission();
  }
  switch (permission) {
    case LocationPermission.deniedForever:
      runApp(const NoPermissionApp(hasCheckedPermissions: true));
      break;

    case LocationPermission.always:
    case LocationPermission.whileInUse:
      runApp(const MyApp());
      break;

    case LocationPermission.denied:
    case LocationPermission.unableToDetermine:
      runApp(const NoPermissionApp(hasCheckedPermissions: false));
  }
}

class NoPermissionApp extends StatelessWidget {
  const NoPermissionApp({Key? key, required hasCheckedPermissions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('No permission'),
          backgroundColor: Colors.amber,
        ),
        body: const Center(
          child: Text('Sem permissao menor'),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corra!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        mainPage: (context) => const MainPageView(),
        intervaladaRoute: (context) => const IntervaladaView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const MainPageView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateRunView) {
          return const MainPageView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
