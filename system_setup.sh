#! /bin/bash
# -CD cahnged above to sh rather than bash ... should still work
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"
#set -x

# This script was created to automate terminal commands for implementation of settings as outlined in:
#
#       CIS Apple OSX 10.12 Benchmark
#       v1.0.0 - 11-04-2016
#
# This script was created by Craig Dorsey and has no warranty expressed or implied. 
# Use at your own risk (i.e. HC SVNT DRACONES)
#
# Variations have been applied to the standard CIS Benchmarks and may follow alternative requirements
# as defined by ORAU

# To run this setup script:
# Open Terminal and navigate to the directory in which it resides then run the following command:
#
# ./osx_10.12_audit.sh
#
# If the preceding command fails, permissions may need repaired, try running the following command 
# in terminal:
#
# chmod 755 osx_10.12_setup.sh
#
# or
#
# chmod a+x osx_10.12_setup.sh
#
# to make it executable.
#
# This script will generate a text file, CDs_CIS_Apple_OSX_10.12_Benchmark_Setup.txt, which will be 
# located in the same directory as this script. This text file will contain the majority of the 
# outputs for auditing. Where noted you will need to check the Terminal for output to verify values. 
# Steps for remediation are included for each required item in the output of this benchmark audit.

# Set up vars to use
currentUser="$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')"
hardwareUUID="$(/usr/sbin/system_profiler SPHardwareDataType | grep "Hardware UUID" | awk -F ": " '{print $2}' | xargs)"


# profile=$( system_profiler SPHardwareDataType )

#hopt -s extglob
# model_name=$( awk -F: ' /Model Name/ { print $2 } ' <<< "$profile")
# model_name="${model_name##*( )}"
# model_identifier=$( awk -F: ' /Model Identifier/ { print $2 } ' <<< "$profile")
# model_identifier="${model_identifier##*( )}"
# serial=$( awk -F: ' /Serial Number/ { print $2 } ' <<< "$profile" )
# serial="${serial##*( )}"
# cpu_name=$( awk -F: ' /Processor Name/ { print $2 } ' <<< "$profile" )
# cpu_name="${cpu_name##*( )}"
# cpu_speed=$( awk -F: ' /Processor Speed/ { print $2 } ' <<< "$profile" )
# cpu_speed="${cpu_speed##*( )}"
# cpu_count=$( awk -F: ' /Number of Processors/ { print $2 } ' <<< "$profile" )
# cpu_count="${cpu_count##*( )}"
# cpu_cores=$( awk -F: ' /Number of Cores/ { print $2 } ' <<< "$profile" )
# cpu_cores="${cpu_cores##*( )}"
# memory=$( awk -F: ' /Memory/ { print $2 } ' <<< "$profile" )
# memory="${memory##*( )}"
# boot_rom_ver=$( awk -F: ' /Boot ROM Version/ { print $2 } ' <<< "$profile" )
# boot_rom_ver="${boot_rom_ver##*( )}"
# hardwareUUID=$( awk -F: '/UUID/ { print $2 }' <<< "$profile" )
# hardwareUUID="${hardwareUUID##*( )}"del_name=$( awk -F: ' /Model Name/ { print $2 } ' <<< "$profile")
#shopt -u extglob
echo "Beginning remediation"
# 1 Install Updates, Patches and Additional Security Software

    # 1.1 Verify all application software is current (Scored)
    sudo softwareupdate -i -a

    # 1.2 Enable Auto Update
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool TRUE #source: https://github.com/krispayne/CIS-Settings/blob/master/Yosemite_CIS.sh
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool TRUE
    sudo softwareupdate --schedule on #source: https://www.cyberciti.biz/faq/apple-mac-os-x-update-softwareupdate-bash-shell-command/
    #sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -int 1
    
    # 1.3 Enable app update installs (Scored)
    sudo defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdate -bool TRUE
    
    # 1.4 Enable system data files and security update installs (Scored)
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall -bool true ; sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -bool true
    
    # 1.5 Enable OS X update installs (Scored)
    sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool TRUE
    
