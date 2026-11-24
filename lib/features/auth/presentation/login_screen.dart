import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/failure_text.dart';
import '../../../core/l10n/app_localizations.dart';
import '../domain/credentials.dart';
import '../domain/school.dart';
import 'auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _user = TextEditingController();
  final _password = TextEditingController();
  String _query = '';
  School? _school;
  bool _remember = true;
  bool _obscure = true;
  bool _busy = false;
  Object? _error;

  @override
  void dispose() {
    _user.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_busy && _school != null && _user.text.trim().isNotEmpty && _password.text.isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).login(
            Credentials(school: _school!, username: _user.text.trim(), password: _password.text),
            remember: _remember,
          );
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: AutofillGroup(
              child: ListView(
                padding: const EdgeInsets.all(24),
                shrinkWrap: true,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset('assets/icon.png', width: 72, height: 72, excludeFromSemantics: true),
                  ),
                  const SizedBox(height: 16),
                  Text(l.appTitle, style: theme.textTheme.displaySmall),
                  const SizedBox(height: 4),
                  Text(l.loginSubtitle, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 32),
                  if (_school == null) ..._schoolSearch(l) else _selectedSchool(l, theme),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _user,
                    enabled: !_busy,
                    autocorrect: false,
                    textInputAction: .next,
                    autofillHints: const [AutofillHints.username],
                    decoration: InputDecoration(labelText: l.usernameLabel),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _password,
                    enabled: !_busy,
                    obscureText: _obscure,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: .done,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: l.passwordLabel,
                      suffixIcon: IconButton(
                        tooltip: _obscure ? l.showPassword : l.hidePassword,
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    contentPadding: .zero,
                    title: Text(l.rememberMe),
                    value: _remember,
                    onChanged: _busy ? null : (v) => setState(() => _remember = v),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          failureText(l, _error!),
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _canSubmit ? _submit : null,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    child: _busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                          )
                        : Text(l.signIn),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _schoolSearch(AppLocalizations l) {
    final results = ref.watch(schoolSearchProvider(_query));
    return [
      TextField(
        autocorrect: false,
        textInputAction: .search,
        decoration: InputDecoration(
          labelText: l.schoolLabel,
          hintText: l.schoolHint,
          prefixIcon: const Icon(Icons.search),
        ),
        onChanged: (v) => setState(() => _query = v),
      ),
      if (_query.trim().length >= 3)
        results.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
          error: (e, _) => ListTile(
            title: Text(
              e is TooManySchoolsFailure ? l.schoolTooManyResults : failureText(l, e),
            ),
          ),
          data: (schools) => schools.isEmpty
              ? ListTile(title: Text(l.schoolNoResults))
              : Column(
                  children: [
                    for (final s in schools.take(8))
                      ListTile(
                        title: Text(s.displayName),
                        subtitle: Text(s.address.trim()),
                        onTap: () => setState(() => _school = s),
                      ),
                  ],
                ),
        ),
    ];
  }

  Widget _selectedSchool(AppLocalizations l, ThemeData theme) => Card(
        margin: .zero,
        child: ListTile(
          leading: const Icon(Icons.school_outlined),
          title: Text(_school!.displayName),
          subtitle: Text(_school!.address.trim()),
          trailing: TextButton(
            onPressed: _busy ? null : () => setState(() => _school = null),
            child: Text(l.schoolChange),
          ),
        ),
      );
}
