import 'package:flutter/material.dart';

import '../model/about_content_model.dart';
import '../service/about_service.dart';

class AboutProvider extends ChangeNotifier {
  AboutProvider({AboutService? service}) : _service = service ?? AboutService();

  final AboutService _service;

  AboutContent? _content;
  bool _isLoading = false;
  String? _error;
  bool _hasLoaded = false;

  AboutContent? get content => _content;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAbout() async {
    if (_isLoading || _hasLoaded) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _content = await _service.getAboutContent();
      _hasLoaded = true;
    } catch (_) {
      _error = 'Unable to load About information.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    _hasLoaded = false;
    await loadAbout();
  }
}
