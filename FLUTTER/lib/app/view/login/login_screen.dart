import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:impactai/app/routes/app_routes.dart';
import 'package:impactai/base/color_data.dart';
import 'package:impactai/base/constant.dart';
import 'package:impactai/base/resizer/fetch_pixels.dart';
import 'package:impactai/base/widget_utils.dart';
import '../../../generated/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  ValueNotifier notifier = ValueNotifier(true);
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController badgeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController reenterPassController = TextEditingController();

  bool chkVal = false;

  ValueNotifier<bool> isShowPass = ValueNotifier(false);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Firebase login method
  Future<void> loginWithFirebase() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      if (userCredential.user != null) {
        print("Firebase Authentication successful!");
        Constant.sendToNext(context, Routes.homeScreenRoute);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else {
        errorMessage = e.message ?? 'An error occurred.';
      }
      showCustomToast(errorMessage, context);
    }
  }

  // Google Sign-In method
  Future<void> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google user credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        print("Google Sign-In successful!");
        Constant.sendToNext(context, Routes.homeScreenRoute);
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
      showCustomToast("Google Sign-In failed. Please try again.", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);
    return WillPopScope(
      child: Scaffold(
        backgroundColor: getCurrentTheme(context).scaffoldBackgroundColor,
        appBar: getInVisibleAppBar(color: getCurrentTheme(context).scaffoldBackgroundColor),
        body: SingleChildScrollView(
          primary: true,
          padding: EdgeInsets.symmetric(horizontal: FetchPixels.getDefaultHorSpace(context)),
          scrollDirection: Axis.vertical,
          child: ValueListenableBuilder(
            valueListenable: notifier,
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.topLeft,
                children: [
                  buildTitleWidget(context),
                  buildSubTitleWidget(context),
                  buildButtonSelectionWidget(context),
                  buildDetailView(),
                ],
              );
            },
          ),
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }

  Widget buildTitleWidget(BuildContext context) {
    return getPaddingWidget(
      EdgeInsets.only(top: FetchPixels.getPixelHeight(111)),
      getCustomFont("Login Account", 22, getFontColor(context), 1,
          textAlign: TextAlign.start, fontWeight: FontWeight.w600),
    );
  }

  Widget buildSubTitleWidget(BuildContext context) {
    return getPaddingWidget(
      EdgeInsets.only(top: FetchPixels.getPixelHeight(150)),
      getCustomFont("Please enter your credentials below.", 15,
          getFontColor(context), 1,
          textAlign: TextAlign.start, fontWeight: FontWeight.w400),
    );
  }

  Widget buildButtonSelectionWidget(BuildContext context) {
    return getPaddingWidget(
      EdgeInsets.only(top: FetchPixels.getPixelHeight(202)),
      Container(
        height: FetchPixels.getPixelHeight(60),
        decoration: getButtonDecoration(getCurrentTheme(context).hoverColor, withBorder: false, withCorners: true, corner: FetchPixels.getPixelHeight(30)),
        padding: EdgeInsets.all(FetchPixels.getPixelHeight(6)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: getButtonDecoration((notifier.value) ? getCurrentTheme(context).primaryColorLight : Colors.transparent, withBorder: false, withCorners: true, corner: FetchPixels.getPixelHeight(24)),
                child: InkWell(
                  onTap: () {
                    notifier.value = true;
                  },
                  child: Center(
                    child: getCustomFont(S.of(context).login, 15, (notifier.value) ? getFontColor(context) : getCurrentTheme(context).disabledColor, 1, textAlign: TextAlign.center, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              flex: 1,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: getButtonDecoration((!notifier.value) ? getCurrentTheme(context).primaryColorLight : Colors.transparent, withBorder: false, withCorners: true, corner: FetchPixels.getPixelHeight(24)),
                child: InkWell(
                  onTap: () {
                    notifier.value = false;
                  },
                  child: Center(
                    child: getCustomFont("Register", 15, (!notifier.value) ? getFontColor(context) : getCurrentTheme(context).disabledColor, 1, textAlign: TextAlign.center, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailView() {
    return ValueListenableBuilder(
      builder: (context, value, child) {
        return (notifier.value)
            ? buildLoginWidget(context)
            : buildSignUpWidget(context);
      },
      valueListenable: notifier,
    );
  }

  Stack buildLoginWidget(BuildContext context) {
    return Stack(
      children: [
        getPaddingWidget(
            EdgeInsets.only(top: FetchPixels.getPixelHeight(302)),
            getDefaultTextFiled(context, "Email or Badge Number", emailController, getFontColor(context))),
        getPaddingWidget(
            EdgeInsets.only(top: FetchPixels.getPixelHeight(380)),
            ValueListenableBuilder(
              builder: (context, value, child) {
                return getPassTextFiled(context, "Password", passController, getFontColor(context), isShowPass.value, () {
                  isShowPass.value = !isShowPass.value;
                });
              },
              valueListenable: isShowPass,
            )),
        getPaddingWidget(
            EdgeInsets.only(top: FetchPixels.getPixelHeight(460)),
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  Constant.sendToNext(context, Routes.forgotPassRoute);
                },
                child: getCustomFont("Forgot Password?", 15, getFontSkip(context), 1,
                    fontWeight: FontWeight.w400, textAlign: TextAlign.end),
              ),
            )),
        getPaddingWidget(
            EdgeInsets.only(top: FetchPixels.getPixelHeight(568)),
            getButton(context, getAccentColor(context), true, S.of(context).login, Colors.white, () {
              loginWithFirebase();
            }, EdgeInsets.zero)),
        getPaddingWidget(
            EdgeInsets.only(top: FetchPixels.getPixelHeight(668)),
            SizedBox(
              width: double.infinity,
              child: getCustomFont("Or sign in with", 15, getFontSkip(context), 1, fontWeight: FontWeight.w400, textAlign: TextAlign.center),
            )),
        getPaddingWidget(
          EdgeInsets.only(top: FetchPixels.getPixelHeight(710)),
          SizedBox(
              width: double.infinity,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: getButton(
                          context,
                          getCurrentTheme(context).hoverColor,
                          true,
                          "Google",
                          getFontColor(context),
                          signInWithGoogle,
                          EdgeInsets.zero,
                          isIcon: true,
                          icons: "google.svg"),
                      flex: 1,
                    ),
                    getHorSpace(FetchPixels.getDefaultHorSpace(context)),
                  ])),
        ),
      ],
    );
  }

  Stack buildSignUpWidget(BuildContext context) {
    return Stack(
      children: [
        // Full Name
        getPaddingWidget(
          EdgeInsets.only(top: FetchPixels.getPixelHeight(302)),
          getDefaultTextFiled(context, "Full Name", fullNameController, getFontColor(context)),
        ),

        // Email Address
        getPaddingWidget(
          EdgeInsets.only(top: FetchPixels.getPixelHeight(380)),
          getDefaultTextFiled(context, "Email Address", emailController, getFontColor(context)),
        ),

        // Badge Number
        getPaddingWidget(
          EdgeInsets.only(top: FetchPixels.getPixelHeight(460)),
          getDefaultTextFiled(context, "Badge Number", badgeController, getFontColor(context)),
        ),

        // Phone Number
        getPaddingWidget(
          EdgeInsets.only(top: FetchPixels.getPixelHeight(540)),
          getDefaultTextFiled(context, "Phone Number", phoneController, getFontColor(context)),
        ),

        // Password
        getPaddingWidget(
          EdgeInsets.only(top: FetchPixels.getPixelHeight(620)),
          ValueListenableBuilder(
            builder: (context, value, child) {
              return getPassTextFiled(context, "Password", passController, getFontColor(context), isShowPass.value, () {
                isShowPass.value = !isShowPass.value;
              });
            },
            valueListenable: isShowPass,
          ),
        ),

        // Re-enter Password
        getPaddingWidget(
          EdgeInsets.only(top: FetchPixels.getPixelHeight(700)),
          ValueListenableBuilder(
            builder: (context, value, child) {
              return getPassTextFiled(context, "Re-enter Password", reenterPassController, getFontColor(context), isShowPass.value, () {
                isShowPass.value = !isShowPass.value;
              });
            },
            valueListenable: isShowPass,
          ),
        ),

        // Terms & Conditions Checkbox
        getPaddingWidget(
          EdgeInsets.only(top: FetchPixels.getPixelHeight(780)),
          Row(
            children: [
              SizedBox(
                height: FetchPixels.getPixelHeight(24),
                width: FetchPixels.getPixelHeight(24),
                child: Checkbox(
                  onChanged: (value) {
                    setState(() {
                      chkVal = value!;
                    });
                  },
                  value: chkVal,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(width: 0.5, color: greyFont),
                  activeColor: primaryColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
              ),
              getHorSpace(FetchPixels.getPixelWidth(5)),
              getCustomFont("I accept the", 15, getFontColor(context), 1, textAlign: TextAlign.start, fontWeight: FontWeight.w400),
              getCustomFont(" Terms & Privacy Policy", 15, getAccentColor(context), 1, textAlign: TextAlign.start, fontWeight: FontWeight.w400),
            ],
          ),
        ),

        // Register Button
        getPaddingWidget(
          EdgeInsets.only(top: FetchPixels.getPixelHeight(850)),
          getButton(context, getAccentColor(context), true, "Register", Colors.white, () {
            if (fullNameController.text.isEmpty) {
              showCustomToast("Full name is required!", context);
              return;
            }
            if (emailController.text.isEmpty) {
              showCustomToast("Email is required!", context);
              return;
            }
            if (badgeController.text.isEmpty) {
              showCustomToast("Badge number is required!", context);
              return;
            }
            if (phoneController.text.isEmpty) {
              showCustomToast("Phone number is required!", context);
              return;
            }
            if (passController.text.isEmpty || reenterPassController.text.isEmpty) {
              showCustomToast("Both passwords are required!", context);
              return;
            }
            if (passController.text != reenterPassController.text) {
              showCustomToast("Passwords do not match!", context);
              return;
            }
            if (!chkVal) {
              showCustomToast("You must accept the Terms & Privacy Policy!", context);
              return;
            }

            // Proceed with registration logic (e.g., Firebase or your server)
            registerWithFirebase();
          }, EdgeInsets.zero),
        ),
      ],
    );
  }

// Registration method
  Future<void> registerWithFirebase() async {
    try {
      // Register user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      // Check if registration was successful
      if (userCredential.user != null) {
        // Log success
        print("User registered successfully!");

        // Get the current user
        User? user = userCredential.user;

        // Save user details to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
          'full_name': fullNameController.text.trim(),
          'email': emailController.text.trim(),
          'badge_number': badgeController.text.trim(),
          'phone_number': phoneController.text.trim(),
          'is_admin': false, // Default value is false
          'address': {
            'latitude': 37.7749,
            'longitude': -122.4194
          },
        });

        // Navigate to home screen
        Constant.sendToNext(context, Routes.homeScreenRoute);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'The email address is already in use by another account.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      } else {
        errorMessage = e.message ?? 'An error occurred during registration.';
      }
      // Show error message
      showCustomToast(errorMessage, context);
    }
  }


}
