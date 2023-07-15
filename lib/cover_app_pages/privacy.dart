import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'package:vip/utils/dark_light.dart';

class CoverPrivacyPage extends StatefulWidget {
  const CoverPrivacyPage({super.key});

  @override
  State<CoverPrivacyPage> createState() => _CoverPrivacyPageState();
}

class _CoverPrivacyPageState extends State<CoverPrivacyPage> {
  TextStyle titleStyle = const TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  TextStyle subtitleStyle = const TextStyle(
    color: Colors.black54,
    fontSize: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.grey[200],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          right: 12,
          left: 12,
          top: 6,
          bottom: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "This privacy policy only covers the use of the 'VIP Player' Android application.",
              style: subtitleStyle,
            ),
            section(
              "1. Personal Data Collection and Cookies",
              " Vip Player does not collect any kind of statistics, personal information, or analytics from its users. However, we do collect the Android operating system's built-in mechanisms that are present for all the mobile applications. Also, VIP Player allows videos to be played on various network transports. Cookies are not stored at any point.",
            ),
            section(
              "2. Sensitive personal data and information",
              " VIP Player will never ask you for any kind of sensitive or personal information. You must never provide sensitive personal data or information to Vip Player or to any person or entity representing Vip Player. Please understand that any disclosure of sensitive information will be at your sole risk, and we will not take any kind of responsibility. You must understand, acknowledge, and agree that Vip Player or any other person acting on behalf of Vip Player shall not in any manner be responsible for the authenticity of sensitive personal data or information provided by you to Vip Player.",
            ),
            section(
              "3. Third-Party Services",
              " Our service may contain links to other websites and services owned and operated by third parties that are not under the control of Vip Player. Also, VIP Player uses various third-party websites to help provide our services, including various blogs and wikis to help us understand the use of our services. For example, Vip Player might use the movie database of IMDB to retrieve multimedia information (posters and descriptions) of the user's video files present on the device or on indexed network shares.\n"
                  " Also, VIP Player has the ability to retrieve subtitles from a third-party subtitle website (opensubtitle.org) upon user request. To find the correct subtitle, a processed version of the video file names is sent to opensubtitle.org. This task is performed with or without opensubtitles user credentials that are stored locally on the user’s device.",
            ),
            section(
              "4. Crash reports",
              " If the Vip Player application crashes, an anonymized crash report is automatically sent and available to Vip Player developers. This report only includes the operating system and hardware product version and an anonymized stack trace of the process causing the crash. Please understand that we need this report to make our application even better for all users.",
            ),
            section(
              "5. Support",
              "If you do not consent to any part of the terms of this privacy policy or just wish to contact us for any kind of suggestion, please feel free to email us at vipplayerxt@gmail.com We will get back to you within 3 business days.",
            ),
          ],
        ),
      ),
    );
  }

  Widget section(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: titleStyle,
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: subtitleStyle,
        ),
      ],
    );
  }
}
