import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivaan_i_docs/colors.dart';
import 'package:rivaan_i_docs/repository/auth_repository.dart';
import 'package:rivaan_i_docs/screens/home_screen.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final sMessenger = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);

    final errorModel =
        await ref.read(authRepositoryProvider).signInWithGoogle();

    if (errorModel.error == null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      navigator.replace('/');
    } else {
      sMessenger.showSnackBar(
        SnackBar(
          content: Text(
            errorModel.error.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Docs'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => signInWithGoogle(ref, context),
              icon: Image.asset(
                'assets/images/g-logo-2.png',
                height: 20,
              ),
              label: const Text(
                'Sign in with Google',
                style: TextStyle(color: kBlackColor),
              ),
              style: ElevatedButton.styleFrom(
                maximumSize: const Size(150, 50),
                backgroundColor: kWhiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
