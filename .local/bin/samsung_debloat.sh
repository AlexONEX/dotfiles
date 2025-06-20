#!/bin/bash
echo "--- Starting Samsung S23 Comprehensive Debloating Process ---"
echo "Ensure your device is connected via USB and authorized (adb devices should show 'device')."
echo "This script will 'uninstall' (disable for user 0) specified packages."
echo "Review each line and comment out (#) any app you wish to keep."
echo "Press Enter to begin, or Ctrl+C to cancel."
read

# --- Samsung Bixby-Related Bloatware ---
adb shell pm uninstall -k --user 0 com.samsung.android.app.settings.bixby # SettingsBixby
adb shell pm uninstall -k --user 0 com.samsung.android.bixby.wakeup # Voice wake-up
adb shell pm uninstall -k --user 0 com.samsung.android.bixby.agent # Bixby Voice
adb shell pm uninstall -k --user 0 com.samsung.android.bixbyvision.framework # Bixby Vision

# --- General System Bloatware on Samsung ---
adb shell pm uninstall -k --user 0 com.sec.android.app.shealth # Samsung Health (keep if you use it)
adb shell pm uninstall -k --user 0 com.samsung.android.arzone # AR Zone
adb shell pm uninstall -k --user 0 com.samsung.android.video # Video Player (keep if you use Samsung's video player)
adb shell pm uninstall -k --user 0 com.sec.android.app.samsungapps # Galaxy Store (remove if you only use Google Play Store)
adb shell pm uninstall -k --user 0 com.samsung.android.dynamiclock # Wallpaper services
adb shell pm uninstall -k --user 0 com.samsung.android.tvplus # Samsung TV+
adb shell pm uninstall -k --user 0 com.samsung.android.app.watchmanagerstub # Wearable Manager Installer (keep if you use Galaxy Wearables)
adb shell pm uninstall -k --user 0 com.samsung.android.app.watchmanager # Galaxy Wearable (keep if you use Galaxy Wearables)
adb shell pm uninstall -k --user 0 com.samsung.android.waterplugin # Galaxy Watch Manager (keep if you use Galaxy Watch)
adb shell pm uninstall -k --user 0 com.samsung.android.accessibility.talkback # Talkback (accessibility service, keep unless you know you don't need it)
adb shell pm uninstall -k --user 0 com.samsung.android.lool # Device Care (provides battery, storage, memory management - often useful)
adb shell pm uninstall -k --user 0 com.samsung.android.messaging # Message app (keep if you use Samsung's default messaging app)
adb shell pm uninstall -k --user 0 com.sec.android.easyonehand # EasyOneHand (keep if you use one-hand mode)
adb shell pm uninstall -k --user 0 com.sec.android.app.sbrowser # Samsung Internet (keep if you use Samsung's browser)
adb shell pm uninstall -k --user 0 com.sec.android.easyMover.Agent # Smart Switch Agent (only needed for Smart Switch transfers)
adb shell pm uninstall -k --user 0 com.sec.android.daemonapp # Weather (keep if you use Samsung Weather)
adb shell pm uninstall -k --user 0 com.sec.android.app.voicenote # Voice Recorder (keep if you use Samsung Voice Recorder)
adb shell pm uninstall -k --user 0 com.samsung.android.oneconnect # Smart Things (keep if you use Smart Things for smart home devices)
adb shell pm uninstall -k --user 0 com.samsung.android.voc # Samsung Members
adb shell pm uninstall -k --user 0 com.samsung.android.calendar # Samsung Calendar (keep if you use Samsung Calendar, remove if you use Google Calendar exclusively)
adb shell pm uninstall -k --user 0 com.sec.android.app.popupcalculator # Samsung Calculator (keep if you use Samsung Calculator)
adb shell pm uninstall -k --user 0 com.samsung.android.app.dressroom # Wallpaper and style
adb shell pm uninstall -k --user 0 com.samsung.android.scloud # Samsung Cloud (keep if you use Samsung Cloud for backup)
adb shell pm uninstall -k --user 0 com.samsung.android.sdk.handwriting # HandwritingService
adb shell pm uninstall -k --user 0 com.samsung.android.universalswitch # Mobile Universal Switch
adb shell pm uninstall -k --user 0 com.samsung.safetyinformation # Safety Information
adb shell pm uninstall -k --user 0 com.samsung.storyservice # Gallery stories
adb shell pm uninstall -k --user 0 com.samsung.android.service.aircommand # Air command (S-Pen related, remove if you don't use S-Pen features)
adb shell pm uninstall -k --user 0 com.samsung.android.app.aodservice # AlwaysOnDisplay (keep if you use AOD)

# --- Samsung Pay & Samsung Pass (Only remove if you DO NOT use these services!) ---
adb shell pm uninstall -k --user 0 com.samsung.android.samsungpassautofill # Autofill with Samsung Pass
adb shell pm uninstall -k --user 0 com.samsung.android.samsungpass # Samsung Pass
adb shell pm uninstall -k --user 0 com.samsung.android.spay # Samsung Wallet
adb shell pm uninstall -k --user 0 com.samsung.android.spayfw # Samsung Pay Framework
adb shell pm uninstall -k --user 0 com.samsung.android.da.daagent # Dual Messenger (keep if you use dual apps)

