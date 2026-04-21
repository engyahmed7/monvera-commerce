class AboutStat {
  const AboutStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class AboutHighlight {
  const AboutHighlight({
    required this.title,
    required this.description,
    required this.iconName,
  });

  final String title;
  final String description;
  final String iconName;
}

class AboutContent {
  const AboutContent({
    required this.heading,
    required this.subheading,
    required this.story,
    required this.email,
    required this.phone,
    required this.address,
    required this.stats,
    required this.highlights,
  });

  final String heading;
  final String subheading;
  final String story;
  final String email;
  final String phone;
  final String address;
  final List<AboutStat> stats;
  final List<AboutHighlight> highlights;
}
