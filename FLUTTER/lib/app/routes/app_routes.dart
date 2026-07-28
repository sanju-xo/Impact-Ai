abstract class Routes {
  static const homeRoute = Paths.homePath;
  static const introRoute = Paths.introPath;
  static const loginRoute = Paths.loginPath;
  static const verifyCodeRoute = Paths.verifyCodePath;
  static const forgotPassRoute = Paths.forgotPassPath;
  static const discoverDetailRoute = Paths.discoverDetailScreenPath;
  static const homeScreenRoute = Paths.homeScreenPath;
  static const profileScreenRoute = Paths.profileScreenPath;
  static const creatorListScreenRoute = Paths.creatorListPath;
  static const editProfileScreenRoute = Paths.editProfileScreenPath;
  static const editLocationScreenRoute = Paths.editLocationScreenPath;
  static const chatSupportRoute = Paths.chatSupportPath;
  static const callSupportRoute = Paths.callSupportPath;

  // 🚀 Add new route for Crash Detail Page
  static const crashDetailRoute = Paths.crashDetailPath;
}

abstract class Paths {
  static const homePath = "/";
  static const introPath = "/intro";
  static const loginPath = "/login";
  static const verifyCodePath = "/verify";
  static const forgotPassPath = "/forgotPass";
  static const homeScreenPath = "/homeScreen";
  static const discoverDetailScreenPath = "/discoverDetail";
  static const creatorListPath = "/TabAllCreators";
  static const profileScreenPath = "/profileScreen";
  static const editProfileScreenPath = "/editprofileScreen";
  static const editLocationScreenPath = "/editlocationScreen";
  static const chatSupportPath = "/chatSupport";
  static const callSupportPath = "/callSupport";

  // 🚀 Define path for Crash Detail Page
  static const crashDetailPath = "/crashDetail";
}