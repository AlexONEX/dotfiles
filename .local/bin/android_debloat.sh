#!/bin/bash
# Samsung S23 Debloat Script - Optimized
# Removes bloatware while preserving core functionality

echo "Samsung S23 Debloat Script"
echo "Press Enter to continue or Ctrl+C to cancel..."
read

# Bixby
echo "[1/10] Removing Bixby..."
adb shell pm uninstall -k --user 0 com.samsung.android.app.settings.bixby
adb shell pm uninstall -k --user 0 com.samsung.android.bixby.wakeup
adb shell pm uninstall -k --user 0 com.samsung.android.bixby.agent
adb shell pm uninstall -k --user 0 com.samsung.android.bixbyvision.framework
adb shell pm uninstall -k --user 0 com.samsung.android.bixby.service
adb shell pm uninstall -k --user 0 com.samsung.android.app.routines
adb shell pm uninstall -k --user 0 com.samsung.android.visionintelligence

# Samsung bloatware
echo "[2/10] Removing Samsung bloatware..."
adb shell pm uninstall -k --user 0 com.samsung.android.arzone
adb shell pm uninstall -k --user 0 com.samsung.android.aremoji
adb shell pm uninstall -k --user 0 com.sec.android.mimage.avatarstickers
adb shell pm uninstall -k --user 0 com.samsung.android.aremojieditor
adb shell pm uninstall -k --user 0 com.samsung.android.stickercenter
adb shell pm uninstall -k --user 0 com.samsung.android.tvplus
adb shell pm uninstall -k --user 0 com.samsung.android.app.spage
adb shell pm uninstall -k --user 0 com.samsung.storyservice
adb shell pm uninstall -k --user 0 com.samsung.android.smartswitchassistant
adb shell pm uninstall -k --user 0 com.sec.android.easyMover.Agent
adb shell pm uninstall -k --user 0 com.samsung.android.voc
adb shell pm uninstall -k --user 0 com.samsung.android.app.tips
adb shell pm uninstall -k --user 0 com.samsung.android.dynamiclock
adb shell pm uninstall -k --user 0 com.samsung.android.livestickers
adb shell pm uninstall -k --user 0 com.samsung.android.rubin.app
adb shell pm uninstall -k --user 0 com.samsung.android.app.dofviewer

# Edge Panels
echo "[3/10] Removing Edge Panels..."
adb shell pm uninstall -k --user 0 com.samsung.android.app.taskedge
adb shell pm uninstall -k --user 0 com.samsung.android.app.clipboardedge
adb shell pm uninstall -k --user 0 com.sec.android.app.quicktool
adb shell pm uninstall -k --user 0 com.samsung.android.service.peoplestripe
adb shell pm uninstall -k --user 0 com.samsung.android.app.appsedge

# Game Launcher
echo "[4/10] Removing Game Launcher..."
adb shell pm uninstall -k --user 0 com.samsung.android.game.gametools
adb shell pm uninstall -k --user 0 com.samsung.android.game.gos
adb shell pm uninstall -k --user 0 com.samsung.android.game.gamehome

# Samsung DeX
echo "[5/10] Removing Samsung DeX..."
adb shell pm uninstall -k --user 0 com.sec.android.dexsystemui
adb shell pm uninstall -k --user 0 com.sec.android.desktopmode.uiservice
adb shell pm uninstall -k --user 0 com.sec.android.app.desktoplauncher

# Facebook & Netflix
echo "[6/10] Removing Facebook and Netflix..."
adb shell pm uninstall -k --user 0 com.facebook.system
adb shell pm uninstall -k --user 0 com.facebook.appmanager
adb shell pm uninstall -k --user 0 com.facebook.services
adb shell pm uninstall -k --user 0 com.facebook.katana
adb shell pm uninstall --user 0 com.netflix.partner.activation
adb shell pm uninstall --user 0 com.netflix.mediaclient

# Google bloatware
echo "[7/10] Removing Google bloatware..."
adb shell pm uninstall --user 0 com.google.android.feedback
adb shell pm uninstall -k --user 0 com.google.android.as
adb shell pm uninstall -k --user 0 com.google.android.apps.turbo
adb shell pm uninstall -k --user 0 com.google.mainline.telemetry
adb shell pm uninstall --user 0 com.google.android.adservices.api
adb shell pm uninstall --user 0 com.google.mainline.adservices
adb shell pm uninstall -k --user 0 com.google.android.setupwizard
adb shell pm uninstall -k --user 0 com.google.android.apps.restore
adb shell pm uninstall --user 0 com.google.android.partnersetup
adb shell pm uninstall --user 0 com.google.android.onetimeinitializer
adb shell pm uninstall -k --user 0 com.google.android.egg
adb shell pm uninstall -k --user 0 com.google.audio.hearing.visualization.accessibility.scribe
adb shell pm uninstall -k --user 0 com.android.hotwordenrollment.xgoogle
adb shell pm uninstall -k --user 0 com.android.hotwordenrollment.okgoogle

# Sharing services
echo "[8/10] Removing sharing services..."
adb shell pm uninstall -k --user 0 com.samsung.android.allshare.service.mediashare
adb shell pm uninstall -k --user 0 com.samsung.android.allshare.service.fileshare
adb shell pm uninstall -k --user 0 com.samsung.android.app.simplesharing
adb shell pm uninstall -k --user 0 com.samsung.android.aware.service
adb shell pm uninstall -k --user 0 com.samsung.android.app.sharelive
adb shell pm uninstall -k --user 0 com.samsung.android.mdx
adb shell pm uninstall -k --user 0 com.samsung.android.mdx.quickboard
adb shell pm uninstall -k --user 0 com.samsung.android.smartmirroring
adb shell pm uninstall -k --user 0 com.samsung.android.mobileservice
adb shell pm uninstall -k --user 0 com.samsung.android.privateshare

