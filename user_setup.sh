#!/bin/bash
#set -x

# Set up vars to use
LOGGEDINUSER=$(ls -l /dev/console | awk '{print $3}')

echo "LOGGEDINUSER is: $LOGGEDINUSER"
# --------------------------------------------------
# Variables for script and commands generated below.
#
# EDIT AS NECESSARY FOR YOUR OWN PASSWORD POLICY
# AND COMPANY INFORMATION
# --------------------------------------------------
COMPANY_NAME="ORAU"             # CHANGE THIS TO YOUR COMPANY NAME
LOCKOUT=300                     # 5 minute lockout
MAX_FAILED=10                   # 10 max failed logins before locking
PW_EXPIRE=180                   # 180 days password expiration
MIN_LENGTH=7                    # at least 7 chars for password
MIN_NUMERIC=1                   # at least 1 number in password
MIN_ALPHA_LOWER=1               # at least 1 lower case letter in password
MIN_UPPER_ALPHA=1               # at least 1 upper case letter in password
MIN_SPECIAL_CHAR=1              # at least one special character in password
PW_HISTORY=5                    # remember last 5 passwords
exemptAccount1="localadmin"     # Exempt account used for remote management. CHANGE THIS TO YOUR EXEMPT ACCOUNT

# --------------------------------------------------
# Create pwpolicy.plist in /private/var/tmp
# Password policy using variables above is:
# Change as necessary in variable flowerbox above
# --------------------------------------------------
# pw's must be at least 8 chars
# pw's must have at least 1 lower case letter
# pw's must have at least 1 upper case letter
# pw's must have at least 1 special non-alpha/non-numeric character
# pw's must have at least 1 number
# can't use any of the previous 10 passwords
# pw's expire at 90 days
# 10 failed successive login attempts results in a 300sec lockout, then auto enables

echo "<dict>
 <key>policyCategoryAuthentication</key>
  <array>
   <dict>
    <key>policyContent</key>
     <string>(policyAttributeFailedAuthentications &lt; policyAttributeMaximumFailedAuthentications) OR (policyAttributeCurrentTime &gt; (policyAttributeLastFailedAuthenticationTime + autoEnableInSeconds))</string>
    <key>policyIdentifier</key>
     <string>Authentication Lockout</string>
    <key>policyParameters</key>
  <dict>
  <key>autoEnableInSeconds</key>
   <integer>$LOCKOUT</integer>
   <key>policyAttributeMaximumFailedAuthentications</key>
   <integer>$MAX_FAILED</integer>
  </dict>
 </dict>
 </array>


 <key>policyCategoryPasswordChange</key>
  <array>
   <dict>
    <key>policyContent</key>
     <string>policyAttributeCurrentTime &gt; policyAttributeLastPasswordChangeTime + (policyAttributeExpiresEveryNDays * 24 * 60 * 60)</string>
    <key>policyIdentifier</key>
     <string>Change every $PW_EXPIRE days</string>
    <key>policyParameters</key>
    <dict>
     <key>policyAttributeExpiresEveryNDays</key>
      <integer>$PW_EXPIRE</integer>
    </dict>
   </dict>
  </array>


  <key>policyCategoryPasswordContent</key>
 <array>
  <dict>
   <key>policyContent</key>
    <string>policyAttributePassword matches '.{$MIN_LENGTH,}+'</string>
   <key>policyIdentifier</key>
    <string>Has at least $MIN_LENGTH characters</string>
   <key>policyParameters</key>
   <dict>
    <key>minimumLength</key>
     <integer>$MIN_LENGTH</integer>
   </dict>
  </dict>


  <dict>
   <key>policyContent</key>
    <string>policyAttributePassword matches '(.*[0-9].*){$MIN_NUMERIC,}+'</string>
   <key>policyIdentifier</key>
    <string>Has a number</string>
   <key>policyParameters</key>
   <dict>
   <key>minimumNumericCharacters</key>
    <integer>$MIN_NUMERIC</integer>
   </dict>
  </dict>


  <dict>
   <key>policyContent</key>
    <string>policyAttributePassword matches '(.*[a-z].*){$MIN_ALPHA_LOWER,}+'</string>
   <key>policyIdentifier</key>
    <string>Has a lower case letter</string>
   <key>policyParameters</key>
   <dict>
   <key>minimumAlphaCharactersLowerCase</key>
    <integer>$MIN_ALPHA_LOWER</integer>
   </dict>
  </dict>



  <dict>
   <key>policyContent</key>
    <string>policyAttributePassword matches '(.*[A-Z].*){$MIN_UPPER_ALPHA,}+'</string>
   <key>policyIdentifier</key>
    <string>Has an upper case letter</string>
   <key>policyParameters</key>
   <dict>
   <key>minimumAlphaCharacters</key>
    <integer>$MIN_UPPER_ALPHA</integer>
   </dict>
  </dict>


  <dict>
   <key>policyContent</key>
    <string>policyAttributePassword matches '(.*[^a-zA-Z0-9].*){$MIN_SPECIAL_CHAR,}+'</string>
   <key>policyIdentifier</key>
    <string>Has a special character</string>
   <key>policyParameters</key>
   <dict>
   <key>minimumSymbols</key>
    <integer>$MIN_SPECIAL_CHAR</integer>
   </dict>
  </dict>



  <dict>
   <key>policyContent</key>
    <string>none policyAttributePasswordHashes in policyAttributePasswordHistory</string>
   <key>policyIdentifier</key>
    <string>Does not match any of last $PW_HISTORY passwords</string>
   <key>policyParameters</key>
   <dict>
    <key>policyAttributePasswordHistoryDepth</key>
     <integer>$PW_HISTORY</integer>
   </dict>
  </dict>


 </array>