# 2 System Preferences

     # 2.1 Bluetooth
         # 2.1.1 Turn off Bluetooth, if no paired devices exist (Scored)
        defaults write /Library/Preferences/com.apple.Bluetooth.plist ControllerPowerState -bool false
	killall -HUP blued

        # 2.1.2 Turn off Bluetooth "Discoverable" mode when not pairing devices (Scored)
        # Starting with OS X (10.9) Bluetooth is only set to Discoverable when the Bluetooth System Preference
        # is selected. To ensure that the computer is not Discoverable do not leave that preference open.

        # 2.1.3 Show Bluetooth status in menu bar (Scored)
        defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/Bluetooth.menu"
        
    # 2.2 Date & Time
    
        # 2.2.1 Enable "Set time and date automatically" (Not Scored)

        TIMESERVER1='tic.orau.org'
        TIMESERVER2='toc.orau.org'
        TIMESERVER3='time.apple.com'

        #sudo systemsetup -setnetworktimeserver $TIMESERVER1 #Updated to reflect CIS guide recommendation.
        #echo "server $TIMESERVER2" >> /etc/ntp.conf
        #echo "server $TIMESERVER3" >> /etc/ntp.conf
        
        # running Craig's external script and it works
        sudo ./time_setup.sh

        sudo systemsetup -setusingnetworktime on
        # - Craig included these but they're not in the CIS guide.
        # Craig is putting this back in because it is the proper way to set up multiple time servers - Craig
        
        # 2.2.2 Ensure time set is within appropriate limits (Scored)
        #sudo ntpdate -sv tic.orau.org
        
        # 2.2.3 Restrict NTP server to loopback interface (Scored) - MANUAL
        # Remediation:
        # Run the following command in Terminal:
        #    sudo vim /etc/ntp-restrict.conf
        # Add the following lines to the file
        #    restrict lo interface ignore wildcard interface listen lo
        
    # 2.3 Desktop & Screen Saver
    
        # 2.3.1 Set an inactivity interval of 20 minutes or less for the screen saver (Scored)
        #defaults -currentHost write com.apple.screensaver idleTime -int 900
        defaults write /Users/"$currentUser"/Library/Preferences/ByHost/com.apple.screensaver."$hardwareUUID".plist idleTime -int 1200
        # 2.3.2 Secure screen saver corners (Scored)
        #defaults write com.apple.dock wvous-tl-corner -int 0
        #defaults write com.apple.dock wvous-tr-corner -int 0
        #defaults write com.apple.dock wvous-bl-corner -int 0
        #defaults write com.apple.dock wvous-br-corner -int 0
        
        # 2.3.4 Set a screen corner to Start Screen Saver (Scored)
        #defaults write com.apple.dock wvous-br-corner -int 5
        
    # 2.4 Sharing
    
        # 2.4.1 Disable Remote Apple Events (Scored)
        sudo systemsetup -setremoteappleevents off
        
        # 2.4.2 Disable Internet Sharing (Scored)
        sudo /usr/libexec/PlistBuddy -c "Delete NAT:Enabled" /Library/Preferences/SystemConfiguration/com.apple.nat.plist
        sudo /usr/libexec/PlistBuddy -c "add NAT:Enabled integer 0" /Library/Preferences/SystemConfiguration/com.apple.nat.plist
        
        # 2.4.3 Disable Screen Sharing (Scored)
        #sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist -- Craig's Original
        sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -configure -access -off
        
        # 2.4.4 Disable Printer Sharing (Scored) -- source: https://www.jamf.com/jamf-nation/discussions/11050/disable-printer-sharing
        while read -r _ _ printer _; do
            /usr/sbin/lpadmin -p "${printer/:}" -o printer-is-shared=false
        done < <(/usr/bin/lpstat -v)

        /usr/sbin/cupsctl --no-share-printers
        
        # 2.4.5 Disable Remote Login (Scored)
        sudo yes | systemsetup -setremotelogin off
        # yes | to automatically respond yes when prompted
        
        # 2.4.6 Disable DVD or CD Sharing (Scored) - MANUAL
        # Remediation:
        #   1. Open System Preferences
        #   2. Select Sharing
        #   3. Uncheck DVD or CD Sharing
        sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.ODSAgent.plist
        
        # 2.4.7 Disable Bluetooth Sharing (Scored)
        #/usr/libexec/PlistBuddy -c "Delete :PrefKeyServicesEnabled" /Users/$LOGGEDINUSER/Library/Preferences/ByHost/com.apple.Bluetooth.F537663C-6E67-569E-AE7E-EF1FBDB4D334.plist
        
        /usr/libexec/PlistBuddy -c "Delete :PrefKeyServicesEnabled" $HOME/Library/Preferences/ByHost/com.apple.Bluetooth.$hardwareUUID.plist

        
        # 2.4.8 Disable File Sharing (Scored)
        sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist
        sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist
        
        # 2.4.9 Disable Remote Management (Scored)
        sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop
        # Note: Removes preference after reboot
        
    # 2.5 Energy Saver
    
        # 2.5.1 Disable "Wake for network access" (Scored)
        sudo pmset -a womp 0
        sudo pmset -c womp 0

        #2.5.2 Disable sleeping the computer when connected to power (Scored)
        #sudo pmset -c sleep 0 - disabled until confirming with team
        
    # 2.6 Security & Privacy
        
        # 2.6.1 Enable FileVault (Scored) - MANUAL
        # Note: WAIT TO DO THIS UNTIL LAST AS IT IS VERY TIME CONSUMING!
        # Remediation:
        # Run the following command in Terminal:
        #   1. Open System Preferences
        #   2. Select Security & Privacy
        #   3. Select FileVault
        #   4. Select Turn on FileVault
        
        # 2.6.2 Enable Gatekeeper (Scored)
        sudo spctl --master-enable
        
        # 2.6.3 Enable Firewall (Scored)
        sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1

        # 2.6.4 Enable Firewall Stealth Mode (Scored)
        #sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on - disabled until confirming with team
        
        # 2.6.5 Review Application Firewall Rules (Scored) - MANUAL
        # Remediation:
        #   1. Open System Preferences
        #   2. Select Security & Privacy
        #   3. Select Firewall Options
        #   4. Select unneeded rules
        #   5. Select the minus sign below to delete them
        
    # 2.7 iCloud
    
        # 2.7.4 iCloud Drive Document sync (Scored) - MANUAL
        # Remediation:
        #   1. Open System Preferences
        #   2. Select iCloud
        #   3. Select iCloud Drive
        #   4. Select Options next to iCloud Drive
        #   5. Uncheck Desktop & Documents Folders
        
    # 2.9 Pair the remote control infrared receiver if enabled (Scored)
    SysProfIRReciever=$(system_profiler 2>/dev/null | egrep "IR Receiver")
    if [[ ${SysProfIRReciever} -eq 0 ]];
    then
        sudo defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -bool false
    else
        echo ""
    fi
    
    # Remediation:
    #
    # Disable the remote control infrared receiver:
    #      1. Open System Preferences
    #      2. Select Security & Privacy
    #      3. Select the General tab
    #      4. Select Advanced
    #      5. Check Disable remote control infrared receiver
    
    # 2.10 Enable Secure Keyboard Entry in terminal.app (Scored) - MANUAL
    # Remediation:
    #   1. Open Terminal
    #   2. Select Terminal
    #   3. Select Secure Keyboard Entry
    defaults write /Users/"$currentUser"/Library/Preferences/com.apple.Terminal SecureKeyboardEntry -bool true
 
    # 2.11 Java 6 is not the default Java runtime (Scored) - MANUAL
    # Remediation:
    # Java 6 can be removed completely or, if necessary Java applications will only work with Java 6, a custom path can be used.
    
