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
adb shell pm uninstall -k --user 0 com.samsung.android.smartswitchassistant
adb shell pm uninstall -k --user 0 com.sec.android.app.myfiles

# --- General System Bloatware on Samsung ---
adb shell pm uninstall -k --user 0 com.sec.android.app.shealth # Samsung Health (keep if you use it)
adb shell pm uninstall -k --user 0 com.samsung.android.arzone # AR Zone
adb shell pm uninstall -k --user 0 com.samsung.android.video # Video Player (keep if you use Samsung's video player)
adb shell pm uninstall -k --user 0 com.sec.android.app.samsungapps # Galaxy Store (remove if you only use Google Play Store)
adb shell pm uninstall --user 0 com.google.android.apps.messaging
adb shell pm uninstall --user 0 com.google.android.apps.bard
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

# --- Google Assistant & Voice Input ---
adb shell pm uninstall -k --user 0 com.android.hotwordenrollment.xgoogle # Google Assistant
adb shell pm uninstall -k --user 0 com.android.hotwordenrollment.okgoogle # Google Assistant
adb shell pm uninstall -k --user 0 com.samsung.android.svoiceime # Samsung voice input
adb shell pm uninstall -k --user 0 com.google.android.tts # Speech Services by Google

# --- Google Services & Bloatware ---
adb shell pm uninstall --user 0 com.android.chrome # Chrome (keep if you use it)
adb shell pm uninstall --user 0 com.google.android.gmsintegration # Google Services Integration
adb shell pm uninstall --user 0 com.google.android.webview # Google WebView
adb shell pm uninstall --user 0 com.google.android.feedback # Google Feedback
adb shell pm uninstall --user 0 com.google.android.partnersetup # Google Partner Setup
adb shell pm uninstall -k --user 0 com.google.android.as # Android System Intelligence (data collection)
adb shell pm uninstall -k --user 0 com.google.android.apps.restore # Data Restore Tool
adb shell pm uninstall -k --user 0 com.google.android.apps.turbo # Device Health Services (data collection)
adb shell pm uninstall -k --user 0 com.google.android.gms.location.history # Google Location History
adb shell pm uninstall -k --user 0 com.google.android.setupwizard # Android Setup
adb shell pm uninstall -k --user 0 com.google.android.egg # Android Easter Egg
adb shell pm uninstall -k --user 0 com.google.android.syncadapters.calendar # Google Calendar Sync (keep if you use it)
adb shell pm uninstall -k --user 0 com.google.android.syncadapters.contacts # Google Contacts Sync (keep if you use it)
adb shell pm uninstall -k --user 0 com.google.audio.hearing.visualization.accessibility.scribe # Live Transcribe
adb shell pm uninstall --user 0 com.google.android.gm # Gmail
adb shell pm uninstall --user 0 com.google.android.youtube # YouTube
adb shell pm uninstall --user 0 com.google.android.gsf # Google Service Framework (critical - use with caution)
adb shell pm uninstall --user 0 com.google.android.gms # Google Play Services (critical - use with caution)
adb shell pm uninstall --user 0 com.google.android.backuptransport # Google Backup Transport

# --- Accessibility & Features ---
adb shell pm uninstall -k --user 0 com.sec.provides.assisteddialing # Assisted Dialing
adb shell pm uninstall -k --user 0 com.samsung.android.app.readingglass # Magnify
adb shell pm uninstall -k --user 0 com.sec.android.app.magnifier # Magnifier
adb shell pm uninstall -k --user 0 com.samsung.android.forest # Digital Wellbeing

# --- Samsung Eye Comfort & Audio ---
adb shell pm uninstall -k --user 0 com.samsung.android.bluelightfilter # Eye comfort shield
adb shell pm uninstall -k --user 0 com.sec.android.app.soundalive # SoundAlive
adb shell pm uninstall -k --user 0 com.sec.hearingadjust # Adapt Sound

# --- Samsung Health & Fitness ---
adb shell pm uninstall -k --user 0 com.samsung.android.service.health # Health Platform (Samsung Health related)

# --- Samsung Finder & Search ---
adb shell pm uninstall -k --user 0 com.samsung.android.app.galaxyfinder # Finder (duplicates built-in search)

# --- Samsung Sharing & Connectivity ---
adb shell pm uninstall -k --user 0 com.samsung.android.allshare.service.mediashare # Nearby Service
adb shell pm uninstall -k --user 0 com.samsung.android.allshare.service.fileshare # Wi-Fi Direct
adb shell pm uninstall -k --user 0 com.samsung.android.app.simplesharing # Link Sharing
adb shell pm uninstall -k --user 0 com.samsung.android.aware.service # Quick Share
adb shell pm uninstall -k --user 0 com.samsung.android.app.sharelive # Quick Share
adb shell pm uninstall -k --user 0 com.samsung.android.mdx # Link to Windows Service (Your Phone)
adb shell pm uninstall -k --user 0 com.samsung.android.mdx.quickboard # Media and devices
adb shell pm uninstall -k --user 0 com.samsung.android.smartmirroring # Smart View
adb shell pm uninstall -k --user 0 com.samsung.android.mobileservice # Group Sharing