</dict>" > /private/var/tmp/pwpolicy.plist
# --------------------------------------------------

#Check for non-admin account before deploying policy
if [ "$LOGGEDINUSER" != "$exemptAccount1" ]; then
  chown $LOGGEDINUSER:staff /private/var/tmp/pwpolicy.plist
  chmod 644 /private/var/tmp/pwpolicy.plist

  # clear account policy before loading a new one
  pwpolicy -u $LOGGEDINUSER -clearaccountpolicies 
  pwpolicy -u $LOGGEDINUSER -setaccountpolicies /private/var/tmp/pwpolicy.plist

elif [ "$LOGGEDINUSER" == "$exemptAccount1" ]; then
    echo "Currently $exemptAccount1 is logged in and the password policy was NOT set. This script can only be run if the standard computer user is logged in."
    rm -f /private/var/tmp/pwpolicy.plist
    exit 1
fi

#delete staged pwploicy.plist
rm -f /private/var/tmp/pwpolicy.plist

echo "Password policy successfully applied. Run \"sudo pwpolicy -u <user> -getaccountpolicies\" to see it."
# --------------------------------------------------
echo "Beginning security configuration."
# --------------------------------------------------
# 1 Install Updates, Patches and Additional Security Software

    # 1.3 Enable app update installs (Scored)
    sudo defaults write /Library/Preferences/com.apple.storeagent AutoUpdate -int 1
	
# 2 System Preferences

    # 2.1 Bluetooth
        
        # 2.1.1 Turn off Bluetooth, if no paired devices exist (Scored)
        #sudo defaults write /Library/Preferences/com.apple.Bluetooth \ ControllerPowerState -int 0
        #sudo killall -HUP blued
		
        # 2.1.2 Turn off Bluetooth "Discoverable" mode when not pairing devices (Scored)
        # Starting with OS X (10.9) Bluetooth is only set to Discoverable when the Bluetooth System Preference
        # is selected. To ensure that the computer is not Discoverable do not leave that preference open.

        # 2.1.3 Show Bluetooth status in menu bar (Scored)
        defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/Bluetooth.menu"
		
	# 2.3 Desktop & Screen Saver
    
        # 2.3.1 Set an inactivity interval of 20 minutes or less for the screen saver (Scored)
        defaults -currentHost write com.apple.screensaver idleTime -int 900
        
        # 2.3.2 Secure screen saver corners (Scored)
        defaults write com.apple.dock wvous-tl-corner -int 0
        defaults write com.apple.dock wvous-tr-corner -int 0
        defaults write com.apple.dock wvous-bl-corner -int 0
        defaults write com.apple.dock wvous-br-corner -int 5
        
        # 2.3.4 Set a screen corner to Start Screen Saver (Scored)
        #defaults write com.apple.dock wvous-br-corner -int 5 -- this is now done above
		
# 5 System Access, Authentication and Authorization

    # 5.1 File System Permissions and Access Controls
        
        # 5.1.1 Secure Home Folders (Scored)
        # Remediation:
        # Run one of the following commands in Terminal:
        #   sudo chmod -R og-rwx /Users/<username>
        #   sudo chmod -R og-rw /Users/<username>
        sudo chmod -R og-rw /Users/$LOGGEDINUSER

# The current user will need to log off and on for changes to take effect.
#sudo defaults write com.apple.screensaver askForPassword -int 1  -- This is obsolete as of 10.13
#following line should not be elevated.  It will write to system level preferences.
defaults write com.apple.screensaver askForPassword -bool TRUE
#This setting is per user,and not per device. Needs to be moved to user script
		
# 6 User Accounts and Environment

    # 6.2 Turn on filename extensions (Scored)
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # 6.3 Disable the automatic run of safe files in Safari (Scored)
    defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# echo "--------------------------------------------------------------------------------"
# echo "Settings for $LOGGEDINUSER successfully applied."
# echo "Reboot before running audit script."
exit 0
