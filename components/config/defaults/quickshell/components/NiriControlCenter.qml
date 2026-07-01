import Quickshell
import Quickshell.Wayland
import QtCore
import QtQuick
import QtQuick.Layouts
import "../styles"

PanelWindow {
    id: controlCenterWindow

    property bool active: false
    property var systemState
    property var materialState
    property string homePath: StandardPaths.writableLocation(StandardPaths.HomeLocation)
    property string userBinPath: homePath + "/.local/bin"
    signal closeRequested()

    WlrLayershell.namespace: "niri-control-center"
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    visible: active || backdrop.opacity > 0

    Colors { id: c }
    Metrics { id: metrics }

    readonly property var profileActions: [
        { label: "Daily", subtitle: "Balanced liquid desktop", accent: c.teal, command: [userBinPath + "/daily-mode"] },
        { label: "Showcase", subtitle: "Max glass and motion", accent: c.peach, command: [userBinPath + "/showcase-mode"] },
        { label: "Focus", subtitle: "Readable and restrained", accent: c.sapphire, command: [userBinPath + "/focus-mode"] },
        { label: "Battery", subtitle: "Lightweight fallback", accent: c.green, command: [userBinPath + "/battery-mode"] }
    ]

    readonly property var materialActions: [
        { label: "Mocha", material: "liquid-mocha", accent: c.teal },
        { label: "Prism", material: "liquid-prism", accent: c.mauve },
        { label: "Sapphire", material: "liquid-sapphire", accent: c.sapphire },
        { label: "Teal", material: "liquid-teal", accent: c.teal },
        { label: "Lavender", material: "liquid-lavender", accent: c.lavender },
        { label: "Peach", material: "liquid-peach", accent: c.peach },
        { label: "Rosewater", material: "liquid-rosewater", accent: c.rosewater },
        { label: "Mauve", material: "liquid-mauve", accent: c.mauve }
    ]

    readonly property var scratchActions: [
        { label: "Terminal", subtitle: "Open Ghostty", accent: c.sapphire, command: ["ghostty"] },
        { label: "Music", subtitle: "Open wheel menu", accent: c.rosewater, command: [userBinPath + "/quickshell-wheel"] },
        { label: "Notes", subtitle: "Open notes in editor", accent: c.yellow, command: ["/bin/sh", "-lc", "\"" + userBinPath + "/zed\" ~/Writing/notes"] },
        { label: "Dashboard", subtitle: "Center command surface", accent: c.mauve, command: [userBinPath + "/quickshell-dashboard"] }
    ]

    readonly property var utilityActions: [
        { label: "Wallpaper", subtitle: "Sync palette + wallpaper", accent: c.yellow, command: [userBinPath + "/wall-select"] },
        { label: "Material Menu", subtitle: "Focused window material", accent: c.mauve, command: [userBinPath + "/material-select"] },
        { label: "Edit Config", subtitle: "Open niri config dir", accent: c.sapphire, command: [userBinPath + "/niri-settings"] },
        { label: "Reload Niri", subtitle: "Load current config.kdl", accent: c.green, command: ["niri", "msg", "action", "load-config-file"] },
        { label: "Reload Shell", subtitle: "Restart quickshell", accent: c.sky, command: [userBinPath + "/quickshell-reload"] },
        { label: "Open Power Menu", subtitle: "System power actions", accent: c.red, command: [userBinPath + "/sys-menu"] }
    ]

    function runCommand(command) {
        Quickshell.execDetached({ command: command });
    }

    function materialLabel() {
        return materialState && materialState.label ? materialState.label : "Mocha";
    }

    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "#b011111b"
        opacity: controlCenterWindow.active ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 180 } }

        MouseArea {
            anchors.fill: parent
            onClicked: closeRequested()
        }

        Rectangle {
            id: card
            anchors.centerIn: parent
            width: Math.min(parent.width - 96, 1160)
            height: Math.min(parent.height - 96, 760)
            radius: 28
            color: "#d61b1b2b"
            border.width: 1
            border.color: "#40ffffff"
            scale: controlCenterWindow.active ? 1.0 : 0.96
            opacity: controlCenterWindow.active ? 1.0 : 0.0
            focus: true

            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 180 } }

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: "#24ffffff"
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 18

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 4

                        Text {
                            text: "Niri Control Center"
                            color: c.text
                            font.pixelSize: 30
                            font.bold: true
                        }

                        Text {
                            text: "Profile, material, scratch columns, and daily shell controls in one place."
                            color: c.subtext1
                            font.pixelSize: 14
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        radius: 16
                        color: "#22ffffff"
                        border.width: 1
                        border.color: "#30ffffff"
                        implicitWidth: 180
                        implicitHeight: 44

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                text: materialState && materialState.icon ? materialState.icon : "󰏘"
                                color: c.text
                                font.pixelSize: 18
                            }

                            ColumnLayout {
                                spacing: 0

                                Text {
                                    text: "Accent Material"
                                    color: c.subtext0
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: materialLabel()
                                    color: c.text
                                    font.pixelSize: 15
                                    font.bold: true
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    Repeater {
                        model: [
                            { title: "Profile", value: systemState ? systemState.profile : "-", accent: c.teal },
                            { title: "Brightness", value: systemState ? systemState.bright + "%" : "-", accent: c.yellow },
                            { title: "Volume", value: systemState ? (systemState.volMuted ? "Muted" : systemState.vol + "%") : "-", accent: c.sapphire },
                            { title: "Network", value: systemState ? systemState.net : "-", accent: c.green },
                            { title: "Battery", value: systemState ? systemState.batCap + "%" : "-", accent: c.peach }
                        ]

                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 86
                            radius: 22
                            color: "#16ffffff"
                            border.width: 1
                            border.color: "#22ffffff"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 2

                                Text {
                                    text: modelData.title
                                    color: c.subtext0
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: modelData.value
                                    color: modelData.accent
                                    font.pixelSize: 24
                                    font.bold: true
                                }
                            }
                        }
                    }
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: width
                    contentHeight: contentColumn.implicitHeight

                    ColumnLayout {
                        id: contentColumn
                        width: parent.width
                        spacing: 18

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 138
                            radius: 24
                            color: "#14ffffff"
                            border.width: 1
                            border.color: "#20ffffff"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 18
                                spacing: 12

                                Text {
                                    text: "Rice Profiles"
                                    color: c.text
                                    font.pixelSize: 19
                                    font.bold: true
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 12

                                    Repeater {
                                        model: profileActions

                                        Rectangle {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            implicitHeight: 64
                                            radius: 18
                                            color: "#1bffffff"
                                            border.width: 1
                                            border.color: modelData.accent

                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                onClicked: runCommand(modelData.command)
                                            }

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 14
                                                spacing: 1

                                                Text {
                                                    text: modelData.label
                                                    color: modelData.accent
                                                    font.pixelSize: 16
                                                    font.bold: true
                                                }
                                                Text {
                                                    text: modelData.subtitle
                                                    color: c.subtext1
                                                    font.pixelSize: 11
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 236
                            radius: 24
                            color: "#14ffffff"
                            border.width: 1
                            border.color: "#20ffffff"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 18
                                spacing: 12

                                Text {
                                    text: "Material Accents"
                                    color: c.text
                                    font.pixelSize: 19
                                    font.bold: true
                                }

                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 4
                                    columnSpacing: 12
                                    rowSpacing: 12

                                    Repeater {
                                        model: materialActions

                                        Rectangle {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            implicitHeight: 72
                                            radius: 18
                                            color: "#1bffffff"
                                            border.width: 1
                                            border.color: modelData.accent

                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                onClicked: runCommand([userBinPath + "/material-apply", modelData.material])
                                            }

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 14
                                                spacing: 2

                                                Text {
                                                    text: modelData.label
                                                    color: modelData.accent
                                                    font.pixelSize: 15
                                                    font.bold: true
                                                }
                                                Text {
                                                    text: modelData.material
                                                    color: c.subtext1
                                                    font.pixelSize: 11
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 150
                            radius: 24
                            color: "#14ffffff"
                            border.width: 1
                            border.color: "#20ffffff"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 18
                                spacing: 12

                                Text {
                                    text: "Scratch Columns"
                                    color: c.text
                                    font.pixelSize: 19
                                    font.bold: true
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 12

                                    Repeater {
                                        model: scratchActions

                                        Rectangle {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            implicitHeight: 72
                                            radius: 18
                                            color: "#1bffffff"
                                            border.width: 1
                                            border.color: modelData.accent

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: runCommand(modelData.command)
                                            }

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 14
                                                spacing: 2

                                                Text {
                                                    text: modelData.label
                                                    color: modelData.accent
                                                    font.pixelSize: 15
                                                    font.bold: true
                                                }
                                                Text {
                                                    text: modelData.subtitle
                                                    color: c.subtext1
                                                    font.pixelSize: 11
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 180
                            radius: 24
                            color: "#14ffffff"
                            border.width: 1
                            border.color: "#20ffffff"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 18
                                spacing: 12

                                Text {
                                    text: "Quick Actions"
                                    color: c.text
                                    font.pixelSize: 19
                                    font.bold: true
                                }

                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 3
                                    columnSpacing: 12
                                    rowSpacing: 12

                                    Repeater {
                                        model: utilityActions

                                        Rectangle {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            implicitHeight: 58
                                            radius: 18
                                            color: "#1bffffff"
                                            border.width: 1
                                            border.color: modelData.accent

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: runCommand(modelData.command)
                                            }

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 12
                                                spacing: 0

                                                Text {
                                                    text: modelData.label
                                                    color: modelData.accent
                                                    font.pixelSize: 14
                                                    font.bold: true
                                                }
                                                Text {
                                                    text: modelData.subtitle
                                                    color: c.subtext1
                                                    font.pixelSize: 10
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 118
                            radius: 24
                            color: "#14ffffff"
                            border.width: 1
                            border.color: "#20ffffff"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 18
                                spacing: 10

                                Text {
                                    text: "Gesture Map"
                                    color: c.text
                                    font.pixelSize: 19
                                    font.bold: true
                                }

                                Flow {
                                    width: parent.width
                                    spacing: 10

                                    Repeater {
                                        model: [
                                            "4F Up: Overview",
                                            "4F Left: Notes",
                                            "4F Right: Music",
                                            "5F Down: Dashboard",
                                            "5F Up: Terminal",
                                            "3F: Native workspace / column flow"
                                        ]

                                        Rectangle {
                                            required property string modelData
                                            radius: 999
                                            height: 34
                                            width: labelText.width + 26
                                            color: "#18ffffff"
                                            border.width: 1
                                            border.color: "#24ffffff"

                                            Text {
                                                id: labelText
                                                anchors.centerIn: parent
                                                text: modelData
                                                color: c.subtext1
                                                font.pixelSize: 12
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    closeRequested();
                    event.accepted = true;
                }
            }
        }
    }

    onActiveChanged: {
        if (active) {
            card.forceActiveFocus();
        }
    }
}
