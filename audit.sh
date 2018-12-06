#! /bin/bash
#set -x

# BEGIN AUDIT SCRIPT

# SET VARIABLES
LOGGEDINUSER=$(ls -l /dev/console | awk '{print $3}')
#COMPANY_NAME="ORAU"

profile=$( system_profiler SPHardwareDataType )

shopt -s extglob
#cmdString4="${hardwareUUID##*( )}"
model_name=$( awk -F: ' /Model Name/ { print $2 } ' <<< "$profile")
model_name="${model_name##*( )}"
model_identifier=$( awk -F: ' /Model Identifier/ { print $2 } ' <<< "$profile")
model_identifier="${model_identifier##*( )}"
serial=$( awk -F: ' /Serial Number/ { print $2 } ' <<< "$profile" )
serial="${serial##*( )}"
cpu_name=$( awk -F: ' /Processor Name/ { print $2 } ' <<< "$profile" )
cpu_name="${cpu_name##*( )}"
cpu_speed=$( awk -F: ' /Processor Speed/ { print $2 } ' <<< "$profile" )
cpu_speed="${cpu_speed##*( )}"
cpu_count=$( awk -F: ' /Number of Processors/ { print $2 } ' <<< "$profile" )
cpu_count="${cpu_count##*( )}"
#cpu_cores=$( awk -F: ' /Number of Cores/ { print $2 } ' <<< "$profile" )
#cpu_cores="${cpu_cores##*( )}"
memory=$( awk -F: ' /Memory/ { print $2 } ' <<< "$profile" )
memory="${memory##*( )}"
boot_rom_ver=$( awk -F: ' /Boot ROM Version/ { print $2 } ' <<< "$profile" )
boot_rom_ver="${boot_rom_ver##*( )}"
#hardwareUUID=$( awk -F: '/UUID/ { print $2 }' <<< "$profile" )
#hardwareUUID="${hardwareUUID##*( )}"
#shopt -u extglob

echo '<!doctype html>'
echo '<html>'
echo '<head>'
echo '<title>CIS Apple OSX 10.12 Benchmark Results</title>'
echo '<style>body {font-family: sans-serif;} div {padding: 10px;} pre {padding: 0 auto; margin: 0 auto;} .result {min-width: 300px; border: 1px solid #d3d3d3; border-radius: 4px; padding: 4px;} .pre {white-space:PRE;} .tag {margin-top: 1em; font-size: 10px; color: #E65100; border: 1px solid #FFD54F; border-radius: 4px; background-color: #FFECB3; padding: 4px;} .result-list {border: 1px solid #d3d3d3; border-radius: 4px;} .compliant {border: 1px solid #1B5E20; background-color: #C8E6C9;} .non-compliant {border: 1px solid #b71c1c; background-color: #ffcdd2;} div.item:nth-child(even){background-color: #f2f2f2; border: 1px solid #f2f2f2;} p.disclaimer{font-size: 0.8em;}</style>'
echo '</head>'
echo '<body>'
# -------------------------------------
echo '<div>'
echo '<h2>DISCLAIMER</h2>'
echo '<p class="disclaimer">'
echo 'This script was created to automate terminal commands for implementation of settings as outlined in:<br /><br />'
echo 'CIS Apple OSX 10.12 Benchmark v1.0.0 - 11-04-2016'
echo '</p>'
echo '<p class="disclaimer">This script was created by Craig Dorsey (heavily modified by Josh Wood) and has no warranty expressed or implied. This script will automate the audit of OS X 10.12 settings as defined by the aforementioned guide.</p>'
echo '<p style="color:red;"><strong>Use at your own risk.</strong></p>'
echo '</div>'
echo '<hr />'
# -------------------------------------
echo '<div>'
echo '<h2>Machine Overview</h2>'
echo '<table>'
echo '<tr>'
echo '<td>User</td>'
echo "<td>$LOGGEDINUSER</td>"
echo '</tr>'
echo '<tr>'
echo '<td>Model Name</td>'
echo "<td>$model_name ($model_identifier)</td>"
echo '</tr>'
echo '<tr>'
echo '<td>Processor(s)</td>'
echo "<td>$cpu_count x $cpu_speed $cpu_name</td>"
echo '</tr>'
echo '<tr>'
echo '<td>Memory</td>'
echo "<td>$memory</td>"
echo '</tr>'
echo '<tr>'
echo '<td>Serial Number (system)</td>'
echo "<td>$serial</td>"
echo '</tr>'
echo '<tr>'
echo '<td>Boot ROM Version</td>'
echo "<td>$boot_rom_ver</td>"
echo '</tr>'
echo '</table>'
echo '</div>'

#Table Template
#echo '<tr>'
#echo '<td></td>'
#echo '<td></td>'
#echo '</tr>'

#echo $modelname
#echo $serial
#echo $cpu_count x $cpu_speed $cpu_name
#echo $memory
echo '<hr />'
# -------------------------------------
echo '<h1>Audit Results</h1>'
# -------------------------------------


#RESULT=$(softwareupdate -l 2>&1)
RESULT=$(softwareupdate -l 2>&1 | grep -o 'No new software available')

if [[ "$RESULT" == 'No new software available' ]];
then
    echo '<h2 class="result compliant">'
else
    echo '<h2 class="result non-compliant">'
fi

#echo '<span class="tag">Manual</span>'
echo '1.1 Verify all application software is current (Scored)</h2>'

echo '<div class="item">'

echo '<p>Note: Device must be connected to the internet in order to achieve compliant result.</p>'
echo '<h4>Expected Result</h4>'
echo '<p class="result">No new software available</p>'

echo '<h4>Actual Result</h4>'
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == 'No new software available' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<ol>'
    echo '<li>Choose <em>Apple menu</em> &gt; <strong>About this Mac.</strong></li>'
    echo '<li>Click <strong>Software update...</strong> &#45; If prompted, enter an admin name and password.</li>'
    echo '<li>Install all available updates and software patches that are applicable.</li>'
    echo '</ol>'
fi    

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>1.2 Enable Auto Update (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">1</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = "1" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Open a terminal and enter the following command:<br />'
    echo '<code>sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool true</code><br />'
    echo '<code>sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool true</code><br />'
    echo '<code>sudo softwareupdate --schedule on</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>1.3 Enable app update installs (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">1</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults read /Library/Preferences/com.apple.commerce AutoUpdate) #2>&1
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = "1" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>'
    echo 'Open a terminal and enter the following command:<br />'
    echo '<code>sudo defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdate -bool TRUE</code>'
    echo '</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

#echo '<span class="tag">Manual</span>'
echo '<h2>1.4 Enable system data files and security update installs (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">ConfigDataInstall = 1;<br />CriticalUpdateInstall = 1;</p>'

ConfigDataInstall=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep ConfigDataInstall)
CriticalUpdateInstall=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep CriticalUpdateInstall)

echo '<h4>Actual Result</h4>'
#RESULT=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate | egrep '(ConfigDataInstall|CriticalUpdateInstall)')
#echo "<p class=\"result pre\">$RESULT &nbsp;</p>"
echo "<p class=\"result\">$ConfigDataInstall<br />$CriticalUpdateInstall</p>"

