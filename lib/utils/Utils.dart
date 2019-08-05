import 'package:appcenter/appcenter.dart';
import 'package:appcenter_analytics/appcenter_analytics.dart';
import 'package:appcenter_crashes/appcenter_crashes.dart';
import 'package:flutter/foundation.dart';

class Utils {
  static Future initAppCenter() async {
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    var appSecret = ios
        ? "b91e941f-c97d-497c-acf4-1a37d8416be5"
        : "b91e941f-c97d-497c-acf4-1a37d8416be5";

    await AppCenter.start(
        appSecret, [AppCenterAnalytics.id, AppCenterCrashes.id]);

    await AppCenter.setEnabled(true); // global
    await AppCenterAnalytics.setEnabled(true); // just a service
    await AppCenterCrashes.setEnabled(true); // just a service
  }
}
