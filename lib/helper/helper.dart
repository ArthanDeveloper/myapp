// Helper function to convert a string to Title Case
String toTitleCase(String text) {
  if (text.isEmpty) {
    return '';
  }
  if (text.length <= 1) {
    return text.toUpperCase();
  }

  // Split the string by words
  final List<String> words = text.split(' ');

  // Capitalize the first letter of each word
  final capitalizedWords = words.map((word) {
    if (word.trim().isEmpty) return '';
    final String firstLetter = word.substring(0, 1).toUpperCase();
    final String remainingLetters = word.substring(1).toLowerCase(); // Optional: make rest lowercase
    return '$firstLetter$remainingLetters';
  });

  // Join the words back together
  return capitalizedWords.join(' ');
}