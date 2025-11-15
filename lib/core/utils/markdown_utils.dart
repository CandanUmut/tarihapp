class MarkdownSection {
  const MarkdownSection({
    required this.heading,
    required this.body,
    this.order = 0,
  });

  final String heading;
  final String body;
  final int order;
}

class MarkdownUtils {
  const MarkdownUtils._();

  static List<MarkdownSection> splitByHeading(String markdown) {
    final lines = markdown.split('\n');
    final sections = <MarkdownSection>[];
    final buffer = StringBuffer();
    String? currentHeading;
    var order = 0;

    void pushSection() {
      if (currentHeading != null || buffer.isNotEmpty) {
        sections.add(
          MarkdownSection(
            heading: currentHeading ?? '',
            body: buffer.toString().trim(),
            order: order++,
          ),
        );
        buffer.clear();
      }
    }

    for (final line in lines) {
      if (line.startsWith('#')) {
        pushSection();
        currentHeading = line.replaceFirst(RegExp(r'^#+'), '').trim();
      } else {
        buffer.writeln(line);
      }
    }
    pushSection();
    return sections;
  }
}
