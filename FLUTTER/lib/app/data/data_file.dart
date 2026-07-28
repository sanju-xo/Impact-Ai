import 'package:impactai/app/models/model_notification.dart';
import 'package:impactai/app/models/model_trending.dart';
import 'package:impactai/app/models/model_intro.dart';

class DataFile {


  static List<ModelNotification> getAllNotificationList() {
    return [
      ModelNotification("Crash Detected", "A major accident was detected",
          "notification1.png", "14:00 PM", true),
      ModelNotification("Emergency Alert", "An ambulance has been dispatched",
          "notification2.png", "14:10 PM", true),
      ModelNotification("Incident Report", "Crash report updated",
          "notification3.png", "15:30 PM", true)
    ];
  }
  static List<ModelIntro> introList = [
    ModelIntro(
        1,
        "🚗 Detect, Alert & Save Lives",
        "Our AI-powered crash detection system helps identify accidents in real-time, ensuring faster emergency response and improved road safety.",
        "intro1.png"),
    ModelIntro(
        2,
        "🤖 Smart Crash Detection, Instant Alerts",
        "Using advanced AI, our system analyzes road incidents from live CCTV and video feeds, ensuring timely intervention when it matters most.",
        "intro2.png"),
    ModelIntro(
        3,
        "🚨 AI That Watches Over You",
        "Accidents happen, but response time matters. Our crash detection AI notifies emergency services instantly to help save lives.",
        "intro3.png")
  ];
}