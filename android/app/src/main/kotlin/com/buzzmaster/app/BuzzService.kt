package com.buzzmaster.app

import android.app.Service
import android.content.Intent
import android.os.IBinder

/**
 * Background service that keeps the network socket alive
 * when the app is backgrounded.
 */
class BuzzService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }
}
