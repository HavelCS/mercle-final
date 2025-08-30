#!/bin/bash

echo "📱 Setting up Xcode Code Signing for Physical Device"
echo "=================================================="

PROJECT_PATH="/Users/havel/Desktop/mercle-app/mercle"
XCODE_PROJECT="$PROJECT_PATH/ios/Runner.xcworkspace"

echo "🔍 Checking Xcode project..."
if [ ! -d "$XCODE_PROJECT" ]; then
    echo "❌ Xcode project not found at: $XCODE_PROJECT"
    echo "Please make sure you're in the Flutter project directory."
    exit 1
fi

echo "✅ Found Xcode project at: $XCODE_PROJECT"

echo ""
echo "📋 Manual Steps Required:"
echo "========================"
echo ""
echo "1. Open Xcode project:"
echo "   open '$XCODE_PROJECT'"
echo ""
echo "2. In Xcode Navigator:"
echo "   - Select 'Runner' project (blue icon)"
echo "   - Select 'Runner' target"
echo "   - Go to 'Signing & Capabilities' tab"
echo ""
echo "3. Configure Code Signing:"
echo "   - ✅ Check 'Automatically manage signing'"
echo "   - Select your Team from dropdown (sign in to Apple ID if needed)"
echo "   - Verify Bundle Identifier: com.havel.mercle"
echo ""
echo "4. If you see errors:"
echo "   - 'No profiles matched': Select your team and let Xcode create profiles"
echo "   - 'Bundle ID not available': Change to: com.havel.mercle.unique.$(date +%s)"
echo ""
echo "5. Build for device:"
echo "   - Connect your iPhone via USB"
echo "   - Select your iPhone from device dropdown"
echo "   - Click 'Build' or press Cmd+B"
echo ""
echo "6. Trust certificate on iPhone:"
echo "   - Settings > General > VPN & Device Management"
echo "   - Find your certificate under 'Developer App'"
echo "   - Tap and select 'Trust [Your Certificate]'"

echo ""
echo "🚀 Opening Xcode now..."
open "$XCODE_PROJECT"

echo ""
echo "📝 Additional Notes:"
echo "==================="
echo "• You need an Apple Developer account (free tier works for device testing)"
echo "• Your iPhone must be connected via USB"
echo "• Enable 'Developer Mode' on iPhone (iOS 16+): Settings > Privacy & Security > Developer Mode"
echo "• Camera permissions work only on physical devices, not simulators"
echo ""
echo "Once configured, run: flutter run -d iPhone"

echo ""
echo "✅ Xcode opened. Follow the manual steps above to complete signing setup."
