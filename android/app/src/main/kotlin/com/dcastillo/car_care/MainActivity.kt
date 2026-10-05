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

        // En arranque en frío, Flutter aún no ha montado la interfaz ni registrado
        // su handler de método. Guardamos el shortcut para que Flutter lo solicite
        // mediante getInitialShortcut una vez montado AppShell.
        val data = intent?.data
        if (data?.scheme == "carcare") {
            initialShortcut = data.host
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val data = intent.data
        if (data?.scheme == "carcare") {
            val host = data.host
            if (host != null) {
                channel?.invokeMethod("onShortcut", host)
            }
        }
    }
}