# --- Samsung SmartThings & Home ---
adb shell pm uninstall -k --user 0 com.samsung.android.service.stplatform # SmartThings Framework
adb shell pm uninstall -k --user 0 com.samsung.android.beaconmanager # Nearby device scanning
adb shell pm uninstall -k --user 0 com.samsung.android.easysetup # Nearby device scanning

# --- Samsung Personalization ---
adb shell pm uninstall -k --user 0 com.samsung.android.rubin.app # Customization Service
adb shell pm uninstall -k --user 0 com.samsung.android.livestickers # DECO PIC
adb shell pm uninstall -k --user 0 com.samsung.android.app.taskedge # Tasks edge panel
adb shell pm uninstall -k --user 0 com.samsung.android.app.clipboardedge # Clipboard edge
adb shell pm uninstall -k --user 0 com.sec.android.app.quicktool # Tools edge panel
adb shell pm uninstall -k --user 0 com.samsung.android.app.reminder # Reminder

# --- Microsoft Services ---
adb shell pm uninstall -k --user 0 com.microsoft.appmanager # Your Phone Companion

# --- Samsung Pass & Payment ---
adb shell pm uninstall -k --user 0 com.samsung.android.samsunpass # Samsung Pass (alternative package name)
adb shell pm uninstall -k --user 0 com.samsung.android.dkey # Samsung Pass
adb shell pm uninstall -k --user 0 com.samsung.android.carkey # Samsung Pass_DKFW

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
adb shell pm uninstall -k --user 0 com.samsung.android.game.gamehome

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

