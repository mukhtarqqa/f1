import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/store/app_store.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.mode});
  final AuthMode mode;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email енгізіңіз';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
    return ok ? null : 'Email мекенжайы дұрыс емес';
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Құпиясөз бос болмауы керек';
    if (widget.mode == AuthMode.register && value.length < 6) {
      return 'Құпиясөз кемінде 6 таңбадан тұрсын';
    }
    return null;
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    final store = StoreScope.of(context, listen: false);
    final result = widget.mode == AuthMode.register
        ? await store.signUp(
            name: name.text,
            email: email.text,
            password: password.text,
          )
        : await store.signIn(email.text, password.text);

    if (!mounted) return;
    if (result == AuthActionResult.authenticated) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.shell, (_) => false);
    } else if (result == AuthActionResult.emailConfirmationRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Кіру алдында email мекенжайын растаңыз.'),
        ),
      );
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final registering = widget.mode == AuthMode.register;
    final store = StoreScope.of(context);
    return Scaffold(
        body: PageContent(children: [
      const F1Logo(),
      const SizedBox(height: 46),
      Text(registering ? 'Аккаунт құру' : 'Қайта оралдыңыз!',
          style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 9),
      Text(
          registering
              ? 'F1 жаңалықтарын өзіңізге бейімдеңіз.'
              : 'Кіру үшін деректеріңізді енгізіңіз.',
          style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 43),
      Form(
          key: formKey,
          child: Column(children: [
            if (registering)
              F1Input(
                  label: 'Аты-жөніңіз',
                  controller: name,
                  prefixIcon: Icons.person_outline,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Атыңызды енгізіңіз'
                      : null),
            F1Input(
                label: 'Email',
                hint: 'example@email.com',
                controller: email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: validateEmail),
            F1Input(
                label: 'Құпиясөз',
                controller: password,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: validatePassword),
            const SizedBox(height: 12),
            if (store.authError != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  store.authError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              const SizedBox(height: 12),
            ],
            F1Button(
              label: store.authLoading
                  ? 'Күте тұрыңыз...'
                  : registering
                      ? 'Тіркелу'
                      : 'Кіру',
              onPressed: store.authLoading ? null : submit,
            ),
          ])),
      const SizedBox(height: 24),
      Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            Text(registering ? 'Аккаунтыңыз бар ма?' : 'Аккаунтыңыз жоқ па?'),
            TextButton(
                onPressed: () => Navigator.pushReplacementNamed(
                    context, registering ? Routes.login : Routes.register),
                child: Text(registering ? 'Кіру' : 'Тіркелу')),
          ]),
      const SizedBox(height: 20),
      Text('Қолданба деректері Supabase PostgreSQL бұлттық қорында сақталады.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall),
    ]));
  }
}
