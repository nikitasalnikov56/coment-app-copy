import 'package:flutter/material.dart';
import 'package:coment_app/src/feature/app/router/router_observer.dart';

class NavigatorObserversFactory {
  const NavigatorObserversFactory();

  List<NavigatorObserver> call() => [
        // SentryNavigatorObserver(),
        HeroController(),
        RouterObserver(),
      ];
}
