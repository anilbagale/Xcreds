#!/bin/bash

# Launch AGENT name
strAGENTPATH=/Library/LaunchAgents/
PLIST_NAME=com.your_company.xcreds
strAGENT=${PLIST_NAME}.plist

loggedInUser=$(stat -f%Su /dev/console)
uid=$(id -u ${loggedInUser})

# If any previous instances of the LaunchAGENT and script exist, unload the LaunchAGENT and remove the LaunchAGENT and script files
if [[ -f "$strAGENTPATH$strAGENT" ]]; then
	if [[ "${loggedInUser}" != "root" ]] || [[ "${loggedInUser}" != "_windowserver" ]] || [[ "${loggedInUser}" != "" ]]; then
    	launchctl bootout gui/$uid/${PLIST_NAME}
    	echo "XCreds LaunchAgent Unloaded..."
  	fi
	rm "$strAGENTPATH$strAGENT"
fi
	
# Create the LaunchAGENT by using cat input redirection
# to write the XML contained below to a new file.
/bin/cat > "/tmp/$strAGENT" << 'LAUNCHAGENT'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.your_company.xcreds</string>
	<key>ProgramArguments</key>
	<array>
		<string>/Applications/XCreds.app/Contents/MacOS/XCreds</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>AbandonProcessGroup</key>
	<true/>
</dict>
</plist>
LAUNCHAGENT


# Once the LaunchAGENT file has been created, fix the permissions
# so that the file is owned by root:wheel and set to not be executable
# After the permissions have been updated, move the LaunchAGENT into 
# place in /Library/LaunchAGENTs.
chown root:wheel "/tmp/$strAGENT"
chmod 755 "/tmp/$strAGENT"
chmod a-x "/tmp/$strAGENT"
mv "/tmp/$strAGENT" "$strAGENTPATH$strAGENT"

# After the LaunchAGENT and script are in place with proper permissions, load the LaunchAGENT if a user is logged in.
if [[ "${loggedInUser}" != "root" ]] || [[ "${loggedInUser}" != "_windowserver" ]] || [[ "${loggedInUser}" != "" ]]; then
	launchctl bootstrap gui/$uid "$strAGENTPATH$strAGENT"
	echo "XCreds LaunchAgent Loaded..."
fi

exit 0