# 3 Logging and Auditing

    # 3.1 Configure asl.conf
    
        # 3.1.1 Retain system.log for 90 or more days (Scored)
        sudo /usr/bin/sed -i.bak 's/^>\ system\.log.*/>\ system\.log\ mode=640\ format=bsd\ rotate=utc\ compress\ file_max=5M\ ttl=90/' /etc/asl.conf

        # 3.1.2 Retain appfirewall.log for 90 or more days (Scored)
        sudo /usr/bin/sed -i.bak 's/^\?\ \[=\ Facility\ com.apple.alf.logging\]\ .*/\?\ \[=\ Facility\ com.apple.alf.logging\]\ file\ appfirewall.log\ mode=0640\ format=bsd\ rotate=utc\ compress\ file_max=5M\ ttl=90/' /etc/asl.conf

        # 3.1.3 Retain authd.log for 90 or more days (Scored)
        sudo /usr/bin/sed -i.bak 's/^\*\ file\ \/var\/log\/authd\.log.*/\*\ file\ \/var\/log\/authd\.log\ mode=640\ format=bsd\ rotate=utc\ compress\ file_max=5M\ ttl=90/' /etc/asl/com.apple.authd
    
    # 3.2 Enable security auditing (Scored)
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist
    
    # 3.3 Configure Security Auditing Flags (Scored)
    sudo /usr/bin/sed -i '' 's/^flags:.*/flags:lo,ad,fd,fm,-all/' /etc/security/audit_control
    sudo /usr/bin/sed -i '' 's/^expire-after:.*/expire-after:90d\ AND\ 1G/' /etc/security/audit_control
    
    # 3.5 Retain install.log for 365 or more days (Scored)
    sudo /usr/bin/sed -i.bak 's/^\*\ file\ \/var\/log\/install\.log.*/\*\ file\ \/var\/log\/install\.log\ mode=0640\ format=bsd\ rotate=utc\ compress\ file_max=5M\ ttl=365/' /etc/asl/com.apple.install
    
