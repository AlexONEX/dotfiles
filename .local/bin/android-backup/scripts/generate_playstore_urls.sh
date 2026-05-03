#!/bin/bash

# Generate Play Store URLs for all missing apps

BACKUP_DIR="/Users/alex/Github/me/dotfiles/.local/bin/android-backup/backups/backup_20260315_112707"
OUTPUT_FILE="/tmp/playstore_apps.html"

# Read installed apps from backup
mapfile -t MISSING_APPS < <(cat /tmp/missing_apps.txt)

# Create HTML file with clickable links
cat > "$OUTPUT_FILE" <<'HTML_HEAD'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Install Apps from Play Store</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            max-width: 800px;
            margin: 40px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        h1 {
            color: #1a73e8;
        }
        .app-list {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .app-item {
            padding: 12px;
            border-bottom: 1px solid #eee;
        }
        .app-item:last-child {
            border-bottom: none;
        }
        a {
            color: #1a73e8;
            text-decoration: none;
            font-size: 14px;
        }
        a:hover {
            text-decoration: underline;
        }
        .package {
            color: #666;
            font-size: 12px;
            font-family: monospace;
        }
        .special {
            background: #fff3cd;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .count {
            color: #666;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <h1>📱 Install Missing Apps</h1>
    <p class="count">Total apps to install: <strong>COUNT_PLACEHOLDER</strong></p>

    <div class="special">
        <h3>⚠️ Apps not in Play Store</h3>
        <p><strong>F-Droid:</strong> <a href="https://f-droid.org/F-Droid.apk" target="_blank">Download APK</a></p>
        <p><strong>Aegis:</strong> <a href="https://github.com/beemdevelopment/Aegis/releases" target="_blank">GitHub Releases</a></p>
    </div>

    <div class="app-list">
HTML_HEAD

COUNT=0
for package in "${MISSING_APPS[@]}"; do
    # Skip empty lines
    [ -z "$package" ] && continue

    ((COUNT++))

    # Generate Play Store URL
    URL="https://play.google.com/store/apps/details?id=$package"

    # Add to HTML
    cat >> "$OUTPUT_FILE" <<EOF
        <div class="app-item">
            <div>$COUNT. <a href="$URL" target="_blank">Install $package</a></div>
            <div class="package">$package</div>
        </div>
EOF
done

# Close HTML
cat >> "$OUTPUT_FILE" <<'HTML_FOOT'
    </div>

    <p style="margin-top: 20px; color: #666; font-size: 12px;">
        💡 Tip: Open this page on your Android device and tap each link to open Play Store directly.
    </p>
</body>
</html>
HTML_FOOT

# Replace count placeholder
sed -i.bak "s/COUNT_PLACEHOLDER/$COUNT/" "$OUTPUT_FILE"
rm "${OUTPUT_FILE}.bak" 2>/dev/null || true

echo "✓ Generated HTML file with Play Store links"
echo "  Location: $OUTPUT_FILE"
echo ""
echo "Open it in your browser:"
echo "  open $OUTPUT_FILE"
echo ""
echo "Or transfer to your Android and open there for direct Play Store links"
