import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myridedriverapp/screens/SplashScreen.dart';
import 'package:myridedriverapp/store/AppStore.dart';
import 'package:myridedriverapp/utils/Colors.dart';
import 'package:myridedriverapp/utils/Common.dart';
import 'package:myridedriverapp/utils/Constants.dart';
import 'package:myridedriverapp/utils/DataProvider.dart';
import 'package:myridedriverapp/utils/Extensions/StringExtensions.dart';
import 'AppTheme.dart';
import 'Services/ChatMessagesService.dart';
import 'Services/NotificationService.dart';
import 'Services/UserServices.dart';
import 'language/AppLocalizations.dart';
import 'language/BaseLanguage.dart';
import 'model/FileModel.dart';
import 'model/LanguageDataModel.dart';
import 'screens/NoInternetScreen.dart';
import 'utils/Extensions/app_common.dart';
import 'package:uuid/uuid.dart';

AppStore appStore = AppStore();
late SharedPreferences sharedPref;
Color textPrimaryColorGlobal = textPrimaryColor;
Color textSecondaryColorGlobal = textSecondaryColor;
Color defaultLoaderBgColorGlobal = Colors.white;
List<LanguageDataModel> localeLanguageList = [];
LanguageDataModel? selectedLanguageDataModel;
late BaseLanguage language;
bool isCurrentlyOnNoInternet = false;
int? stutasCount = 0;

late List<FileModel> fileList = [];
bool mIsEnterKey = false;
// String mSelectedImage = "assets/default_wallpaper.png";

ChatMessageService chatMessageService = ChatMessageService();
NotificationService notificationService = NotificationService();
UserService userService = UserService();

final navigatorKey = GlobalKey<NavigatorState>();

get getContext => navigatorKey.currentState?.overlay?.context;
late LocationPermission locationPermissionHandle;

Future<void> initialize({
  double? defaultDialogBorderRadius,
  List<LanguageDataModel>? aLocaleLanguageList,
  String? defaultLanguage,
}) async {
  localeLanguageList = aLocaleLanguageList ?? [];
  selectedLanguageDataModel = getSelectedLanguageModel(defaultLanguage: default_Language);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseOptions(apiKey: "AIzaSyDsrIPWz-0hhD1SJ_u0tgTQ5zf3eMWjKtw", appId: "1:552752569147:ios:8b34b26eec118dbb1bf51e", messagingSenderId: "552752569147", projectId: "myride-capcana", storageBucket: "myride-capcana.appspot.com", databaseURL: "https://myride-capcana-default-rtdb.firebaseio.com")).then((value) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  });

  sharedPref = await SharedPreferences.getInstance();
  await initialize(aLocaleLanguageList: languageList());
  appStore.setLanguage(default_Language);

  await appStore.setLoggedIn(sharedPref.getBool(IS_LOGGED_IN) ?? false, isInitializing: true);
  await appStore.setUserId(sharedPref.getInt(USER_ID) ?? 0, isInitializing: true);
  await appStore.setUserEmail(sharedPref.getString(USER_EMAIL).validate(), isInitialization: true);
  await appStore.setUserProfile(sharedPref.getString(USER_PROFILE_PHOTO).validate(), isInitialization: true);
  oneSignalSettings();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    var uuid = const Uuid();
    var generatedUuid = uuid.v4();
    if(sharedPref.getString(PLAYER_ID) == null) sharedPref.setString(PLAYER_ID, generatedUuid);
    print('shared ref ---> ${sharedPref.getString(PLAYER_ID)}');
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((e) {
      if (e == ConnectivityResult.none) {
        log('not connected');
        isCurrentlyOnNoInternet = true;
        launchScreen(navigatorKey.currentState!.overlay!.context, NoInternetScreen());
      } else {
        if (isCurrentlyOnNoInternet) {
          Navigator.pop(navigatorKey.currentState!.overlay!.context);
          isCurrentlyOnNoInternet = false;
          toast('Internet is connected.');
        }
        log('connected');
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
    connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: mAppName,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          return ScrollConfiguration(behavior: MyBehavior(), child: child!);
        },
        home: SplashScreen(),
        supportedLocales: LanguageDataModel.languageLocales(),
        localizationsDelegates: [
          AppLocalizations(),
          CountryLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguage.validate(value: default_Language)),
      );
    });
  }
}