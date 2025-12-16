import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15

Window {
	id: root
	width: 781
	height: 310
	visible: false
	color: "transparent"
	flags: Qt.FramelessWindowHint

	Shortcut {
		sequence: "Escape"
		onActivated: exitSequence.start()
	}

	Rectangle {
		id: dimOverlay
		anchors.fill: parent
		color: "#000216"
		opacity: 0
	}

	Item {
		id: launcherContainer
		width: 781
		height: 310

		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter

		Rectangle {
			id: topStrip
			width: 0
			height: 310
			color: "transparent"
			anchors.top: parent.top
			anchors.left: parent.left
			clip: true

			// This forces the GPU to render this entire box as a texture during animation.
			// It prevents the "stutter" caused by the layout engine waking up at the end.
			layer.enabled: true
			layer.smooth: true

			Image {
				source: "qrc:/assets/punkmenu_bg.png"
				anchors.left: parent.left
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				width: topStrip.parent.width

				fillMode: Image.Stretch
				opacity: 0.9
			}

			RowLayout {
				x: 0
				y: 0
				width: 781
				height: parent.height

				anchors.margins: 0
				spacing: 0
			}
		}

		PowerMenu {
			id: powerMenu
			x: 0
			y: 40

			opacity: 0

			onRequested: cmd => {
							 console.log("Starting parallel exit for:", cmd)
							 backend.runCommand(cmd)
							 exitSequence.start()
						 }
		}

		ParallelAnimation {
			id: startSequence
			running: true

			NumberAnimation {
				target: dimOverlay
				property: "opacity"
				from: 0
				to: 0.7
				duration: 400
				easing.type: Easing.OutExpo
			}

			SequentialAnimation {

				NumberAnimation {
					target: topStrip
					property: "width"
					from: 0
					to: 781
					duration: 150
					easing.type: Easing.Linear
				}
			}

			SequentialAnimation {
				PauseAnimation {
					duration: 150
				}

				NumberAnimation {
					target: powerMenu
					property: "opacity"
					to: 0.5
					duration: 60
				}
				NumberAnimation {
					target: powerMenu
					property: "opacity"
					to: 0.1
					duration: 40
				}
				NumberAnimation {
					target: powerMenu
					property: "opacity"
					to: 1.0
					duration: 40
				}
				NumberAnimation {
					target: powerMenu
					property: "opacity"
					to: 0.2
					duration: 50
				}

				NumberAnimation {
					target: powerMenu
					property: "opacity"
					to: 1.0
					duration: 50
					easing.type: Easing.OutQuad
				}
			}

			ScriptAction {
				script: topStrip.layer.enabled = false
			}
		}

		ParallelAnimation {
			id: exitSequence
			running: false

			ScriptAction {
				script: topStrip.layer.enabled = true
			}

			SequentialAnimation {
				NumberAnimation {
					target: powerMenu
					property: "opacity"
					to: 0.2
					duration: 50
				}
				NumberAnimation {
					target: powerMenu
					property: "opacity"
					to: 1
					duration: 100
				}
				NumberAnimation {
					target: powerMenu
					property: "opacity"
					to: 0.0
					duration: 50
				}

				ScriptAction {
					script: Qt.quit()
				}
			}

			NumberAnimation {
				target: topStrip
				property: "width"
				from: 781
				to: 0
				duration: 200
				easing.type: Easing.Linear
			}

			NumberAnimation {
				target: dimOverlay
				property: "opacity"
				from: 0.8
				to: 0
				duration: 200
			}
		}
	}
}
