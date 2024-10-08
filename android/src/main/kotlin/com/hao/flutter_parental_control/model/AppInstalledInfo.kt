package com.hao.flutter_parental_control.model


data class AppInstalledInfo(
    val isInstalled: Boolean,
    val packageName: String,
    val appName: String,
    val appIcon: ByteArray
) {
    fun toMap(): Map<String, Any> {
        return mapOf(
            "isInstalled" to isInstalled,
            "packageName" to packageName,
            "appName" to appName,
            "appIcon" to appIcon
        )
    }
}