ConfigDataResult=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep ConfigDataInstall | grep -o '1')
CriticalUpdateResult=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep CriticalUpdateInstall | grep -o '1')

echo '<h4>Findings</h4>'
if [[ "$ConfigDataResult" == "1" && "$CriticalUpdateResult" == "1" ]];
then
   echo '<p class="result compliant">Compliant</p>'
else
   echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Open a terminal and enter the following command:<br />'
    echo '<code>sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall -bool true && sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -bool true</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>1.5 Enable OS X update installs (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">1</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults read /Library/Preferences/com.apple.commerce.plist AutoUpdateRestartRequired)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = "1" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>'
    echo 'Open a terminal and enter the following command:<br />'
    echo '<code>sudo defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdateRestartRequired -bool TRUE</code>'
    echo '</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.1.1 Turn off Bluetooth, if no paired devices exist (Scored)</h2>'

echo '<h3>Bluetooth Status</h3>'
echo '<h4>Expected Result</h4>'
echo '<p class="result">Off</p>'

echo '<h4>Actual Result</h4>'
#Detects power state of Bluetooth adapter
BluetoothPowerState=$(system_profiler SPBluetoothDataType | grep "Bluetooth Power" | grep -Eoi "(on|off)")
echo "<p class=\"result\">$BluetoothPowerState &nbsp;</p>"

echo '<h3>Paired Devices</h3>'
echo '<h4>Expected Result</h4>'
if [[ "$BluetoothPowerState" =~ "Off" ]];
then
    echo '<p class="result">No</p>'
    echo '<span><strong>or</strong></span>'
    echo '<p class="result">&nbsp;</p>'
else
    echo '<p class="result">Yes</p>'
fi

echo '<h4>Actual Result</h4>'
BTDevicesConnected=$(system_profiler SPBluetoothDataType | grep 'Connectable:' | grep -Eoi "(yes|no)")
echo "<p class=\"result\">$BTDevicesConnected &nbsp;</p>"
# If the Bluetooth controller is powered off at the time the device is booted and the script is run without powering on Bluetooth, "Connectable" will return no matches from grep.
# But if it's powered on and then off again, "Connectable" will return a result.

echo '<h4>Findings</h4>'
#if [[ "$BlueToothState" =~ "1" ]] && [[ "$BTDevicesConnected" =~ "Connectable: Yes" ]];
#then
    #echo '<p class="result compliant">Compliant</p>'
if [[ "$BluetoothPowerState" =~ "Off" ]] && ([[ "$BTDevicesConnected" =~ "No" ]] || [[ "$BTDevicesConnected" == "" ]]);
then
    echo '<p class="result compliant">Compliant</p>'
elif [[ "$ControllerPowerState" =~ "On" ]] && [[ "$BTDevicesConnected" =~ "Yes" ]];
then
    echo '<p class="tag">Provisionally Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Bluetooth is allowed to be enabled if Bluetooth devices are actively used and paired with the device, otherwise it should be disabled. By default, OS X lists a Bluetooth keyboard and mouse in the list of paired devices, regardless of whether these are actual devices owned and utilized by the user. Please ensure than any paired devices listed in the <strong>Devices</strong> list of the Bluetooth preferences menu are necessary and <strong>remove them</strong> if they are not. If the user has no Bluetooth devices, simply turn off Bluetooth.</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>It appears as if Bluetooth is enabled, but no devices are paired with the computer. Please disable Bluetooth.</p>'
#    echo '<br />'
#    echo '<p>In Terminal, run the following commands:<br />'
#    echo '<code>sudo defaults write /Library/Preferences/com.apple.Bluetooth \ ControllerPowerState -int 0</code><br/>'
#    echo '<code>sudo killall -HUP blued</code><br/>'
#    echo '...<strong>Or simply turn off Bluetooth from the menu...</strong></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.1.2 Turn off Bluetooth "Discoverable" mode when not pairing devices (Scored)</h2>'
echo '<p>Note: In OS X Sierra (10.12), "Discoverable" status is now only enabled when the Bluetooth menu is open, otherwise it is disabled by default.</p>'

echo '<h4>Expected Result</h4>'
if [[ "$BluetoothPowerState" =~ "Off" ]];
then
    echo '<p class="result">Discoverable: Off</p>'
    echo '<span><strong>or</strong></span>'
    echo '<p class="result">&nbsp;</p>'
else
    echo '<p class="result">Discoverable: On</p>'
fi

echo '<h4>Actual Result</h4>'
RESULT=$(/usr/sbin/system_profiler SPBluetoothDataType | grep -i discoverable)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$BluetoothPowerState" =~ "On" ]] && [[ "$RESULT" =~ "Discoverable: On" ]];
then
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Starting with OS X (10.9) Bluetooth is only set to Discoverable when the Bluetooth System Preference is selected. To ensure that the computer is not "Discoverable" do not leave the Bluetooth system preferences window open.</p>'
else
    echo '<p class="result compliant">Compliant</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.1.3 Show Bluetooth status in menu bar (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">"/System/Library/CoreServices/Menu Extras/Bluetooth.menu"</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(/usr/bin/defaults read com.apple.systemuiserver menuExtras | grep Bluetooth.menu)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ [[:punct:]]'/System/Library/CoreServices/Menu Extras/Bluetooth.menu'[[:punct:]] ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>'
    echo 'In Terminal, run the following command:'
    echo '<code>defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/Bluetooth.menu"</code>'
    echo '</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.2.1 Enable "Set time and date automatically" (Not Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">Network Time: On</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(sudo systemsetup -getusingnetworktime)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ "Network Time: On" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>In Terminal, run the following command:<br />'
    #echo '<code>sudo systemsetup -setnetworktimeserver tic.orau.org</code></p>
    # Note - commented out above as it does not set multiple time servers which are needed for users
    # that move on and off the internal network (laptops)
    echo '<code>sudo time_setup.sh</code></p>'
    #echo '<p>Multiple time servers can be enter in the GUI as a space or comma delimited list. Doing so populates the file: <code>/etc/ntp.conf</code>. To set multiple servers use my <code>set-ntp.sh</code> script.'
    echo '<p>You can run Craig&apos; time_setup.sh to setup multime time servers. '
    echo 'You may need to set permissons on the time_setup.sh to allow execution from terminal.'
    echo 'If so, open terminal and navigate to the directory containing time_setup.sh and run the following command:<br>'
    echo '<code>chmod 755 time_setup.sh</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<span class="tag">Manual</span>'
echo '<h2>2.2.2 Ensure time set is within appropriate limits (Scored)</h2>'

echo '<p>Note: You must be connected to the internet and on the ORAU network (locally or through VPN) for this test to correctly determine compliance.</p>'
echo '<h4>Expected Result</h4>'
echo '<p class="result">Offsets: Between -270.x and 270.x seconds</p>'

echo '<h4>Actual Result</h4>'
NTS=$(sudo systemsetup -getnetworktimeserver)
RESULT=$(sudo ntpdate -svd $NTS | egrep offset)
echo "<p class=\"result pre\">$RESULT &nbsp;</p>"

