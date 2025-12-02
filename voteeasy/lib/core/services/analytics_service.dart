import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics;
  final FirebaseAnalyticsObserver observer;

  AnalyticsService._({
    required FirebaseAnalytics analytics,
  })  : _analytics = analytics,
        observer = FirebaseAnalyticsObserver(analytics: analytics);

  static final AnalyticsService _instance = AnalyticsService._(
    analytics: FirebaseAnalytics.instance,
  );

  static AnalyticsService get instance => _instance;

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  Future<void> logLogin({String? method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp({String? method}) async {
    await _analytics.logSignUp(signUpMethod: method ?? 'email');
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  Future<void> logPollCreated({
    required String pollId,
    int? optionsCount,
  }) async {
    await _analytics.logEvent(
      name: 'poll_created',
      parameters: {
        'poll_id': pollId,
        'options_count': optionsCount ?? 0,
      },
    );
  }

  Future<void> logPollVoted({
    required String pollId,
    required String optionId,
  }) async {
    await _analytics.logEvent(
      name: 'poll_voted',
      parameters: {
        'poll_id': pollId,
        'option_id': optionId,
      },
    );
  }

  Future<void> logPollResultsViewed({required String pollId}) async {
    await _analytics.logEvent(
      name: 'poll_results_viewed',
      parameters: {
        'poll_id': pollId,
      },
    );
  }

  Future<void> logShare({
    required String contentType,
    required String itemId,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: 'share_button',
    );
  }

  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    await _analytics.setUserProperty(
      name: name,
      value: value,
    );
  }
}
