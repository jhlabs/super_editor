import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

/// Example of various [TextWithHintComponent] visual configurations.
///
/// To replicate behavior like this in your own code, ensure that you
/// do the following:
///
///  * Specify how headers should be styled by defining a style
///    builder function.
///  * Define a custom [ComponentBuilder] that builds a widget capable
///    of rendering hint text and add it to the builders passed to
///    [SuperEditor]. Consider using [TextWithHintComponent].
///
/// Each of the above steps are demonstrated in this example.
class TextWithHintDemo extends StatefulWidget {
  @override
  _TextWithHintDemoState createState() => _TextWithHintDemoState();
}

class _TextWithHintDemoState extends State<TextWithHintDemo> {
  late MutableDocument _doc;
  late DocumentEditor _docEditor;

  @override
  void initState() {
    super.initState();
    _doc = _createDocument();
    _docEditor = DocumentEditor(document: _doc);
  }

  @override
  void dispose() {
    _doc.dispose();
    super.dispose();
  }

  /// Creates a document with multiple levels of headers with hint text, and a
  /// regular paragraph for comparison.
  MutableDocument _createDocument() {
    return MutableDocument(
      nodes: [
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText(text: ''),
          metadata: {'blockType': header1Attribution},
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText(text: ''),
          metadata: {'blockType': header2Attribution},
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText(text: ''),
          metadata: {'blockType': header3Attribution},
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText(
            text:
                'Nam hendrerit vitae elit ut placerat. Maecenas nec congue neque. Fusce eget tortor pulvinar, cursus neque vitae, sagittis lectus. Duis mollis libero eu scelerisque ullamcorper. Pellentesque eleifend arcu nec augue molestie, at iaculis dui rutrum. Etiam lobortis magna at magna pellentesque ornare. Sed accumsan, libero vel porta molestie, tortor lorem eleifend ante, at egestas leo felis sed nunc. Quisque mi neque, molestie vel dolor a, eleifend tempor odio.',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SuperEditor(
      editor: _docEditor,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),

      /// Adjust the default styles to style 3 levels of headers
      /// with large font sizes.
      textStyleBuilder: _textStyleBuilder,

      /// Add a new component builder to the front of the list
      /// that knows how to render header widgets with hint text.
      componentBuilders: [
        _headerWithHintBuilder,
        ...defaultComponentBuilders,
      ],
    );
  }
}

/// Styles to apply to all the text in the editor.
TextStyle _textStyleBuilder(Set<Attribution> attributions) {
  // We only care about altering a few styles. Start by getting
  // the standard styles for these attributions.
  var newStyle = defaultStyleBuilder(attributions);

  // Style headers
  for (final attribution in attributions) {
    if (attribution == header1Attribution) {
      newStyle = newStyle.copyWith(
        color: const Color(0xFF444444),
        fontSize: 48,
        fontWeight: FontWeight.bold,
      );
    } else if (attribution == header2Attribution) {
      newStyle = newStyle.copyWith(
        color: const Color(0xFF444444),
        fontSize: 30,
        fontWeight: FontWeight.bold,
      );
    } else if (attribution == header3Attribution) {
      newStyle = newStyle.copyWith(
        color: const Color(0xFF444444),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );
    }
  }

  return newStyle;
}

/// SuperEditor [ComponentBuilder] that builds a component for Header 1, Header 2,
/// and Header 3 `ParagraphNode`s, displays "header goes here..." when the content
/// text is empty.
///
/// [ComponentBuilder]s operate at the document level, which means that they can
/// make decisions based on global document structure. Therefore, if you'd like
/// to limit hint text to the very first header in a document, or the first header
/// and paragraph, you can make that decision at the beginning of your
/// [ComponentBuilder]:
///
/// ```
/// final nodeIndex = componentContext.document.getNodeIndex(
///   componentContext.documentNode,
/// );
///
/// if (nodeIndex > 0) {
///   // This isn't the first node, we don't ever want to show hint text.
///   return null;
/// }
/// ```
Widget? _headerWithHintBuilder(ComponentContext componentContext) {
  if (componentContext.documentNode is! ParagraphNode) {
    return null;
  }

  final blockAttribution = (componentContext.documentNode as TextNode).metadata['blockType'];
  if (!(const [header1Attribution, header2Attribution, header3Attribution]).contains(blockAttribution)) {
    return null;
  }

  final textSelection =
      componentContext.nodeSelection == null || componentContext.nodeSelection!.nodeSelection is! TextSelection
          ? null
          : componentContext.nodeSelection!.nodeSelection as TextSelection;

  final showCaret = componentContext.showCaret && componentContext.nodeSelection != null
      ? componentContext.nodeSelection!.isExtent
      : false;

  return TextWithHintComponent(
    key: componentContext.componentKey,
    text: (componentContext.documentNode as TextNode).text,
    textStyleBuilder: _textStyleBuilder,
    metadata: (componentContext.documentNode as TextNode).metadata,
    // This is the text displayed as a hint.
    hintText: AttributedText(
      text: 'header goes here...',
      spans: AttributedSpans(
        attributions: [
          const SpanMarker(attribution: italicsAttribution, offset: 12, markerType: SpanMarkerType.start),
          const SpanMarker(attribution: italicsAttribution, offset: 15, markerType: SpanMarkerType.end),
        ],
      ),
    ),
    // This is the function that selects styles for the hint text.
    hintStyleBuilder: (Set<Attribution> attributions) => _textStyleBuilder(attributions).copyWith(
      color: const Color(0xFFDDDDDD),
    ),
    textSelection: textSelection,
    selectionColor: (componentContext.extensions[selectionStylesExtensionKey] as SelectionStyle).selectionColor,
    showCaret: showCaret,
  );
}
