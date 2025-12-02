import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _lastFilterKey = 'last_selected_filter';
  static const String _searchHistoryKey = 'search_history';
  static const String _sortOrderKey = 'sort_order';
  static const String _showClosedPollsKey = 'show_closed_polls';

  static final UserPreferencesService _instance = UserPreferencesService._internal();
  factory UserPreferencesService() => _instance;
  UserPreferencesService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> saveLastFilter(String filter) async {
    await init();
    await _prefs!.setString(_lastFilterKey, filter);
  }

  Future<String> getLastFilter() async {
    await init();
    return _prefs!.getString(_lastFilterKey) ?? 'All';
  }

  Future<List<String>> getSearchHistory() async {
    await init();
    return _prefs!.getStringList(_searchHistoryKey) ?? [];
  }

  Future<void> addSearchQuery(String query) async {
    if (query.trim().isEmpty) return;

    await init();
    List<String> history = await getSearchHistory();

    history.remove(query);
    history.insert(0, query);

    if (history.length > 5) {
      history = history.sublist(0, 5);
    }

    await _prefs!.setStringList(_searchHistoryKey, history);
  }

  Future<void> clearSearchHistory() async {
    await init();
    await _prefs!.remove(_searchHistoryKey);
  }

  Future<void> removeSearchQuery(String query) async {
    await init();
    List<String> history = await getSearchHistory();
    history.remove(query);
    await _prefs!.setStringList(_searchHistoryKey, history);
  }

  Future<void> saveSortOrder(String sortOrder) async {
    await init();
    await _prefs!.setString(_sortOrderKey, sortOrder);
  }

  Future<String> getSortOrder() async {
    await init();
    return _prefs!.getString(_sortOrderKey) ?? 'newest';
  }

  Future<void> setShowClosedPolls(bool show) async {
    await init();
    await _prefs!.setBool(_showClosedPollsKey, show);
  }

  Future<bool> getShowClosedPolls() async {
    await init();
    return _prefs!.getBool(_showClosedPollsKey) ?? true;
  }

  Future<void> clearAll() async {
    await init();
    await _prefs!.clear();
  }

  Future<Map<String, dynamic>> getAllPreferences() async {
    await init();
    return {
      'last_filter': await getLastFilter(),
      'search_history': await getSearchHistory(),
      'sort_order': await getSortOrder(),
      'show_closed_polls': await getShowClosedPolls(),
    };
  }
}