# --- Samsung AR Emoji (Only remove if you DO NOT use AR Emojis) ---
adb shell pm uninstall -k --user 0 com.samsung.android.aremoji # AR Emoji
adb shell pm uninstall -k --user 0 com.sec.android.mimage.avatarstickers # Stickers for AR Emoji app
adb shell pm uninstall -k --user 0 com.samsung.android.aremojieditor # AR Emoji Editor
adb shell pm uninstall -k --user 0 com.samsung.android.stickercenter # Sticker Center

# --- Facebook Bloatware (Often pre-installed system apps by Samsung) ---
adb shell pm uninstall -k --user 0 com.facebook.system # Facebook spyware
adb shell pm uninstall -k --user 0 com.facebook.appmanager
adb shell pm uninstall -k --user 0 com.facebook.services

# --- Printing Service Components (Remove if you DO NOT print from your phone) ---
adb shell pm uninstall -k --user 0 com.android.bips # Default print service
adb shell pm uninstall -k --user 0 com.google.android.printservice.recommendation

# --- Game Launcher & Settings (Remove if you DO NOT game on your phone or use these features) ---
adb shell pm uninstall -k --user 0 com.samsung.android.game.gametools # Game Booster
adb shell pm uninstall -k --user 0 com.samsung.android.game.gos # Game Optimizing Service

# --- Samsung Kids Mode (Remove if you DO NOT use Kids Mode) ---
adb shell pm uninstall -k --user 0 com.samsung.android.kidsinstaller # Kids Mode
adb shell pm uninstall -k --user 0 com.samsung.android.app.camera.sticker.facearavatar.preload # Crocro and friends

# --- Edge Display (Remove if you DO NOT use the Edge Panels or related features) ---
adb shell pm uninstall -k --user 0 com.samsung.android.service.peoplestripe # Edge panel plugin for contacts
adb shell pm uninstall -k --user 0 com.samsung.android.app.appsedge # Apps plugin for Edge display

# --- Samsung Dex (Remove if you DO NOT use Samsung Dex) ---
adb shell pm uninstall -k --user 0 com.sec.android.dexsystemui # Samsung DeX System UI
adb shell pm uninstall -k --user 0 com.sec.android.desktopmode.uiservice # Samsung DeX
adb shell pm uninstall -k --user 0 com.sec.android.app.desktoplauncher # Samsung DeX home

# --- Verizon Bloatware List (Remove only if you are on Verizon and don't use these services) ---
adb shell pm uninstall -k --user 0 com.vcast.mediamanager # Verizon Cloud
adb shell pm uninstall -k --user 0 com.samsung.vmmhux
adb shell pm uninstall -k --user 0 com.vzw.hss.myverizon # My Verizon
adb shell pm uninstall -k --user 0 com.asurion.android.verizon.vms # Digital Secure
adb shell pm uninstall -k --user 0 com.motricity.verizon.ssodownloadable # Verizon Login
adb shell pm uninstall -k --user 0 com.vzw.hs.android.modlite # Verizon Tones
adb shell pm uninstall -k --user 0 com.samsung.vvm # Visual Voicemail (if you use Verizon's Visual Voicemail)
# adb shell pm uninstall -k --user 0 com.vznavigator.[You_Model_Here] # VZ Navigator (replace [You_Model_Here] with actual model if present)

# --- AT&T Bloatware List (Remove only if you are on AT&T and don't use these services) ---
adb shell pm uninstall -k --user 0 com.att.dh # Device Help
adb shell pm uninstall -k --user 0 com.att.dtv.shaderemote # DIRECTV Remote App
adb shell pm uninstall -k --user 0 com.att.tv # AT&T TV
adb shell pm uninstall -k --user 0 com.samsung.attvvm # Samsung AT&T Visual Voicemail (if you use AT&T's Visual Voicemail)
adb shell pm uninstall -k --user 0 com.att.myWireless # myAT&T
adb shell pm uninstall -k --user 0 com.asurion.android.protech.att # AT&T ProTech
adb shell pm uninstall -k --user 0 com.att.android.attsmartwifi # AT&T Smart Wi-Fi

# --- Miscellaneous Samsung Bloatware List (Found on AT&T/US variants - remove if you don't use them) ---
adb shell pm uninstall -k --user 0 com.synchronoss.dcs.att.r2g
adb shell pm uninstall -k --user 0 com.wavemarket.waplauncher
adb shell pm uninstall -k --user 0 com.pandora.android # Pandora (if pre-installed and you don't use it)
adb shell pm uninstall -k --user 0 com.sec.penup # Pen Up (S-Pen related, remove if you don't use it)
adb shell pm uninstall -k --user 0 com.wb.goog.got.conquest # Game: Game of Thrones
adb shell pm uninstall -k --user 0 com.playstudios.popslots # Game: Pop Slots
adb shell pm uninstall -k --user 0 com.gsn.android.tripeaks # Game: TriPeaks Solitaire
adb shell pm uninstall -k --user 0 com.foxnextgames.m3 # Game
adb shell pm uninstall -k --user 0 com.microsoft.skydrive # Microsoft OneDrive (remove if you don't use OneDrive)

echo "--- Debloating script completed. ---"
echo "It's recommended to reboot your device now: adb reboot"