# 4 Network Configurations

    # 4.1 Disable Bonjour advertising service (Scored)
    sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true
    
    # 4.2 Enable "Show Wi-Fi status in menu bar" (Scored)
    sudo defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/AirPort.menu"
    
    # 4.4 Ensure http server is not running (Scored)
    sudo apachectl stop
    sudo defaults write /System/Library/LaunchDaemons/org.apache.httpd Disabled -bool true
    
    # 4.5 Ensure ftp server is not running (Scored)
    sudo launchctl unload -w /System/Library/LaunchDaemons/ftp.plist
    
    # 4.6 Ensure nfs server is not running (Scored)
    sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.nfsd.plist
    #sudo nfsd disable
    sudo yes | rm /etc/export
    
# 5 System Access, Authentication and Authorization

    # 5.1 File System Permissions and Access Controls
        
        # 5.1.1 Secure Home Folders (Scored)
        # Remediation:
        # Run one of the following commands in Terminal:
        # sudo chmod -R og-rwx /Users/<username>
        # sudo chmod -R og-rw /Users/<username>
        # sudo chmod -R og-rw /Users/$LOGGEDINUSER
        
        # 5.1.2 Check System Wide Applications for appropriate permissions (Scored) - MANUAL
        # Remediation:
        # Run the following command in Terminal:
        # sudo chmod -R o-w /Applications/Bad\ Permissions.app/
        
        # 5.1.3 Check System folder for world writable files (Scored) - MANUAL
        # Remediation:
        # Change permissions so that "Others" can only execute. (Example Below)
        # Run the following command in Terminal:
        # sudo chmod -R o-w /Bad/Directory
        
    # 5.2 Password Management
    
        # 5.2.1 Configure account lockout threshold (Scored)
        # 5.2.2 Set a minimum password length (Scored)
        # 5.2.3 Complex passwords must contain an Alphabetic Character (Scored)
        # 5.2.4 Complex passwords must contain a Numeric Character (Scored)
        # 5.2.5 Complex passwords must contain a Special Character (Scored)
        # 5.2.6 Complex passwords must uppercase and lowercase letters (Scored)
        # 5.2.7 Password Age (Scored)
        # 5.2.8 Password History (Scored)
        
        # run password policy script to address 5.2.* above
        #sudo ./password-policy.sh
        
    # 5.3 Reduce the sudo timeout period (Scored) - MANUAL
    # Remediation:
    # Run the following command in Terminal:
    #   sudo visudo
    # In the "# Override built-in defaults" section, add the line:
    #   Defaults timestamp_timeout=0
    echo "Defaults timestamp_timeout=0" >> /etc/sudoers

    # 5.4 Automatically lock the login keychain for inactivity (Scored) - MANUAL
    # Remediation:
    # Run the following command in Terminal:
    #   1. Open Utilities
    #   2. Select Keychain Access
    #   3. Select a keychain
    #   4. Select Edit
    #   5. Select Change Settings for keychain <keychain_name>
    #   6. Authenticate, if requested.
    #   7. Change the Lock after # minutes of inactivity setting for the Login Keychain to an approved value that should be longer than 6 hours or 3600 minutes or based on the access frequency of the security credentials included in the keychain for other keychains.
    security set-keychain-settings -u -t 21600s /Users/"$currentUser"/Library/Keychains/login.keychain
 
    # 5.6 Enable OCSP and CRL certificate checking (Scored)
    sudo defaults write com.apple.security.revocation CRLStyle -string RequireIfPresent
    sudo defaults write com.apple.security.revocation OCSPStyle -string RequireIfPresent
    
    # 5.7 Do not enable the "root" account (Scored)
    #note: you will be prompter to enter password, this cannot be bypassed with sudo
    dsenableroot -d
    
    # 5.8 Disable automatic login (Scored)
    sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser
    
    # 5.9 Require a password to wake the computer from sleep or screen saver (Scored)
    # The current user will need to log off and on for changes to take effect.
    #sudo defaults write com.apple.screensaver askForPassword -int 1  -- This is obsolete as of 10.13
    #sudo defaults write com.apple.screensaver askForPassword -bool TRUE
    defaults write /Users/"$currentUser"/Library/Preferences/com.apple.screensaver askForPassword -int 1

    #This setting is per user,and not per device. Needs to be moved to user script
    
    # 5.10 Require an administrator password to access system-wide preferences (Scored)
    /usr/bin/security authorizationdb read system.preferences > /tmp/system.preferences.plist
    /usr/bin/defaults write /tmp/system.preferences.plist shared -bool false
    sudo /usr/bin/security authorizationdb write system.preferences < /tmp/system.preferences.plist
    rm /tmp/system.preferences.plist
    
    # 5.11 Disable ability to login to another user's active and locked session (Scored)
    /usr/bin/sed -i.bak s/admin,//g /etc/pam.d/screensaver
    
    
    #5.12 Create a custom message for the Login Screen (Scored)
    # clear it out first
    sudo defaults delete /Library/Preferences/com.apple.loginwindow LoginwindowText
    sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "SECURITY NOTICE: This is a Singapore Government system for authorized use only. Users have no explicit or implicit expectation of privacy. All use of this system may be intercepted, monitored, recorded, inspected, and disclosed to authorized Government officials. Unauthorized or improper use may result in disciplinary action, civil, and criminal penalties. By continuing to use this system you indicate your consent to these terms and conditions of use. LOG OFF IMMEDIATELY if you do not agree to these conditions."
    
    # 5.13 Create a Login window banner (Scored)
    sudo cp PolicyBanner.rtf /Library/Security/PolicyBanner.rtf
    
    # 5.14 Do not enter a password-related hint (Not Scored) - MANUAL
    # Remediation:
    #    1. Open System Preferences
    #    2. Select Users & Groups
    #    3. Highlight the user
    #    4. Select Change Password
    #    5. Verify that no text is entered in the Password hint box
    
    # 5.18 System Integrity Protection status (Scored) - MANUAL
    # Remediation:
    # Perform the following while booted in OS X Recovery Partition.
    # Run the following command in Terminal while booted in OS X Recovery Partition:
    #   /usr/bin/csrutil enable
    # The output should be: Successfully enabled System Integrity Protection. Please restart the machine for the changes to take effect.
    
# 6 User Accounts and Environment

    # 6.1.1 Display login window as name and password (Scored)
    sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true
    
    # 6.1.2 Disable "Show password hints" (Scored)
    sudo defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int 0
    
    # 6.1.3 Disable guest account login (Scored)
    sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
    
    # 6.1.4 Disable "Allow guests to connect to shared folders" (Scored)
    sudo defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool false
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool false
    
    # 6.1.5 Remove Guest home folder (Scored)
    yes | sudo rm -R /Users/Guest
    # yes | to automatically respond yes when prompted
    
    # 6.2 Turn on filename extensions (Scored) -- account level
    #defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    sudo -u "$currentUser" defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    pkill -u "$currentUser" Finder

    # 6.3 Disable the automatic run of safe files in Safari (Scored) -- account level
    #sudo defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
    defaults write /Users/"$currentUser"/Library/Preferences/com.apple.Safari AutoOpenSafeDownloads -bool false

echo "Remediation complete"
exit 0
