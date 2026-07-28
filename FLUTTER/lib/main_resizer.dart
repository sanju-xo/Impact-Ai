// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     //Set the fit size (fill in the screen size of the device in the design) If the design is based on the size of the iPhone6 ​​(iPhone6 ​​750*1334)
//     return ScreenUtilInit(
//       designSize: const Size(414, 896),
//       // minTextAdapt: true,
//       splitScreenMode: true,
//       builder: () => MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Flutter_ScreenUtil',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           textTheme: TextTheme(button: TextStyle(fontSize: 100.sp)),
//         ),
//         builder: (context, widget) {
//           ScreenUtil.setContext(context);
//           return MediaQuery(
//             //Setting font does not change with system font size
//             data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
//             child: widget!,
//           );
//         },
//         home: HomePage(title: 'FlutterScreenUtil Demo'),
//       ),
//     );
//   }
// }
//
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key, this.title}) : super(key: key);
//
//   final String? title;
//
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     printScreenInformation();
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 0,
//         title: Text(widget.title!),
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         color: toColor("#0F172A"),
//         child: Stack(
//           alignment: Alignment.topCenter,
//           children: [
//             Container(
//               width: 330,
//               height: 330,
//               margin: EdgeInsets.only(top: 90, left: 42, right: 42),
//               decoration: const BoxDecoration(
//                   image:
//                       DecorationImage(image: AssetImage("assets/images1.png"))),
//             ),
//             Padding(
//               padding: EdgeInsets.only(left: 20, right: 20, top: 450),
//               child: Image.asset(
//                 "assets/img_txt.png",
//                 width: 374,
//                 height: 88,
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(left: 20,right: 20,top: 548),
//               child: Text(
//                 "Digital art is an artistic work or practice that uses digital technology.",
//                 style: TextStyle(
//                     fontFamily: "Poppins",
//                     fontSize: 15,
//                     color: toColor("#FFFFFF"),
//                     fontWeight: FontWeight.w400,
//                     fontStyle: FontStyle.normal),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(left: 183, right: 183, top: 650),
//               child: Image.asset(
//                 "assets/indicator.png",
//                 width: 48,
//                 height: 8,
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(left: 20, right:20, top: 698),
//               child: Container(
//                 width: 374,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: toColor("#5E57FF"),
//                   borderRadius: BorderRadius.all(Radius.circular(12))
//                 ),
//                 child: Center(
//                   child: Text(
//                     "Next",
//                     style: TextStyle(
//                         fontFamily: "Poppins",
//                         fontSize: 16,
//                         color: toColor("#FFFFFF"),
//                         fontWeight: FontWeight.w600,
//                         ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.only(top: 796),
//               child: Text(
//                 "Skip",
//                 style: TextStyle(
//                     fontFamily: "Poppins",
//                     fontSize: 16,
//                     color: toColor("#A6ADBE"),
//                     fontWeight: FontWeight.w400,
//                     fontStyle: FontStyle.normal),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//
//
//           ],
//         ),
//       ),
//     );
//   }
//
//   toColor(String hexColor) {
//     hexColor = hexColor.toUpperCase().replaceAll("#", "");
//     if (hexColor.length == 6) {
//       hexColor = "FF" + hexColor;
//     }
//     return Color(int.parse(hexColor, radix: 16));
//   }
//
//   void printScreenInformation() {
//     print('Device Size:${Size(1.sw, 1.sh)}');
//     print('Device pixel density:${ScreenUtil().pixelRatio}');
//     print('Bottom safe zone distance dp:${ScreenUtil().bottomBarHeight}dp');
//     print('Status bar height dp:${ScreenUtil().statusBarHeight}dp');
//     print('The ratio of actual width to UI design:${ScreenUtil().scaleWidth}');
//     print(
//         'The ratio of actual height to UI design:${ScreenUtil().scaleHeight}');
//     print('System font scaling:${ScreenUtil().textScaleFactor}');
//     print('0.5 times the screen width:${0.5.sw}dp');
//     print('0.5 times the screen height:${0.5.sh}dp');
//     print('Screen orientation:${ScreenUtil().orientation}');
//   }
// }
