import 'package:flutter/material.dart';
import 'package:raspi_temp/settings/settings_saving/settings_savings.dart';
import 'package:theme_mode_handler/theme_mode_handler.dart';

import '../settings_saving/theme_saver.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController serverUrlController = TextEditingController();
  final TextEditingController serverUsernameController =
      TextEditingController();
  final TextEditingController serverPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ListTile(
              title: const Text("Adresse du serveur"),
              subtitle: FutureBuilder(
                  future: SettingsSaving.loadServerUrl(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      serverUrlController.text = snapshot.data ?? '';
                      return Text(snapshot.data ?? '');
                    } else {
                      return const Text('');
                    }
                  }),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Adresse du serveur"),
                    content: TextField(
                      controller: serverUrlController,
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Annuler")),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              SettingsSaving.saveServerUrl(
                                  serverUrlController.text);
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("OK")),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Identifiants"),
              subtitle: FutureBuilder(
                  future: SettingsSaving.loadServerCredentials(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      serverUsernameController.text =
                          snapshot.data?.username ?? '';
                      return Text(snapshot.data?.username ?? '');
                    } else {
                      return const Text('');
                    }
                  }),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Identifiants"),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      TextField(
                        decoration: const InputDecoration(
                            labelText: "Nom d'utilisateur"),
                        controller: serverUsernameController,
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Mot de passe",
                        ),
                        obscureText: true,
                        controller: serverPasswordController,
                      ),
                    ]),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Annuler")),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              SettingsSaving.saveServerCredentials(
                                  serverUsernameController.text,
                                  serverPasswordController.text);
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("OK")),
                    ],
                  ),
                );
              },
            ),
            ListTile(
                title: const Text("Thème"),
                subtitle: ThemeModeHandler(
                  manager: ThemeSaver(),
                  defaultTheme: ThemeMode.system,
                  builder: (themeMode) => Text(themeModeToString(themeMode)),
                ),
                onTap: () async {
                  showDialog(
                      context: context,
                      builder: (context) => const ThemePickerDialog());
                }),
          ],
        ),
      ),
    );
  }
}

class ThemePickerDialog extends StatelessWidget {
  /// Creates a `ThemePickerDialog`.
  const ThemePickerDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Sélectionnez un thème'),
      children: ThemeMode.values.map((themeMode) {
        return SimpleDialogOption(
          onPressed: () async {
            await ThemeModeHandler.of(context)?.saveThemeMode(themeMode);
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: Text(themeModeToString(themeMode)),
        );
      }).toList(),
    );
  }
}

String themeModeToString(ThemeMode themeMode) {
  switch (themeMode) {
    case ThemeMode.dark:
      return "Sombre";
    case ThemeMode.light:
      return "Clair";
    case ThemeMode.system:
      return "Système";
  }
}
