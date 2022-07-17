import 'package:jaspr/jaspr.dart';

class Static {
  const Static();
}

class DynamicBoundary extends StatelessComponent {
  final String id;
  final Component child;

  DynamicBoundary({required this.id, required this.child});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield RenderBuilder(renderer: (b) {
      b.open('dynamic_boundary', id: id);
      b.close();
    });
    yield child;
    yield RenderBuilder(renderer: (b) {
      b.open('dynamic_boundary', id: id);
      b.close();
    });
  }
}

abstract class StaticComponent extends Component {
  const StaticComponent({super.key});

  @override
  Element createElement() => StaticElement(this);

  Component? hydrate(String id);
}

class StaticElement extends SingleChildElement {
  StaticElement(StaticComponent component) : super(component);

  @override
  StaticComponent get component => super.component as StaticComponent;

  @override
  Component? build() => null;

  @override
  void render(DomBuilder b) {
    super.render(b);

    b.skipRemainingNodes(); // TODO skip until end marker
    // TODO inner dynamics
  }
}
