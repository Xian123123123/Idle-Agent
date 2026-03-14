package com.idleagent.idle_agent

import android.service.dreams.DreamService
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

class IdleAgentDream : DreamService() {

    private var flutterEngine: FlutterEngine? = null

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()

        isInteractive = false
        isFullscreen = true

        window?.addFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        flutterEngine = FlutterEngine(this)
        flutterEngine!!.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )

        val flutterView = FlutterView(this)
        flutterView.attachToFlutterEngine(flutterEngine!!)
        setContentView(flutterView)
    }

    override fun onDreamingStarted() {
        super.onDreamingStarted()
    }

    override fun onDreamingStopped() {
        super.onDreamingStopped()
    }

    override fun onDetachedFromWindow() {
        flutterEngine?.destroy()
        flutterEngine = null
        super.onDetachedFromWindow()
    }
}