# --- Additional Samsung Bloatware (From comprehensive list) ---
adb shell pm uninstall -k --user 0 com.samsung.aasaservice # AASAService
adb shell pm uninstall -k --user 0 com.samsung.bbc.bbcagent # BBCAgent
adb shell pm uninstall -k --user 0 com.sec.android.app.chromecustomizations # ChromeCustomizations
adb shell pm uninstall -k --user 0 com.android.providers.partnerbookmarks # Partner Bookmarks Provider
adb shell pm uninstall -k --user 0 com.android.sharedstoragebackup # Shared Storage Backup
adb shell pm uninstall -k --user 0 com.android.wallpapercropper # Wallpaper Cropper
adb shell pm uninstall -k --user 0 com.sec.bcservice # BC Service
adb shell pm uninstall -k --user 0 com.sec.factory # DeviceTest
adb shell pm uninstall -k --user 0 com.sec.epdgtestapp # EpdgTestApp
adb shell pm uninstall -k --user 0 com.android.wallpaper.livepicker # Live Wallpaper Picker
adb shell pm uninstall -k --user 0 com.android.dreams.phototable # Photo Screensavers
adb shell pm uninstall -k --user 0 com.android.printspooler # Print Spooler
adb shell pm uninstall -k --user 0 com.sec.android.app.SecSetupWizard # Samsung Setup Wizard
adb shell pm uninstall -k --user 0 com.sec.android.mimage.photoretouching # Photo Editor
adb shell pm uninstall -k --user 0 com.sec.android.app.billing # Samsung Checkout
adb shell pm uninstall -k --user 0 com.sec.spp.push # Samsung Push Service
adb shell pm uninstall -k --user 0 com.samsung.SMT # Samsung text-to-speech engine
adb shell pm uninstall -k --user 0 com.samsung.android.fmm # Find My Mobile
adb shell pm uninstall -k --user 0 com.sec.android.widgetapp.easymodecontactswidget # Favorite Contacts
adb shell pm uninstall -k --user 0 com.samsung.android.app.dofviewer # Portrait (portrait mode editing)
adb shell pm uninstall -k --user 0 com.samsung.android.privateshare # Private Share
adb shell pm uninstall -k --user 0 com.samsung.android.app.omcagent # Recommended apps
adb shell pm uninstall -k --user 0 com.samsung.android.coldwalletservice # Samsung Blockchain Keystore
adb shell pm uninstall -k --user 0 com.sec.android.app.ve.vebgm # Samsung Editing Assets
adb shell pm uninstall -k --user 0 com.samsung.android.app.spage # Samsung Free
adb shell pm uninstall -k --user 0 com.samsung.android.ipsgeofence # Samsung Visit In
adb shell pm uninstall -k --user 0 com.samsung.android.net.wifi.wifiguider # Wi-Fi Tips
adb shell pm uninstall -k --user 0 com.sec.location.nsflp2 # Samsung Location SDK
adb shell pm uninstall -k --user 0 com.samsung.android.location # slocation
adb shell pm uninstall -k --user 0 com.samsung.android.smartcallprovider # Smart Call
adb shell pm uninstall -k --user 0 com.samsung.android.smartface # SmartFaceService
adb shell pm uninstall -k --user 0 com.sec.android.app.safetyassurance # Send SOS messages
adb shell pm uninstall -k --user 0 com.samsung.android.app.soundpicker # Sound picker
adb shell pm uninstall -k --user 0 com.samsung.android.service.tagservice # Tags
adb shell pm uninstall -k --user 0 com.android.apps.tag # Tags
adb shell pm uninstall -k --user 0 com.samsung.android.service.airviewdictionary # Translate
adb shell pm uninstall -k --user 0 com.samsung.android.vtcamerasettings # Video call effects
adb shell pm uninstall -k --user 0 com.samsung.android.knox.containercore # Work Profile
adb shell pm uninstall -k --user 0 com.samsung.android.knox.containeragent # Work Profile
adb shell pm uninstall -k --user 0 com.android.managedprovisioning # Work Setup
adb shell pm uninstall -k --user 0 com.android.dreams.basic # Basic Daydreams
adb shell pm uninstall -k --user 0 com.diotek.sec.lookup.dictionary # Dictionary
adb shell pm uninstall -k --user 0 com.sec.mhs.smarttethering # Auto Hotspot
adb shell pm uninstall -k --user 0 com.sec.android.autodoodle.service # AutoDoodle
adb shell pm uninstall -k --user 0 com.sec.android.app.DataCreate # Automation Test
adb shell pm uninstall -k --user 0 com.samsung.android.bixby.service # Bixby dictation (if not using Bixby)
adb shell pm uninstall -k --user 0 com.samsung.android.app.routines # Bixby Routines (if not using Bixby)
adb shell pm uninstall -k --user 0 com.samsung.android.visionintelligence # Bixby Vision (if not using Bixby)
adb shell pm uninstall -k --user 0 com.android.bookmarksprovider # Bookmark Provider
adb shell pm uninstall -k --user 0 com.android.providers.calendar # Calendar Storage (keep if you use calendar sync)
adb shell pm uninstall -k --user 0 com.samsung.android.mdeservice # Call & text on other devices
adb shell pm uninstall -k --user 0 com.samsung.android.service.livedrawing # Live messages
adb shell pm uninstall -k --user 0 com.samsung.faceservice # FaceService
adb shell pm uninstall -k --user 0 com.hiya.star # Hiya Service (Caller ID & Call Protection)
adb shell pm uninstall -k --user 0 com.samsung.android.fast # Secure Wi-Fi
adb shell pm uninstall -k --user 0 com.sem.factoryapp # SEMFactoryApp
adb shell pm uninstall -k --user 0 com.sec.android.app.ve.vebgm # Samsung Video Editor Assets

# --- Google Extended Services & Bloatware ---
# ⚠️ CRITICAL - DO NOT UNINSTALL - Can break entire system
# adb shell pm uninstall --user 0 com.google.android.gsf # Google Service Framework (CRITICAL)
# adb shell pm uninstall --user 0 com.google.android.gms # Google Play Services (CRITICAL)
# adb shell pm uninstall --user 0 com.google.android.webview # WebView (CRITICAL - used by many apps)

# Safe to uninstall:
adb shell pm uninstall --user 0 com.google.android.youtube # YouTube
adb shell pm uninstall --user 0 com.google.android.gm # Gmail
adb shell pm uninstall --user 0 com.google.android.apps.tachyon # Google Duo
adb shell pm uninstall --user 0 com.google.android.projection.gearhead # Android Auto
adb shell pm uninstall --user 0 com.google.android.googlequicksearchbox # Google Search
adb shell pm uninstall --user 0 com.google.android.gms.supervision # GMS Supervision
adb shell pm uninstall --user 0 com.google.mainline.telemetry # Google Telemetry
adb shell pm uninstall --user 0 com.google.android.adservices.api # Google Ad Services API
adb shell pm uninstall --user 0 com.google.android.onetimeinitializer # Google One Time Initializer
adb shell pm uninstall --user 0 com.google.ar.core # Google AR Core
adb shell pm uninstall --user 0 com.google.mainline.adservices # Google Ad Services Mainline
adb shell pm uninstall --user 0 com.google.android.apps.maps # Google Maps
adb shell pm uninstall --user 0 com.google.android.apps.restore # Data Restore Tool
adb shell pm uninstall --user 0 com.google.android.apps.turbo # Device Health Services
adb shell pm uninstall --user 0 com.google.android.as.oss # Google Android System Intelligence OSS

