part of 'package:flutter_parental_control/flutter_parental_control.dart';

/// Cài đặt giám sát trong thiết bị iOS
class MonitorSetting {
  /// Yêu cầu tự động cập nhật ngày và giờ
  bool? requireAutomaticDateAndTime;

  /// Khoá tài khoản iCloud
  bool? lockAccounts;

  /// Khoá thay đổi mật khẩu thiết bị
  bool? lockPasscode;

  /// Khoá cài đặt dữ dụng dữ liệu
  bool? lockAppCellularData;

  /// Khoá cài đặt E SIM
  bool? lockESIM;

  /// Chặn dùng Siri
  bool? denySiri;

  /// Chặn mua ứng dụng
  bool? denyInAppPurchases;

  /// Yêu cầu mật khẩu khi mua hàng
  bool? requirePasswordForPurchases;

  /// Chặn các nội dung người lớn
  bool? denyExplicitContent;

  /// Chặn dùng dịch vụ âm nhạc
  bool? denyMusicService;

  /// Chặn đọc sách có nội dung người lớn
  bool? denyBookstoreErotica;

  /// Chặn chơi game nhiều người chơi trên Game Center
  bool? denyMultiplayerGaming;

  /// Chặn kết bạn trên Game Center
  bool? denyAddingFriends;

  /// Giới hạn sử dụng ứng dụng theo xếp hạng
  /// Các xếp hạng là:
  /// 1000 - All
  /// 600 - 17+
  /// 300 - 12+
  /// 200 - 9+
  /// 100 - 4+
  /// 0 - None
  int? maximumRating;

  /// Giới hạn xem phim theo xếp hạng
  /// Xếp hạng là:
  /// 1000: All
  /// 500: NC-17
  /// 400: R
  ///300: PG-13
  /// 200: PG
  /// 100: G
  /// 0: None
  int? maximumMovieRating;

  /// Giới hạn chương trình truyền hình theo xếp hạng
  /// 1000: Tất cả
  /// 600: TM-MA
  /// 500: TV-14
  /// 400: TV-PG
  /// 300: TV-G
  /// 200: TV-Y7
  /// 100: TV-Y
  /// 0: Không có
  int? maximumTVShowRating;

  MonitorSetting({
    this.requireAutomaticDateAndTime = false,
    this.lockAccounts = false,
    this.lockPasscode = false,
    this.denySiri = false,
    this.lockAppCellularData = false,
    this.lockESIM = false,
    this.denyInAppPurchases = false,
    this.requirePasswordForPurchases = false,
    this.denyExplicitContent = false,
    this.denyMusicService = false,
    this.denyBookstoreErotica = false,
    this.denyMultiplayerGaming = false,
    this.denyAddingFriends = false,
    this.maximumRating = 1000,
    this.maximumMovieRating = 1000,
    this.maximumTVShowRating = 1000,
  });

  MonitorSetting copyWith({
    bool? requireAutomaticDateAndTime,
    bool? lockAccounts,
    bool? lockPasscode,
    bool? denySiri,
    bool? denyInAppPurchases,
    int? maximumRating,
    int? maximumMovieRating,
    int? maximumTVShowRating,
    bool? requirePasswordForPurchases,
    bool? denyExplicitContent,
    bool? denyMultiplayerGaming,
    bool? denyMusicService,
    bool? denyAddingFriends,
  }) {
    return MonitorSetting(
      requireAutomaticDateAndTime:
      requireAutomaticDateAndTime ?? this.requireAutomaticDateAndTime,
      lockAccounts: lockAccounts ?? this.lockAccounts,
      lockPasscode: lockPasscode ?? this.lockPasscode,
      denySiri: denySiri ?? this.denySiri,
      denyInAppPurchases: denyInAppPurchases ?? this.denyInAppPurchases,
      requirePasswordForPurchases:
      requirePasswordForPurchases ?? this.requirePasswordForPurchases,
      maximumRating: maximumRating ?? this.maximumRating,
      maximumMovieRating: maximumMovieRating ?? this.maximumMovieRating,
      maximumTVShowRating: maximumTVShowRating ?? this.maximumTVShowRating,
      denyExplicitContent: denyExplicitContent ?? this.denyExplicitContent,
      denyMultiplayerGaming:
      denyMultiplayerGaming ?? this.denyMultiplayerGaming,
      denyMusicService: denyMusicService ?? this.denyMusicService,
      denyAddingFriends: denyAddingFriends ?? this.denyAddingFriends,
    );
  }

  /// Chuyển đổi đối tượng thành map
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

  /// chuyển đổi map thành đối tượng
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

  /// Danh sách keys của monitor
  static List<String> get keys=> [
    AppConstants.requireAutoTime,
    AppConstants.lockAccounts,
    AppConstants.lockPasscode,
    AppConstants.denySiri,
    AppConstants.lockAppCellularData,
    AppConstants.lockESIM,
    AppConstants.denyInAppPurchases,
    AppConstants.maximumRating,
    AppConstants.requirePasswordForPurchases,
    AppConstants.denyExplicitContent,
    AppConstants.denyMusicService,
    AppConstants.denyBookstoreErotica,
    AppConstants.maximumMovieRating,
    AppConstants.maximumTVShowRating,
    AppConstants.denyMultiplayerGaming,
    AppConstants.denyAddingFriends,
  ];
}
