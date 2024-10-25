part of 'package:flutter_parental_control/flutter_parental_control.dart';

class MonitorSetting {
  bool? requireAutomaticDateAndTime;
  bool? lockAccounts;
  bool? lockPasscode;
  bool? denySiri;
  bool? lockAppCellularData;
  bool? lockESIM;
  bool? denyInAppPurchases;
  int? maximumRating;
  bool? requirePasswordForPurchases;
  bool? denyExplicitContent;
  bool? denyMusicService;
  bool? denyBookstoreErotica;
  int? maximumMovieRating;
  int? maximumTVShowRating;
  bool? denyMultiplayerGaming;
  bool? denyAddingFriends;

  MonitorSetting({
    this.requireAutomaticDateAndTime,
    this.lockAccounts,
    this.lockPasscode,
    this.denySiri,
    this.lockAppCellularData,
    this.lockESIM,
    this.denyInAppPurchases,
    this.maximumRating,
    this.requirePasswordForPurchases,
    this.denyExplicitContent,
    this.denyMusicService,
    this.denyBookstoreErotica,
    this.maximumMovieRating,
    this.maximumTVShowRating,
    this.denyMultiplayerGaming,
    this.denyAddingFriends,
  });

  // Chuyển đổi đối tượng thành map
  Map<String, dynamic> toMap() {
    return {
      AppConstants.requireAutoTime: requireAutomaticDateAndTime,
      AppConstants.lockAccounts: lockAccounts,
      AppConstants.lockPasscode: lockPasscode,
      AppConstants.denySiri: denySiri,
      AppConstants.lockAppCellularData: lockAppCellularData,
      AppConstants.lockESIM: lockESIM,
      AppConstants.denyInAppPurchases: denyInAppPurchases,
      AppConstants.maximumRating: maximumRating,
      AppConstants.requirePasswordForPurchases: requirePasswordForPurchases,
      AppConstants.denyExplicitContent: denyExplicitContent,
      AppConstants.denyMusicService: denyMusicService,
      AppConstants.denyBookstoreErotica: denyBookstoreErotica,
      AppConstants.maximumMovieRating: maximumMovieRating,
      AppConstants.maximumTVShowRating: maximumTVShowRating,
      AppConstants.denyMultiplayerGaming: denyMultiplayerGaming,
      AppConstants.denyAddingFriends: denyAddingFriends,
    };
  }

  // chuyển đổi map thành đối tượng
  factory MonitorSetting.fromMap(Map<String, dynamic> map) {
    return MonitorSetting(
      requireAutomaticDateAndTime: map[AppConstants.requireAutoTime],
      lockAccounts: map[AppConstants.lockAccounts],
      lockPasscode: map[AppConstants.lockPasscode],
      denySiri: map[AppConstants.denySiri],
      lockAppCellularData: map[AppConstants.lockAppCellularData],
      lockESIM: map[AppConstants.lockESIM],
      denyInAppPurchases: map[AppConstants.denyInAppPurchases],
      maximumRating: map[AppConstants.maximumRating],
      requirePasswordForPurchases:
          map[AppConstants.requirePasswordForPurchases],
      denyExplicitContent: map[AppConstants.denyExplicitContent],
      denyMusicService: map[AppConstants.denyMusicService],
      denyBookstoreErotica: map[AppConstants.denyBookstoreErotica],
      maximumMovieRating: map[AppConstants.maximumMovieRating],
      maximumTVShowRating: map[AppConstants.maximumTVShowRating],
      denyMultiplayerGaming: map[AppConstants.denyMultiplayerGaming],
      denyAddingFriends: map[AppConstants.denyAddingFriends],
    );
  }
}
