import 'package:auto_styles/main.styles.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/styles.dart';

const smallText = Styles.text(
  color: Colors.aqua,
  fontSize: Unit.pixels(40),
);

const largeText = Styles.combine([
  Styles.text(
    fontFamily: FontFamilies.comicSans,
    color: Colors.coral,
    fontSize: Unit.em(5),
  ),
]);

class Counter extends StatefulComponent {
  const Counter({Key? key}) : super(key: key);

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Text('Count is $count');

    yield DomComponent(
      tag: 'button',
      events: {
        'click': (e) {
          setState(() => count++);
        },
      },
      classes: [count < 5 ? smallText.auto : largeText.auto],
      child: Text('Press Me'),
    );
  }
}
