package mobile.bkav.db_helper

import android.content.Context
import io.realm.Realm
import io.realm.RealmList
import io.realm.RealmObject
import io.realm.annotations.Index
import io.realm.annotations.PrimaryKey
import mobile.bkav.manager.ManageApp
import mobile.bkav.models.OverlayInfo
import mobile.bkav.utils.AppConstants
import mobile.bkav.utils.Utils
import org.bson.types.ObjectId

object DBHelper {
    // Thêm danh sách tên ứng dụng bị chặn vào DB
    fun insertAppBlock(context: Context, appList: List<Map<String, Any>>, addNew: Boolean = false) {
        Realm.getDefaultInstance().use { realm ->
            realm.executeTransaction {
                if (!addNew) {
                    realm.delete(BlockedApp::class.java)
                }
                appList.forEach { map ->
                    // Chuyển map thành object để lưu vào Realm
                    val app = BlockedApp().fromMap(context, map)
                    if (app != null) realm.copyToRealmOrUpdate(app)
                }
            }
        }
    }

    // Kiểm tra xem ứng dụng bị chặn, dùng packageName
    fun getPackageAppBlock(context: Context, appName: String): String? {
        Realm.getDefaultInstance().use { realm ->
            val app: BlockedApp =
                realm.where(BlockedApp::class.java).equalTo(AppConstants.APP_NAME, appName)
                    .findFirst() ?: return null
            val timeLimit = app.timeLimit
            if (timeLimit == 0) return app.packageName
            val timeUse = ManageApp().getAppUsageTimeInMinutes(context, app.packageName)
            if (timeUse >= timeLimit) return app.packageName
            return null
        }
    }

    // Kiểm tra ứng dụng bị chặn dùng appName
    fun getAppBlock(context: Context, packageName: String): String? {
        Realm.getDefaultInstance().use { realm ->
            val app: BlockedApp =
                realm.where(BlockedApp::class.java).equalTo(AppConstants.PACKAGE_NAME, packageName)
                    .findFirst() ?: return null
            val timeLimit = app.timeLimit
            if (timeLimit == 0) return app.appName
            val timeUse = ManageApp().getAppUsageTimeInMinutes(context, packageName)
            if (timeUse >= timeLimit) return app.appName
            return null
        }
    }

    // Lưu ứng dụng nằm trong danh sách luôn được sử dụng
    fun insertAppAlwaysUse(context: Context, appList: List<String>) {
        Realm.getDefaultInstance().use { realm ->
            realm.executeTransaction {
                realm.delete(AppAlwaysAllow::class.java)
                appList.forEach { packageName ->
                    val appName = Utils().getAppName(context, packageName)
                    realm.copyToRealmOrUpdate(AppAlwaysAllow().apply {
                        this.packageName = packageName
                        this.appName = appName ?: AppConstants.EMPTY
                    })
                }
            }
        }
    }

    // Kiểm tra ứng dụng có nằm trong danh sách luôn được sử dụng không
    fun isAppAlwaysUse(appName: String): Boolean {
        Realm.getDefaultInstance().use { realm ->
            realm.where(AppAlwaysAllow::class.java).equalTo(AppConstants.APP_NAME, appName)
                .findFirst() ?: return false
            return true
        }
    }

    // Lấy thời gian sử dụng giới hạn của ứng dụng
    fun getTimeAppLimit(appName: String): Int {
        Realm.getDefaultInstance().use { realm ->
            val app: BlockedApp =
                realm.where(BlockedApp::class.java).equalTo(AppConstants.APP_NAME, appName)
                    .findFirst() ?: return 0
            return app.timeLimit
        }
    }

    // Thêm danh sách tên website bị chặn vào DB
    fun insertWebBlock(webList: List<String>, addNew: Boolean = false) {
        Realm.getDefaultInstance().use { realm ->
            realm.executeTransaction {
                if (!addNew) {
                    realm.delete(BlockedWebsite::class.java)
                }
                webList.forEach { webUrl ->
                    it.copyToRealmOrUpdate(BlockedWebsite().apply {
                        this.websiteUrl = webUrl
                    })
                }
            }
        }
    }

    // Kiểm tra URL có bị chặn hay không
    fun isUrlBlocked(webUrl: String): Boolean {
        Realm.getDefaultInstance().use { realm ->
            val blockedWebsites = realm.where(BlockedWebsite::class.java).findAll()
            return blockedWebsites.any { blockedSite ->
                val keywords = blockedSite.websiteUrl.split(" ")
                keywords.all { keyword -> webUrl.contains(keyword, ignoreCase = true) }
            }
        }
    }

    // Thêm lịch sử duyệt web của trẻ vào DB
    fun insertWebHistory(searchQuery: String) {
        Realm.getDefaultInstance().use { realm ->
            realm.executeTransaction {
                realm.copyToRealmOrUpdate(WebHistory().apply {
                    this.searchQuery = searchQuery
                    this.visitedTime = System.currentTimeMillis()
                })
            }
        }
    }

    // Lấy danh sách lịch sử duyệt web của trẻ
    fun getWebHistory(): List<Map<String, Any>> {
        Realm.getDefaultInstance().use { realm ->
            val webHistoryList = realm.where(WebHistory::class.java).findAll()
            return webHistoryList.map { it.toMap() }
        }
    }

