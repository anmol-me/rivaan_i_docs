import 'dart:convert';
import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';

import 'package:rivaan_i_docs/constants.dart';
import 'package:rivaan_i_docs/models/error_model.dart';
import 'package:rivaan_i_docs/models/user_model.dart';
import 'package:rivaan_i_docs/repository/local_storage_repository.dart';

/// Providers

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    googleSignIn: GoogleSignIn(),
    client: Client(),
    localStorageRepository: LocalStorageRepository(),
  ),
);

final userProvider = StateProvider<UserModel?>((ref) => null);

/// class
class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepository _localStorageRepository;

  AuthRepository({
    required GoogleSignIn googleSignIn,
    required Client client,
    required LocalStorageRepository localStorageRepository,
  })  : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepository = localStorageRepository;

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error =
        const ErrorModel(error: 'Some error occurred', data: null);

    try {
      final user = await _googleSignIn.signIn();

      if (user != null) {
        final userAcc = UserModel(
          email: user.email,
          name: user.displayName ?? '',
          profilePic: user.photoUrl ?? '',
          uid: '',
          token: '',
        );

        var res = await _client.post(
          Uri.parse('$host/api/signup'),
          body: json.encode(userAcc.toJson()),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8'
          },
        );

        log(res.statusCode.toString());

        switch (res.statusCode) {
          case 200:
            final newUser = userAcc.copyWith(
              uid: jsonDecode(res.body)['user']['_id'],
              token: jsonDecode(res.body)['token'],
            );

            log(newUser.token);

            error = ErrorModel(error: null, data: newUser);
            _localStorageRepository.setToken(newUser.token);
            break;
          default:
            error = ErrorModel(
              error: res.body,
              data: null,
            );
        }
      }
    } catch (e) {
      log('AR-SignIn: ${e}');
      ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> getUserData() async {
    ErrorModel error =
        const ErrorModel(error: 'Some error occurred', data: null);

    try {
      String? token = await _localStorageRepository.getToken();

      if (token != null) {
        var res = await _client.get(
          Uri.parse('$host/'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );

        switch (res.statusCode) {
          case 200:
            final newUser = UserModel.fromJson(
              // jsonEncode(
              //   jsonDecode(res.body)['user'],
              // ),

              jsonDecode(res.body)['user'],
            ).copyWith(
              token: token,
            );

            error = ErrorModel(error: null, data: newUser);
            _localStorageRepository.setToken(newUser.token);
            break;
        }
      }
    } catch (e) {
      log('AR-getUD: ${e}');
      ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  void signOut() async {
    // await _googleSignIn.signOut();
    _localStorageRepository.setToken('');
  }
}
