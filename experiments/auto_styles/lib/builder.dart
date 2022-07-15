import 'dart:async';
import 'dart:math';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:jaspr/styles.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

final stylesChecker = TypeChecker.fromRuntime(Styles);
final splitter = RegExp(r'[ ./_\-\\]+|(?<=[a-z])(?=[A-Z])');

/// Entry point for the builder
AutoStylesBuilder buildAutoStyles(BuilderOptions options) => AutoStylesBuilder(options);

/// The main builder used for code generation
class AutoStylesBuilder implements Builder {
  AutoStylesBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;
    var outputId = inputId.changeExtension('.styles.dart');

    try {
      var stylesSource = generateSource(buildStep);
      await buildStep.writeAsString(
        outputId,
        stylesSource,
      );
    } catch (e, st) {
      print('An unexpected error occurred.\n'
          'This is probably a bug in jaspr_web_builder.\n'
          'Please report this here: '
          'https://github.com/schultek/jaspr/issues\n\n'
          'The error was:\n$e\n\n$st');
      rethrow;
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.dart': ['.styles.dart']
      };

  Future<String> generateSource(BuildStep buildStep) async {
    var lib = await buildStep.inputLibrary;

    var styles = <VariableElement>{};

    void checkVariable(VariableElement e) {
      if (e.isConst && e.type.element != null && stylesChecker.isAssignableFrom(e.type.element!)) {
        print("found const style: ${e.getDisplayString(withNullability: true)}");
        styles.add(e);
      }
    }

    var toCheck = [lib];
    var checked = <LibraryElement>{};

    while (toCheck.isNotEmpty) {
      var lib = toCheck.removeLast();
      checked.add(lib);
      if (lib.isInSdk) continue;

      for (var e in lib.topLevelElements) {
        if (e is VariableElement) {
          checkVariable(e);
        }
      }

      for (var llib in lib.importedLibraries) {
        if (checked.contains(llib) || toCheck.contains(llib)) continue;
        toCheck.add(llib);
      }
    }

    var output = StringBuffer();

    var imports = ImportsBuilder(buildStep.inputId);
    var classes = <String>{};
    var consts = <dynamic>{};

    output.write('const classStyles = {\n');
    for (var style in styles) {
      var obj = style.computeConstantValue();
      if (consts.contains(obj)) {
        continue;
      }
      consts.add(obj);

      var name = snakeCase(style.name);
      if (classes.contains(name)) {
        var libName = style.library!.name;
        if (libName.isEmpty) {
          libName = style.librarySource!.shortName;
        }
        name += '_${snakeCase(libName)}';
      }
      if (classes.contains(name)) {
        name += '_${randHex(4)}';
      }
      classes.add(name);
      var prefix = imports.add(style.librarySource!.uri);

      output.writeln("  $prefix.${style.name}: '$name',");
    }

    output.writeln('};');

    var sp = imports.add(Uri.parse('package:jaspr/styles.dart'));

    output.writeln('''
      extension StylesClass on $sp.Styles {
        String get auto => classStyles[this] ?? '';
      }
    ''');

    return DartFormatter().format(imports.write() + output.toString());
  }
}

String snakeCase(String s) {
  var words = s.split(splitter);
  return words.map((w) => w.toLowerCase()).join('_');
}

String randHex(int length) {
  var random = Random();
  return List.generate(length, (i) => random.nextInt(255).toRadixString(16).padLeft(2, '0')).join();
}

final path = p.posix;

class ImportsBuilder {
  final Map<Uri, String> _imports = {};
  final AssetId _input;

  ImportsBuilder(this._input) {}

  String _nextPrefix() {
    var l = _imports.length;
    return 'p$l';
  }

  String add(Uri import) {
    if (_imports.containsKey(import)) {
      return _imports[import]!;
    } else {
      return _imports[import] = _nextPrefix();
    }
  }

  String prefix(Element e) {
    return _imports[e.librarySource?.uri] ?? '__';
  }

  String write() {
    List<String> sdk = [], package = [], relative = [];
    var prefixes = <String, String>{};

    for (var import in _imports.keys) {
      if (import.isScheme('asset')) {
        var relativePath = path.relative(import.path, from: path.dirname(_input.uri.path));

        relative.add(relativePath);
        prefixes[relativePath] = _imports[import]!;
      } else if (import.isScheme('package') &&
          import.pathSegments.first == _input.package &&
          _input.pathSegments.first == 'lib') {
        var libPath = import.replace(pathSegments: import.pathSegments.skip(1)).path;

        var inputPath = _input.uri.replace(pathSegments: _input.uri.pathSegments.skip(1)).path;

        var relativePath = path.relative(libPath, from: path.dirname(inputPath));

        relative.add(relativePath);
        prefixes[relativePath] = _imports[import]!;
      } else if (import.scheme == 'dart') {
        sdk.add(import.toString());
        prefixes[import.toString()] = _imports[import]!;
      } else if (import.scheme == 'package') {
        package.add(import.toString());
        prefixes[import.toString()] = _imports[import]!;
      } else {
        relative.add(import.toString()); // TODO: is this correct?
        prefixes[import.toString()] = _imports[import]!;
      }
    }

    sdk.sort();
    package.sort();
    relative.sort();

    String joined(List<String> s) =>
        s.isNotEmpty ? '${s.map((s) => "import '$s' as ${prefixes[s]};").join('\n')}\n\n' : '';

    return joined(sdk) + joined(package) + joined(relative);
  }
}
