import 'package:flutter/material.dart';
import 'package:vip/utils/dark_light.dart';

class MyPageRoute extends MaterialPageRoute {
  final Duration? duration;
  MyPageRoute({required WidgetBuilder builder, this.duration}) : super(builder: builder);

  @override
  Duration get transitionDuration => duration ?? const Duration(milliseconds: 200);
}

class UpwardPageTransitionsBuilder extends PageTransitionsBuilder {
  const UpwardPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      _UpwardPageTransitions(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      );
}

class _UpwardPageTransitions extends StatelessWidget {
  const _UpwardPageTransitions({
    Key? key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  }) : super(key: key);

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  static final Tween<Offset> _primaryTranslationTween = Tween<Offset>(
    begin: const Offset(0.0, 0.30),
    end: Offset.zero,
  );

  static final Tween<Offset> _secondaryTranslationTween = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.0, -0.15),
  );

  static final Tween<double> _scrimOpacityTween = Tween<double>(
    begin: 0.0,
    end: 1.0,
  );

  static const Curve _transitionCurve = Cubic(0.0, 0.0, 0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Size size = constraints.biggest;

        CurvedAnimation primaryAnimation = CurvedAnimation(
          parent: animation,
          curve: _transitionCurve,
          reverseCurve: _transitionCurve.flipped,
        );

        Animation<double> clipAnimation = Tween(
          begin: 0.0,
          end: size.height,
        ).animate(primaryAnimation);

        Animation<double> opacityAnimation =
            _scrimOpacityTween.animate(primaryAnimation);
        Animation<Offset> primaryTranslationAnimation =
            _primaryTranslationTween.animate(primaryAnimation);

        Animation<Offset> secondaryTranslationAnimation =
            _secondaryTranslationTween.animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: _transitionCurve,
            reverseCurve: _transitionCurve.flipped,
          ),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) => Container(
            color: darkLight.withOpacity(opacityAnimation.value),
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              child: SizedBox(
                height: clipAnimation.value,
                child: OverflowBox(
                  alignment: Alignment.bottomCenter,
                  maxHeight: size.height,
                  child: child,
                ),
              ),
            ),
          ),
          child: AnimatedBuilder(
            animation: secondaryAnimation,
            builder: (BuildContext context, Widget? child) =>
                FractionalTranslation(
              translation: secondaryTranslationAnimation.value,
              child: child,
            ),
            child: FractionalTranslation(
              translation: primaryTranslationAnimation.value,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
