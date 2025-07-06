# Contributing to Shonen Shelf

Thank you for your interest in contributing to Shonen Shelf! This document provides guidelines for contributing to this project.

## 🤝 How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in the [Issues](https://github.com/yourusername/flutter_shonen_shelf/issues) section
2. Create a new issue with a clear and descriptive title
3. Include steps to reproduce the bug
4. Add screenshots if applicable
5. Include your device/OS information

### Suggesting Features

1. Check if the feature has already been suggested
2. Create a new issue with the "enhancement" label
3. Describe the feature clearly and explain why it would be useful
4. Include mockups or examples if possible

### Code Contributions

1. Fork the repository
2. Create a new branch for your feature (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Follow the coding standards below
5. Test your changes thoroughly
6. Commit your changes with a clear message (`git commit -m 'Add AmazingFeature'`)
7. Push to your branch (`git push origin feature/AmazingFeature`)
8. Open a Pull Request

## 📋 Coding Standards

### Dart/Flutter

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Use proper error handling

### Code Style

```dart
// Good
class AnimeService {
  Future<List<Anime>> getAnimeList() async {
    try {
      final response = await _api.get('/anime');
      return response.map((json) => Anime.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch anime list: $e');
    }
  }
}

// Bad
class anime_service {
  Future<List> get_anime_list() async {
    var response = await api.get('/anime');
    return response;
  }
}
```

### File Organization

- Keep related files together
- Use meaningful file names
- Follow the existing project structure
- Separate concerns (UI, business logic, data)

## 🧪 Testing

- Test your changes on multiple devices/screen sizes
- Ensure the app works in both light and dark themes
- Test error scenarios
- Verify that existing functionality still works

## 📝 Commit Messages

Use clear and descriptive commit messages:

```
✅ Good:
- "Add anime search functionality"
- "Fix navigation issue in anime details screen"
- "Update README with installation instructions"

❌ Bad:
- "fix stuff"
- "update"
- "wip"
```

## 🔄 Pull Request Process

1. **Title**: Use a clear, descriptive title
2. **Description**: Explain what changes you made and why
3. **Testing**: Mention what you tested
4. **Screenshots**: Add screenshots for UI changes
5. **Checklist**: Use the provided PR template

## 📞 Getting Help

If you need help with contributing:

1. Check the [Issues](https://github.com/yourusername/flutter_shonen_shelf/issues) for similar questions
2. Create a new issue with the "question" label
3. Join our community discussions

## 🙏 Recognition

Contributors will be recognized in the project's README and release notes.

Thank you for contributing to Shonen Shelf! 🎬 