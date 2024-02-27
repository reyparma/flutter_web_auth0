import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  late Auth0Web auth0Web;

  AuthenticationBloc() : super(AuthInitialState()) {
    
    on<LogIn>((event, emit) async {
      try {
        final credentials = await auth0Web.loginWithPopup();
        // Successful login
        emit(LoggedIn(userProfile: credentials.user));
      } catch (e) {
        // Log error also
        // Restart login transaction
        add(LogIn());
      }

      // Alternate Auth0 login method
      // try {
      //   await auth0Web.loginWithRedirect(redirectUrl: 'http://localhost:3000');
      // } catch (e) {
      //   Log error also
      //   add(LogIn());
      // }
    });

    on<LogOut>((event, emit) async {
      try {
        await auth0Web.logout();
      } catch (e) {
        // Log error
      }
    });

    on<AuthInit>((event, emit) async {
      auth0Web =
          Auth0Web(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
      await auth0Web.onLoad().then((credentials) {
        if (credentials != null) {
          emit(LoggedIn(userProfile: credentials.user));
        } else {
          emit(LoggedOut());
        }
      }).catchError((error) {
        // Log error also
        emit(LoginFailed(message: error));
      });
    });
  }
}
