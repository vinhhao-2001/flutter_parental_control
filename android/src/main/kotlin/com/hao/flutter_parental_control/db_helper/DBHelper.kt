package com.hao.flutter_parental_control.db_helper

import com.hao.flutter_parental_control.utils.AppConstants
import io.realm.Realm
import io.realm.RealmList

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