import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings

@available(iOS 16.0, *)
class ParentalControlManager: ObservableObject {
    static let shared = ParentalControlManager()
    let store = ManagedSettingsStore()
    
    private init() {}
    
    // mở giao diện chọn ứng dụng giới hạn
    var selectionToDiscourage = FamilyActivitySelection() {
        willSet {
            let applications = newValue.applicationTokens
            let categories = newValue.categoryTokens
            let webCategories = newValue.webDomainTokens
            store.shield.applications = applications.isEmpty ? nil : applications
            store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categories, except: Set())
            store.shield.webDomains = webCategories
        }
    }
    
    // Thiết lập thời gian giới hạn ứng dụng
    func scheduleMonitor(with options: [String: Any?]) throws{
        let center = DeviceActivityCenter()
        
        guard let isMonitoring = options[AppConstants.IS_MONITORING] as? Bool else {
            return
        }
        
        if isMonitoring {
            let startHour = options[AppConstants.START_HOUR] as? Int ?? 0
            let startMinute = options[AppConstants.START_MINUTE] as? Int ?? 0
            let endHour = options[AppConstants.END_HOUR] as? Int ?? 23
            let endMinute = options[AppConstants.END_MINUTE] as? Int ?? 59
            
            let start = DateComponents(hour: startHour, minute: startMinute)
            let end = DateComponents(hour: endHour, minute: endMinute)
            
            let schedule = DeviceActivitySchedule(
                intervalStart: start,
                intervalEnd: end,
                repeats: true,
                warningTime: nil
            )
            do {
                try center.startMonitoring(.daily, during: schedule)
            } catch {
                throw error
            }
        } else {
            center.stopMonitoring()
        }
    }
    
    // Cài đặt giám sát trên thiết bị
    func settingMonitor(with options: [String: Any?]) {
        func setBool(for key: String, _ setter: @escaping (Bool) -> Void) {
            if let value = options[key] as? Bool {
                setter(value)
            }
        }
        
        func setInt(for key: String, _ setter: @escaping (Int) -> Void) {
            if let value = options[key] as? Int {
                setter(value)
            }
        }
        
        setBool(for: AppConstants.REQUIRE_AUTO_DATE) { self.store.dateAndTime.requireAutomaticDateAndTime = $0 }
        setBool(for: AppConstants.LOCK_ACCOUNTS) { self.store.account.lockAccounts = $0 }
        setBool(for: AppConstants.LOCK_PASSCODE) { self.store.passcode.lockPasscode = $0 }
        setBool(for: AppConstants.DENY_SIRI) { self.store.siri.denySiri = $0 }
        setBool(for: AppConstants.LOCK_APP_CELLULAR_DATA) { self.store.cellular.lockAppCellularData = $0 }
        setBool(for: AppConstants.LOCK_E_SIM) { self.store.cellular.lockESIM = $0 }
        setBool(for: AppConstants.DENY_IN_APP_PURCHASES) { self.store.appStore.denyInAppPurchases = $0 }
        setBool(for: AppConstants.REQUIRE_PASSWORD_FOR_PURCHASES) { self.store.appStore.requirePasswordForPurchases = $0 }
        setBool(for: AppConstants.DENY_EXPLICIT_CONTENT) { self.store.media.denyExplicitContent = $0 }
        setBool(for: AppConstants.DENY_MUSIC_SERVICE) { self.store.media.denyMusicService = $0 }
        setBool(for: AppConstants.DENY_BOOKSTORE_EROTICA) { self.store.media.denyBookstoreErotica = $0 }
        setBool(for: AppConstants.DENY_MULTIPLAYER_GAMING) { self.store.gameCenter.denyMultiplayerGaming = $0 }
        setBool(for: AppConstants.DENY_ADDING_FRIENDS) { self.store.gameCenter.denyAddingFriends = $0 }
        
        setInt(for: AppConstants.MAXIMUM_RATING) { self.store.appStore.maximumRating = $0 }
        setInt(for: AppConstants.MAXIMUM_MOVIE_RATING) { self.store.media.maximumMovieRating = $0 }
        setInt(for: AppConstants.MAXIMUM_TV_SHOW_RATING) { self.store.media.maximumTVShowRating = $0 }
    }
}

@available(iOS 16.0, *)
extension DeviceActivityName {
    static let daily = Self(AppConstants.DAILY)
    static let weekly = Self(AppConstants.WEEKLY)
}
