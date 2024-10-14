package com.hao.flutter_parental_control.db_helper

import com.hao.flutter_parental_control.utils.AppConstants
import io.realm.RealmList
import io.realm.RealmObject
import io.realm.annotations.Index
import io.realm.annotations.PrimaryKey
import org.bson.types.ObjectId

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

open class BlockRemoveApp : RealmObject() {
    @PrimaryKey
    var id: ObjectId = ObjectId()

    @Index
    var appName: String = AppConstants.EMPTY
    var blockedRemoveAppList: RealmList<BlockRemoveApp>? = RealmList()
}