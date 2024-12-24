package mobile.bkav.manager

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import mobile.bkav.db_helper.DBHelper
import mobile.bkav.overlay.Overlay
import java.util.concurrent.TimeUnit

class TimeCheckWorker(
    context: Context,
    workerParams: WorkerParameters
) : CoroutineWorker(context, workerParams) {

    override suspend fun doWork(): Result {
        val timeUsed = ManagerApp().getDeviceUsage(applicationContext)
        val timeAllow = DBHelper.getTimeAllow()

        if (timeAllow != null) {
            val periodValid = DBHelper.isTimeAllowedValid()
            if (timeAllow * 60000 > timeUsed && periodValid) {
                val delayTime = (timeAllow * 60000 - timeUsed)
                setWorkRequestDelay(delayTime)
                return Result.success()
            } else {
                withContext(Dispatchers.Main) {
                    Overlay(applicationContext).showExpiredTimeOverlay()
                }
                return Result.failure()
            }
        }
        return Result.failure()
    }

    private fun setWorkRequestDelay(delayTime: Long) {
        val workRequest = OneTimeWorkRequestBuilder<TimeCheckWorker>()
            .setInitialDelay(delayTime, TimeUnit.MILLISECONDS)
            .build()
        WorkManager.getInstance(applicationContext).enqueue(workRequest)
    }
}