    // Thêm overlay view vào DB
    fun insertOverlayView(
        id: Boolean,
        overlayView: String,
        nameBackButtonId: String,
        askParentBtnId: String? = null,
    ) {
        Realm.getDefaultInstance().use { realm ->
            realm.executeTransaction {
                realm.copyToRealmOrUpdate(OverlayView().apply {
                    this.id = if (id) 1 else 0
                    this.overlayView = overlayView
                    this.backBtnId = nameBackButtonId
                    this.askParentBtn = askParentBtnId
                })
            }
        }
    }

    // Lấy overlay view theo id, 1 là chặn ứng dụng, 0 là chặn xoá
    fun getOverlayView(isBlock: Boolean): OverlayInfo? {
        val id = if (isBlock) 1 else 0
        Realm.getDefaultInstance().use { realm ->
            val overlay =
                realm.where(OverlayView::class.java).equalTo(AppConstants.ID, id).findFirst()

            return overlay?.let {
                OverlayInfo(
                    overlayView = it.overlayView,
                    backBtnId = it.backBtnId,
                    askParentBtn = it.askParentBtn
                )
            }
        }
    }


    // Thêm thời gian cho phép sử dụng thiết bị trong ngày
    fun insertTimeAllowed(
        timeAllowed: Int? = null, timePeriod: List<Map<String, Any>>? = null
    ) {
        Realm.getDefaultInstance().use { realm ->
            realm.executeTransaction { transactionRealm ->
                val device = transactionRealm.where(TimeAllowedDevice::class.java)
                    .equalTo(AppConstants.ID, AppConstants.TIME_ALLOW).findFirst()

                val timePeriodList = timePeriod?.map { periodMap ->
                    TimePeriod().apply {
                        startTime = (periodMap["startTime"] as? Int) ?: 0
                        endTime = (periodMap["endTime"] as? Int) ?: 0
                    }
                }

                if (device != null) {
                    // Cập nhật đối tượng tồn tại
                    if (timeAllowed != null) device.timeAllowed = timeAllowed
                    if (timePeriodList != null) {
                        device.timePeriod.clear()
                        device.timePeriod.addAll(timePeriodList)
                    }
                } else {
                    // Tạo mới đối tượng nếu không tồn tại
                    transactionRealm.copyToRealmOrUpdate(TimeAllowedDevice().apply {
                        if (timeAllowed != null) this.timeAllowed = timeAllowed
                        if (timePeriodList != null) {
                            this.timePeriod.addAll(timePeriodList)
                        }
                    })
                }
            }
        }
    }

    // Kiểm tra xem còn được sử dụng màn hình không
    fun canUseDevice(context: Context): Boolean {
        Realm.getDefaultInstance().use { realm ->
            val timeAllowedDevice = realm.where(TimeAllowedDevice::class.java)
                .equalTo(AppConstants.ID, AppConstants.TIME_ALLOW).findFirst()

            // Thời gian sử dụng
            val timeUsed = ManageApp().getDeviceUsage(context)
            val isWithinTimeLimit = (timeAllowedDevice?.timeAllowed ?: 0) >= timeUsed

            // Khoảng thời gian sử dụng
            val currentTime = Utils().getCurrentMinutesOfDay()
            val isWithinAllowedPeriod = timeAllowedDevice?.timePeriod?.any { period ->
                currentTime in period.startTime..period.endTime
            } ?: true

            return isWithinTimeLimit && isWithinAllowedPeriod
        }
    }

}

// Các model tương ứng với các bảng trong DB
open class BlockedApp : RealmObject() {
    @PrimaryKey
    var packageName: String = AppConstants.EMPTY

    @Index
    var appName: String = AppConstants.EMPTY
    var timeLimit: Int = 0 // Bị chặn

    // Chuyển map thành object
    fun fromMap(context: Context, map: Map<String, Any>): BlockedApp? {
        val appName =
            Utils().getAppName(context, map[AppConstants.PACKAGE_NAME] as String) ?: return null
        return BlockedApp().apply {
            this.appName = appName
            this.packageName = map[AppConstants.PACKAGE_NAME] as String
            this.timeLimit = map[AppConstants.TIME_LIMIT] as Int
        }
    }
}

// Danh sách ứng dụng luôn được phép sử dụng
open class AppAlwaysAllow : RealmObject() {
    @PrimaryKey
    var packageName: String = AppConstants.EMPTY
    var appName: String = AppConstants.EMPTY
}

open class TimePeriod(
    @PrimaryKey var id: ObjectId = ObjectId(), var startTime: Int = 0,  // Thời gian bắt đầu
    var endTime: Int = 0     // Thời gian kết thúc
) : RealmObject()

open class TimeAllowedDevice : RealmObject() {
    @PrimaryKey
    var id: String = AppConstants.TIME_ALLOW
    var timeAllowed: Int = 1440
    var timePeriod: RealmList<TimePeriod> = RealmList()
}

open class BlockedWebsite : RealmObject() {
    @PrimaryKey
    var id: ObjectId = ObjectId()

    @Index
    var websiteUrl: String = AppConstants.EMPTY
}

open class WebHistory : RealmObject() {
    @PrimaryKey
    var id: ObjectId = ObjectId()

    @Index
    var searchQuery: String = AppConstants.EMPTY
    var visitedTime: Long = 0

    // chuyển thành map để gửi ra flutter
    fun toMap(): Map<String, Any> {
        return mapOf(
            AppConstants.SEARCH_QUERY to searchQuery,
            AppConstants.VISITED_TIME to visitedTime,
        )
    }
}

open class OverlayView : RealmObject() {
    @PrimaryKey
    var id: Int = 0

    @Index
    var overlayView: String = AppConstants.EMPTY
    var backBtnId: String = AppConstants.EMPTY
    var askParentBtn: String? = null
}