# Microsoft services
echo "[9/10] Removing Microsoft services..."
adb shell pm uninstall -k --user 0 com.microsoft.appmanager
adb shell pm uninstall --user 0 com.microsoft.skydrive

# Additional services
echo "[10/10] Removing additional services..."
adb shell pm uninstall -k --user 0 com.android.bips
adb shell pm uninstall -k --user 0 com.google.android.printservice.recommendation
adb shell pm uninstall -k --user 0 com.android.printspooler
adb shell pm uninstall -k --user 0 com.samsung.android.kidsinstaller
adb shell pm uninstall -k --user 0 com.samsung.android.app.camera.sticker.facearavatar.preload
adb shell pm uninstall -k --user 0 com.samsung.android.app.reminder
adb shell pm uninstall -k --user 0 com.samsung.android.app.soundpicker
adb shell pm uninstall -k --user 0 com.samsung.android.service.tagservice
adb shell pm uninstall -k --user 0 com.android.apps.tag
adb shell pm uninstall -k --user 0 com.samsung.android.vtcamerasettings
adb shell pm uninstall -k --user 0 com.samsung.android.service.airviewdictionary
adb shell pm uninstall -k --user 0 com.samsung.android.mdeservice
adb shell pm uninstall -k --user 0 com.samsung.android.service.livedrawing
adb shell pm uninstall -k --user 0 com.samsung.faceservice
adb shell pm uninstall -k --user 0 com.samsung.safetyinformation
adb shell pm uninstall -k --user 0 com.samsung.android.app.omcagent
adb shell pm uninstall -k --user 0 com.samsung.android.coldwalletservice
adb shell pm uninstall -k --user 0 com.samsung.android.app.updatecenter
adb shell pm uninstall -k --user 0 com.samsung.android.smartsuggestions
adb shell pm uninstall -k --user 0 com.samsung.android.visualars
adb shell pm uninstall -k --user 0 com.diotek.sec.lookup.dictionary
adb shell pm uninstall -k --user 0 com.android.dreams.basic
adb shell pm uninstall -k --user 0 com.android.dreams.phototable
adb shell pm uninstall -k --user 0 com.android.wallpaper.livepicker
adb shell pm uninstall -k --user 0 com.android.wallpapercropper
adb shell pm uninstall -k --user 0 com.android.bookmarksprovider

# Optional - uncomment if you don't use these features

# Samsung Pass
# adb shell pm uninstall -k --user 0 com.samsung.android.samsungpass
# adb shell pm uninstall -k --user 0 com.samsung.android.samsungpassautofill
# adb shell pm uninstall -k --user 0 com.samsung.android.dkey
# adb shell pm uninstall -k --user 0 com.samsung.android.carkey

# Samsung Pay
# adb shell pm uninstall -k --user 0 com.samsung.android.spay
# adb shell pm uninstall -k --user 0 com.samsung.android.spayfw

# Samsung Calendar
# adb shell pm uninstall -k --user 0 com.samsung.android.calendar

# Samsung Internet
# adb shell pm uninstall -k --user 0 com.sec.android.app.sbrowser

# Samsung Gallery
# adb shell pm uninstall -k --user 0 com.sec.android.gallery3d

# Samsung Messages
# adb shell pm uninstall -k --user 0 com.samsung.android.messaging

# Samsung Video
# adb shell pm uninstall -k --user 0 com.samsung.android.video

# Galaxy Store
# adb shell pm uninstall -k --user 0 com.sec.android.app.samsungapps

# Samsung Cloud
# adb shell pm uninstall -k --user 0 com.samsung.android.scloud

# Blue Light Filter
# adb shell pm uninstall -k --user 0 com.samsung.android.bluelightfilter

# Talkback
# adb shell pm uninstall -k --user 0 com.samsung.android.accessibility.talkback

# SmartThings
# adb shell pm uninstall -k --user 0 com.samsung.android.oneconnect
# adb shell pm uninstall -k --user 0 com.samsung.android.service.stplatform
# adb shell pm uninstall -k --user 0 com.samsung.android.beaconmanager
# adb shell pm uninstall -k --user 0 com.samsung.android.easysetup

# Galaxy Wearables
# adb shell pm uninstall -k --user 0 com.samsung.android.app.watchmanagerstub
# adb shell pm uninstall -k --user 0 com.samsung.android.app.watchmanager
# adb shell pm uninstall -k --user 0 com.samsung.android.waterplugin

# My Files
# adb shell pm uninstall -k --user 0 com.sec.android.app.myfiles

# Chrome
# adb shell pm uninstall --user 0 com.android.chrome

# Android Auto
# adb shell pm uninstall --user 0 com.google.android.projection.gearhead

# Google AR Core
# adb shell pm uninstall --user 0 com.google.ar.core

echo ""
echo "Process completed"
echo "Reboot device: adb reboot"
echo ""
echo "Useful commands:"
echo "  List disabled packages: adb shell pm list packages -d"
echo "  Reinstall package: adb shell cmd package install-existing [package]"
echo ""