# --- Samsung Theme & Customization ---
adb shell pm disable-user --user 0 com.samsung.android.themecenter # Theme Center (disable instead of uninstall)
adb shell pm uninstall --user 0 com.samsung.android.themestore # Theme Store
adb shell pm uninstall --user 0 com.samsung.android.app.dressroom # Wallpaper and style

# --- Samsung Advanced Features ---
adb shell pm uninstall --user 0 com.samsung.android.widget.pictureframe # Picture Frame Widget
adb shell pm uninstall --user 0 com.samsung.android.app.tips # Tips
adb shell pm uninstall --user 0 com.samsung.android.smartsuggestions # Smart Suggestions
adb shell pm uninstall --user 0 com.samsung.android.visualars # Visual AR
adb shell pm uninstall --user 0 com.samsung.android.app.updatecenter # Samsung Update Center
adb shell pm uninstall --user 0 com.samsung.android.app.cocktailbarservice # Cocktail Bar Service
adb shell pm uninstall --user 0 com.samsung.android.scpm # Samsung Context Processor

# --- Samsung Contacts & Calendar ---
adb shell pm uninstall --user 0 com.samsung.android.app.contacts # Samsung Contacts

# --- Samsung Knox (Advanced - use with caution) ---
# ⚠️ CRITICAL - Knox services can break Secure Folder and security features
# adb shell pm uninstall --user 0 com.samsung.android.knox.analytics.uploader # Knox Analytics Uploader
# adb shell pm uninstall --user 0 com.samsung.android.knox.kpecore # Knox PE Core (CRITICAL)
# adb shell pm uninstall --user 0 com.samsung.android.knox.attestation # Knox Attestation
# adb shell pm uninstall --user 0 com.knox.vpn.proxyhandler # Knox VPN Proxy Handler
# adb shell pm uninstall --user 0 com.samsung.knox.securefolder # Knox Secure Folder (CRITICAL if used)
# adb shell pm uninstall --user 0 com.samsung.android.knox.pushmanager # Knox Push Manager
# adb shell pm uninstall --user 0 com.sec.enterprise.knox.cloudmdm.smdms # Knox CloudMDM
# adb shell pm uninstall --user 0 com.samsung.android.knox.containercore # Knox Container Core (CRITICAL)
# adb shell pm uninstall --user 0 com.samsung.android.kgclient # Knox Guard Client (CRITICAL)

# --- Netflix & Streaming ---
adb shell pm uninstall --user 0 com.netflix.partner.activation # Netflix Partner Activation
adb shell pm uninstall --user 0 com.netflix.mediaclient # Netflix

# --- Microsoft Services ---
adb shell pm uninstall --user 0 com.microsoft.skydrive # OneDrive
adb shell pm uninstall --user 0 com.microsoft.appmanager # Your Phone Companion

# --- Facebook & Social ---
adb shell pm uninstall --user 0 com.facebook.system # Facebook System
adb shell pm uninstall --user 0 com.facebook.appmanager # Facebook App Manager
adb shell pm uninstall --user 0 com.facebook.services # Facebook Services
adb shell pm uninstall --user 0 com.facebook.katana # Facebook App

# --- Carrier Specific Bloatware ---
adb shell pm uninstall --user 0 com.vodafone.android.app.rbt # Vodafone Ringtones
adb shell pm uninstall --user 0 com.zte.zdm # ZTE Device Manager

# --- Samsung System Services (Advanced - use with caution) ---
adb shell pm uninstall --user 0 com.samsung.accessibility # Samsung Accessibility
adb shell pm uninstall --user 0 com.samsung.android.mateagent # Samsung MATE Agent
adb shell pm uninstall --user 0 com.samsung.android.svcagent # Samsung Service Agent
adb shell pm uninstall --user 0 com.samsung.oda.service # Samsung ODA Service
adb shell pm uninstall --user 0 com.samsung.gpuwatchapp # Samsung GPU Watch App
adb shell pm uninstall --user 0 com.aura.oobe.samsung.gl # Samsung Aura OOBE
adb shell pm uninstall --user 0 com.skms.android.agent # Samsung KMS Agent

# --- Google Play Store & Services ---
# ⚠️ CRITICAL - DO NOT UNINSTALL - Required to install/update apps
# adb shell pm uninstall --user 0 com.android.vending # Google Play Store (CRITICAL)

echo "--- Debloating script completed. ---"
echo "It's recommended to reboot your device now: adb reboot"
