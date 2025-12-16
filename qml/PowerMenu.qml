import QtQuick 2.15
import QtQuick.Controls 2.15

ListView {
	id: rootList
	clip: true

	signal requested(string cmd)

	focus: true

	width: 781
	height: 270

	onActiveFocusChanged: {
		console.log('sdsd')
	}

	model: ListModel {
		id: buttonModel

		// ListElement {
		// 	name: "Reboot"
		// 	// The image used when this button is highlighted
		// 	imgActive: "qrc:/assets/punkmenu_restart_active.png"
		// 	// The image used when this button is NOT highlighted
		// 	imgIdle: "qrc:/assets/punkmenu_restart.png"
		// 	cmd: "systemctl reboot"
		// }

		// ListElement {
		// 	name: "Shutdown"
		// 	imgActive: "qrc:/assets/punkmenu_poweroff_active.png"
		// 	imgIdle: "qrc:/assets/punkmenu_poweroff.png"
		// 	cmd: "systemctl poweroff"
		// }

		// ListElement {
		// 	name: "Lock"
		// 	imgActive: "qrc:/assets/punkmenu_lock_active.png"
		// 	imgIdle: "qrc:/assets/punkmenu_lock.png"
		// 	cmd: "loginctl lock-session"
		// }
	}

	anchors.fill: parent
	anchors.leftMargin: 14
	anchors.topMargin: 53
	orientation: ListView.Horizontal
	spacing: 13

	currentIndex: 1
	keyNavigationEnabled: true

	// Debugging: prove keys are working
	Keys.onLeftPressed: {
		decrementCurrentIndex()
		console.log(currentIndex)
	}
	Keys.onRightPressed: {
		incrementCurrentIndex()
		console.log(currentIndex)
	}

	Keys.onReturnPressed: {
		var action = buttonModel.get(currentIndex).cmd
		if (action !== "") {
			rootList.requested(action)
		}
	}

	Component.onCompleted: {
		// Fetch data from C++
		var configData = backend.loadConfig()

		if (configData.length === 0) {
			console.log("No config found or empty! using fallback.")
			// Optional: Add a fallback button so the app isn't empty
			buttonModel.append({
								   "name": "Error",
								   "cmd": "",
								   "imgIdle": "qrc:/assets/error.png",
								   "imgActive": "qrc:/assets/error.png"
							   })
		} else {
			for (var i = 0; i < configData.length; i++) {
				buttonModel.append(configData[i])
			}
		}

		// Focus the list immediately
		rootList.forceActiveFocus()
		rootList.currentIndex = 1
	}

	delegate: ItemDelegate {
		id: buttonDelegate
		width: 242
		height: 242
		background: null

		property string command: cmd

		Image {
			anchors.fill: parent
			fillMode: Image.PreserveAspectFit

			source: buttonDelegate.ListView.isCurrentItem ? imgActive : imgInactive

			smooth: true
			mipmap: true
		}
	}
}
