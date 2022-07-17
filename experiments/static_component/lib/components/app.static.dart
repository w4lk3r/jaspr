import 'package:jaspr/jaspr.dart';

import '../src/static_component.dart';
import 'counter.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    print("build test");

    yield DomComponent(
      tag: 'h1',
      child: Text('Hello World'),
    );
    yield DomComponent(
      tag: 'p',
      children: [Text('Hello World'), DynamicBoundary(id: 'counter', child: Counter())],
    );
  }
}
