import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:family_food_analysis/ui/theme/app_theme.dart';
import 'package:family_food_analysis/ui/view_models/main_view_model.dart';
import 'package:family_food_analysis/data/services/google_auth/web_wrapper.dart' as google_web;

/// Plain, blank-background sign-in screen — no hero art, no marketing copy.
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'FAMILY FOOD',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.muted(context)),
                  ),
                  const SizedBox(height: 40),
                  if (vm.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  _buildGoogleSignInButton(vm),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: vm.isLoading ? null : () => vm.signInWithGithub(),
                      icon: const Icon(Icons.code_rounded, size: 20),
                      label: const Text('Continue with GitHub'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: vm.isLoading ? null : () => vm.signInAsGuest(),
                      child: const Text('Try Guest / Demo Mode'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Demo mode pre-loads a sample family's pantry & meals",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.muted(context)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// On platforms where Google Identity Services supports an explicit
  /// prompt, a normal styled button works. On web, sign-in must be
  /// triggered by Google's own rendered button (a browser security/GIS
  /// requirement) — this app-provided button can't call authenticate()
  /// there, so it renders that instead.
  Widget _buildGoogleSignInButton(MainViewModel vm) {
    bool supportsExplicitPrompt;
    try {
      supportsExplicitPrompt = GoogleSignIn.instance.supportsAuthenticate();
    } catch (_) {
      // GoogleSignIn.initialize() didn't complete successfully (e.g. no
      // network at startup) — fall back to the simulated button below.
      supportsExplicitPrompt = true;
    }

    if (!supportsExplicitPrompt && kIsWeb) {
      try {
        return SizedBox(width: double.infinity, height: 48, child: google_web.renderButton());
      } catch (_) {
        // Fall through to the simulated button.
      }
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: vm.isLoading ? null : () => vm.signInWithGoogle(),
        icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
        label: const Text('Continue with Google'),
      ),
    );
  }
}
