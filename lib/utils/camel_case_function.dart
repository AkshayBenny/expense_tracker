extension StringExtensions on String {
  String toCamelCase() {
    if (this.isEmpty) return '';

    return this
        .split(' ') // Split the string into words
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' '); // Join words back into a string
  }
}
