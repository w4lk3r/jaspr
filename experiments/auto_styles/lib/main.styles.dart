import 'package:jaspr/styles.dart' as p2;

import 'app.dart' as p0;
import 'counter.dart' as p1;

const classStyles = {
  p0.aquaText: 'aqua_text',
  p0.headingText: 'heading_text',
  p1.largeText: 'large_text',
};

extension StylesClass on p2.Styles {
  String get auto => classStyles[this] ?? '';
}
