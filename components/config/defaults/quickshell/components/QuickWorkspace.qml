import Quickshell
import Quickshell.Wayland
import QtCore
import QtQuick
import QtQuick.Layouts
import "../styles"
import "../services"

PanelWindow {
    id: dashboardWindow
    
    // Properties to link with shell.qml root states
    property bool active: false
    property var systemState // Reference to root state object
    property var modeState   // Reference to ModeState service
    property var openTasksPanel
    property string homePath: StandardPaths.writableLocation(StandardPaths.HomeLocation)
    property string userBinPath: homePath + "/.local/bin"
    signal closeRequested()

    WlrLayershell.namespace: "overview-dashboard"
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
    visible: active || dashboardContainer.opacity > 0

    // Design System References
    Colors { id: c }
    Metrics { id: metrics }

    // Dashboard Internal State
    property int selectedTileIndex: 0
    property string timeString: "00:00"

    onActiveChanged: {
        if (active) {
            dashboardContainer.forceActiveFocus();
            selectedTileIndex = 0;
            updateTime();
        }
    }

    function updateTime() {
        var date = new Date();
        var h = date.getHours().toString().padStart(2, '0');
        var m = date.getMinutes().toString().padStart(2, '0');
        timeString = h + ":" + m;
    }

    Timer {
        interval: 1000
        running: dashboardWindow.active
        repeat: true
        onTriggered: updateTime()
    }

    // Tiles Metadata
    property var tilesData: [
        { id: "write", title: "Write", subtitle: "Markdown / Notes", icon: "📝", accent: c.mauve, script: userBinPath + "/write-mode" },
        { id: "research", title: "Research", subtitle: "Papers / Web / Notes", icon: "🔬", accent: c.sapphire, script: userBinPath + "/research-mode" },
        { id: "code", title: "Code", subtitle: "Python / Config", icon: "💻", accent: c.green, script: userBinPath + "/code-mode" },
        { id: "r-stats", title: "R / Stats", subtitle: "Econometrics", icon: "󰟔", accent: c.sky, script: userBinPath + "/r-mode" },
        { id: "reading", title: "Reading", subtitle: "PDF / Books", icon: "📚", accent: c.yellow, script: userBinPath + "/reading-mode" },
        { id: "music", title: "Music", subtitle: "Audio / Meter", icon: "🎵", accent: c.rosewater, script: userBinPath + "/music-mode" },
        { id: "files", title: "Files", subtitle: "File Manager", icon: "📁", accent: c.teal, script: "thunar" },
        { id: "battery", title: "Battery", subtitle: "Low power mode", icon: "🔋", accent: c.green, script: userBinPath + "/battery-mode" },
        { id: "showcase", title: "Showcase", subtitle: "Unixporn mode", icon: "󰃠", accent: c.peach, script: userBinPath + "/showcase-mode" },
        { id: "niri-control", title: "Niri Control", subtitle: "Shell / Rice / Gestures", icon: "󰒓", accent: c.mauve, script: userBinPath + "/niri-control-center" }
    ]

    function executeTile(index) {
        if (index < 0 || index >= tilesData.length) return;
        var tile = tilesData[index];
        
        // If it's a mode tile, update the ModeState
        if (tile.id === "battery") {
            modeState.setMode("battery");
        } else if (tile.id === "showcase") {
            modeState.setMode("showcase");
        } else {
            // Default workspace launches or script executions
            Quickshell.execDetached({ command: ["bash", "-c", tile.script] });
        }
        closeRequested();
    }

    // Fullscreen translucent backdrop
    Rectangle {
        id: dashboardContainer
        anchors.fill: parent
        color: "#b011111b" // Translucent dark overlay
        opacity: dashboardWindow.active ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 180 } }

        // Close when clicking empty space
        MouseArea {
            anchors.fill: parent
            onClicked: closeRequested()
        }

        // Keyboard navigation handler
        focus: true
        Keys.onPressed: (event) => {
            // Close on Escape
            if (event.key === Qt.Key_Escape) {
                closeRequested();
                event.accepted = true;
                return;
            }
            
            // Numeric selection (1-9)
            if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                var idx = event.key - Qt.Key_1;
                executeTile(idx);
                event.accepted = true;
                return;
            }

            // Grid movement navigation
            if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
                selectedTileIndex = (selectedTileIndex - 1 + 9) % 9;
                event.accepted = true;
            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
                selectedTileIndex = (selectedTileIndex + 1) % 9;
                event.accepted = true;
            } else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) {
                selectedTileIndex = (selectedTileIndex - 3 + 9) % 9;
                event.accepted = true;
            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) {
                selectedTileIndex = (selectedTileIndex + 3) % 9;
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                executeTile(selectedTileIndex);
                event.accepted = true;
            }
        }

        // Main Centered Dashboard Card
        Rectangle {
            id: mainCard
            width: metrics.cardWidth; height: metrics.cardHeight
            radius: metrics.radiusCard
            color: "#ee1e1e2e" // Catppuccin base with opacity
            border.color: c.surfaceBorder
            border.width: 1
            anchors.centerIn: parent

            scale: dashboardWindow.active ? 1.0 : 0.92
            opacity: dashboardWindow.active ? 1.0 : 0.0
            Behavior on scale { NumberAnimation { duration: 320; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 180 } }

            // Block clicks from propagating to background close handler
            MouseArea {
                anchors.fill: parent
                onClicked: (mouse) => { mouse.accepted = true; }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: metrics.paddingCard
                spacing: metrics.spacingCard

                // ── 1. HEADER SECTION ──
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: "QuickWorkspace"
                            color: c.text
                            font.pixelSize: 18
                            font.bold: true
                        }
                        Text {
                            text: "Mode: " + modeState.currentMode.toUpperCase()
                            color: {
                                if (modeState.currentMode === "focus") return c.mauve;
                                if (modeState.currentMode === "battery") return c.green;
                                if (modeState.currentMode === "showcase") return c.peach;
                                return c.sapphire;
                            }
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Header Status Badges
                    RowLayout {
                        spacing: 12

                        // Time
                        Text {
                            text: timeString
                            color: c.text
                            font.pixelSize: 14
                            font.bold: true
                        }

                        // Separator
                        Text { text: "|"; color: c.surface2; font.pixelSize: 12 }

                        // Battery status
                        Text {
                            text: "🔋 " + systemState.batCap + "%"
                            color: systemState.batCap > 20 ? c.green : c.red
                            font.pixelSize: 12
                        }

                        // Wi-Fi Status
                        Text {
                            text: "🌐 " + (systemState.net === "offline" ? "Offline" : "Online")
                            color: systemState.net === "offline" ? c.subtext0 : c.sapphire
                            font.pixelSize: 12
                        }

                        // DND Status
                        Text {
                            text: "🚫 DND " + (modeState.dnd ? "ON" : "OFF")
                            color: modeState.dnd ? c.mauve : c.subtext0
                            font.pixelSize: 12
                            font.bold: modeState.dnd
                        }
                    }
                }

                // ── 2. MAIN WORKSPACE TILES (3x3 Grid) ──
                GridLayout {
                    columns: 3
                    rowSpacing: metrics.spacingGrid
                    columnSpacing: metrics.spacingGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Repeater {
                        model: tilesData.length
                        delegate: LiquidTile {
                            title: tilesData[modelData].title
                            subtitle: tilesData[modelData].subtitle
                            iconText: tilesData[modelData].icon
                            accentColor: tilesData[modelData].accent
                            isSelected: selectedTileIndex === modelData
                            onClicked: executeTile(modelData)
                        }
                    }
                }

                // ── 3. RECENT WORK SECTION ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "RECENT"
                        color: c.subtext1
                        font.pixelSize: 10
                        font.bold: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        // Fixed Recent shortcut helpers
                        property var recents: [
                            { name: "Writing", path: "~/Writing", icon: "📝", cmd: "ghostty --working-directory=~/Writing -e nvim" },
                            { name: "Research", path: "~/Research", icon: "🔬", cmd: "thunar ~/Research" },
                            { name: "Projects", path: "~/Projects", icon: "💻", cmd: "ghostty --working-directory=~/Projects -e nvim" },
                            { name: "Screenshots", path: "~/Pictures/Screenshots", icon: "📸", cmd: "thunar ~/Pictures/Screenshots" },
                            { name: "Downloads", path: "~/Downloads", icon: "📥", cmd: "thunar ~/Downloads" },
                            { name: "Dotfiles", path: "~/.config", icon: "⚙️", cmd: "ghostty --working-directory=~/.config -e nvim" }
                        ]

                        Repeater {
                            model: parent.recents
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 32
                                radius: 8
                                color: recMouse.containsMouse ? c.surface1 : c.surface0
                                border.color: recMouse.containsMouse ? c.mauve : c.surfaceBorder
                                border.width: 1
                                Behavior on color { ColorAnimation { duration: 100 } }
                                Behavior on border.color { ColorAnimation { duration: 100 } }

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Text { text: modelData.icon; font.pixelSize: 12 }
                                    Text { text: modelData.name; color: c.text; font.pixelSize: 11 }
                                }

                                MouseArea {
                                    id: recMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        Quickshell.execDetached({ command: ["bash", "-c", modelData.cmd] });
                                        closeRequested();
                                    }
                                }
                            }
                        }
                    }
                }

                // ── 4. BOTTOM ACTIONS (FOOTER) ──
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: c.surfaceBorder
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    property var footers: [
                        { name: "Calendar", icon: "📅", cmd: userBinPath + "/jackrose-calendar" },
                        { name: "Tasks", icon: "☑", action: "tasks" },
                        { name: "Notes", icon: "🗒", cmd: "\"" + userBinPath + "/zed\" ~/Writing/notes" },
                        { name: "Files", icon: "📂", cmd: "thunar" },
                        { name: "Clipboard", icon: "📋", cmd: userBinPath + "/clip-menu" },
                        { name: "Screenshot", icon: "📸", cmd: userBinPath + "/screenshot-edit" },
                        { name: "Power", icon: "⏻", cmd: userBinPath + "/sys-menu" }
                    ]

                    Repeater {
                        model: parent.footers
                        delegate: Rectangle {
                            height: 30
                            implicitWidth: footerText.implicitWidth + 24
                            radius: 6
                            color: footMouse.containsMouse ? c.surface1 : "transparent"
                            Behavior on color { ColorAnimation { duration: 100 } }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                Text { text: modelData.icon; font.pixelSize: 12 }
                                Text { 
                                    id: footerText
                                    text: modelData.name
                                    color: footMouse.containsMouse ? c.mauve : c.subtext0
                                    font.pixelSize: 11
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }
                            }

                                MouseArea {
                                    id: footMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if (modelData.action === "tasks" && openTasksPanel) {
                                            openTasksPanel();
                                        } else {
                                            Quickshell.execDetached({ command: ["bash", "-c", modelData.cmd] });
                                        }
                                        closeRequested();
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
}
