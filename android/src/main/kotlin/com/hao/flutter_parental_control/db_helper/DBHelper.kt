package com.hao.flutter_parental_control.db_helper

import com.hao.flutter_parental_control.utils.AppConstants
import io.realm.Realm
import io.realm.RealmList
import io.realm.RealmObject
import io.realm.annotations.Index
import io.realm.annotations.PrimaryKey
import org.bson.types.ObjectId

object DBHelper {
    fun insertListAppBlock(appList: List<String>) {
        // Thêm danh sách tên ứng dụng bị chặn vào DB
        Realm.getDefaultInstance().use { realm ->
            realm.executeTransaction {
                realm.delete(BlockedApp::class.java)
                appList.forEach { appName ->
                    it.copyToRealmOrUpdate(BlockedApp().apply {
                        this.appName = appName
                        blockedAppList = RealmList()
                    })
                }
            }
        }
    }

    fun isAppBlocked(appName: String): Boolean {
        // Kiểm tra tên ứng dụng có bị chặn hay không
        Realm.getDefaultInstance().use { realm ->
            val blockedApp =
                realm.where(BlockedApp::class.java).equalTo(AppConstants.APP_NAME, appName).findFirst()
            return blockedApp != null
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

    fun isUrlBlocked(webUrl: String): Boolean {
        // Kiểm tra URL có bị chặn hay không
        Realm.getDefaultInstance().use { realm ->
            val blockedWebsites = realm.where(BlockedWebsite::class.java).findAll()
            return blockedWebsites.any { blockedSite ->
                webUrl.contains(blockedSite.websiteUrl, ignoreCase = true)
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
}

// Các model tương ứng với các bảng trong DB
open class BlockedApp : RealmObject() {
    @PrimaryKey
    var id: ObjectId = ObjectId()

    @Index
    var appName: String = AppConstants.EMPTY
    var blockedAppList: RealmList<BlockedApp>? = RealmList()
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