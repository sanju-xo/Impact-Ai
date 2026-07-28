import 'package:flutter/material.dart';
import 'package:impactai/base/color_data.dart';
import 'package:impactai/base/constant.dart';
import 'package:impactai/base/resizer/fetch_pixels.dart';
import 'package:impactai/base/widget_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:impactai/app/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EditProfileScreen();
  }
}

class _EditProfileScreen extends State<EditProfileScreen> {
  TextEditingController nameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController numberCont = TextEditingController();
  TextEditingController badgeCont = TextEditingController(); // Change to badge number

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fetch user data from Firestore
  Future<void> fetchUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();

    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;

      nameCont.text = userData['full_name'] ?? '';
      emailCont.text = userData['email'] ?? '';
      numberCont.text = userData['phone_number'] ?? '';
      badgeCont.text = userData['badge_number'] ?? '';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when the screen loads
  }

  // Save user profile data to Firestore
  Future<void> saveProfileData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await firestore.collection('users').doc(userId).update({
      'full_name': nameCont.text.trim(),
      'email': emailCont.text.trim(),
      'phone_number': numberCont.text.trim(),
      'badge_number': badgeCont.text.trim(),
    }).then((value) {
      print("User profile updated successfully!");
      Constant.sendToNext(context, Routes.homeScreenRoute); // Navigate to home screen
    }).catchError((error) {
      showCustomToast("Failed to update profile: $error", context);
    });
  }

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);
    Widget verSpace = getVerSpace(FetchPixels.getPixelHeight(20));
    return WillPopScope(
        child: Scaffold(
          backgroundColor: getCurrentTheme(context).scaffoldBackgroundColor,
          appBar: getInVisibleAppBar(),
          extendBodyBehindAppBar: true,
          body: ListView(
            padding: EdgeInsets.zero,
            primary: true,
            shrinkWrap: true,
            children: [
              getProfileTopView(context, () {
                Constant.backToPrev(context);
              }, "Edit Profile", visibleMore: false, visibleEdit: false),
              getVerSpace(FetchPixels.getPixelHeight(16)),
              buildExpanded(context, verSpace),
            ],
          ),
        ),
        onWillPop: () async {
          Constant.backToPrev(context);
          return false;
        });
  }

  ListView buildExpanded(BuildContext context, Widget verSpace) {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(
          horizontal: FetchPixels.getDefaultHorSpace(context)),
      primary: false,
      children: [
        getDefaultTextFiled(
          context,
          "Name",
          nameCont,
          getFontColor(context),
        ),
        verSpace,
        getDefaultTextFiled(
          context,
          "Email",
          emailCont,
          getFontColor(context),
        ),
        verSpace,
        getDefaultTextFiled(
          context,
          "Phone Number", // Change "Blood group" to "Blood number"
          numberCont,
          getFontColor(context),
        ),
        verSpace,
        getDefaultTextFiled(
          context,
          "Badge Number", // Change "Address" to "Badge Number"
          badgeCont,
          getFontColor(context),
        ),
        getVerSpace(FetchPixels.getPixelHeight(30)),
        getButton(
            context, getAccentColor(context), true, "Save", Colors.white, () {
          saveProfileData(); // Save the updated data to Firestore
        }, EdgeInsets.zero)
      ],
    );
  }

  showProfileDialog() {
    FetchPixels(context);
    double horSpace = FetchPixels.getPixelWidth(20);
    double radius = FetchPixels.getPixelHeight(40);

    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: getCurrentTheme(context).scaffoldBackgroundColor,
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius),
                topRight: Radius.circular(radius))),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return FractionallySizedBox(
                heightFactor: 0.58,
                child: Column(
                  children: [
                    getVerSpace(FetchPixels.getPixelHeight(10)),
                    Center(child: getDialogDividerTop(context)),
                    buildExpandView(context, horSpace),
                    Center(
                      child: getDialogDividerBottom(context),
                    ),
                    getVerSpace(FetchPixels.getPixelHeight(15)),
                  ],
                ),
              );
            },
          );
        });
  }

  Expanded buildExpandView(BuildContext context, double horSpace) {
    return Expanded(
      child: ListView(
        children: [
          getVerSpace(FetchPixels.getPixelHeight(26)),
          getSettingRow(context, "Export.svg", "Share", () {}),
          getSettingRow(context, "Gallery.svg", "Replace Cover", () {}),
          getSettingRow(context, "user.svg", "Remove Cover", () {}),
          buildButton(context, horSpace),
          getVerSpace(FetchPixels.getPixelHeight(20)),
        ],
      ),
      flex: 1,
    );
  }

  Widget buildButton(BuildContext context, double horSpace) {
    return getButton(
        context, Colors.transparent, true, "Cancel", getAccentColor(context),
            () {
          Constant.backToPrev(context);
        },
        EdgeInsets.symmetric(
            horizontal: horSpace, vertical: FetchPixels.getPixelHeight(10)),
        isBorder: true,
        borderColor: getAccentColor(context));
  }
}