echo '<h5>Remediation</h5>'
echo '<p>In Terminal, run the following command:<br />'
echo '<code>sudo ntpdate -sv tic.orau.org</code></p>'

echo '<h5>Information</h5>'
ALL_NTS=$(grep '^server' /etc/ntp.conf)
echo "<p>$NTS</p>"
echo '<br/>'
echo '<p>All network time servers listed in `/etc/ntp.conf`:<br />'
echo "$ALL_NTS"
echo '</p>'
# Section 2.2.3 Restrict NTP server to loopback interfact remove in 10.13 CIS Benchmark  JAH
echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.3.1 Set an inactivity interval of 20 minutes or less for the screen saver (Scored)</h2>'

echo '<h4>Expected Result</h4>'
#echo '<p>Result should be <strong>greater than</strong> 0 but <strong>less than</strong> 1200.</p>'
echo '<p class="result">900</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults -currentHost read com.apple.screensaver idleTime)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ '900' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br />'
    echo '<code>defaults -currentHost write com.apple.screensaver idleTime -int 900</code>'
    echo '</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<span class="tag">Manual</span>'
echo '<h2>2.3.2 & 2.3.4 Screen Saver Corners (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<ul class="result-list">'
echo '<li>Top-Left: 0</li>'
echo '<li>Top-Right: 0</li>'
echo '<li>Bottom-Left: 0</li>'
echo '<li>Bottom-Right: 5</li></ul>'

echo '<h4>Actual Result</h4>'
TLCORNER=$(defaults read com.apple.dock wvous-tl-corner)
TRCORNER=$(defaults read com.apple.dock wvous-tr-corner)
BLCORNER=$(defaults read com.apple.dock wvous-bl-corner)
BRCORNER=$(defaults read com.apple.dock wvous-br-corner)
echo '<p><ul class="result-list">'
echo "<li>Top-Left: $TLCORNER</li>"
echo "<li>Top-Right: $TRCORNER</li>"
echo "<li>Bottom-Left: $BLCORNER</li>"
echo "<li>Bottom-Right: $BRCORNER</li>"
echo "</ul></p>"

echo '<h5>Remediation</h5>'
echo '<p>Run the following commands in Terminal:<br />'
echo '<code>defaults write com.apple.dock wvous-tl-corner -int 0</code><br />'
echo '<code>defaults write com.apple.dock wvous-tr-corner -int 0</code><br />'
echo '<code>defaults write com.apple.dock wvous-bl-corner -int 0</code><br />'
echo '<code>defaults write com.apple.dock wvous-br-corner -int 5</code>'
echo '</p>'

echo '</div>'
# -------------------------------------
echo '<div class="item">'

#echo '<span class="tag">Manual</span>'
echo '<h2>2.4.1 Disable Remote Apple Events (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">Remote Apple Events: Off</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(sudo systemsetup -getremoteappleevents)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ "Remote Apple Events: Off" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br />'
    echo '<code>sudo systemsetup -setremoteappleevents off</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.4.2 Disable Internet Sharing (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">0</p>'
echo '<p><small>Note: "File or directory does not exist" (sic) is also an acceptable result.</small></p>'

echo '<h4>Actual Result</h4>'
RESULT=$(sudo defaults read /Library/Preferences/SystemConfiguration/com.apple.nat | grep -0 'Enabled = 0' | grep -o '0')
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == "0" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following commands in Terminal:<br />'
    echo '<pre><code>'
    echo "sudo /usr/libexec/PlistBuddy -c \'Delete NAT:Enabled\' /Library/Preferences/SystemConfiguration/com.apple.nat.plist"
    echo "sudo /usr/libexec/PlistBuddy -c \'add NAT:Enabled integer 0\' /Library/Preferences/SystemConfiguration/com.apple.nat.plist"
    echo '</code></pre></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.4.3 Disable Screen Sharing (Scored)</h2>'

