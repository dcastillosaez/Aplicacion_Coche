package com.dcastillo.car_care

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.dcastillo.car_care/shortcuts"
    private var channel: MethodChannel? = null
    private var initialShortcut: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                if (call.method == "getInitialShortcut") {
                    result.success(initialShortcut)
                    initialShortcut = null
                } else {
                    result.notImplemented()
                }
            }
        }
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val data = intent?.data
        val host = if (data?.scheme == "carcare") data.host else null
        if (host != null) {
            val ch = channel
            if (ch != null) {
                ch.invokeMethod("onShortcut", host)
            } else {
                initialShortcut = host
            }
        }
    }
}
