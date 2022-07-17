import '../../jaspr.dart';
import '../framework/framework.dart';

class RenderBuilder extends CustomRenderComponent {
  const RenderBuilder({
    required this.renderer,
  });

  final void Function(DomBuilder) renderer;

  @override
  void render(DomBuilder b) => renderer(b);
}

/// Component that has a custom render function
abstract class CustomRenderComponent extends Component {
  const CustomRenderComponent();

  void render(DomBuilder b);

  @override
  Element createElement() => CustomRenderElement(this);
}

/// Element that lets the component perform the rendering
class CustomRenderElement extends SingleChildElement {
  CustomRenderElement(CustomRenderComponent component) : super(component);

  @override
  CustomRenderComponent get component => super.component as CustomRenderComponent;

  @override
  Component? build() => null;

  @override
  void render(DomBuilder b) {
    super.render(b);
    component.render(b);
  }
}

/// Component that skips rendering for all child nodes
class SkipRenderComponent extends CustomRenderComponent {
  @override
  void render(DomBuilder b) {
    try {
      b.skipRemainingNodes();
    } on AssertionError {
      // ignore
    }
  }
}
