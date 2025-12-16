import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15

// import QtGraphicalEffects 2.15
Window {
	id: root
	width: 781
	height: 310
	visible: false // Keep false so C++ handles the show()
	color: "transparent"
	flags: Qt.FramelessWindowHint

	// onActiveFocusItemChanged: console.log("active focus: ", activeFocusItem)
	Shortcut {
		sequence: "Escape"
		onActivated: exitSequence.start()
	}

	Rectangle {
		id: dimOverlay
		anchors.fill: parent
		color: "#000216"
		opacity: 0 // Start invisible
	}

	// 2. Blur it (hides ugly details)
	// FastBlur {
	// 	anchors.fill: parent
	// 	source: bgSource
	// 	radius: 64 // High blur destroys distinct shapes
	// }

	// 3. The Tint Overlay
	// Rectangle {
	// 	anchors.fill: parent
	// 	color: "#01041B" // Bright purple
	// 	opacity: 0.6 // "Multiply" look
	// }

	// 1. The Source Image (Hidden)
	// Image {
	// 	id: desktopScreenshot
	// 	source: "file:///home/bluebottle/Pictures/Wallpapers/jinx-flare-cropped-upscaled-blue.png" // Path to your screenshot
	// 	visible: false // HIDE THIS! The shader will draw it instead.
	// }

	// Place this INSIDE your main Window or Item
	// ShaderEffect {
	// 	id: crtEffect
	// 	anchors.fill: parent

	// 	// The "texture" we want to warp.
	// 	// We bind this to the screenshot of your desktop.
	// 	property variant source: desktopScreenshot

	// 	// Curvature amount (0.0 = flat, 1.0 = extreme fish-eye)
	// 	property real curvature: 0.0
	// 	property real opacityVal: 1.0

	// 	// Optional: Add scanlines brightness
	// 	property real scanlineStrength: 0.15

	// 	fragmentShader: "file:///home/bluebottle/dev/qt/punkmenu/crt.frag.qsb"
	// }
	Item {
		id: launcherContainer
		width: 781 // Your desired total width
		height: 310 // Your desired total height

		// Position it where you want on the screen
		// anchors.top: parent.top
		// anchors.topMargin: 100 // Move down 100px (replaces C++ margins)
		anchors.horizontalCenter: parent.horizontalCenter // Optional: Center it?
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

			// Layout Container
			RowLayout {
				// Don't use anchors.fill: parent. It causes circular dependency lag.
				// Explicitly bind dimensions.
				x: 0
				y: 0
				width: 779 // Fixed width of the final content
				height: parent.height

				anchors.margins: 0
				spacing: 0
			}
		}

		PowerMenu {
			id: powerMenu
			// anchors.centerIn: parent // Centers the buttons on screen
			x: 0
			y: 40

			// Optional: Fade it in when the app starts
			opacity: 0

			onRequested: cmd => {
							 console.log("Starting parallel exit for:", cmd)

							 // A. Run the System Command (Shutdown/Reboot/Lock) immediately
							 backend.runCommand(cmd)

							 // B. Start the visual Exit Animation immediately
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
				to: 0.7 // 60% Dark
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
				// 1. Wait for strip to open slightly
				PauseAnimation {
					duration: 150
				}

				// 2. The Flicker (Explicitly targeting powerMenu)
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

				// 3. Final Stabilize
				NumberAnimation {
					target: powerMenu
					property: "opacity"
					to: 1.0
					duration: 50
					easing.type: Easing.OutQuad
				}
			}

			// 4. Turn off layering after animation to save memory (Optional)
			ScriptAction {
				script: topStrip.layer.enabled = false
			}
		}

		// --- EXIT ANIMATION ---
		ParallelAnimation {
			id: exitSequence
			running: false // Do not run automatically

			// 1. Force the layer on again for smooth resizing
			ScriptAction {
				script: topStrip.layer.enabled = true
			}

			SequentialAnimation {
				// Surge bright (if you had brightness control), then die
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
				} // Last spark
				NumberAnimation {
					target: powerMenu
					property: "opacity"
					to: 0.0
					duration: 50
				} // Dead

				ScriptAction {
					script: Qt.quit()
				}
			}

			// Shrink Strip
			NumberAnimation {
				target: topStrip
				property: "width"
				from: 781
				to: 0
				duration: 200
				easing.type: Easing.Linear
			}

			// Fade out Background
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
