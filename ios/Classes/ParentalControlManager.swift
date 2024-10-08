import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings

@available(iOS 16.0, *)
class ParentalControlManager: ObservableObject {
    static let shared = ParentalControlManager()
    let store = ManagedSettingsStore()
    
    private init() {}
    
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
    func scheduleMonitor(with options: [String: Any?]) {
        let center = DeviceActivityCenter()
        
        guard let isMonitoring = options["isMonitoring"] as? Bool else {
            return
        }
        
        if isMonitoring {
            let startHour = options["startHour"] as? Int ?? 0
            let startMinute = options["startMinute"] as? Int ?? 0
            let endHour = options["endHour"] as? Int ?? 23
            let endMinute = options["endMinute"] as? Int ?? 59
            
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
                print("Đã bắt đầu giám sát.")
            } catch {
                print("Không thể bắt đầu giám sát: \(error.localizedDescription)")
            }
        } else {
            center.stopMonitoring()
        }
    }
    
    func settingMonitor(with options: [String: Any?]) {
        let settings: [(key: String, setter: (Any) -> Void)] = [
            ("requireAutomaticDateAndTime", { store.dateAndTime.requireAutomaticDateAndTime = $0 as! Bool }),
            ("lockAccounts", { store.account.lockAccounts = $0 as! Bool }),
            ("lockPasscode", { store.passcode.lockPasscode = $0 as! Bool }),
            ("denySiri", { store.siri.denySiri = $0 as! Bool }),
            ("lockAppCellularData", { store.cellular.lockAppCellularData = $0 as! Bool }),
            ("lockESIM", { store.cellular.lockESIM = $0 as! Bool }),
            ("denyInAppPurchases", { store.appStore.denyInAppPurchases = $0 as! Bool }),
            ("maximumRating", { store.appStore.maximumRating = $0 as! Int }),
            ("requirePasswordForPurchases", { store.appStore.requirePasswordForPurchases = $0 as! Bool }),
            ("denyExplicitContent", { store.media.denyExplicitContent = $0 as! Bool }),
            ("denyMusicService", { store.media.denyMusicService = $0 as! Bool }),
            ("denyBookstoreErotica", { store.media.denyBookstoreErotica = $0 as! Bool }),
            ("maximumMovieRating", { store.media.maximumMovieRating = $0 as! Int }),
            ("maximumTVShowRating", { store.media.maximumTVShowRating = $0 as! Int }),
            ("denyMultiplayerGaming", { store.gameCenter.denyMultiplayerGaming = $0 as! Bool }),
            ("denyAddingFriends", { store.gameCenter.denyAddingFriends = $0 as! Bool })
        ]
        
        for (key, setter) in settings {
            if let value = options[key] {
                setter(value)
            }
        }
    }
    
    
    
    //    func settingMonitor(with options: [String: Any]) {
    //        store.dateAndTime.requireAutomaticDateAndTime = options["requireAutomaticDateAndTime"] as? Bool ?? false
    //        store.account.lockAccounts = options["lockAccounts"] as? Bool ?? false
    //        store.passcode.lockPasscode = options["lockPasscode"] as? Bool ?? false
    //        store.siri.denySiri = options["denySiri"] as? Bool ?? false
    //        store.cellular.lockAppCellularData = options["lockAppCellularData"] as? Bool ?? false
    //        store.cellular.lockESIM = options["lockESIM"] as? Bool ?? false
    //        store.appStore.denyInAppPurchases = options["denyInAppPurchases"] as? Bool ?? true
    //        store.appStore.maximumRating = options["maximumRating"] as? Int ?? 1000
    //        store.appStore.requirePasswordForPurchases = options["requirePasswordForPurchases"] as? Bool ?? true
    //        store.media.denyExplicitContent = options["denyExplicitContent"] as? Bool ?? true
    //        store.media.denyMusicService = options["denyMusicService"] as? Bool ?? false
    //        store.media.denyBookstoreErotica = options["denyBookstoreErotica"] as? Bool ?? false
    //        store.media.maximumMovieRating = options["maximumMovieRating"] as? Int ?? 1000
    //        store.media.maximumTVShowRating = options["maximumTVShowRating"] as? Int ?? 1000
    //        store.gameCenter.denyMultiplayerGaming = options["denyMultiplayerGaming"] as? Bool ?? false
    //        store.gameCenter.denyAddingFriends = options["denyAddingFriends"] as? Bool ?? false
    //    }
}

@available(iOS 16.0, *)
extension DeviceActivityName {
    static let daily = Self("daily")
    static let weekly = Self("weekly")
}
