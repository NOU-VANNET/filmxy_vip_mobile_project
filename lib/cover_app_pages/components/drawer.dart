import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/cover_app_pages/favorites.dart';
import 'package:vip/cover_app_pages/privacy.dart';
import 'package:vip/login_page.dart';

enum CoverMediaType {
  video,
  audio,
}

class CoverDrawerWidget extends StatelessWidget {
  final CoverMediaType currentMediaType;
  final void Function(CoverMediaType type)? onChangeMediaType;
  final void Function()? onOpenPrivacy;
  const CoverDrawerWidget({
    super.key,
    this.currentMediaType = CoverMediaType.video,
    this.onChangeMediaType,
    this.onOpenPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/icons/v.png',
              width: context.width,
              height: 64,
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: context.width,
              child: const Text(
                'VIP APP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (builder) => const AuthPage(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.login),
                  SizedBox(width: 12),
                  Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {
                if (currentMediaType != CoverMediaType.video) {
                  onChangeMediaType?.call(CoverMediaType.video);
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: currentMediaType == CoverMediaType.video
                    ? Colors.grey[700]
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.videocam,
                    color: currentMediaType == CoverMediaType.video
                        ? Colors.white
                        : Colors.white54,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Video',
                    style: TextStyle(
                      color: currentMediaType == CoverMediaType.video
                          ? Colors.white
                          : Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {
                if (currentMediaType != CoverMediaType.audio) {
                  onChangeMediaType?.call(CoverMediaType.audio);
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: currentMediaType == CoverMediaType.audio
                    ? Colors.grey[700]
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.audiotrack_rounded,
                    color: currentMediaType == CoverMediaType.audio
                        ? Colors.white
                        : Colors.white54,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Audio',
                    style: TextStyle(
                      color: currentMediaType == CoverMediaType.audio
                          ? Colors.white
                          : Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (builder) => const CoverFavoritesPage(),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: Colors.transparent,
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.favorite,
                    color: Colors.white54,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Favorites',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () {
                onOpenPrivacy?.call();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (builder) => const CoverPrivacyPage(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: Colors.transparent,
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.privacy_tip,
                    color: Colors.white54,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
