import 'package:jaspr/jaspr.dart';
import 'package:static_component/components/counter.dart';

import '../src/static_component.dart';

class App extends StaticComponent {
  @override
  Component? hydrate(String id) {
    if (id == 'counter') {
      return Counter();
    }
    return null;
  }
}
