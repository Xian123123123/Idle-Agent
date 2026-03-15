# Idle Agent — Project Status

## What Was Built

A fully functional Android screensaver app that displays simulated AI coding terminals when the phone is idle or charging. Built with Flutter 3.x, Riverpod, and Android's DreamService API.

### Completed Features

- **4 AI Agents** — GPT-Engineer (free), Research-Agent, DevOps-Agent, Startup-CTO (Pro)
- **16 Unique Scenarios** — each agent has 4 scenarios with randomized tokens (project names, modules, functions, error messages) so every run looks different
- **5 Terminal Themes** — Hacker Green (free), Cyberpunk Neon, Minimal Dark, AI Research Lab, Retro UNIX (Pro)
- **Terminal Renderer** — custom `CustomPainter` with per-line syntax coloring, blinking cursor, scanline CRT overlay effect
- **Simulation Engine** — streaming architecture using Dart `StreamController`, configurable speed (0.5x–4x), auto-cycles through scenarios with pauses between them
- **Settings Screen** — agent selection, theme preview, speed control, language selector, battery pause threshold slider, all persisted via `SharedPreferences`
- **Onboarding Flow** — 3-page intro shown only on first launch
- **Paywall Screen** — Pro unlock UI with mock purchase logic (ready for RevenueCat integration)
- **Battery Optimization** — pauses simulation when battery drops below threshold, auto-resumes when charging detected
- **Android DreamService** — native screensaver integration via Kotlin `IdleAgentDream` class, registered in AndroidManifest
- **App Icon** — programmatically generated adaptive launcher icons for all densities
- **Release APK** — builds successfully at 44.7MB

### Tech Stack

- Flutter 3.41.4 / Dart
- flutter_riverpod for state management
- shared_preferences for persistence
- battery_plus for battery monitoring
- purchases_flutter (RevenueCat) for IAP (mock for now)
- google_fonts for JetBrains Mono
- Custom `CustomPainter` for terminal rendering

### Git History

15 commits, one per phase (Phase 0–15), all passing `flutter analyze` with zero errors.

---

## The Main Challenge

### DreamService Is Effectively Broken for Real Users

Android's `DreamService` API is the intended mechanism for screensaver apps. In theory, users go to **Settings → Display → Screen Saver**, select "Idle Agent", and it activates automatically when charging.

**In practice, this fails for most users:**

1. **OEM manufacturers hide or remove the setting.** Xiaomi (MIUI/HyperOS), Samsung (One UI), Huawei (EMUI), Oppo (ColorOS), and other major OEMs frequently remove the Screen Saver / Daydream settings page entirely. These brands collectively represent 60%+ of the global Android market.

2. **The setting is hard to find even on stock Android.** It's buried under Settings → Display → Screen Saver, which most users have never seen or heard of. There is no standardized path across Android versions.

3. **No programmatic way to enable it.** An app cannot register itself as the active DreamService without user action. At best, you can open the settings page via intent — but if the OEM removed that page, the intent fails or shows a blank screen.

4. **The standalone app doesn't solve the problem.** If Idle Agent runs as a regular foreground app, the screen turns off after the system timeout, killing the animation. This defeats the entire purpose of a screensaver.

### Summary

The app works perfectly as built. The problem is not technical — it's a platform limitation. Android's screensaver API exists but is practically inaccessible to end users on most devices.

---

## Recommendations

### Option A: Keep Screen On via WakeLock (Simplest)

Add a `KEEP_SCREEN_ON` flag or `WakeLock` when the app is in the foreground. The user opens Idle Agent, plugs in their charger, and the terminal runs indefinitely without the screen turning off.

**Pros:** Works on every Android device. No DreamService setup needed. Simple to implement.
**Cons:** User must manually open the app. Not a true screensaver — more of a "desk display" mode. Battery drain if not plugged in (mitigated by existing battery pause feature).

**Implementation:** Add `wakelock` package, acquire wake lock when app is in foreground and optionally only when charging.

### Option B: Foreground Service + Overlay (Most Ambitious)

Run a foreground service that detects when the phone is charging and the screen is locked, then displays a system overlay with the terminal animation.

**Pros:** True auto-activation without DreamService. Works on all OEMs.
**Cons:** Requires `SYSTEM_ALERT_WINDOW` permission (user must grant manually). Foreground service shows a persistent notification. Some OEMs aggressively kill background services. More complex to build and maintain.

### Option C: Live Wallpaper Instead of Screensaver (Pivot)

Reframe the app as a live wallpaper rather than a screensaver. Android's `WallpaperService` API is well-supported across all OEMs and easy for users to activate (long-press home → Wallpapers).

**Pros:** Works everywhere. Users know how to change wallpapers. Always visible on home/lock screen.
**Cons:** Different product concept — always-on rather than idle-activated. May drain battery if animation runs continuously (can be mitigated by only animating when screen is on).

### Option D: DreamService + WakeLock Fallback (Recommended)

Keep DreamService for stock Android / Pixel users where it works, but make WakeLock the default experience:

1. App opens → terminal runs fullscreen with screen kept on
2. Add a "Desk Mode" toggle that acquires wake lock (keep screen on indefinitely)
3. In Settings, add an "Enable Screensaver" button that attempts to open DreamService settings via intent
4. If the intent fails or user is confused, they already have Desk Mode as the primary experience

**This is the recommended approach** because it works for 100% of users out of the box, while still offering the native screensaver for those who can access it.

---

## Remaining Work

- [ ] Implement WakeLock / Desk Mode (Option D)
- [ ] Integrate RevenueCat for real IAP (replace mock purchase)
- [ ] Add "Enable Screensaver" button with intent + fallback messaging
- [ ] Test on physical devices across OEMs (Samsung, Xiaomi, Pixel, OnePlus)
- [ ] Play Store listing screenshots
- [ ] Privacy policy page
- [ ] Onboarding swipe — currently uses PageView but needs gesture hint on first page
