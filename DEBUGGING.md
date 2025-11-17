# StarDate - Debugging & Log Access Guide

## Accessing Xcode Console Logs

### Method 1: Xcode Debug Area (Recommended)

1. **Open the Debug Area**:
   - Press `⌘⇧Y` (Command + Shift + Y)
   - Or go to **View → Debug Area → Show Debug Area**
   - Or click the debug area button in the bottom toolbar

2. **View Console Output**:
   - The bottom panel shows console output
   - Select the **Console** tab if not already selected
   - Logs appear in real-time as the app runs

3. **Filter Logs**:
   - Use the search box at the bottom to filter logs
   - Type keywords like "error", "StarDate", or specific function names
   - Use the filter button to show only errors/warnings

### Method 2: Console.app (System Logs)

1. **Open Console.app**:
   - Press `⌘Space` to open Spotlight
   - Type "Console" and press Enter
   - Or go to **Applications → Utilities → Console**

2. **Filter for Your App**:
   - In the search box, type "StarDate"
   - Select your device/simulator from the sidebar
   - View system-level logs and crash reports

3. **View Crash Reports**:
   - In Console.app sidebar, expand **Crash Reports**
   - Look for "StarDate" entries
   - Double-click to view detailed crash information

### Method 3: Device Logs (Physical Device)

1. **Connect Your Vision Pro**:
   - Connect via USB-C
   - Unlock the device

2. **Access Logs in Xcode**:
   - Go to **Window → Devices and Simulators** (`⌘⇧2`)
   - Select your Vision Pro device
   - Click **"Open Console"** button
   - View real-time device logs

3. **Download Device Logs**:
   - In Devices window, select your device
   - Click **"View Device Logs"**
   - Export logs by right-clicking and selecting **Export**

### Method 4: Terminal (Command Line)

1. **View Simulator Logs**:
   ```bash
   # View simulator logs
   xcrun simctl spawn booted log stream --predicate 'processImagePath contains "StarDate"'
   ```

2. **View Device Logs**:
   ```bash
   # List connected devices
   xcrun xctrace list devices

   # Stream logs from device (replace DEVICE_UDID)
   idevicesyslog -u DEVICE_UDID
   ```

3. **Export Console Logs**:
   ```bash
   # Export to file
   xcrun simctl spawn booted log stream --predicate 'processImagePath contains "StarDate"' > stardate_logs.txt
   ```

## Common Log Locations

### Simulator Logs
- **Location**: `~/Library/Logs/CoreSimulator/[DEVICE_UDID]/`
- **Crash Reports**: `~/Library/Logs/DiagnosticReports/`

### Device Logs
- **Location**: Accessed via Xcode Devices window
- **Crash Reports**: `~/Library/Logs/DiagnosticReports/`

### Xcode Derived Data
- **Location**: `~/Library/Developer/Xcode/DerivedData/StarDate-*/`
- Contains build logs and intermediate files

## Understanding Log Messages

### Error Patterns to Look For

**Permission Errors**:
```
Error: Missing required Info.plist key
Error: Microphone access denied
Error: Speech recognition not authorized
```
**Solution**: Check Info.plist keys and grant permissions

**Audio Errors**:
```
Failed to setup audio session
Failed to start audio engine
Failed to setup audio file
```
**Solution**: Check microphone permissions and audio session configuration

**Speech Recognition Errors**:
```
Speech recognizer not available
Recognition task failed
```
**Solution**: Check internet connection and speech recognition permissions

**Storage Errors**:
```
Failed to save entry
Failed to encode diary entry
```
**Solution**: Check UserDefaults and file system permissions

## Debugging Tips

### 1. Add Debug Print Statements

Add print statements to track execution:

```swift
print("🔵 [StarDate] Starting recording...")
print("🔵 [StarDate] Transcript: \(transcript)")
print("🔵 [StarDate] Error: \(error.localizedDescription)")
```

### 2. Use Breakpoints

1. Click in the gutter (left of line numbers) to set breakpoints
2. Run the app (`⌘R`)
3. When execution hits the breakpoint, inspect variables
4. Use the debugger controls:
   - **Continue**: `⌘⌃Y`
   - **Step Over**: `F6`
   - **Step Into**: `F7`
   - **Step Out**: `F8`

### 3. View Variable Values

- Hover over variables in the code editor
- Use the **Variables View** in the debug area
- Type `po variableName` in the LLDB console

### 4. Enable Exception Breakpoints

1. Go to **Debug → Breakpoints → Create Exception Breakpoint**
2. This will pause execution when exceptions occur
3. Helps catch crashes before they happen

## Exporting Logs for Sharing

### Export from Xcode Console

1. Select all logs in the console (`⌘A`)
2. Copy (`⌘C`)
3. Paste into a text file
4. Save as `stardate_logs.txt`

### Export from Console.app

1. Select the log entries you want
2. Go to **File → Export**
3. Choose format (Text or CSV)
4. Save the file

### Create Log Export Script

Save this as `export_logs.sh`:

```bash
#!/bin/bash

# Export StarDate logs
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="stardate_logs_${TIMESTAMP}.txt"

echo "Exporting StarDate logs to ${LOG_FILE}..."

# Simulator logs
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "StarDate"' --level debug > "${LOG_FILE}" 2>&1 &

# Wait a few seconds to collect logs
sleep 5

# Kill the log stream
pkill -f "log stream"

echo "Logs exported to ${LOG_FILE}"
```

Make it executable:
```bash
chmod +x export_logs.sh
./export_logs.sh
```

## Common Issues & Log Patterns

### Issue: App Crashes on Launch

**Look for**:
- Missing Info.plist keys
- Uninitialized variables
- Force unwraps on nil values

**Check**:
```bash
# View crash report
open ~/Library/Logs/DiagnosticReports/StarDate*.crash
```

### Issue: Microphone Not Working

**Look for**:
- "Microphone access denied"
- "Failed to setup audio session"
- AVAudioSession errors

**Check permissions**:
- Settings → Privacy & Security → Microphone
- Ensure StarDate has access

### Issue: Speech Recognition Fails

**Look for**:
- "Speech recognizer not available"
- Network errors
- Authorization errors

**Check**:
- Internet connection
- Speech recognition permissions
- SFSpeechRecognizer availability

## Getting Help

When reporting issues, include:

1. **Xcode Version**: `Xcode → About Xcode`
2. **visionOS Version**: Device/Simulator version
3. **Error Messages**: Copy from console
4. **Crash Reports**: If app crashes
5. **Steps to Reproduce**: What you did before the error
6. **Console Logs**: Relevant log entries

## Quick Debug Commands

```bash
# Clear simulator logs
xcrun simctl spawn booted log erase

# View app's document directory (simulator)
xcrun simctl get_app_container booted com.yourname.StarDate data

# List all processes
xcrun simctl spawn booted log stream --predicate '1 == 1' | grep StarDate

# Monitor memory usage
xcrun simctl spawn booted log stream --predicate 'eventMessage contains "memory"'
```
