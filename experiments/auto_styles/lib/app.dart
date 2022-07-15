import 'package:auto_styles/main.styles.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/styles.dart';

import 'counter.dart';

const aquaText = Styles.text(
  color: Colors.aqua,
  fontSize: Unit.pixels(40),
);

const headingText = Styles.combine([
  Styles.text(fontFamily: FontFamilies.comicSans, color: Colors.coral),
]);

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    print("build test");

    yield DomComponent(
      tag: 'h1',
      classes: [headingText.auto],
      child: Text('Hello World'),
    );
    yield DomComponent(
      tag: 'p',
      classes: [aquaText.auto],
      children: [
        Text('Hello World'),
        Counter(),
      ],
    );
  }
}