echo '<h4>Expected Result</h4>'
#echo '<p class="result">/System/Library/LaunchDaemons/com.apple.screensharing.plist: Service is disabled</p>'
echo '<p class="result">1</p>'
echo '<h4>Actual Result</h4>'
#RESULT=$(sudo launchctl load /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>&1)
RESULT=$(/usr/bin/defaults read /System/Library/LaunchDaemons/com.apple.screensharing.plist | grep -o 'Disabled = 1' | grep -o '1')
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
#if [[ "$RESULT" = "/System/Library/LaunchDaemons/com.apple.screensharing.plist: Service is disabled" ]];
if [[ "$RESULT" == '1' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br />'
    #echo '<code>sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist</code>'
    echo '<code>/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -configure -access -off</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.4.4 Disable Printer Sharing (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">&nbsp;</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(system_profiler SPPrintersDataType | egrep 'Shared: Yes' 2>&1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = "" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following commands in Terminal:<br />'
    echo '<pre><code>'
    # disable sharing on all specific printers
    echo "while read -r _ _ printer _; do"
    echo "/usr/sbin/lpadmin -p \"\${printer/:}\" -o printer-is-shared=false"
    echo "done < <(/usr/bin/lpstat -v)"
    # disable printer sharing
    echo ''
    echo '/usr/sbin/cupsctl --no-share-printers'
    echo '</code></pre></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.4.5 Disable Remote Login (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">Off</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(sudo systemsetup -getremotelogin | grep -o 'Remote Login: Off' | grep -o 'Off')
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == "Off" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br />'
    echo '<code>sudo systemsetup -setremotelogin off</code>'
    echo '</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.4.6 Disable DVD or CD Sharing (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">&nbsp;</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(sudo launchctl list | egrep ODSAgent)
#RESULT=$(ps -Ar | grep ARDAgent)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == "" ]]; #-n checks for null
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p><ol>'
    echo '<li>Open <strong>System Preferences</strong></li>'
    echo '<li>Select <strong>Sharing</strong></li>'
    echo '<li>Uncheck <strong>DVD or CD Sharing</strong></li>'
    echo '</ol></p>'

    echo '<h5>Remediation (Alt)</h5>'
    echo '<p>Run the following command in Terminal:<br />'
    echo '<code>launchctl unload -w /System/Library/LaunchDaemons/com.apple.ODSAgent.plist</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.4.7 Disable Bluetooth Sharing (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">State: Disabled<br />State: Disabled<br /> State: Disabled</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(system_profiler SPBluetoothDataType | grep State)
echo '<p class="result pre">'
echo "$RESULT"
echo '&nbsp;</p>'

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ 'State: Disabled'* ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal (for each user):<br />'

    # CD - Built command pulling in vars current user home directory path and hardware UUID
    #      It is specific to current user and machine.
    cmdString1="/usr/libexec/PlistBuddy -c \'Delete :PrefKeyServicesEnabled\' "
    cmdString2=$HOME
    cmdString3='/Library/Preferences/ByHost/com.apple.Bluetooth.'
    # begin trimming whitespace
    cmdString4=$hardwareUUID
    # end trimming whitespace
    cmdString5='.plist'
    cmd=$cmdString1$cmdString2$cmdString3$cmdString4$cmdString5
    echo "<code>$cmd</code></p>"
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.4.8 Disable Apple File Sharing (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">&nbsp;</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(sudo launchctl list | egrep AppleFileServer)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == "" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal to turn off AFP from the command line:<br />'
    echo '<code>sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.4.8 Disable Windows File Server (SMB) (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">&nbsp;</p>'

echo '<h4>Actual Result</h4>'
#RESULT=$(grep -i array /Library/Preferences/SystemConfiguration/com.apple.smb.server.plist)
# audit command in CIS Benchmark was not working replaced with the following
RESULT=$(sudo launchctl list | egrep smbd)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == "" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal to turn off AFP from the command line:<br />'
    echo '<code>sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.4.9 Disable Remote Management (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">&nbsp;</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(sudo launchctl print system | grep -i ARDAgent)
#RESULT=$(ps -ef | egrep ARDAgent)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == "" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'
    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br /><code>sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop</code></p>'
    echo '<p>Note: Requires reboot to take effect.</p>'   
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<span class="tag">Manual</span>'
echo '<h2>2.5.1 Disable "Wake for network access" (Scored)</h2>'

echo '<p>Note: Device must be plugged in to AC power to receive compliant result.</p>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">womp&nbsp;&nbsp;&nbsp;&nbsp;0<br />womp&nbsp;&nbsp;&nbsp;&nbsp;0</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(pmset -c -g | grep womp; pmset -b -g | grep womp | awk '{print $0,"\n"}')
#RESULT=$(pmset -a -g | grep womp; pmset -c -g | grep sleep | awk '{print $0,"\n"}')
echo "<p class=\"result pre\">$RESULT &nbsp;</p>"

echo '<h5>Remediation</h5>'
echo '<p>Run the following commands in Terminal:<br />'
echo '<code>sudo pmset -a womp 0 ; sudo pmset -c womp 0</code></p>'

echo '</div>'
# -------------------------------------
#echo '<div class="item">'

#echo '<span class="tag">Manual</span>'
#echo '<h2>2.5.2 Disable sleeping the computer when connected to power (Scored)</h2>'

#echo '<p>Note: Device must be plugged in to AC power to receive compliant result.</p>'

#echo '<h4>Expected Result</h4>'
#echo '<p class="result">0</p>'

#echo '<h4>Actual Result</h4>'
#RESULT=$(pmset -g | grep ^sleep$)
#echo "<p class=\"result pre\">$RESULT &nbsp;</p>"

#if [[ "$RESULT" == "0" ]];
#then
#    echo '<p class="result compliant">Compliant</p>'
#else
#    echo '<p class="result non-compliant">Non-Compliant</p>'
#    
#    echo '<h5>Remediation</h5>'
#    echo '<p>Run the following commands in Terminal:<br />'
#    echo '<code>sudo pmset -c sleep 0</code></p>'
#fi

#echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.6.1 Enable FileVault (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">FileVault is On.</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(fdesetup status)
echo "<p class=\"result pre\">$RESULT &nbsp;</p>"

#SIMPRESULT=$(diskutil cs list | grep -i encryption | grep -o 'AES-XTS')
echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ 'FileVault is On' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>'
    echo '<ol>'
    echo '<li>Open <strong>System Preferences</strong></li>'
    echo '<li>Select <strong>Security & Privacy</strong></li>'
    echo '<li>Select <strong>FileVault</strong></li>'
    echo '<li>Select <strong>Turn on FileVault</strong></li>'
    echo '</ol>'
    echo 'Note: This can be a time consuming process depending on the system hardware.</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.6.2 Enable Gatekeeper (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">assessments enabled</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(sudo spctl --status)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ 'assessments enabled' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br /><code>sudo spctl --master-ena</code></p>'
fi

echo '</div>'    
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.6.3 Enable Firewall (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">1 or 2</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults read /Library/Preferences/com.apple.alf globalstate)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == "1" ]] || [[ "$RESULT" == "2" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br /><code>sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1</code></p>'
fi
    
echo '</div>'
# -------------------------------------
# echo '<div class="item">'

# echo '<h2>2.6.4 Enable Firewall Stealth Mode (Scored)</h2>'

# echo '<h4>Expected Result</h4>'
# echo '<p class="result">Stealth mode enabled</p>'

# echo '<h4>Actual Result</h4>'
# RESULT=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode)
# echo "<p class=\"result\">$RESULT &nbsp;</p>"

# echo '<h4>Findings</h4>'
# if [[ "$RESULT" == [Ee]nabled$ ]];
# then
#     echo '<p class="result compliant">Compliant</p>'
# else
#     echo '<p class="result non-compliant">Non-Compliant</p>'

#     echo '<h5>Remediation</h5>'
#     echo '<p>Run the following command in Terminal:<br /><code>sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on</code></p>'
# fi
    
# echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.6.5 Review Application Firewall Rules (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">&nbsp;</p>'
echo '<p>Note: If results are returned, <em>less than 10 results</em> is also acceptable, but the rules should be reviewed for safety.</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(/usr/libexec/ApplicationFirewall/socketfilterfw --listapps)
echo "<p class=\"result pre\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = '' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Do the following:<ol class="result-list">'
    echo '<li>Open <strong>System Preferences</strong></li>'
    echo '<li>Select <strong>Security & Privacy</strong></li>'
    echo '<li>Select <strong>Firewall Options</strong></li>'
    echo '<li>Select <em>any unneeded rules</em></li>'
    echo '<li>Select <strong>the minus sign</strong> below to delete them</li>'
    echo '</ol></p>'
fi
    
echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.7.4 iCloud Drive Document sync (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">&nbsp;</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(ls -l ~/Library/Mobile\ Documents/com~apple~CloudDocs/Documents/ | grep total)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == '' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    # echo '<p><ol class="result-list">'
    # echo '<li>Open System Preferences</li>'
    # echo '<li>Select iCloud</li>'
    # echo '<li>Select iCloud Drive</li>'
    # echo '<li>Select Options next to iCloud Drive</li>'
    # echo '<li>Uncheck Desktop & Documents Folders</li>'
    # echo '</ol></p>'
    echo '<p>Refer to the provided <strong>ReadMe.pdf</strong> for instructions.</p>'

fi

echo '</div>'    
# -------------------------------------
echo '<div class="item">'

# echo '<span class="tag">Manual</span>'
echo '<h2>2.9 Pair the remote control infrared receiver if enabled (Scored)</h2>'

echo '<h3>Device Enabled</h3>'
echo '<h4>Expected Result</h4>'
# DeviceExists=$(system_profiler 2>/dev/null | egrep "IR Receiver")
# #if [[ "$DeviceExists" =~ 'does not exist' ]];
# if [[ "$DeviceExists" == "" ]]
# then
#     echo '<p class="result">&nbsp;</p>'
# else
    echo '<p class="result">0</p>'
#fi

echo '<h4>Actual Result</h4>'
DeviceEnabled=$(defaults read /Library/Preferences/com.apple.driver.AppleIRController | grep -o 'DeviceEnabled = '[[:digit:]] | grep -o [[:digit:]])
echo "<p class=\"result\">$DeviceEnabled &nbsp;</p>"

echo '<h3>UIDFilter Enabled</h3>'
echo '<h4>Expected Result</h4>'
echo '<p class="result">none</p>'

echo '<h4>Actual Result</h4>'
UIDFilter=$(defaults read /Library/Preferences/com.apple.driver.AppleIRController | grep -Eo UIDFilter..."([A-z]*)" | grep -Eo "[^UIDFilter = ]([A-z]*)")
echo "<p class=\"result\">$UIDFilter &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$DeviceExists" =~ 'does not exist' ]];
then
   echo '<p class="result compliant">Compliant</p>'
elif [[ "$DeviceEnabled" == "0" ]] && [[ "$UIDFilter" =~ "none" ]];
then
   echo '<p class="result compliant">Compliant</p>'
else
   echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    # echo '<p>Disable the remote control infrared receiver:<ol>'
    # echo '<li>Open System Preferences</li>'
    # echo '<li>Select Security & Privacy</li>'
    # echo '<li>Select the General tab</li>'
    # echo '<li>Select Advanced</li>'
    # echo '<li>Check Disable remote control infrared receiver</li>'
    # echo '</ol></p>'
    echo '<p>Refer to the provided <strong>ReadMe.pdf</strong> for instructions.</p>'
fi
    
echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>2.10 Enable Secure Keyboard Entry in terminal.app (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">1</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults read -app Terminal SecureKeyboardEntry)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = 1 ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    # echo '<p><ol class="result-list">'
    # echo '<li>Open Terminal</li>'
    # echo '<li>Select Terminal</li>'
    # echo '<li>Select Secure Keyboard Entry</li>'
    # echo '</ol></p>'
    echo '<p>Refer to the provided <strong>ReadMe.pdf</strong> for instructions.</p>'
fi
    
echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<span class="tag">Manual</span>'
echo '<h2>2.11 Java 6 is not the default Java runtime (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result"><em>Should not return "Java version &apos;1.6.0_x&apos;"</em></p>'

echo '<h4>Actual Result</h4>'
# The below command checks for the JRE version
#RESULT=$(/Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/java -version 2>&1)
RESULT=$(java -version 2>&1)
echo "<p class=\"result pre\">$RESULT &nbsp;</p>"

echo '<h5>Remediation</h5>'
echo '<p>Java 6 can be uninstalled completely or, if necessary Java applications will only work with Java 6, a custom path can be used.</p>'

echo '</div>'
# -------------------------------------
echo '<div class="item">'

#echo '<span class="tag">Manual</span>'
echo '<h2>3.1.1 Retain system.log for 90 or more days (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">90</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(grep -i system.log /etc/asl.conf | grep -Eo ttl="([[:digit:]]+)" | grep -Eo "([[:digit:]]+)")
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ "90" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    # echo '<p><ol>'
    # echo "<li>Run this command in terminal:<br /><code>sudo vim /etc/asl.conf</code></li>"
    # echo "<li>Replace or edit the current setting with the following:<br /><code>system.log mode=0640 format=bsd rotate=utc compress file_max=5M ttl=90</code></li>"
    # echo "<li>Run the following command in Terminal:<br /><code>sudo /usr/bin/sed -i.bak 's/^>\ system\.log.*/>\ system\.log\ mode=640\ format=bsd\ rotate=utc\ compress\ file_max=5M\ ttl=90/' /etc/asl.conf</code></li>"
    # echo '</ol></p>'
    echo '<p>Run the system configuration script again and reboot the device before running the audit script.</p>'
fi    

echo '</div>'
# -------------------------------------
echo '<div class="item">'

#echo '<span class="tag">Manual</span>'
echo '<h2>3.1.2 Retain appfirewall.log for 90 or more days (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">90</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(grep -i appfirewall.log /etc/asl.conf | grep -Eo ttl="([[:digit:]]+)" | grep -Eo "([[:digit:]]+)")
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ "90" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    # echo '<p><ol>'
    # echo '<li>Run this command in terminal:<br /><code>sudo vim /etc/asl.conf</code></li>'
    # echo "<li>Replace or edit the current setting with the following:<br /><code>appfirewall.log mode=0640 format=bsd rotate=utc compress file_max=5M ttl=90</code></li>"
    # echo "<li>Run the following command in terminal:<br /><code>sudo /usr/bin/sed -i.bak 's/^\?\ \[=\ Facility\ com.apple.alf.logging\]\ .*/\?\ \[=\ Facility\ com.apple.alf.logging\]\ file\ appfirewall.log\ mode=0640\ format=bsd\ rotate=utc\ compress\ file_max=5M\ ttl=90/' /etc/asl.conf</code></li>"
    # echo '</ol></p>'
    echo '<p>Run the system configuration script again and reboot the device before running the audit script.</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

#echo '<span class="tag">Manual</span>'
echo '<h2>3.1.3 Retain authd.log for 90 or more days (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">90</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(grep -i authd.log /etc/asl/com.apple.authd | grep -Eo ttl="([[:digit:]]+)" | grep -Eo "([[:digit:]]+)")
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ "90" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    # echo '<p><ol>'
    # echo '<li>Run the following command in Terminal:<br/><code>sudo vim /etc/asl/com.apple.authd</code></li>'
    # echo '<li>Replace or edit the current setting with the following:<br/><code>* file /var/log/authd.log mode=0640 format=bsd rotate=utc compress file_max=5M ttl=90</code></li>'
    # echo '<li>Run the following command in Terminal:<br />'
    # echo "<code>sudo /usr/bin/sed -i.bak 's/^\*\ file\ \/var\/log\/authd\.log.*/\*\ file\ \/var\/log\/authd\.log\ mode=640\ format=bsd\ rotate=utc\ compress\ file_max=5M\ ttl=90/' /etc/asl/com.apple.authd</code></li>"
    # echo '</ol></p>'
    echo '<p>Run the system configuration script again and reboot the device before running the audit script.</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>3.2 Enable security auditing (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">com.apple.auditd</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(sudo launchctl list | grep -o 'com.apple.auditd')
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == 'com.apple.auditd' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br /><code>sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>3.3 Configure Security Auditing Flags (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">flags:lo,ad,fd,fm,-all</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(sudo egrep '^flags:' /etc/security/audit_control)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ 'flags:lo,ad,fd,fm,-all' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br />'
    echo "<code>sudo /usr/bin/sed -i '' 's/^flags:.*/flags:lo,ad,fd,fm,-all/' /etc/security/audit_control</code><br />"
    echo "<code>sudo /usr/bin/sed -i '' 's/^expire-after:.*/expire-after:90d\ AND\ 1G/' /etc/security/audit_control</code>"
    echo '</p>'
fi
    
echo '</div>'
# -------------------------------------
echo '<div class="item">'

# echo '<span class="tag">Manual</span>'
echo '<h2>3.5 Retain install.log for 365 or more days (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">365</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(grep -i ttl /etc/asl/com.apple.install | grep -Eo ttl="([[:digit:]]+)" | grep -Eo "([[:digit:]]+)")
echo "<p class=\"result\">$RESULT &nbsp;</p>"

if [[ "$RESULT" == '365' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo 'p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br />'
    echo "<code>sudo /usr/bin/sed -i.bak 's/^\*\ file\ \/var\/log\/install\.log.*/\*\ file\ \/var\/log\/install\.log\ mode=0640\ format=bsd\ rotate=utc\ compress\ file_max=5M\ ttl=365/' /etc/asl/com.apple.install</code></p>"
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>4.1 Disable Bonjour advertising service (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">1</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults read /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements | grep -o [[:digit:]])
#RESULT=$(defaults read /Library/Preferences/com.apple.alf globalstate)
#RESULT=$(sudo launchctl print system | grep mDNS)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ "1" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br /><code>defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>4.2 Enable "Show Wi-Fi status in menu bar" (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">"/System/Library/CoreServices/Menu Extras/AirPort.menu",</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults read com.apple.systemuiserver menuExtras | grep AirPort.menu)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ [[:punct:]]'/System/Library/CoreServices/Menu Extras/AirPort.menu'[[:punct:]] ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo "<p>Run the following command in Terminal:<br /><code>defaults write com.apple.systemuiserver menuExtras -array-add \'/System/Library/CoreServices/Menu Extras/AirPort.menu\'</code></p>"
fi
    
echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>4.4 Ensure http server is not running (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">&nbsp;</p>'

echo '<h4>Actual Result</h4>'
#RESULT=$(ps -ef | grep -i httpd) -- shows process info even if not running, difficult to audit
RESULT=$(sudo launchctl print system | grep com.apple.httpd)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == '' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following commands in Terminal:<br/>'
    echo '<code>sudo apachectl stop</code><br />'
    echo '<code>sudo defaults write /System/Library/LaunchDaemons/org.apache.httpd Disabled -bool true</code></p>'
fi

echo '</div>'
# -------------------------------------
#echo '<div class="item">'

#echo '<h2>4.5 Ensure ftp server is not running (Scored)</h2>'*********FTP server was removed from MacOS 10.13



#echo '</div>'
# -------------------------------------
echo '<div class="item">'

#echo '<span class="tag">Manual</span>'
echo '<h2>4.6 Ensure nfs server is not running (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">nfsd service is enabled<br />nfsd is not running</p>'

echo '<h4>Actual Result</h4>'
#RESULT=$(ps -ef | grep -i nfsd) -- shows process info even if not running, difficult to audit
#RESULT=$(sudo launchctl print system | grep -o 'com.apple.nfsd')
RESULT=$(nfsd status)
echo "<p class=\"result pre\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ "com.apple.nfsd" ]];
then
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command(s) in Terminal:<br/>'
    echo '<code>sudo launchctl -w unload com.apple.nfsd</code><br/>'
    echo '<code>rm /etc/export</code></p>'
    # echo 'or the command listed in the CIS Benchmark Guide...<br />'
    # echo "<code>sudo nfsd disable</code> <small>(Although, I don't believe this is correct as of Sierra. - jw)</small></p>"
    echo '<p>Note: This will place the server into hibernation. To fully disable nfsd, Apple System Protection must first be disabled while in Recovery.</p>'
else
    echo '<p class="result compliant">Compliant</p>'
fi

echo '<h4>Expected Result</h4>'
echo '<p class="result">No such file or directory</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(cat /etc/exports 2>&1 | grep -oi 'No such file or directory')
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ 'No such file or directory' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br/>'
    echo "<code>rm /etc/export</code></p>"
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<span class="tag">Manual</span>'
echo '<h2>5.1.1 Secure Home Folders (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo "<p class=\"result\">drwx--x--x+ # $LOGGEDINUSER ...</p>"

echo '<h4>Actual Result</h4>'
RESULT=$(ls -l /Users/ | grep $LOGGEDINUSER )
echo "<p class=\"result pre\">$RESULT &nbsp;</p>"

echo '<h5>Remediation</h5>'
echo '<p>Run one of the following commands in Terminal:<br />'
echo '<code>sudo chmod -R og-rwx /Users/{username}</code><br />'
#echo '<code>sudo chmod -R og-rw /Users/{username}</code><br />'
echo '<small><em>Where {username} is the current user account.</em></small><br />'
#echo 'Note: This command has to be run for each user account with a local home folder.</p>'
echo '</p>'

echo '</div>'
# -------------------------------------
echo '<div class="item">'

#echo '<span class="tag">Manual</span>'
echo '<h2>5.1.2 Check System Wide Applications for appropriate permissions (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">&nbsp;</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(sudo find /Applications -iname '*\.app' -type d -perm -2 -ls)
echo "<p class=\"result pre\">$RESULT &nbsp;</p>"
echo '<p>Note: Any applications discovered should be removed or changed.<br />If changed the results should look like this on the next audit: <code>drwxr-xr-x</code></p>'

echo '<h4>Findings</h4>'
if [[ "$RESULT" == "" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal for each application in the list:<br />'
    echo '<code>sudo chmod -R o-w /Applications/{app_name}.app/</code>'
    echo '<em>Where {app_name} is the name of the app to be reconfigured.</em></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>5.1.3 Check System folder for world writable files (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">&nbsp;</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(sudo find /System -type d -perm -2 -ls | grep -v 'Public/Drop Box')
echo "<p class=\"result pre\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == '' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'
fi

echo '<h5>Remediation</h5>'
echo '<p>Run the following command in Terminal:<br />'
echo '<code>sudo chmod -R o-w /path/to/{bad directory}</code><br />'
echo '<em>Where /path/to/{bad directory} is the path and folder to be reconfigured.</em></p>'

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>5.2.1 Configure account lockout threshold (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">10</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(pwpolicy -u $LOGGEDINUSER -getaccountpolicies | grep -A 1 '<key>policyAttributeMaximumFailedAuthentications</key>' | tail -1 | cut -d'>' -f2 | cut -d '<' -f1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = 10 ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the "user setup" script.</p>'
fi
    
echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>5.2.2 Set a minimum password length (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">7</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(pwpolicy -u $LOGGEDINUSER -getaccountpolicies | egrep -A1 '<key>minimumLength</key>' | tail -1 | cut -d'>' -f2 | cut -d '<' -f1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == 7 ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the "user setup" script.</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>5.2.3 Complex passwords must contain an Alphabetic Character (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">1</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(pwpolicy -u $LOGGEDINUSER -getaccountpolicies | egrep -A1 '<key>minimumAlphaCharacters</key' | tail -1 | cut -d'>' -f2 | cut -d '<' -f1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = 1 ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the "user setup" script.</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>5.2.4 Complex passwords must contain a Numeric Character (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">1</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(pwpolicy -u $LOGGEDINUSER -getaccountpolicies | egrep -A1 '<key>minimumNumericCharacters' | tail -1 | cut -d'>' -f2 | cut -d '<' -f1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == 1 ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the "user setup" script.</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>5.2.5 Complex passwords must contain a Special Character (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">1</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(pwpolicy -u $LOGGEDINUSER -getaccountpolicies | egrep -A1 '<key>minimumSymbols' | tail -1 | cut -d'>' -f2 | cut -d '<' -f1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = 1 ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the "user setup" script.</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>5.2.6 Complex passwords must uppercase and lowercase letters (Scored)</h2>'

echo '<h4>Expected Result (Lowercase)</h4>'
echo '<p class="result">1</p>'

echo '<h4>Actual Result</h4>'
#lowercase
RESULT=$(pwpolicy -u $LOGGEDINUSER -getaccountpolicies | egrep -A1 '<key>minimumAlphaCharactersLowerCase</key>' | tail -1 | cut -d'>' -f2 | cut -d '<' -f1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = 1 ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the "user setup" script.</p>'
fi

echo '<h4>Expected Result (Uppercase)</h4>'
echo '<p class="result">1</p>'

echo '<h4>Actual Result</h4>'
#UPPERCASE
RESULT=$(pwpolicy -u $LOGGEDINUSER -getaccountpolicies | egrep -A1 '<key>minimumAlphaCharacters</key>' | tail -1 | cut -d'>' -f2 | cut -d '<' -f1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = 1 ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the "user setup" script.</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>5.2.7 Password Age (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">180</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(pwpolicy -u $LOGGEDINUSER -getaccountpolicies | egrep -A1 '<key>policyAttributeExpiresEveryNDays</key' | tail -1 | cut -d'>' -f2 | cut -d '<' -f1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = 180 ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the "user setup" script.</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>5.2.8 Password History (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">5</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(pwpolicy -u $LOGGEDINUSER -getaccountpolicies | egrep -A1 '<key>policyAttributePasswordHistoryDepth</key>' | tail -1 | cut -d'>' -f2 | cut -d '<' -f1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = 5 ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the "user setup" script.</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

# echo '<span class="tag">Manual</span>'
echo '<h2>5.3 Reduce the sudo timeout period (Scored)</h2>'

echo '<h4>Expected Result</h4>'
#echo '<p class="result">Defaults timestamp_timeout=0</p>'
echo '<p class="result">0</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(sudo cat /etc/sudoers | grep timestamp | grep -0 'timeout=0' | grep -o '0')
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == "0" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br/>'
    echo '<code>sudo visudo</code><br />'
    echo 'In the "# Override built-in defaults" section, add following line:<br/>'
    echo '<code>Defaults timestamp_timeout=0</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

# echo '<span class="tag">Manual</span>'
echo '<h2>5.4 Automatically lock the login keychain for inactivity (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">21600</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(security show-keychain-info 2>&1 | grep -Eo [[:digit:]]+)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == "21600" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    # echo '<p>Run the following command in Terminal:'
    # echo '<ol>'
    # echo '<li>Open Utilities</li>'
    # echo '<li>Select Keychain Access</li>'
    # echo '<li>Select a keychain</li>'
    # echo '<li>Select Edit</li>'
    # echo '<li>Select Change Settings for keychain <keychain_name></li>'
    # echo '<li>Authenticate, if requested.</li>'
    # echo '<li>Change the Lock after # minutes of inactivity setting for the Login Keychain to an approved value that should be longer than 6 hours or 3600 minutes or based on the access frequency of the security credentials included in the keychain for other keychains.</li>'
    # echo '</ol></p>'
    echo '<p>Refer to the provided <strong>ReadMe.pdf</strong> for instructions.</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'
#echo '<span class="tag">Manual</span>'
echo '<h2>5.6 Enable OCSP and CRL certificate checking (Scored)</h2>'

echo '<h3>CRL</h3>'
echo '<h4>Expected Result</h4>'
echo '<p class="result">RequireIfPresent</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(sudo defaults read com.apple.security.revocation CRLStyle)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ 'RequireIfPresent' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br />'
    echo '<code>sudo defaults write com.apple.security.revocation CRLStyle -string RequireIfPresent</code></p>'
fi

echo '<h3>OCSP</h3>'
echo '<h4>Expected Result</h4>'
echo '<p class="result">RequireIfPresent</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(sudo defaults read com.apple.security.revocation OCSPStyle)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ 'RequireIfPresent' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br/>'
    echo '<code>sudo defaults write com.apple.security.revocation OCSPStyle -string RequireIfPresent</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>5.7 Do not enable the <em>root</em> account (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">No such key: AuthenticationAuthority</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(dscl . -read /Users/root AuthenticationAuthority 2>&1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" =~ 'No such key: AuthenticationAuthority' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br/>'
    echo '<code>sudo dsenableroot -d</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

#echo '<span class="tag">Manual</span>'
echo '<h2>5.8 Disable automatic login (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">&nbsp;</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults read /Library/Preferences/com.apple.loginwindow | grep autoLoginUser)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

if [[ "$RESULT" == "" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br />'
    echo '<code>sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>5.9 Require a password to wake the computer from sleep or screen saver (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">1</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults read com.apple.screensaver askForPassword)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == "1" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'
fi

echo '<h5>Remediation</h5>'
echo '<p>Run the following command in Terminal:<br />'
echo '<code>sudo defaults write com.apple.screensaver askForPassword -bool TRUE</code><br />'
echo 'Note: The current user will need to log off and on for changes to take effect.</p>'

echo '</div>'
# -------------------------------------
echo '<div class="item">'

#echo '<span class="tag">Manual</span>'
echo '<h2>5.10 Require an administrator password to access system-wide preferences (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">false &nbsp;</p>'

echo '<h4>Actual Result</h4>'
# previous "grep -e '(true|false)'" -- this is not what was suggested in the CIS Benchmark guide
RESULT=$(security authorizationdb read system.preferences 2> /dev/null | grep -A1 shared | grep -Eo "(true|false)")
echo "<p class=\"result\">$RESULT</p>"

if [[ "$RESULT" =~ "false" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following commands in Terminal:<br />'
        echo '<code>/usr/bin/security authorizationdb read system.preferences > /tmp/system.preferences.plist</code><br />'
        echo '<code>/usr/bin/defaults write /tmp/system.preferences.plist shared -bool false</code><br />'
        echo '<code>sudo /usr/bin/security authorizationdb write system.preferences < /tmp/system.preferences.plist</code><br />'
        echo '<code>rm /tmp/system.preferences.plist</code>'
    echo '</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo "<h2>5.11 Disable ability to login to another user's active and locked session (Scored)</h2>"

echo '<h4>Expected Result</h4>'
echo '<p class="result">&nbsp;</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(grep -i 'group=admin,wheel fail_safe' /etc/pam.d/screensaver)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == "" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br />'
    #echo '<code>/usr/bin/sed -i.bak s/admin,//g /etc/pam.d/screensaver</code>'
echo '</p>'
echo '<p>Refer to the provided <strong>ReadMe.pdf</strong> for instructions.</p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<span class="tag">Manual</span>'
echo '<h2>5.12 Create a custom message for the Login Screen (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">SECURITY NOTICE: This is a US Government system for authorized use only. Users have no explicit or implicit expectation of privacy. All use of this system may be intercepted, monitored, recorded, inspected, and disclosed to authorized Government officials. Unauthorized or improper use may result in disciplinary action, civil, and criminal penalties. By continuing to use this system you indicate your consent to these terms and conditions of use. LOG OFF IMMEDIATELY if you do not agree to these conditions.</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults read /Library/Preferences/com.apple.loginwindow.plist LoginwindowText)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h5>Remediation</h5>'
echo '<p>Run the following command in Terminal:<br/>'
echo "<code>sudo defaults write /Library/Preferences/com.apple.loginwindow \ LoginwindowText \'SECURITY NOTICE: This is a US Government system for authorized use only. Users have no explicit or implicit expectation of privacy. All use of this system may be intercepted, monitored, recorded, inspected, and disclosed to authorized Government officials. Unauthorized or improper use may result in disciplinary action, civil, and criminal penalties. By continuing to use this system you indicate your consent to these terms and conditions of use. LOG OFF IMMEDIATELY if you do not agree to these conditions.\'</code></p>"

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<span class="tag">Manual</span>'
echo '<h2>5.13 Create a Login window banner (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">{\rtf1\ansi\ansicpg1252\cocoartf1344\cocoasubrtf720 {\fonttbl\f0\fswiss\fcharset0 Helvetica;} {\colortbl;\red255\green255\blue255;\red217\green11\blue0;} \margl1440\margr1440\vieww10800\viewh8400\viewkind0 \deftab720 \pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardeftab720 \f0\fs24 \cf0 \expnd0\expndtw0\kerning0 This is a Federal computer system and is property of the United States Government. It is for authorized use only. Users (authorized or unauthorized) have no explicit or implicit expectation of privacy.\uc0\u8232 \u8232 Any or all uses of this system and all files on this system may be intercepted, monitored, recorded, copied, audited, inspected, and disclosed to authorized site, Department of Energy, and law enforcement personnel, as well as authorized officials of other agencies, both domestic and foreign. By using this system, the user consents to such interception, monitoring, recording, copying, auditing, inspection, and disclosure at the discretion of authorized site or Department of Energy personnel.\u8232 \u8232 Unauthorized use of this system may result in administrative disciplinary action and civil and criminal penalties. By continuing to use this system you indicate your awareness of and consent to these terms and conditions of use. \b \cf2 LOG OFF IMMEDIATELY \b0 \cf0 if you do not agree to the conditions stated in this warning.} </p>'

echo '<h4>Actual Result</h4>'
RESULT=$(cat /Library/Security/PolicyBanner.rtf)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h5>Remediation</h5>'
# echo '<p>Place the supplied PolicyBanner.rtf file in: <code>/Library/Security/</code></p>'
echo '<p>Refer to the provided <strong>ReadMe.pdf</strong> for instructions.</p>'

echo '</div>'
# -------------------------------------
echo '<div class="item">'
echo '<span class="tag">Manual</span>'
echo '<h2>5.14 Do not enter a password-related hint (Not Scored)</h2>'

echo "<p>A manual check of each account's login information is required to confirm compliance to this criteria. Ensure that no account has a password hint.</p>"

echo '<h5>Remediation</h5>'
# echo '<p><ol>'
# echo '<li>Open System Preferences</li>'
# echo '<li>Select Users & Groups</li>'
# echo '<li>Highlight the user</li>'
# echo '<li>Select Change Password</li>'
# echo '<li>Verify that no text is entered in the Password hint box</li>'
# echo '</ol></p>'
echo '<p>Refer to the provided <strong>ReadMe.pdf</strong> for instructions.</p>'

echo '</div>'
# -------------------------------------
echo '<div class="item">'

#echo '<span class="tag">Manual</span>'
echo '<h2>5.18 System Integrity Protection status (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">enabled</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(/usr/bin/csrutil status | grep -o [Ee]nabled)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

if [[ "$RESULT" == 'enabled' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal while booted in OS X Recovery:<br />'
    echo '<code>/usr/bin/csrutil enable</code><br />'
    echo 'The output should be:<br />'
    echo '<code>Successfully enabled System Integrity Protection. Please restart the machine for the changes to take effect.</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>6.1.1 Display login window as name and password (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">1</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults read /Library/Preferences/com.apple.loginwindow SHOWFULLNAME 2>&1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == "1" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br />'
    echo '<code>sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>6.1.2 Disable "Show password hints" (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">0</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults read /Library/Preferences/com.apple.loginwindow RetriesUntilHint 2>&1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == "0" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br />'
    echo '<code>sudo defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int 0</code></p>'
fi
    
echo '</div>'
# -------------------------------------
echo '<div class="item">'
echo '<h2>6.1.3 Disable guest account login (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">0</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(sudo defaults read /Library/Preferences/com.apple.loginwindow.plist GuestEnabled 2>&1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = 0 ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br />'
    echo '<code>sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false</code></p>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'
echo '<h2>6.1.4 Disable "Allow guests to connect to shared folders" (Scored)</h2>'

echo '<h3>AFP</h3>'
echo '<h4>Expected Result</h4>'
echo '<p class="result">0</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults read /Library/Preferences/com.apple.AppleFileServer | grep -o 'guestAccess = 0' | grep -o '0')
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = '0' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following commands in Terminal:<br />'
    echo '<code>sudo defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool false</code></p>'
fi

echo '<h3>SMB</h3>'
echo '<h4>Expected Result</h4>'
echo '<p class="result">0</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server | grep -o 'AllowGuestAccess = 0' | grep -o '0')
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = '0' ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following commands in Terminal:<br />'
    echo '<code>sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool false</code></p>'
fi
    
echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>6.1.5 Remove Guest home folder (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">&nbsp;</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(ls /Users/ | grep Guest 2>&1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" = "" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br />'
    echo '<code>rm -R /Users/Guest</code></p>'
fi    

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>6.2 Turn on filename extensions (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">1</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults read NSGlobalDomain AppleShowAllExtensions 2>&1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == "1" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br />'
    echo '<code>defaults write NSGlobalDomain AppleShowAllExtensions -bool true</code>'
fi

echo '</div>'
# -------------------------------------
echo '<div class="item">'

echo '<h2>6.3 Disable the automatic run of safe files in Safari (Scored)</h2>'

echo '<h4>Expected Result</h4>'
echo '<p class="result">0</p>'

echo '<h4>Actual Result</h4>'
RESULT=$(defaults read com.apple.Safari AutoOpenSafeDownloads 2>&1)
echo "<p class=\"result\">$RESULT &nbsp;</p>"

echo '<h4>Findings</h4>'
if [[ "$RESULT" == "0" ]];
then
    echo '<p class="result compliant">Compliant</p>'
else
    echo '<p class="result non-compliant">Non-Compliant</p>'

    echo '<h5>Remediation</h5>'
    echo '<p>Run the following command in Terminal:<br />'
    echo '<code>defaults write com.apple.Safari AutoOpenSafeDownloads -bool false</code></p>'
fi    

echo '</div>'
# -------------------------------------
echo '</body>'
echo '</html>'
#set +x
