class Brand {
  final int id;
  final String name;
  final String slug;
  final String? logoPath;

  Brand({
    required this.id,
    required this.name,
    required this.slug,
    this.logoPath,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      logoPath: json['logo'],
    );
  }

  // Helper method to get the full image URL assuming ApiService baseUrl
  String get logoUrl {
    if (logoPath == null) return '';
    if (logoPath!.startsWith('http')) {
      return logoPath!;
    }
    // Correct backslashes if present and ensure it starts with /
    final sanitizedPath = logoPath!.replaceAll('\\', '/');
    final String formattedPath = sanitizedPath.startsWith('/')
        ? sanitizedPath
        : '/$sanitizedPath';
    return 'http://10.0.2.2:8000/storage$formattedPath';
  }
}
