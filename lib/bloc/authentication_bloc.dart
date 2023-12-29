
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

import '../models/user.dart';
import '../services/authentication.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';



class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthService authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  AuthenticationBloc() : super(AuthenticationInitialState()) {
    on<AuthenticationEvent>((event, emit) {});

    on<SignUpUser>((event, emit) async {
      emit(AuthenticationLoadingState(isLoading: true));
      try {
          final UserModel? user =
          await authService.signUpUser(event.email, event.password);
      if (user != null) {
        emit(AuthenticationLoadingState(isLoading: false));
        emit(AuthenticationSuccessState(user));
        
      } else {
        emit(const AuthenticationFailureState('create user failed'));
        print(state.toString());
        print('error');
      }
      } catch (e) {
        print(e.toString());
      }
     emit(AuthenticationLoadingState(isLoading: false));
    });

     on<SignOut>((event, emit) async {
      emit(AuthenticationLoadingState(isLoading: true));
      try {
        authService.signOutUser();
      } catch (e) {
        print('error');
        print(e.toString());
      }
       emit(AuthenticationLoadingState(isLoading: false));
     });
    on<SignInWithGoogleEvent>((event, emit) async {
      emit(AuthenticationLoadingState(isLoading: true));
      try {

        final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

// Sign in with the credential once
        UserCredential authResult = await _auth.signInWithCredential(credential);

        User user = authResult.user!;

// Emit AuthenticationSuccessState with the user
        emit(AuthenticationSuccessState(user as UserModel));
      } catch (e) {
      }
      emit(AuthenticationLoadingState(isLoading: false));
    });


  }
}
