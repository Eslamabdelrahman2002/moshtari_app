part of 'app_settings_cubit.dart';

@freezed
class AppSettingsState with _$AppSettingsState {
  const factory AppSettingsState.initial() = _Initial;

  const factory AppSettingsState.authenticated() = _Authenticated;
  const factory AppSettingsState.unauthenticated() = _Unauthenticated;
}
