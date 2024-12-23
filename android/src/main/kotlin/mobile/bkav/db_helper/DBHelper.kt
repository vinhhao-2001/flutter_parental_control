package mobile.bkav.db_helper

import android.content.Context
import io.realm.Realm
import io.realm.RealmList
import io.realm.RealmObject
import io.realm.annotations.Index
import io.realm.annotations.PrimaryKey
import mobile.bkav.utils.AppConstants
import mobile.bkav.utils.Utils
import org.bson.types.ObjectId

object DBHelper {
    fun insertListAppBlock(context: Context, appList: List<Map<String, Any>>) {
        // Thêm danh sách tên ứng dụng bị chặn vào DB
        Realm.getDefaultInstance().use { realm ->
            realm.executeTransaction {
                realm.delete(BlockedApp::class.java)
                appList.forEach { map ->
                    // Chuyển map thành object để lưu vào Realm
                    val app = BlockedApp().fromMap(context, map)
                    if (app != null)
                        realm.copyToRealmOrUpdate(app)
                }
            }
        }
    }

    fun insertNewAppBlock(context: Context, appList: List<Map<String, Any>>) {
        // Thêm danh sách tên ứng dụng bị chặn vào DB
        Realm.getDefaultInstance().use { realm ->
            realm.executeTransaction {
                appList.forEach { map ->
                    // Chuyển map thành object để lưu vào Realm
                    val app = BlockedApp().fromMap(context, map)
                    if (app != null)
                        realm.copyToRealmOrUpdate(app)
                }
            }
        }
    }


    fun isAppBlocked(context: Context, appName: String): String? {
        // Kiểm tra xem ứng dụng bị chặn không
        Realm.getDefaultInstance().use { realm ->
            val app: BlockedApp = realm.where(BlockedApp::class.java)
                .equalTo(AppConstants.APP_NAME, appName)
                .findFirst() ?: return null
            val timeLimit = app.timeLimit
            if (timeLimit == 0) return app.packageName
            val timeUse = Utils().getAppUsageTimeInMinutes(context, app.packageName)
            if (timeUse >= timeLimit) return app.packageName
            return null
        }
    }

    // Lấy thời gian sử dụng giới hạn của ứng dụng
    fun getTimeAppLimit(appName: String): Int? {
        Realm.getDefaultInstance().use { realm ->
            val app: BlockedApp = realm.where(BlockedApp::class.java)
                .equalTo(AppConstants.APP_NAME, appName)
                .findFirst() ?: return null
            return app.timeLimit
        }
    }

    fun insertListWebBlock(webList: List<String>) {
        // Thêm danh sách tên website bị chặn vào DB
        Realm.getDefaultInstance().use { realm ->
            realm.executeTransaction {
                realm.delete(BlockedWebsite::class.java)
                webList.forEach { webUrl ->
                    it.copyToRealmOrUpdate(BlockedWebsite().apply {
                        this.websiteUrl = webUrl
                        blockedWebsiteList = RealmList()
                    })
                }
            }
        }
    }

    fun insertNewWebBlock(webList: List<String>) {
        // Thêm danh sách tên website bị chặn vào DB
        Realm.getDefaultInstance().use { realm ->
            realm.executeTransaction {
                webList.forEach { webUrl ->
                    it.copyToRealmOrUpdate(BlockedWebsite().apply {
                        this.websiteUrl = webUrl
                        blockedWebsiteList = RealmList()
                    })
                }
            }
        }
    }

    fun isUrlBlocked(webUrl: String): Boolean {
        // Kiểm tra URL có bị chặn hay không
        Realm.getDefaultInstance().use { realm ->
            val blockedWebsites = realm.where(BlockedWebsite::class.java).findAll()
            return blockedWebsites.any { blockedSite ->
                val keywords = blockedSite.websiteUrl.split(" ")
                keywords.all { keyword -> webUrl.contains(keyword, ignoreCase = true) }
            }
        }
    }

    fun insertWebHistory(searchQuery: String) {
        // Thêm lịch sử duyệt web của trẻ vào DB
        Realm.getDefaultInstance().use { realm ->
            realm.executeTransaction {
                realm.copyToRealmOrUpdate(WebHistory().apply {
                    this.searchQuery = searchQuery
                    this.visitedTime = System.currentTimeMillis()
                })
            }
        }
    }

    fun getWebHistory(): List<Map<String, Any>> {
        // Lấy danh sách lịch sử duyệt web của trẻ
        Realm.getDefaultInstance().use { realm ->
            val webHistoryList = realm.where(WebHistory::class.java).findAll()
            return webHistoryList.map { it.toMap() }
        }
    }

    fun insertOverlayView(
        id: Boolean,
        overlayView: String,
        nameBackButtonId: String,
        nameAskParentBtnId: String? = null,
    ) {
        // Thêm overlay view vào DB
        Realm.getDefaultInstance().use { realm ->
            realm.executeTransaction {
                realm.copyToRealmOrUpdate(OverlayView().apply {
                    this.id = if (id) 1 else 0
                    this.overlayView = overlayView
                    this.backBtnId = nameBackButtonId
                    this.askParentBtn = nameAskParentBtnId
                    this.overlayViewList = RealmList()
                })
            }
        }
    }

    fun getOverlayView(isBlock: Boolean): OverlayView? {
        // Lấy overlay view theo id,
        val id = if (isBlock) 1 else 0
        val realm = Realm.getDefaultInstance()
        return realm.where(OverlayView::class.java).equalTo(AppConstants.ID, id)
            .findFirst()
    }
}

// Các model tương ứng với các bảng trong DB
open class BlockedApp : RealmObject() {
    @PrimaryKey
    var packageName: String = AppConstants.EMPTY
    @Index
    var appName: String = AppConstants.EMPTY

    var timeLimit: Int = 0 // Bị chặn
    private var blockedAppList: RealmList<BlockedApp>? = RealmList()

    // Chuyển map thành object
    fun fromMap(context: Context, map: Map<String, Any>): BlockedApp? {
        val appName =
            Utils().getAppName(context, map[AppConstants.PACKAGE_NAME] as String) ?: return null
        return BlockedApp().apply {
            this.appName = appName
            this.packageName = map[AppConstants.PACKAGE_NAME] as String
            this.timeLimit = map[AppConstants.TIME_LIMIT] as Int
            blockedAppList = RealmList()
        }
    }
}

open class BlockedWebsite : RealmObject() {
    @PrimaryKey
    var id: ObjectId = ObjectId()

    @Index
    var websiteUrl: String = AppConstants.EMPTY
    var blockedWebsiteList: RealmList<BlockedWebsite>? = RealmList()
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
    var overlayViewList: RealmList<OverlayView>? = RealmList()
}