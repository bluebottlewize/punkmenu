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
	}

	anchors.fill: parent
	anchors.leftMargin: 14
	anchors.topMargin: 53
	orientation: ListView.Horizontal
	spacing: 13

	currentIndex: 1
	keyNavigationEnabled: true

	Keys.onReturnPressed: {
		var action = buttonModel.get(currentIndex).cmd
		if (action !== "") {
			rootList.requested(action)
		}
	}

	Component.onCompleted: {
		var configData = backend.loadConfig()

		if (configData.length === 0) {
			console.log("No config found or empty! using fallback.")

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
