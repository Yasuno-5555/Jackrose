import Quickshell
import Quickshell.Wayland
import QtCore
import QtQuick
import QtQuick.Layouts
import "../styles"

PanelWindow {
    id: wheelMenuWindow

    property bool active: false
    property var systemState
    property string homePath: StandardPaths.writableLocation(StandardPaths.HomeLocation)
    property string userBinPath: homePath + "/.local/bin"
    signal closeRequested()

    WlrLayershell.namespace: "wheel-menu"
    WlrLayershell.keyboardFocus: active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayershell.Overlay

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    visible: active || wheelMenuContainer.opacity > 0

    // Design System References
    Colors { id: c }
    Metrics { id: metrics }

    // Click Wheel Internal State
    property int selectedIdx: 0
    property real wheelAngle: 0
    property int scrollAccumulator: 0

    onActiveChanged: {
        if (active) {
            scrollAccumulator = 0;
            wheelBackgroundMouse.forceActiveFocus();
        }
    }

    property var wheelItems: [
        { "name": "Ghostty", "icon": "", "accent": c.mauve, "action": "spawn ghostty" },
        { "name": "Firefox", "icon": "", "accent": c.sapphire, "action": "spawn firefox" },
        { "name": "Thunar", "icon": "󰉋", "accent": c.teal, "action": "spawn thunar" },
        { "name": "Zed", "icon": "󰅪", "accent": c.sky, "action": "spawn \"" + userBinPath + "/zed\"" },
        { "name": "Helix", "icon": "🧬", "accent": c.lavender, "action": "spawn ghostty -e helix" },
        { "name": "Calendar", "icon": "📅", "accent": c.peach, "action": "toggle-calendar" },
        { "name": "Wallpaper", "icon": "󰸉", "accent": c.yellow, "action": "toggle-wallpaper" },
        { "name": "Power", "icon": "⏻", "accent": c.red, "action": "spawn \"" + userBinPath + "/sys-menu\"" }
    ]

    function selectNext() {
        selectedIdx = (selectedIdx + 1) % 8;
        wheelAngle -= 45;
    }

    function selectPrev() {
        selectedIdx = (selectedIdx - 1 + 8) % 8;
        wheelAngle += 45;
    }

    function executeAction(act) {
        if (act.startsWith("spawn ")) {
            Quickshell.execDetached({ command: ["/bin/sh", "-lc", act.substring(6)] });
        } else if (act === "toggle-calendar") {
            root.rightDockActive = !root.rightDockActive;
        } else if (act === "toggle-wallpaper") {
            root.bottomActive = !root.bottomActive;
        }
        closeRequested();
    }

    // Global mouse, scroll & keyboard handler
    MouseArea {
        id: wheelBackgroundMouse
        anchors.fill: parent
        focus: true
        onClicked: closeRequested()
        onWheel: (wheel) => {
            scrollAccumulator += wheel.angleDelta.y;
            var threshold = 120; // 1 notch
            while (scrollAccumulator >= threshold) {
                selectPrev();
                scrollAccumulator -= threshold;
            }
            while (scrollAccumulator <= -threshold) {
                selectNext();
                scrollAccumulator += threshold;
            }
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                executeAction(wheelItems[selectedIdx].action);
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                closeRequested();
                event.accepted = true;
            } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Left) {
                selectPrev();
                event.accepted = true;
            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Right) {
                selectNext();
                event.accepted = true;
            }
        }
    }

    // Click Wheel Container (Visually redesigned)
    Rectangle {
        id: wheelMenuContainer
        width: 300; height: 300
        radius: 150
        color: "#cc11111b" // Glassmorphism backdrop
        border.color: c.surfaceBorder
        border.width: 1
        anchors.centerIn: parent

        scale: active ? 1.0 : 0.8
        opacity: active ? 1.0 : 0.0
        Behavior on scale { SpringAnimation { spring: 2.2; damping: 0.15 } }
        Behavior on opacity { NumberAnimation { duration: 150 } }

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => { mouse.accepted = true; }
        }

        // Active Pointer Glow indicator at the top
        Rectangle {
            width: 8; height: 8; radius: 4
            color: wheelItems[selectedIdx].accent
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 12
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        // Rotating Circle
        Item {
            id: wheelCircle
            anchors.fill: parent
            rotation: wheelAngle

            // Dynamic Spring Rotation
            Behavior on rotation {
                SpringAnimation {
                    spring: 2.8
                    damping: 0.22
                }
            }

            Repeater {
                model: wheelItems
                delegate: Item {
                    width: 46; height: 46
                    x: 150 - 23 + 104 * Math.cos((index * 45 - 90) * Math.PI / 180)
                    y: 150 - 23 + 104 * Math.sin((index * 45 - 90) * Math.PI / 180)
                    rotation: -parent.rotation

                    // Selection highlight behind icon
                    Rectangle {
                        anchors.centerIn: parent
                        width: 38; height: 38; radius: 19
                        color: index === selectedIdx ? "rgba(255, 255, 255, 0.06)" : "transparent"
                        border.color: index === selectedIdx ? modelData.accent : "transparent"
                        border.width: 1
                        scale: index === selectedIdx ? 1.1 : 0.9
                        opacity: index === selectedIdx ? 1.0 : 0.0
                        Behavior on scale { NumberAnimation { duration: 120 } }
                        Behavior on opacity { NumberAnimation { duration: 120 } }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        color: index === selectedIdx ? modelData.accent : c.subtext0
                        font.pixelSize: index === selectedIdx ? 24 : 16
                        font.bold: index === selectedIdx
                        Behavior on font.pixelSize { NumberAnimation { duration: 100 } }
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }
                }
            }
        }

        // Center control disk (clickwheel center button)
        Rectangle {
            id: centerDisk
            width: 86; height: 86; radius: 43
            color: centerMouse.containsMouse ? c.surface1 : c.surface0
            border.color: wheelItems[selectedIdx].accent
            border.width: 1.5
            anchors.centerIn: parent
            scale: centerMouse.pressed ? 0.94 : 1.0

            Behavior on scale { NumberAnimation { duration: 80 } }
            Behavior on border.color { ColorAnimation { duration: 120 } }
            Behavior on color { ColorAnimation { duration: 100 } }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2

                Text {
                    text: wheelItems[selectedIdx].name
                    color: c.text
                    font.pixelSize: 11
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Click to Run"
                    color: c.subtext0
                    font.pixelSize: 8
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            MouseArea {
                id: centerMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    executeAction(wheelItems[selectedIdx].action);
                }
            }
        }
    }
}
