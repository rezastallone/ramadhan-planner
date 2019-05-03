import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:path/path.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:taskist/quran/app_settings.dart';
import 'package:taskist/quran/helpers/settings_helpers.dart';
import 'package:taskist/quran/localizations/app_localizations.dart';
import 'package:taskist/quran/models/theme_model.dart';
import 'package:taskist/quran/routes/routes.dart';
import 'package:taskist/quran/screens/main_drawer.dart';
import 'package:taskist/quran/services/bookmarks_data_service.dart';
import 'package:taskist/quran/services/database_file_service.dart';
import 'package:taskist/quran/services/quran_data_services.dart';
import 'package:taskist/quran/services/translations_list_service.dart';
import 'package:taskist/service/authentication.dart';
import 'package:taskist/ui/root_page.dart';

Future<Null> main() async {
  // Load secrets file, ignore if the secrets.json is not exists
  // This is meant to use in development only
  try {
    var json = await rootBundle.loadString('assets/data/secrets.json');
    var a = jsonDecode(json);
    AppSettings.secrets = a;

    if (AppSettings.secrets.containsKey('key')) {
      AppSettings.key = AppSettings.secrets['key'];
    }
    if (AppSettings.secrets.containsKey('iv')) {
      AppSettings.iv = AppSettings.secrets['iv'];
    }
  } catch (error) {
    print('No secrets.json file');
  }

  await SettingsHelpers.instance.init();

  // Make sure /database directory created
  var databasePath = await getDatabasesPath();
  var f = Directory(databasePath);
  if (!f.existsSync()) {
    f.createSync();
  }

  registerDependencies();

  runApp(new TaskistApp());
}


void registerDependencies() {
  Application.container
      .registerSingleton<IBookmarksDataService, BookmarksDataService>(
        (c) => BookmarksDataService(),
  );
  Application.container
      .registerSingleton<ITranslationsListService, TranslationsListService>(
        (c) => TranslationsListService(),
  );
  Application.container.registerSingleton<IQuranDataService, QuranDataService>(
        (c) => QuranDataService(),
  );
  Application.container
      .registerSingleton<IDatabaseFileService, DatabaseFileService>(
        (c) => DatabaseFileService(),
  );
}


typedef void ChangeLocaleCallback(Locale locale);
typedef void ChangeThemeCallback(ThemeModel themeMpdel);

class Application {
  static ChangeLocaleCallback changeLocale;

  static ChangeThemeCallback changeThemeCallback;

  static kiwi.Container container = kiwi.Container();
}



class TaskistApp extends StatelessWidget {

  MyAppModel myAppModel;

  @override
  Widget build(BuildContext context) {
//    return MaterialApp(
//      debugShowCheckedModeBanner: false,
//      title: "Taskist",
//      home: new RootPage(auth: Auth()),
//      theme: new ThemeData(primarySwatch: Colors.blue),
//    );

    myAppModel = MyAppModel(
      locale: Locale(
        'en',
      ),
    );

    Application.changeLocale = null;
//    Application.changeLocale = changeLocale;

    Application.changeThemeCallback = null;
//    Application.changeThemeCallback = changeTheme;

    var locale = SettingsHelpers.instance.getLocale();
    myAppModel.changeLocale(locale);
//    changeTheme(SettingsHelpers.instance.getTheme());

    return MaterialApp(
      localizationsDelegates: [
        myAppModel.appLocalizationsDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: myAppModel.supportedLocales,
      locale: myAppModel.locale,
      onGenerateTitle: (context) =>
      AppLocalizations
          .of(context)
          .appName,
      theme: new ThemeData(primarySwatch: Colors.blue),
//      routes: Routes.routes,
      home: new RootPage(auth: Auth()),
    );
  }
}

class MyAppModel extends Model {
  AppLocalizationsDelegate appLocalizationsDelegate;
  Locale locale;

  List<Locale> supportedLocales = [
    Locale('en'),
    Locale('id'),
  ];

  MyAppModel({
    @required this.locale,
  }) {
    appLocalizationsDelegate = AppLocalizationsDelegate(
      locale: locale,
      supportedLocales: supportedLocales,
    );
  }

  void changeLocale(Locale locale) {
    this.locale = locale;
    notifyListeners();
  }
}