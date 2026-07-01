import QtQuick
import Quickshell
import QtCore

QtObject {
    id: modeState
    property string homePath: StandardPaths.writableLocation(StandardPaths.HomeLocation)
    property string userBinPath: homePath + "/.local/bin"

    // Mode state: daily | focus | battery | showcase
    property string currentMode: "daily"

    // DND state
    property bool dnd: false

    // Audio meter state: off | subtle | full
    property string audioMeterMode: "subtle"

    // Power profile: balanced | power-saver | performance
    property string powerProfile: "balanced"

    function setMode(mode) {
        currentMode = mode

        // Execute corresponding system mode script
        switch(mode) {
            case "daily":
                dnd = false
                audioMeterMode = "subtle"
                powerProfile = "balanced"
                Quickshell.execDetached({ command: [userBinPath + "/daily-mode"] })
                break
            case "focus":
                dnd = true
                audioMeterMode = "off"
                powerProfile = "balanced"
                Quickshell.execDetached({ command: [userBinPath + "/focus-mode"] })
                break
            case "battery":
                dnd = false
                audioMeterMode = "off"
                powerProfile = "power-saver"
                Quickshell.execDetached({ command: [userBinPath + "/battery-mode"] })
                break
            case "showcase":
                dnd = false
                audioMeterMode = "full"
                powerProfile = "performance"
                Quickshell.execDetached({ command: [userBinPath + "/showcase-mode"] })
                break
        }
    }
}
