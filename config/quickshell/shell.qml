import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import QtCore
import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import "./components"
import "./services"
import "./styles"

ShellRoot {
    id: root
    property string homePath: StandardPaths.writableLocation(StandardPaths.HomeLocation)
    property string configPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation)
    property string picturesPath: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
    property string userBinPath: homePath + "/.local/bin"
    property string userSharePath: homePath + "/.local/share"

    // Design System Colors
    Colors {
        id: c
    }

    // Mode state manager
    ModeState {
        id: modeState
    }

    // Dynamic Wallpaper Folder Model
    FolderListModel {
        id: wallpaperFolder
        folder: "file://" + picturesPath + "/Wallpapers"
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
        showDirs: false
        showDotAndDotDot: false
    }

    // ── State ──────────────────────────────────────────────
    QtObject {
        id: state
        property int cpu: 0
        property int mem: 0
        property int batCap: 100
        property string batStatus: "Full"
        property string vol: "0"
        property bool volMuted: false
        property int bright: 100
        property string net: "offline"
        property string btStatus: "off"
        property string profile: "normal"
        property string activeWindow: ""
        property var workspaces: []
        property var windows: []
        property string swayncAlt: "none"
        property int swayncCount: 0
    }

    QtObject {
        id: materialState
        property string icon: "󰏘"
        property string label: "Mocha"
        property string className: "material-mocha"
    }

    // ── Left Dock Autohide State ──────────────────────────
    property bool dockActive: false
    Timer {
        id: dockCollapseTimer
        interval: 350
        running: false
        repeat: false
        onTriggered: {
            dockActive = false
        }
    }

    // ── Bottom Bar Autohide State & Wallpaper ─────────────
    property bool bottomActive: false
    property string currentWallpaper: userSharePath + "/backgrounds/jackrose-glass-mocha.png"
    property bool ignoreHoverChange: false

    Timer {
        id: ignoreHoverTimer
        interval: 200
        running: false
        repeat: false
        onTriggered: {
            ignoreHoverChange = false
            if (!bottomHoverAreaHandler.hovered) {
                bottomCollapseTimer.start();
            }
        }
    }

    Timer {
        id: bottomCollapseTimer
        interval: 800
        running: false
        repeat: false
        onTriggered: {
            bottomActive = false
            // プレビューから元の壁紙へ確実に復元する
            Quickshell.execDetached({ command: [userBinPath + "/jackrose-wallpaper-apply", currentWallpaper] })
        }
    }

    // ── Right Dock Autohide State ─────────────────────────
    property bool rightDockActive: false
    property bool audioMeterHovered: false
    property bool mediaTooltipVisible: false
    
    // ── Clipboard Brain State ─────────────────────────────
    property bool clipboardPopupVisible: false
    property var clipboardHistory: []
    property string activeClipboardTab: "All"
    
    // ── Niri Minimap State ─────────────────────────────────
    property bool minimapPopupVisible: false
    property var niriMinimapState: ({})

    // ── Dotfiles Control Center State ──────────────────────
    property bool dotfilesActive: false
    property var dotfilesGitStatus: []

    Timer {
        id: tooltipCloseTimer
        interval: 300
        running: false
        repeat: false
        onTriggered: {
            mediaTooltipVisible = false;
        }
    }

    Timer {
        id: rightDockCollapseTimer
        interval: 350
        running: false
        repeat: false
        onTriggered: {
            rightDockActive = false
        }
    }

    // ── Mini Dashboard States & Operations ────────────────
    property bool dashboardActive: false
    
    QtObject {
        id: dashboardState
        property var files: []
        property var projects: []
        property string searchText: ""
    }

    Process {
        id: dashboardTrigger
        command: ["/bin/sh", "-c", "while true; do cat /tmp/quickshell-dashboard-flag 2>/dev/null && rm -f /tmp/quickshell-dashboard-flag; sleep 0.1; done"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim() === "toggle") {
                    dashboardActive = !dashboardActive;
                }
            }
        }
    }

    Process {
        id: dashboardDataFetcher
        command: ["python3", configPath + "/quickshell/dashboard_data.py"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                try {
                    var data = JSON.parse(line);
                    dashboardState.files = data.files || [];
                    dashboardState.projects = data.projects || [];
                } catch (e) {
                    console.log("Error parsing dashboard JSON: " + e);
                }
            }
        }
    }

    onDashboardActiveChanged: {
        if (dashboardActive) {
            dashboardDataFetcher.running = true;
        }
    }

    // ── Niri Control Center State & Operations ────────────
    property bool niriControlCenterActive: false

    Process {
        id: niriControlCenterTrigger
        command: ["/bin/sh", "-c", "while true; do cat /tmp/quickshell-niri-control-center-flag 2>/dev/null && rm -f /tmp/quickshell-niri-control-center-flag; sleep 0.1; done"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim() === "toggle") {
                    niriControlCenterActive = !niriControlCenterActive;
                }
            }
        }
    }

    Process {
        id: materialStateStream
        command: ["/bin/sh", "-c", "while true; do \"" + userBinPath + "/material-status\"; sleep 2; done"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (!line.trim()) return;
                try {
                    var data = JSON.parse(line);
                    materialState.icon = data.text || "󰏘";
                    materialState.label = (data.tooltip || "Material accent: Mocha").replace("Material accent: ", "");
                    materialState.className = data.class || "material-mocha";
                } catch (e) {}
            }
        }
    }

    // ── Click Wheel Menu States & Operations ──────────────
    property bool wheelMenuActive: false

    Process {
        id: wheelTrigger
        command: ["/bin/sh", "-c", "while true; do cat /tmp/quickshell-wheel-flag 2>/dev/null && rm -f /tmp/quickshell-wheel-flag; sleep 0.1; done"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim() === "toggle") {
                    wheelMenuActive = !wheelMenuActive;
                }
            }
        }
    }

    // ── Calendar Grid States ──────────────────────────────
    property int currentYear: new Date().getFullYear()
    property int currentMonth: new Date().getMonth()
    property string selectedDateStr: {
        var today = new Date();
        return today.getFullYear() + "-" + 
               (today.getMonth() + 1).toString().padStart(2, '0') + "-" + 
               today.getDate().toString().padStart(2, '0');
    }
    
    property string currentParsedDate: ""

    function changeMonth(dir) {
        var m = currentMonth + dir;
        var y = currentYear;
        if (m < 0) {
            m = 11;
            y -= 1;
        } else if (m > 11) {
            m = 0;
            y += 1;
        }
        currentMonth = m;
        currentYear = y;
    }

    function getMonthYearString(y, m) {
        var months = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"];
        return y + "年 " + (months[m] || "");
    }

    function hasEventOnDate(dateStr) {
        for (var i = 0; i < calendarEvents.length; i++) {
            if (calendarEvents[i].date === dateStr && !calendarEvents[i].isSpecial) {
                return true;
            }
        }
        return false;
    }

    function getEventsForDate(dateStr) {
        var filtered = [];
        for (var i = 0; i < calendarEvents.length; i++) {
            if (calendarEvents[i].date === dateStr && !calendarEvents[i].isSpecial) {
                filtered.push(calendarEvents[i]);
            }
        }
        if (filtered.length === 0) {
            return [{"displayText": "No events on this day", "summary": "", "date": dateStr, "isSpecial": true}];
        }
        return filtered;
    }

    function generateCalendar(year, month) {
        var firstDay = new Date(year, month, 1);
        var lastDay = new Date(year, month + 1, 0);
        
        var startDay = firstDay.getDay(); 
        var offset = startDay === 0 ? 6 : startDay - 1; 
        
        var days = [];
        
        // Prev month padding
        var prevMonthLastDay = new Date(year, month, 0).getDate();
        for (var i = offset - 1; i >= 0; i--) {
            var d = prevMonthLastDay - i;
            var pm = month === 0 ? 11 : month - 1;
            var py = month === 0 ? year - 1 : year;
            var dateStr = py + "-" + (pm + 1).toString().padStart(2, '0') + "-" + d.toString().padStart(2, '0');
            days.push({
                day: d,
                isCurrentMonth: false,
                isToday: false,
                dateStr: dateStr
            });
        }
        
        // Current month
        var today = new Date();
        var todayStr = today.getFullYear() + "-" + 
                       (today.getMonth() + 1).toString().padStart(2, '0') + "-" + 
                       today.getDate().toString().padStart(2, '0');
        var numDays = lastDay.getDate();
        for (var d = 1; d <= numDays; d++) {
            var dateStr = year + "-" + (month + 1).toString().padStart(2, '0') + "-" + d.toString().padStart(2, '0');
            var isToday = (todayStr === dateStr);
            days.push({
                day: d,
                isCurrentMonth: true,
                isToday: isToday,
                dateStr: dateStr
            });
        }
        
        // Next month padding
        var nextDays = 42 - days.length;
        for (var d = 1; d <= nextDays; d++) {
            var nm = month === 11 ? 0 : month + 1;
            var ny = month === 11 ? year + 1 : year;
            var dateStr = ny + "-" + (nm + 1).toString().padStart(2, '0') + "-" + d.toString().padStart(2, '0');
            days.push({
                day: d,
                isCurrentMonth: false,
                isToday: false,
                dateStr: dateStr
            });
        }
        
        return days;
    }

    // ── Calendar & TODO States ────────────────────────────
    property var calendarEvents: [{"displayText": "No events today", "summary": "", "date": "", "isSpecial": true}]
    property var todoTasks: [{"displayText": "No pending tasks", "id": "", "status": "", "date": "", "title": "No pending tasks", "isSpecial": true}]

    Process {
        id: calendarProc
        running: rightDockActive
        command: ["/bin/sh", "-lc", "if command -v khal >/dev/null 2>&1; then khal list today 30d; fi"]
        stdout: SplitParser {
            onRead: (line) => {
                if (!line.trim()) return;
                
                var dateMatch = line.match(/\d{4}-\d{2}-\d{2}/);
                if (dateMatch) {
                    currentParsedDate = dateMatch[0];
                    return;
                }
                
                if (calendarEvents.length === 1 && calendarEvents[0].isSpecial) {
                    calendarEvents = [];
                }
                
                var clean = line.trim();
                var summary = clean;
                var timeMatch = clean.match(/^\d{2}:\d{2}-\d{2}:\d{2}\s+(.*)$/);
                if (timeMatch) {
                    summary = timeMatch[1];
                }
                
                var newArr = calendarEvents.slice();
                newArr.push({
                    "displayText": clean,
                    "summary": summary,
                    "date": currentParsedDate,
                    "isSpecial": false
                });
                calendarEvents = newArr;
            }
        }
        onRunningChanged: {
            if (running) {
                calendarEvents = [{"displayText": "Loading calendar...", "summary": "", "date": "", "isSpecial": true}];
                currentParsedDate = "";
            } else {
                if (calendarEvents.length === 0 || calendarEvents[0].isSpecial) {
                    calendarEvents = [{"displayText": "No events today", "summary": "", "date": "", "isSpecial": true}];
                }
            }
        }
    }

    Process {
        id: todoProc
        running: rightDockActive
        command: [userBinPath + "/todo", "list"]
        stdout: SplitParser {
            onRead: (line) => {
                if (!line.trim()) return;
                
                if (todoTasks.length === 1 && todoTasks[0].isSpecial) {
                    todoTasks = [];
                }
                
                var raw = line.trim();
                var match = raw.match(/^\[([ xX]*)\]\s+(\d+)\s+([\d-]+\s+[\d:]+)?\s*(.*)$/);
                var isSpecial = false;
                var id = "";
                var status = "";
                var date = "";
                var title = raw;
                var displayText = raw;
                
                if (match) {
                    status = match[1].trim();
                    id = match[2];
                    date = match[3] ? match[3].trim() : "";
                    title = match[4].trim();
                    displayText = (status === "x" || status === "X" ? "☑ " : "☐ ") + title;
                }
                
                var newArr = todoTasks.slice();
                newArr.push({
                    "displayText": displayText,
                    "id": id,
                    "status": status,
                    "date": date,
                    "title": title,
                    "isSpecial": isSpecial
                });
                todoTasks = newArr;
            }
        }
        onRunningChanged: {
            if (running) {
                todoTasks = [{"displayText": "Loading tasks...", "id": "", "status": "", "date": "", "title": "Loading...", "isSpecial": true}];
            } else {
                if (todoTasks.length === 0 || todoTasks[0].isSpecial) {
                    todoTasks = [{"displayText": "No pending tasks", "id": "", "status": "", "date": "", "title": "No pending tasks", "isSpecial": true}];
                }
            }
        }
    }

    // ── Calendar/Todo Operations ────────────────────────
    Process {
        id: addEventProc
        command: [configPath + "/quickshell/add_event.sh", selectedDateStr]
        running: false
        onRunningChanged: {
            if (!running) {
                calendarProc.running = true;
            }
        }
    }

    Process {
        id: deleteEventProc
        property string eventSummary: ""
        command: [configPath + "/quickshell/delete_event.sh", eventSummary]
        running: false
        onRunningChanged: {
            if (!running) {
                calendarProc.running = true;
            }
        }
        function run(summary) {
            eventSummary = summary;
            running = true;
        }
    }

    Process {
        id: addTodoProc
        command: [configPath + "/quickshell/add_todo.sh"]
        running: false
        onRunningChanged: {
            if (!running) {
                todoProc.running = true;
            }
        }
    }

    Process {
        id: doneTodoProc
        property string todoId: ""
        command: [userBinPath + "/todo", "done", todoId]
        running: false
        onRunningChanged: {
            if (!running) {
                todoProc.running = true;
            }
        }
        function run(id) {
            todoId = id;
            running = true;
        }
    }

    Process {
        id: deleteTodoProc
        property string todoId: ""
        command: [userBinPath + "/todo", "delete", "--yes", todoId]
        running: false
        onRunningChanged: {
            if (!running) {
                todoProc.running = true;
            }
        }
        function run(id) {
            todoId = id;
            running = true;
        }
    }

    // ── Media State & Stream ──────────────────────────────
    QtObject {
        id: media
        property string title: "No Media"
        property string artist: "Idle"
        property string album: ""
        property string status: "Stopped"
    }

    Process {
        command: ["/bin/bash", configPath + "/quickshell/media-stream.sh"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (!line.trim()) return;
                try {
                    var data = JSON.parse(line);
                    media.title = data.title || "No Media";
                    media.artist = data.artist || "Idle";
                    media.album = data.album || "";
                    media.status = data.status || "Stopped";
                } catch(e) {}
            }
        }
    }

    // ── Clock ──────────────────────────────────────────────
    property string timeStr: ""
    property string dateStr: ""
    property int currentHour: 0
    property int currentMinute: 0
    property int currentSecond: 0
    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            var d = new Date();
            timeStr = d.getHours().toString().padStart(2, '0') + ":" + d.getMinutes().toString().padStart(2, '0');
            dateStr = d.getDate().toString();
            currentHour = d.getHours();
            currentMinute = d.getMinutes();
            currentSecond = d.getSeconds();
        }
    }

    // ── Stats Stream ───────────────────────────────────────
    Process {
        command: ["/bin/bash", configPath + "/quickshell/stats.sh"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (!line.trim()) return;
                try {
                    var data = JSON.parse(line);
                    state.cpu = data.cpu;
                    state.mem = data.mem;
                    state.batCap = data.bat_cap;
                    state.batStatus = data.bat_status;
                    state.vol = data.vol;
                    state.volMuted = data.vol_muted || false;
                    state.bright = data.bright;
                    state.net = data.net;
                    state.btStatus = data.bt || "off";
                    state.profile = data.profile || "normal";
                } catch (e) {}
            }
        }
    }

    // ── Niri Event Stream ──────────────────────────────────
    Process {
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (!line.trim()) return;
                try {
                    var event = JSON.parse(line);
                    if (event.WorkspacesChanged) {
                        var ws = event.WorkspacesChanged.workspaces;
                        ws.sort((a, b) => a.idx - b.idx);
                        state.workspaces = ws;
                    }
                    if (event.WindowsChanged) {
                        var windows = event.WindowsChanged.windows;
                        state.windows = windows;
                        var active = windows.find(w => w.is_focused);
                        state.activeWindow = active ? active.title : "";
                    }
                } catch (e) {}
            }
        }
    }

    // ── Swaync Event Stream ────────────────────────────────
    Process {
        command: ["swaync-client", "-swb"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (!line.trim()) return;
                try {
                    var data = JSON.parse(line);
                    state.swayncAlt = data.alt;
                    state.swayncCount = parseInt(data.text) || 0;
                } catch (e) {}
            }
        }
    }

    // ── Clipboard Brain Stream ────────────────────────────
    Process {
        command: ["python3", configPath + "/quickshell/clipboard-brain.py", "--watch"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (!line.trim()) return;
                try {
                    clipboardHistory = JSON.parse(line);
                } catch (e) {
                    console.log("Clipboard Brain Error: " + e);
                }
            }
        }
    }

    // ── Niri Minimap Stream ───────────────────────────────
    Process {
        command: ["python3", configPath + "/quickshell/niri-minimap.py"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (!line.trim()) return;
                try {
                    niriMinimapState = JSON.parse(line);
                } catch (e) {
                    console.log("Niri Minimap Error: " + e);
                }
            }
        }
    }

    // ── Dotfiles Control Center Processes ─────────────────
    Process {
        id: dotfilesTrigger
        command: ["/bin/sh", "-c", "while true; do cat /tmp/quickshell-dotfiles-flag 2>/dev/null && rm -f /tmp/quickshell-dotfiles-flag; sleep 0.1; done"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim() === "toggle") {
                    dotfilesActive = !dotfilesActive;
                    if (dotfilesActive) {
                        dotfilesFetcher.running = true;
                    }
                }
            }
        }
    }

    Process {
        id: dotfilesFetcher
        command: ["python3", configPath + "/quickshell/dotfiles-panel.py", "--status"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                try {
                    dotfilesGitStatus = JSON.parse(line);
                } catch (e) {}
            }
        }
    }

    Process {
        id: dotfilesCommitter
        running: false
        onRunningChanged: {
            if (!running) {
                dotfilesFetcher.running = true;
            }
        }
    }

    // ═══════════════════════════════════════════════════════
    // 1. TOP BAR — 36px, Liquid Glass
    // ═══════════════════════════════════════════════════════
    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }
        height: 36
        margins {
            top: 6
            left: 12
            right: 12
        }
        color: "transparent"

        Item {
            anchors.fill: parent

            // ── Left: Workspaces + App Title ────────────
            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                // Workspaces pill
                Rectangle {
                    color: c.surface
                    border.color: c.surfaceBorder
                    border.width: 1
                    radius: 13
                    implicitHeight: 28
                    implicitWidth: wsRow.width + 14
                    clip: true

                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        height: 1; color: c.surfaceHighlight
                    }

                    Row {
                        id: wsRow
                        anchors.centerIn: parent
                        spacing: 6

                        Repeater {
                            model: state.workspaces
                            delegate: Text {
                                text: {
                                    if (modelData.is_focused) return "●";
                                    if (modelData.is_active) return "○";
                                    if (modelData.is_urgent) return "!";
                                    if (modelData.active_window_id === null) return "·";
                                    return "○";
                                }
                                font.pixelSize: 13
                                font.bold: modelData.is_focused
                                color: modelData.is_focused ? c.mauve :
                                       (modelData.is_active ? c.text : c.subtext0)
                                opacity: modelData.active_window_id === null ? 0.4 : 1.0

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        Quickshell.execDetached({
                                            command: ["niri", "msg", "action", "focus-workspace", modelData.idx.toString()]
                                        })
                                    }
                                }
                            }
                        }
                    }
                }

                // App title pill
                Rectangle {
                    color: c.surface
                    border.color: c.surfaceBorder
                    border.width: 1
                    radius: 13
                    implicitHeight: 28
                    implicitWidth: Math.min(titleText.implicitWidth + 16, 320)
                    clip: true
                    visible: state.activeWindow !== ""

                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        height: 1; color: c.surfaceHighlight
                    }

                    Text {
                        id: titleText
                        anchors.centerIn: parent
                        text: {
                            var t = state.activeWindow;
                            if (t.indexOf("Mozilla Firefox") !== -1) return "󰈹  " + t.replace(" - Mozilla Firefox", "");
                            if (t.indexOf("ghostty") !== -1) return "  " + t.replace(" - ghostty", "");
                            if (t.indexOf("Thunar") !== -1) return "  " + t;
                            return "  " + t;
                        }
                        color: c.subtext0
                        font.pixelSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                        width: parent.width - 16
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // ── Center: Clock ───────────────────────────
            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                // Minimap Button
                Rectangle {
                    id: minimapBarButton
                    color: minimapHover.hovered ? c.surface1 : c.surface
                    border.color: minimapHover.hovered ? (niriMinimapState.has_urgent ? c.red : c.mauve) : c.surfaceBorder
                    border.width: 1
                    radius: 13
                    implicitHeight: 28
                    implicitWidth: minimapButtonText.implicitWidth + 14
                    scale: minimapHover.hovered ? 1.04 : 1.0

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        height: 1; color: minimapHover.hovered ? "transparent" : c.surfaceHighlight
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    Row {
                        id: minimapButtonText
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            text: "🗺️"
                            font.pixelSize: 11
                        }
                        Text {
                            text: {
                                var left = niriMinimapState.left_count || 0;
                                var right = niriMinimapState.right_count || 0;
                                return left + " 󰁍 󰁔 " + right;
                            }
                            color: niriMinimapState.has_urgent ? c.red : c.text
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    HoverHandler {
                        id: minimapHover
                        onHoveredChanged: {
                            if (hovered) {
                                minimapPopupVisible = true;
                            } else {
                                minimapPopupVisible = false;
                            }
                        }
                    }
                }

                // Clipboard Button
                Rectangle {
                    id: clipboardBarButton
                    color: clipboardHover.hovered ? c.surface1 : c.surface
                    border.color: clipboardHover.hovered ? c.rosewater : c.surfaceBorder
                    border.width: 1
                    radius: 13
                    implicitHeight: 28
                    implicitWidth: 32
                    scale: clipboardHover.hovered ? 1.04 : 1.0

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        height: 1; color: clipboardHover.hovered ? "transparent" : c.surfaceHighlight
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "📋"
                        font.pixelSize: 13
                    }

                    HoverHandler {
                        id: clipboardHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            clipboardPopupVisible = !clipboardPopupVisible;
                        }
                    }
                }

                Rectangle {
                    id: digitalClockPill
                    color: clockHover.hovered ? c.surface1 : c.surface
                    border.color: clockHover.hovered ? c.mauve : c.surfaceBorder
                    border.width: 1
                    radius: 13
                    implicitHeight: 28
                    implicitWidth: clockText.implicitWidth + 18
                    clip: true
                    scale: clockHover.hovered ? 1.04 : 1.0

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        height: 1; color: clockHover.hovered ? "transparent" : c.surfaceHighlight
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    Text {
                        id: clockText
                        anchors.centerIn: parent
                        text: "  " + timeStr
                        color: clockHover.hovered ? c.mauve : c.text
                        font.pixelSize: 13
                        font.bold: true
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    HoverHandler {
                        id: clockHover
                    }
                }


                // Audio meter bars next to clock
                Item {
                    id: audioMeterArea
                    width: audioMeterRow.width + 12
                    height: 28
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        id: audioMeterRow
                        spacing: 2
                        anchors.centerIn: parent

                        Repeater {
                            model: 16
                            delegate: Rectangle {
                                width: 4
                                height: 3 + Math.min(cavaBars[index] / 100.0, 1.0) * 14
                                radius: 2
                                anchors.verticalCenter: parent.verticalCenter
                                color: {
                                    var colors = [
                                        c.mauve, c.mauve, c.sapphire, c.sapphire,
                                        c.sky, c.sky, c.teal, c.teal,
                                        c.green, c.green, c.yellow, c.yellow,
                                        c.peach, c.peach, c.red, c.red
                                    ];
                                    return colors[index] || c.mauve;
                                }
                            }
                        }
                    }

                    HoverHandler {
                        id: audioMeterHover
                        onHoveredChanged: {
                            if (hovered) {
                                mediaTooltipVisible = true;
                                tooltipCloseTimer.stop();
                            } else {
                                tooltipCloseTimer.start();
                            }
                        }
                    }
                }
            }

            // ── Right: System Indicators ────────────────
            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                // Network
                Rectangle {
                    color: c.surface
                    border.color: c.surfaceBorder
                    border.width: 1
                    radius: 13
                    implicitHeight: 28
                    implicitWidth: netText.implicitWidth + 18
                    clip: true

                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        height: 1; color: c.surfaceHighlight
                    }

                    Text {
                        id: netText
                        anchors.centerIn: parent
                        text: {
                            if (state.net === "offline") return "󰖪  offline";
                            if (state.net === "wired") return "󰈀  wired";
                            if (state.net.startsWith("wifi:")) return "  " + state.net.substring(5);
                            return "  connected";
                        }
                        color: state.net === "offline" ? c.red : c.teal
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var panel = (state.net === "wired") ? "network" : "wifi";
                            Quickshell.execDetached({ command: ["gnome-control-center", panel] })
                        }
                    }
                }

                // Bluetooth
                Rectangle {
                    color: c.surface
                    border.color: c.surfaceBorder
                    border.width: 1
                    radius: 13
                    implicitHeight: 28
                    implicitWidth: btText.implicitWidth + 18
                    clip: true

                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        height: 1; color: c.surfaceHighlight
                    }

                    Text {
                        id: btText
                        anchors.centerIn: parent
                        text: state.btStatus === "on" ? "󰂯" : "󰂲"
                        color: state.btStatus === "on" ? c.sapphire : c.subtext0
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Quickshell.execDetached({ command: ["/bin/sh", "-lc", "command -v blueman-manager >/dev/null 2>&1 && exec blueman-manager || notify-send 'Jackrose' 'blueman is not installed.'"] })
                        }
                    }
                }

                // Volume
                Rectangle {
                    color: c.surface
                    border.color: c.surfaceBorder
                    border.width: 1
                    radius: 13
                    implicitHeight: 28
                    implicitWidth: volText.implicitWidth + 18
                    clip: true

                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        height: 1; color: c.surfaceHighlight
                    }

                    Text {
                        id: volText
                        anchors.centerIn: parent
                        text: state.volMuted ? "󰝟  muted" : "  " + state.vol + "%"
                        color: state.volMuted ? c.subtext0 : c.sapphire
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Quickshell.execDetached({ command: ["pavucontrol"] })
                        }
                    }
                }

                // Brightness
                Rectangle {
                    id: brightBarPill
                    color: brightBarScrollArea.containsMouse ? c.surface1 : c.surface
                    border.color: brightBarScrollArea.containsMouse ? c.yellow : c.surfaceBorder
                    border.width: 1
                    radius: 13
                    implicitHeight: 28
                    implicitWidth: brightText.implicitWidth + 18
                    clip: true
                    scale: brightBarScrollArea.containsMouse ? 1.04 : 1.0

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        height: 1; color: brightBarScrollArea.containsMouse ? "transparent" : c.surfaceHighlight
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    Text {
                        id: brightText
                        anchors.centerIn: parent
                        text: "󰃠  " + state.bright + "%"
                        color: c.yellow
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        id: brightBarScrollArea
                        anchors.fill: parent
                        hoverEnabled: true
                        
                        onWheel: (wheel) => {
                            var step = 5; // Change by 5%
                            var current = state.bright;
                            if (wheel.angleDelta.y > 0) {
                                current = Math.min(100, current + step);
                            } else {
                                current = Math.max(1, current - step);
                            }
                            state.bright = current;
                            Quickshell.execDetached({ command: ["brightnessctl", "set", current + "%"] });
                        }
                    }
                }

                // Battery
                Rectangle {
                    color: c.surface
                    border.color: c.surfaceBorder
                    border.width: 1
                    radius: 13
                    implicitHeight: 28
                    implicitWidth: batText.implicitWidth + 18
                    clip: true

                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        height: 1; color: c.surfaceHighlight
                    }

                    Text {
                        id: batText
                        anchors.centerIn: parent
                        text: {
                            var icon = (state.batCap >= 90) ? "󰁹" :
                                       (state.batCap >= 70) ? "󰂁" :
                                       (state.batCap >= 50) ? "󰁿" :
                                       (state.batCap >= 30) ? "󰁽" :
                                       (state.batCap >= 15) ? "󰁻" : "󰁺";
                            if (state.batStatus === "Charging") icon = "󰂄";
                            return icon + "  " + state.batCap + "%";
                        }
                        color: {
                            if (state.batStatus === "Charging") return c.teal;
                            if (state.batCap <= 15) return c.red;
                            if (state.batCap <= 30) return c.peach;
                            return c.green;
                        }
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                // Notification Bell
                Rectangle {
                    color: c.surface
                    border.color: notifyBorderColor
                    border.width: 1
                    radius: 13
                    implicitHeight: 28
                    implicitWidth: notifyRow.width + 16
                    clip: true

                    property color notifyBorderColor: {
                        if (state.swayncAlt.indexOf("dnd") !== -1) return "#33" + c.mauve.substring(1);
                        if (state.swayncCount > 0) return "#33" + c.sapphire.substring(1);
                        return c.surfaceBorder;
                    }

                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        height: 1; color: c.surfaceHighlight
                    }

                    Row {
                        id: notifyRow
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            id: notifyIcon
                            text: (state.swayncAlt.indexOf("dnd") !== -1) ? "󰂛" : "󰂚"
                            color: {
                                if (state.swayncAlt.indexOf("dnd") !== -1) return c.mauve;
                                if (state.swayncCount > 0) return c.sapphire;
                                return c.subtext0;
                            }
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            id: countText
                            text: state.swayncCount.toString()
                            visible: state.swayncCount > 0
                            color: c.subtext0
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.RightButton) {
                                Quickshell.execDetached({ command: ["swaync-client", "-d"] })
                            } else {
                                Quickshell.execDetached({ command: ["swaync-client", "-t"] })
                            }
                        }
                    }
                }

                // System Tray
                Rectangle {
                    color: c.surface
                    border.color: c.surfaceBorder
                    border.width: 1
                    radius: 13
                    implicitHeight: 28
                    implicitWidth: Math.max(trayRow.width + 12, 28)
                    visible: SystemTray.items.length > 0
                    clip: true

                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        height: 1; color: c.surfaceHighlight
                    }

                    Row {
                        id: trayRow
                        anchors.centerIn: parent
                        spacing: 6

                        Repeater {
                            model: SystemTray.items
                            delegate: Image {
                                source: modelData.icon
                                width: 16
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: modelData.activate()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Media Info Tooltip Popup ──────────────────────────
    PanelWindow {
        id: mediaTooltip
        WlrLayershell.namespace: "media-tooltip"
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        anchors {
            top: true
            right: true
        }
        margins {
            top: 46
            right: 12
        }
        width: 300
        height: 80
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        visible: mediaTooltipVisible || mediaTooltipContent.opacity > 0

        HoverHandler {
            onHoveredChanged: {
                if (hovered) {
                    mediaTooltipVisible = true;
                    tooltipCloseTimer.stop();
                } else {
                    tooltipCloseTimer.start();
                }
            }
        }

        Rectangle {
            id: mediaTooltipContent
            anchors.fill: parent
            anchors.margins: 4
            radius: 12
            color: "#dd1e1e2e"
            border.color: c.surfaceBorder
            border.width: 1
            opacity: mediaTooltipVisible ? 1.0 : 0.0
            scale: mediaTooltipVisible ? 1.0 : 0.92

            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - 24
                spacing: 6

                Text {
                    id: mediaTooltipText
                    Layout.fillWidth: true
                    text: {
                        if (media.status === "Stopped" || media.title === "No Media") {
                            return "No media playing";
                        }
                        var t = media.title;
                        if (media.artist && media.artist !== "Idle") {
                            t += " — " + media.artist;
                        }
                        if (media.album) {
                            t += "\n" + media.album;
                        }
                        return t;
                    }
                    color: c.text
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                // Media controls — only show when media is playing
                RowLayout {
                    id: mediaControlsRow
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8
                    visible: media.status !== "Stopped" && media.title !== "No Media"

                    // Previous
                    Rectangle {
                        width: 26; height: 26; radius: 13
                        color: prevHover.hovered ? c.surface1 : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: "⏮"
                            font.pixelSize: 12
                            color: c.subtext0
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            id: prevHover
                            onClicked: Quickshell.execDetached({ command: ["playerctl", "previous"] })
                        }
                    }

                    // Play/Pause
                    Rectangle {
                        width: 32; height: 32; radius: 16
                        color: playHover.hovered ? c.mauve : c.surface1
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: media.status === "Playing" ? "⏸" : "▶"
                            font.pixelSize: 14
                            color: playHover.hovered ? c.base : c.text
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            id: playHover
                            onClicked: Quickshell.execDetached({ command: ["playerctl", "play-pause"] })
                        }
                    }

                    // Next
                    Rectangle {
                        width: 26; height: 26; radius: 13
                        color: nextHover.hovered ? c.surface1 : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: "⏭"
                            font.pixelSize: 12
                            color: c.subtext0
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            id: nextHover
                            onClicked: Quickshell.execDetached({ command: ["playerctl", "next"] })
                        }
                    }
                }
            }
        }
    }

    // ── Dotfiles Control Center Popup ──────────────────
    PanelWindow {
        id: dotfilesPopup
        WlrLayershell.namespace: "dotfiles-popup"
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        visible: dotfilesActive || dotfilesPopupContent.opacity > 0

        Rectangle {
            anchors.fill: parent
            color: "#66000000"
            opacity: dotfilesActive ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    dotfilesActive = false;
                }
            }
        }

        Rectangle {
            id: dotfilesPopupContent
            anchors.centerIn: parent
            width: 540
            height: 480
            radius: 20
            color: "#f51e1e2e"
            border.color: c.surfaceBorder
            border.width: 1
            opacity: dotfilesActive ? 1.0 : 0.0
            scale: dotfilesActive ? 1.0 : 0.95

            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }

            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "⚙️  Dotfiles Control Center"
                        color: c.mauve
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Rectangle {
                        width: 24; height: 24; radius: 12
                        color: dotfilesCloseHover.hovered ? c.surface1 : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: c.subtext0
                            font.pixelSize: 12
                        }
                        HoverHandler { id: dotfilesCloseHover }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: dotfilesActive = false
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 20

                    ColumnLayout {
                        Layout.preferredWidth: 240
                        Layout.fillHeight: true
                        spacing: 8

                        Text {
                            text: "📁  DOTFILES"
                            color: c.teal
                            font.pixelSize: 11
                            font.bold: true
                        }

                        ListView {
                            id: dotfilesListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 4
                            
                            model: [
                                { "name": "niri config", "path": configPath + "/niri/config.kdl", "icon": "⚙️" },
                                { "name": "quickshell shell.qml", "path": configPath + "/quickshell/shell.qml", "icon": "💻" },
                                { "name": "quickshell styles", "path": configPath + "/quickshell/styles", "icon": "🎨" },
                                { "name": "swaync css", "path": configPath + "/swaync/style.css", "icon": "🔔" },
                                { "name": "ghostty config", "path": configPath + "/ghostty/config", "icon": "📟" },
                                { "name": "nvim config", "path": configPath + "/nvim/init.lua", "icon": "📝" },
                                { "name": "zshrc", "path": homePath + "/.zshrc", "icon": "🐚" },
                                { "name": "scripts", "path": userBinPath, "icon": "📜" }
                            ]

                            delegate: Rectangle {
                                width: dotfilesListView.width
                                height: 34
                                radius: 8
                                color: listHover.hovered ? c.surface1 : c.surface
                                border.color: listHover.hovered ? c.teal : c.surfaceBorder
                                border.width: 1
                                
                                Behavior on color { ColorAnimation { duration: 100 } }
                                Behavior on border.color { ColorAnimation { duration: 100 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 8

                                    Text {
                                        text: modelData.icon
                                        font.pixelSize: 14
                                    }

                                    Text {
                                        text: modelData.name
                                        color: c.text
                                        font.pixelSize: 12
                                        font.bold: listHover.hovered
                                    }
                                }

                                HoverHandler {
                                    id: listHover
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        Quickshell.execDetached({
                                            command: [userBinPath + "/zed", modelData.path]
                                        });
                                        dotfilesActive = false;
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        color: c.surfaceBorder
                        width: 1
                        Layout.fillHeight: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 12

                        Text {
                            text: "🐙  GIT VERSION CONTROL"
                            color: c.yellow
                            font.pixelSize: 11
                            font.bold: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: c.surface
                            border.color: c.surfaceBorder
                            border.width: 1
                            radius: 10
                            clip: true

                            ListView {
                                id: gitStatusListView
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 6
                                model: dotfilesGitStatus
                                
                                delegate: RowLayout {
                                    width: gitStatusListView.width
                                    spacing: 8

                                    Rectangle {
                                        width: 24; height: 16; radius: 4
                                        color: {
                                            if (modelData.status === "M") return c.yellow;
                                            if (modelData.status === "A") return c.green;
                                            if (modelData.status === "??") return c.sky;
                                            if (modelData.status === "D") return c.red;
                                            return c.subtext0;
                                        }
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.status
                                            color: c.base
                                            font.pixelSize: 9
                                            font.bold: true
                                        }
                                    }

                                    Text {
                                        text: modelData.path
                                        color: c.text
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "Clean (No modifications)"
                                    color: c.green
                                    font.pixelSize: 12
                                    font.bold: true
                                    visible: dotfilesGitStatus.length === 0
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            visible: dotfilesGitStatus.length > 0

                            Rectangle {
                                Layout.fillWidth: true
                                height: 32
                                color: c.surface
                                border.color: commitMessageField.activeFocus ? c.mauve : c.surfaceBorder
                                border.width: 1
                                radius: 8

                                TextInput {
                                    id: commitMessageField
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    verticalAlignment: Text.AlignVCenter
                                    color: c.text
                                    font.pixelSize: 11
                                    
                                    Text {
                                        text: "Enter commit message..."
                                        color: c.subtext0
                                        font.pixelSize: 11
                                        visible: !commitMessageField.text && !commitMessageField.activeFocus
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 32
                                radius: 8
                                color: commitMessageField.text.trim() !== "" ? c.mauve : c.surface0
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "Commit changes"
                                    color: commitMessageField.text.trim() !== "" ? c.base : c.subtext0
                                    font.bold: true
                                    font.pixelSize: 11
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: commitMessageField.text.trim() !== ""
                                    onClicked: {
                                        dotfilesCommitter.command = ["python3", configPath + "/quickshell/dotfiles-panel.py", "--commit", commitMessageField.text];
                                        dotfilesCommitter.start();
                                        commitMessageField.text = "";
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Niri Minimap Popup ─────────────────────────────
    PanelWindow {
        id: minimapPopup
        WlrLayershell.namespace: "niri-minimap-popup"
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        anchors {
            top: true
            left: true
            right: true
        }
        margins {
            top: 46
        }
        height: 110
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        visible: minimapPopupVisible || minimapPopupContent.opacity > 0

        HoverHandler {
            onHoveredChanged: {
                if (hovered) {
                    minimapPopupVisible = true;
                } else {
                    minimapPopupVisible = false;
                }
            }
        }

        Rectangle {
            id: minimapPopupContent
            anchors.horizontalCenter: parent.horizontalCenter
            width: 320
            height: parent.height
            radius: 16
            color: "#ee1e1e2e"
            border.color: c.surfaceBorder
            border.width: 1
            opacity: minimapPopupVisible ? 1.0 : 0.0
            scale: minimapPopupVisible ? 1.0 : 0.95

            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "🗺️  " + (niriMinimapState.workspace_name || "Workspace")
                        color: c.mauve
                        font.pixelSize: 13
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: niriMinimapState.active_app ? ("Active: " + niriMinimapState.active_app) : ""
                        color: c.subtext0
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                // Spatial columns display
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8
                    
                    Text {
                        text: "◀"
                        color: niriMinimapState.left_count > 0 ? c.text : c.surface0
                        font.pixelSize: 11
                        visible: niriMinimapState.left_count > 0
                    }

                    Row {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 4
                        
                        Repeater {
                            model: niriMinimapState.columns || []
                            delegate: Rectangle {
                                width: modelData.is_focused ? 48 : 32
                                height: 28
                                radius: 6
                                color: modelData.is_focused ? c.mauve : (modelData.is_urgent ? c.red : c.surface)
                                border.color: modelData.is_focused ? "transparent" : c.surfaceBorder
                                border.width: 1
                                
                                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    
                                    Repeater {
                                        model: modelData.windows || []
                                        delegate: Rectangle {
                                            width: 4
                                            height: 4
                                            radius: 2
                                            color: modelData.is_focused ? c.base : (modelData.is_urgent ? c.red : c.text)
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }

                                Text {
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 2
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: {
                                        if (modelData.windows && modelData.windows.length > 0) {
                                            var app = modelData.windows[0].app_id || modelData.windows[0].title || "";
                                            if (app.includes(".")) {
                                                app = app.split(".").pop();
                                            }
                                            return app.substring(0, 1).toUpperCase();
                                        }
                                        return "";
                                    }
                                    font.pixelSize: 8
                                    font.bold: true
                                    color: modelData.is_focused ? c.base : c.subtext0
                                }
                            }
                        }
                    }

                    Text {
                        text: "▶"
                        color: niriMinimapState.right_count > 0 ? c.text : c.surface0
                        font.pixelSize: 11
                        visible: niriMinimapState.right_count > 0
                    }
                }
                
                // Footer
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: {
                            var total = (niriMinimapState.columns ? niriMinimapState.columns.length : 0);
                            return total + " Columns Total"
                        }
                        color: c.subtext0
                        font.pixelSize: 9
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: niriMinimapState.has_urgent ? "⚠️ URGENT WINDOW DETECTED" : ""
                        color: c.red
                        font.pixelSize: 9
                        font.bold: true
                    }
                }
            }
        }
    }

    // ── Clipboard Brain Popup ──────────────────────────
    PanelWindow {
        id: clipboardPopup
        WlrLayershell.namespace: "clipboard-popup"
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        anchors {
            top: true
            right: true
        }
        margins {
            top: 46
            right: 12
        }
        width: 360
        height: 500
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        visible: clipboardPopupVisible || clipboardPopupContent.opacity > 0

        Rectangle {
            id: clipboardPopupContent
            anchors.fill: parent
            radius: 16
            color: "#ee1e1e2e"
            border.color: c.surfaceBorder
            border.width: 1
            opacity: clipboardPopupVisible ? 1.0 : 0.0
            scale: clipboardPopupVisible ? 1.0 : 0.95

            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "🧠  Clipboard Brain"
                        color: c.mauve
                        font.pixelSize: 15
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    
                    Rectangle {
                        width: 22; height: 22; radius: 11
                        color: closeHover.hovered ? c.surface1 : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: c.subtext0
                            font.pixelSize: 11
                        }
                        HoverHandler { id: closeHover }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: clipboardPopupVisible = false
                        }
                    }
                }

                // Tabs (All, Text, URL, Code, Image, File path)
                Flickable {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    contentWidth: tabRow.width
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Row {
                        id: tabRow
                        spacing: 6
                        
                        Repeater {
                            model: ["All", "Text", "URL", "Code", "Image", "File path"]
                            delegate: Rectangle {
                                height: 26
                                width: tabText.implicitWidth + 16
                                radius: 13
                                color: activeClipboardTab === modelData ? c.mauve : (tabHover.hovered ? c.surface1 : c.surface)
                                border.color: activeClipboardTab === modelData ? "transparent" : c.surfaceBorder
                                border.width: 1

                                Text {
                                    id: tabText
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: activeClipboardTab === modelData ? c.base : c.text
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                                
                                HoverHandler { id: tabHover }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: activeClipboardTab = modelData
                                }
                            }
                        }
                    }
                }

                // Divider
                Rectangle {
                    color: c.surfaceBorder; height: 1
                    Layout.fillWidth: true
                }

                // List View
                ListView {
                    id: clipboardListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    model: {
                        var filtered = [];
                        for (var i = 0; i < clipboardHistory.length; i++) {
                            var item = clipboardHistory[i];
                            if (activeClipboardTab === "All" || item.category === activeClipboardTab) {
                                filtered.push(item);
                            }
                        }
                        return filtered;
                    }

                    delegate: Rectangle {
                        width: clipboardListView.width
                        height: {
                            if (modelData.category === "Image") return 90;
                            if (modelData.category === "Code") return 80;
                            return 54;
                        }
                        radius: 8
                        color: itemHover.hovered ? c.surface1 : c.surface
                        border.color: itemHover.hovered ? c.mauve : c.surfaceBorder
                        border.width: 1
                        
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Behavior on border.color { ColorAnimation { duration: 100 } }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            hoverEnabled: true
                            onClicked: (mouse) => {
                                if (mouse.button === Qt.LeftButton) {
                                    Quickshell.execDetached({
                                        command: ["python3", configPath + "/quickshell/clipboard-brain.py", "copy", modelData.id]
                                    });
                                    Quickshell.execDetached({
                                        command: ["notify-send", "-t", "1500", "Clipboard Brain", "Copied to clipboard"]
                                    });
                                    clipboardPopupVisible = false;
                                } else if (mouse.button === Qt.RightButton) {
                                    Quickshell.execDetached({
                                        command: ["python3", configPath + "/quickshell/clipboard-brain.py", "save", modelData.id, modelData.category]
                                    });
                                }
                            }
                        }

                        HoverHandler {
                            id: itemHover
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            Text {
                                text: {
                                    if (modelData.category === "Text") return "📝";
                                    if (modelData.category === "URL") return "🔗";
                                    if (modelData.category === "Code") return "💻";
                                    if (modelData.category === "Image") return "🖼️";
                                    if (modelData.category === "File path") return "📁";
                                    return "📄";
                                }
                                font.pixelSize: 16
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 2

                                Text {
                                    text: modelData.category
                                    color: {
                                        if (modelData.category === "Text") return c.text;
                                        if (modelData.category === "URL") return c.teal;
                                        if (modelData.category === "Code") return c.yellow;
                                        if (modelData.category === "Image") return c.green;
                                        if (modelData.category === "File path") return c.sapphire;
                                        return c.subtext0;
                                    }
                                    font.pixelSize: 9
                                    font.bold: true
                                }

                                Text {
                                    visible: modelData.category !== "Image" && modelData.category !== "Code"
                                    text: modelData.preview
                                    color: c.text
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                    wrapMode: Text.Wrap
                                    verticalAlignment: Text.AlignVCenter
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }

                                Text {
                                    visible: modelData.category === "Code"
                                    text: modelData.preview
                                    color: c.yellow
                                    font.pixelSize: 10
                                    font.family: "Monospace"
                                    elide: Text.ElideRight
                                    maximumLineCount: 3
                                    wrapMode: Text.Wrap
                                    verticalAlignment: Text.AlignVCenter
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }

                                Image {
                                    visible: modelData.category === "Image"
                                    source: modelData.category === "Image" ? "file://" + modelData.content : ""
                                    fillMode: Image.PreserveAspectFit
                                    horizontalAlignment: Image.AlignLeft
                                    verticalAlignment: Image.AlignVCenter
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    asynchronous: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════
    // 2. LEFT DOCK — 52px margin, 44px glass panel
    // ═══════════════════════════════════════════════════════
    PanelWindow {
        WlrLayershell.namespace: "left-dock"
        anchors {
            left: true
            top: true
            bottom: true
        }
        width: dockActive ? 68 : 8
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        Item {
            id: dockHoverArea
            anchors.fill: parent
            z: dockActive ? -1 : 99
            HoverHandler {
                onHoveredChanged: {
                    if (hovered) {
                        dockCollapseTimer.stop();
                        dockActive = true;
                    } else {
                        dockCollapseTimer.start();
                    }
                }
            }
        }

        MultiPointTouchArea {
            anchors.fill: parent
            mouseEnabled: false
            onPressed: (touchPoints) => {
                if (touchPoints.length >= 4) {
                    wheelMenuActive = !wheelMenuActive;
                }
            }
        }

        Rectangle {
            id: dockBg
            color: c.surface
            border.color: c.surfaceBorder
            border.width: 1
            radius: 22
            width: 44
            height: Math.min(dockContent.implicitHeight + 20, parent.height - 24)
            anchors.verticalCenter: parent.verticalCenter
            x: dockActive ? 12 : -56
            opacity: dockActive ? 1.0 : 0.0

            Behavior on x {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }

            clip: true

            Rectangle {
                anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                height: 1; color: c.surfaceHighlight
            }

            ColumnLayout {
                id: dockContent
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                // ── App Launchers ───────────────────────

                // Launcher
                Rectangle {
                    color: "transparent"
                    implicitWidth: 30; implicitHeight: 30
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        anchors.fill: parent; radius: 8
                        color: c.surfaceHover
                        opacity: launcherMa.containsMouse ? 1.0 : 0.0
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰣇"; color: c.mauve; font.pixelSize: 18
                    }

                    MouseArea {
                        id: launcherMa
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: { Quickshell.execDetached({ command: ["fuzzel"] }) }
                    }
                }

                // Divider
                Rectangle {
                    color: c.surfaceBorder; height: 1
                    Layout.fillWidth: true
                    Layout.leftMargin: 4; Layout.rightMargin: 4
                }

                // Ghostty
                Rectangle {
                    color: "transparent"
                    implicitWidth: 30; implicitHeight: 30
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        anchors.fill: parent; radius: 8
                        color: c.surfaceHover
                        opacity: gtyMa.containsMouse ? 1.0 : 0.0
                    }

                    Text {
                        anchors.centerIn: parent
                        text: ""; color: c.sapphire; font.pixelSize: 18
                    }

                    MouseArea {
                        id: gtyMa
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: { Quickshell.execDetached({ command: ["ghostty"] }) }
                    }
                }

                // Thunar
                Rectangle {
                    color: "transparent"
                    implicitWidth: 30; implicitHeight: 30
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        anchors.fill: parent; radius: 8
                        color: c.surfaceHover
                        opacity: thunarMa.containsMouse ? 1.0 : 0.0
                    }

                    Text {
                        anchors.centerIn: parent
                        text: ""; color: c.yellow; font.pixelSize: 18
                    }

                    MouseArea {
                        id: thunarMa
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: { Quickshell.execDetached({ command: ["thunar"] }) }
                    }
                }

                // Zed
                Rectangle {
                    color: "transparent"
                    implicitWidth: 30; implicitHeight: 30
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        anchors.fill: parent; radius: 8
                        color: c.surfaceHover
                        opacity: zedMa.containsMouse ? 1.0 : 0.0
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰸰"; color: c.subtext0; font.pixelSize: 18
                    }

                    MouseArea {
                        id: zedMa
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: { Quickshell.execDetached({ command: [userBinPath + "/zed"] }) }
                    }
                }

                // Helix
                Rectangle {
                    color: "transparent"
                    implicitWidth: 30; implicitHeight: 30
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        anchors.fill: parent; radius: 8
                        color: c.surfaceHover
                        opacity: helixMa.containsMouse ? 1.0 : 0.0
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "🧬"; color: c.green; font.pixelSize: 16
                    }

                    MouseArea {
                        id: helixMa
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: { Quickshell.execDetached({ command: ["ghostty", "-e", "helix"] }) }
                    }
                }

                // Firefox
                Rectangle {
                    color: "transparent"
                    implicitWidth: 30; implicitHeight: 30
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        anchors.fill: parent; radius: 8
                        color: c.surfaceHover
                        opacity: ffMa.containsMouse ? 1.0 : 0.0
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰈹"; color: c.peach; font.pixelSize: 18
                    }

                    MouseArea {
                        id: ffMa
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: { Quickshell.execDetached({ command: ["firefox"] }) }
                    }
                }

                // ── Workspace Indicators ────────────────
                Rectangle {
                    color: c.surfaceBorder; height: 1
                    Layout.fillWidth: true
                    Layout.leftMargin: 4; Layout.rightMargin: 4
                }

                Column {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 4

                    Repeater {
                        model: state.workspaces
                        delegate: Rectangle {
                            width: 12; height: 12; radius: 6
                            color: modelData.is_focused ? c.mauve :
                                   (modelData.is_active ? c.text : c.surface0)
                            opacity: modelData.is_focused ? 1.0 :
                                     (modelData.is_active ? 0.7 : 0.3)
                            anchors.horizontalCenter: parent.horizontalCenter

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Quickshell.execDetached({
                                        command: ["niri", "msg", "action", "focus-workspace", modelData.idx.toString()]
                                    })
                                }
                            }
                        }
                    }
                }

                // ── Utility Buttons ────────────────────
                Rectangle {
                    color: c.surfaceBorder; height: 1
                    Layout.fillWidth: true
                    Layout.leftMargin: 4; Layout.rightMargin: 4
                }

                // Calendar
                Rectangle {
                    color: "transparent"
                    implicitWidth: 30; implicitHeight: 30
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        anchors.fill: parent; radius: 8
                        color: c.surfaceHover
                        opacity: calMa.containsMouse ? 1.0 : 0.0
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰃭"; color: c.peach; font.pixelSize: 16
                    }

                    MouseArea {
                        id: calMa
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: { Quickshell.execDetached({ command: [userBinPath + "/jackrose-calendar"] }) }
                    }
                }

                // Tasks
                Rectangle {
                    color: "transparent"
                    implicitWidth: 30; implicitHeight: 30
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        anchors.fill: parent; radius: 8
                        color: c.surfaceHover
                        opacity: taskMa.containsMouse ? 1.0 : 0.0
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰔡"; color: c.teal; font.pixelSize: 16
                    }

                    MouseArea {
                        id: taskMa
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            rightDockCollapseTimer.stop();
                            rightDockActive = true;
                            todoProc.running = true;
                        }
                    }
                }

                // Settings
                Rectangle {
                    color: "transparent"
                    implicitWidth: 30; implicitHeight: 30
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        anchors.fill: parent; radius: 8
                        color: c.surfaceHover
                        opacity: setMa.containsMouse ? 1.0 : 0.0
                    }

                    Text {
                        anchors.centerIn: parent
                        text: ""; color: c.subtext0; font.pixelSize: 16
                    }

                    MouseArea {
                        id: setMa
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: { Quickshell.execDetached({ command: [userBinPath + "/niri-settings"] }) }
                    }
                }

                // Screenshot
                Rectangle {
                    color: "transparent"
                    implicitWidth: 30; implicitHeight: 30
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        anchors.fill: parent; radius: 8
                        color: c.surfaceHover
                        opacity: shotMa.containsMouse ? 1.0 : 0.0
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰄀"; color: c.lavender; font.pixelSize: 16
                    }

                    MouseArea {
                        id: shotMa
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: { Quickshell.execDetached({ command: [userBinPath + "/screenshot-edit"] }) }
                    }
                }

                // Power
                Rectangle {
                    color: "transparent"
                    implicitWidth: 30; implicitHeight: 30
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        anchors.fill: parent; radius: 8
                        color: "#33f38ba8"
                        opacity: pwrMa.containsMouse ? 1.0 : 0.0
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "⏻"; color: c.red; font.pixelSize: 16
                    }

                    MouseArea {
                        id: pwrMa
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: { Quickshell.execDetached({ command: [userBinPath + "/sys-menu"] }) }
                    }
                }
            }
        }
    }

    // ── Cava Audio Visualizer Stream ───────────────────────
    property var cavaBars: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    Process {
        command: ["cava", "-p", configPath + "/cava/config"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (!line.trim()) return;
                if (line.indexOf("shader") !== -1) return;
                var parts = line.split(';');
                if (parts.length >= 16) {
                    var newBars = [];
                    for (var i = 0; i < 16; i++) {
                        var val = parseInt(parts[i]) || 0;
                        newBars.push(val);
                    }
                    cavaBars = newBars;
                }
            }
        }
    }

    PanelWindow {
        WlrLayershell.namespace: "bottom-bar"
        anchors {
            bottom: true
            left: true
            right: true
        }
        height: bottomActive ? 110 : 52
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        // Main content
        Item {
            anchors.fill: parent
            visible: bottomActive
            opacity: bottomActive ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            // ── 2段目: 壁紙クイック変更 (上部にスライドイン) ──
            Rectangle {
                id: wallpaperSection
                color: "#aa11111b"
                border.color: c.surfaceBorder
                border.width: 1
                radius: 12
                width: Math.min(wpRow.implicitWidth + 24, parent.width - 32)
                height: 48
                anchors.horizontalCenter: parent.horizontalCenter
                y: bottomActive ? 56 : 110
                opacity: bottomActive ? 1.0 : 0.0

                Behavior on y {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }

                RowLayout {
                    id: wpRow
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "󰸉"
                        color: c.mauve
                        font.pixelSize: 14
                        font.bold: true
                        Layout.rightMargin: 4
                    }

                    Repeater {
                        model: wallpaperFolder
                        delegate: Rectangle {
                            width: 72; height: 32; radius: 6; color: c.surfaceHover
                            border.color: c.surfaceBorder
                            border.width: 1

                            Text {
                                text: {
                                    var idx = fileName.lastIndexOf('.');
                                    var name = (idx !== -1) ? fileName.substring(0, idx) : fileName;
                                    return name.length > 8 ? name.substring(0, 6) + ".." : name;
                                }
                                color: c.text
                                font.pixelSize: 10
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    ignoreHoverChange = true;
                                    ignoreHoverTimer.start();
                                    Quickshell.execDetached({ command: [userBinPath + "/jackrose-wallpaper-apply", filePath] })
                                }
                                onExited: {
                                    ignoreHoverChange = true;
                                    ignoreHoverTimer.start();
                                    Quickshell.execDetached({ command: [userBinPath + "/jackrose-wallpaper-apply", currentWallpaper] })
                                }
                                onClicked: {
                                    ignoreHoverChange = true;
                                    ignoreHoverTimer.start();
                                    currentWallpaper = filePath;
                                    Quickshell.execDetached({ command: [userBinPath + "/jackrose-wallpaper-apply", currentWallpaper] })
                                }
                            }
                        }
                    }
                }
            }

            // ── 1段目: オーディオメーター (下部に固定) ──
            Rectangle {
                id: visualizerContainer
                visible: false
                color: "transparent"
                width: 240
                height: 40
                anchors.horizontalCenter: parent.horizontalCenter
                y: 6
                clip: true

                Row {
                    anchors.centerIn: parent
                    spacing: 4

                    Repeater {
                        model: 16
                        delegate: Rectangle {
                            width: 8
                            height: 4 + Math.min(cavaBars[index] / 100.0, 1.0) * 24
                            radius: 4
                            color: {
                                var colors = [
                                    c.mauve, c.mauve, c.sapphire, c.sapphire,
                                    c.sky, c.sky, c.teal, c.teal,
                                    c.green, c.green, c.yellow, c.yellow,
                                    c.peach, c.peach, c.red, c.red
                                ];
                                return colors[index] || c.mauve;
                            }
                        }
                    }
                }
            }
        }

        // Hover detection area (on top of content in z-order)
        Item {
            id: bottomHoverArea
            width: bottomActive ? Math.min(parent.width - 32, Math.max(wallpaperSection.width, 280)) : 220
            height: bottomActive ? 56 : 3
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            HoverHandler {
                id: bottomHoverAreaHandler
                onHoveredChanged: {
                    if (hovered) {
                        bottomCollapseTimer.stop();
                        bottomActive = true;
                    } else {
                        if (!ignoreHoverChange) {
                            bottomCollapseTimer.start();
                        }
                    }
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════
    // 4. RIGHT DOCK — Dashboard & Media Manager
    // ═══════════════════════════════════════════════════════
    PanelWindow {
        WlrLayershell.namespace: "right-dock"
        anchors {
            right: true
            top: true
            bottom: true
        }
        width: rightDockActive ? 260 : 8
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        Item {
            id: rightDockHoverArea
            anchors.fill: parent
            z: rightDockActive ? -1 : 99
            HoverHandler {
                onHoveredChanged: {
                    if (hovered) {
                        rightDockCollapseTimer.stop();
                        rightDockActive = true;
                    } else {
                        rightDockCollapseTimer.start();
                    }
                }
            }
        }

        Rectangle {
            id: rightDockBg
            color: "#a611111b" // 透過率を下げて（不透明度65%）視認性を確保
            border.color: c.surfaceBorder
            border.width: 1
            radius: 22
            width: 240
            height: parent.height - 24
            anchors.verticalCenter: parent.verticalCenter
            
            // 右端マージンをアニメーションさせてスライドイン
            anchors.right: parent.right
            anchors.rightMargin: rightDockActive ? 12 : -252
            opacity: rightDockActive ? 1.0 : 0.0

            Behavior on anchors.rightMargin {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }

            clip: true

            Rectangle {
                anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                height: 1; color: c.surfaceHighlight
            }

            ColumnLayout {
                id: rightDockContent
                anchors.fill: parent
                anchors.margins: 14
                spacing: 16

                // ── Section 1: Dashboard Header ────────
                Text {
                    text: "📊  DASHBOARD"
                    color: c.mauve
                    font.pixelSize: 13
                    font.bold: true
                    Layout.alignment: Qt.AlignLeft
                }

                // ── Section 2: System Status ───────────
                ColumnLayout {
                    spacing: 8
                    Layout.fillWidth: true

                    // CPU
                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "󰻠  CPU"; color: c.subtext0; font.pixelSize: 11; font.bold: true }
                            Item { Layout.fillWidth: true }
                            Text { text: state.cpu + "%"; color: c.text; font.pixelSize: 11; font.bold: true }
                        }
                        Rectangle {
                            height: 6; radius: 3; color: c.surface0; Layout.fillWidth: true
                            Rectangle {
                                height: 6; radius: 3; color: c.mauve; width: (parent.width * Math.min(state.cpu / 100.0, 1.0))
                                Behavior on width { NumberAnimation { duration: 200 } }
                            }
                        }
                    }

                    // Memory
                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "󰍛  MEM"; color: c.subtext0; font.pixelSize: 11; font.bold: true }
                            Item { Layout.fillWidth: true }
                            Text { text: state.mem + "%"; color: c.text; font.pixelSize: 11; font.bold: true }
                        }
                        Rectangle {
                            height: 6; radius: 3; color: c.surface0; Layout.fillWidth: true
                            Rectangle {
                                height: 6; radius: 3; color: c.sapphire; width: (parent.width * Math.min(state.mem / 100.0, 1.0))
                                Behavior on width { NumberAnimation { duration: 200 } }
                            }
                        }
                    }

                    // Battery
                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "󰁹  BAT"; color: c.subtext0; font.pixelSize: 11; font.bold: true }
                            Item { Layout.fillWidth: true }
                            Text { text: state.batCap + "% (" + state.batStatus + ")"; color: c.text; font.pixelSize: 11; font.bold: true }
                        }
                        Rectangle {
                            height: 6; radius: 3; color: c.surface0; Layout.fillWidth: true
                            Rectangle {
                                height: 6; radius: 3; color: c.green; width: (parent.width * Math.min(state.batCap / 100.0, 1.0))
                                Behavior on width { NumberAnimation { duration: 200 } }
                            }
                        }
                    }


                }

                // Divider
                Rectangle {
                    color: c.surfaceBorder; height: 1
                    Layout.fillWidth: true
                }

                // ── Section: Calendar ───────────────
                ColumnLayout {
                    spacing: 8
                    Layout.fillWidth: true

                    // 月・年のヘッダーと前後ボタン
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: getMonthYearString(currentYear, currentMonth)
                            color: c.rosewater
                            font.pixelSize: 13
                            font.bold: true
                        }
                        Item { Layout.fillWidth: true }
                        
                        // Prev month button
                        Item {
                            Layout.preferredWidth: 20; Layout.preferredHeight: 20
                            Text {
                                anchors.centerIn: parent
                                text: ""
                                color: prevMonthMouse.containsMouse ? c.rosewater : c.subtext0
                                font.pixelSize: 13
                            }
                            MouseArea {
                                id: prevMonthMouse
                                anchors.fill: parent; hoverEnabled: true
                                onClicked: changeMonth(-1)
                            }
                        }
                        // Next month button
                        Item {
                            Layout.preferredWidth: 20; Layout.preferredHeight: 20
                            Text {
                                anchors.centerIn: parent
                                text: ""
                                color: nextMonthMouse.containsMouse ? c.rosewater : c.subtext0
                                font.pixelSize: 13
                            }
                            MouseArea {
                                id: nextMonthMouse
                                anchors.fill: parent; hoverEnabled: true
                                onClicked: changeMonth(1)
                            }
                        }
                        // Add button
                        Item {
                            Layout.preferredWidth: 20; Layout.preferredHeight: 20
                            Text {
                                anchors.centerIn: parent
                                text: ""
                                color: addEventMouseArea.containsMouse ? c.rosewater : c.subtext0
                                font.pixelSize: 13
                            }
                            MouseArea {
                                id: addEventMouseArea
                                anchors.fill: parent; hoverEnabled: true
                                onClicked: addEventProc.running = true
                            }
                        }
                    }

                    // 曜日ヘッダー
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Repeater {
                            model: ["月", "火", "水", "木", "金", "土", "日"]
                            delegate: Text {
                                text: modelData
                                color: index === 5 ? c.sapphire : (index === 6 ? c.red : c.subtext0)
                                font.pixelSize: 10
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // カレンダーグリッド
                    Grid {
                        columns: 7
                        spacing: 0
                        Layout.fillWidth: true
                        
                        Repeater {
                            model: generateCalendar(currentYear, currentMonth)
                            delegate: Item {
                                width: parent.width / 7
                                height: 26
                                
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 20; height: 20; radius: 10
                                    color: modelData.isToday ? c.rosewater : (selectedDateStr === modelData.dateStr ? c.surface1 : "transparent")
                                    border.color: selectedDateStr === modelData.dateStr && !modelData.isToday ? c.rosewater : "transparent"
                                    border.width: 1
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.day
                                    color: modelData.isToday ? c.base : (modelData.isCurrentMonth ? c.text : c.surface0)
                                    font.pixelSize: 10
                                    font.bold: modelData.isToday
                                }
                                
                                // Event dot
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 2
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 3; height: 3; radius: 1.5
                                    color: modelData.isToday ? c.base : c.rosewater
                                    visible: hasEventOnDate(modelData.dateStr)
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        selectedDateStr = modelData.dateStr;
                                    }
                                }
                            }
                        }
                    }

                    // 選択された日付のテキスト
                    Text {
                        text: {
                            var parts = selectedDateStr.split('-');
                            return parts[1] + "月" + parts[2] + "日の予定:"
                        }
                        color: c.subtext0
                        font.pixelSize: 11
                        font.bold: true
                        Layout.topMargin: 4
                    }

                    // その日の予定リスト
                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true
                        Repeater {
                            model: getEventsForDate(selectedDateStr)
                            delegate: RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text {
                                    text: modelData.displayText
                                    color: modelData.isSpecial ? c.subtext0 : c.text
                                    font.pixelSize: 12
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1 // QML RowLayout wrapping bugfix
                                }
                                Item {
                                    Layout.preferredWidth: 20
                                    Layout.preferredHeight: 20
                                    visible: !modelData.isSpecial
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰆴"
                                        color: calDelMouse.containsMouse ? c.red : c.subtext0
                                        font.pixelSize: 12
                                    }
                                    MouseArea {
                                        id: calDelMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: deleteEventProc.run(modelData.summary)
                                    }
                                }
                            }
                        }
                    }
                }

                // Divider
                Rectangle {
                    color: c.surfaceBorder; height: 1
                    Layout.fillWidth: true
                }

                // ── Section: Todo ───────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        text: "☑  TASKS"
                        color: c.peach
                        font.pixelSize: 13
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Item {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: addTodoMouseArea.containsMouse ? c.peach : c.subtext0
                            font.pixelSize: 13
                        }
                        MouseArea {
                            id: addTodoMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: addTodoProc.running = true
                        }
                    }
                }

                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true
                    Repeater {
                        model: todoTasks
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Text {
                                text: modelData.displayText
                                color: modelData.isSpecial ? c.subtext0 : (modelData.status === "x" || modelData.status === "X" ? c.subtext0 : c.text)
                                font.pixelSize: 12
                                font.strikeout: modelData.status === "x" || modelData.status === "X"
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1 // QML RowLayout wrapping bugfix
                                MouseArea {
                                    anchors.fill: parent
                                    enabled: !modelData.isSpecial
                                    onClicked: {
                                        if (modelData.status !== "x" && modelData.status !== "X") {
                                            doneTodoProc.run(modelData.id)
                                        }
                                    }
                                }
                            }
                            Text {
                                text: modelData.date ? modelData.date.substring(5) : ""
                                color: c.subtext0
                                font.pixelSize: 10
                                visible: !modelData.isSpecial && modelData.date !== ""
                            }
                            Item {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                visible: !modelData.isSpecial
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰆴"
                                    color: todoDelMouse.containsMouse ? c.red : c.subtext0
                                    font.pixelSize: 12
                                }
                                MouseArea {
                                    id: todoDelMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: deleteTodoProc.run(modelData.id)
                                }
                            }
                        }
                    }
                }

                // Divider
                Rectangle {
                    color: c.surfaceBorder; height: 1
                    Layout.fillWidth: true
                }

                // ── Section 3: Media Player ───────────
                Text {
                    text: "🎵  NOW PLAYING"
                    color: c.teal
                    font.pixelSize: 13
                    font.bold: true
                    Layout.alignment: Qt.AlignLeft
                }

                ColumnLayout {
                    spacing: 8
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    // Track Title
                    Text {
                        text: media.title
                        color: c.text
                        font.pixelSize: 14
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Artist Name
                    Text {
                        text: media.artist
                        color: c.subtext0
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item { height: 4 }

                    // Media Controls
                    RowLayout {
                        spacing: 20
                        Layout.alignment: Qt.AlignHCenter

                        // Prev
                        Rectangle {
                            width: 30; height: 30; radius: 15; color: "transparent"
                            Text {
                                text: "󰒮"; color: c.text; font.pixelSize: 18; anchors.centerIn: parent
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Quickshell.execDetached({ command: ["playerctl", "previous"] })
                            }
                        }

                        // Play/Pause
                        Rectangle {
                            width: 36; height: 36; radius: 18; color: c.surfaceHover
                            Text {
                                text: media.status === "Playing" ? "󰏤" : "󰐊"
                                color: c.mauve; font.pixelSize: 22; anchors.centerIn: parent
                                anchors.horizontalCenterOffset: media.status === "Playing" ? 0 : 2
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Quickshell.execDetached({ command: ["playerctl", "play-pause"] })
                            }
                        }

                        // Next
                        Rectangle {
                            width: 30; height: 30; radius: 15; color: "transparent"
                            Text {
                                text: "󰒭"; color: c.text; font.pixelSize: 18; anchors.centerIn: parent
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Quickshell.execDetached({ command: ["playerctl", "next"] })
                            }
                        }
                    }
                }

                // Spacer
                Item { Layout.fillHeight: true }
            }
        }
    }

    // ── Click Wheel Menu Window ──────────────────────────
    WheelSwitcher {
        id: wheelMenuWindow
        active: wheelMenuActive
        systemState: state
        onActiveChanged: {
            wheelMenuActive = active;
        }
        onCloseRequested: {
            wheelMenuActive = false;
        }
    }

    // ── Analog Clock Hover Popup Window ──────────────────
    PanelWindow {
        id: analogClockWindow
        WlrLayershell.namespace: "analog-clock-popup"
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        anchors {
            top: true
        }
        margins {
            top: 40 // Positioned right under the top bar
        }
        implicitWidth: 170
        implicitHeight: 170
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        visible: (clockHover.hovered || analogClockHover.hovered) || analogClockContainer.opacity > 0

        // Main glass container
        Rectangle {
            id: analogClockContainer
            anchors.fill: parent
            radius: 20
            color: "#ee11111b" // Catppuccin crust with opacity
            border.color: c.surfaceBorder
            border.width: 1

            opacity: (clockHover.hovered || analogClockHover.hovered) ? 1.0 : 0.0
            scale: (clockHover.hovered || analogClockHover.hovered) ? 1.0 : 0.9
            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            // Highlight top border
            Rectangle {
                anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                height: 1; color: c.surfaceHighlight
                radius: 20
            }

            HoverHandler {
                id: analogClockHover
            }

            // Dial Container
            Item {
                width: 140; height: 140
                anchors.centerIn: parent

                // Dial Face Circle
                Rectangle {
                    anchors.fill: parent
                    radius: 70
                    color: "transparent"
                    border.color: "#1affffff"
                    border.width: 1
                }

                // Dial Center Pivot
                Item {
                    id: dialCenter
                    anchors.centerIn: parent
                }

                // Hour markers (12-hour tick lines)
                Repeater {
                    model: 12
                    delegate: Rectangle {
                        width: index % 3 === 0 ? 3 : 1.5
                        height: index % 3 === 0 ? 8 : 4
                        color: index % 3 === 0 ? c.mauve : c.subtext1
                        radius: 1
                        x: 70 - width / 2 + 56 * Math.cos((index * 30 - 90) * Math.PI / 180)
                        y: 70 - height / 2 + 56 * Math.sin((index * 30 - 90) * Math.PI / 180)
                        transform: Rotation {
                            origin.x: width / 2
                            origin.y: height / 2
                            angle: index * 30
                        }
                    }
                }

                // Hour Hand
                Rectangle {
                    id: hourHand
                    width: 4
                    height: 30
                    color: c.text
                    radius: 2
                    transformOrigin: Item.Bottom
                    anchors.bottom: dialCenter.verticalCenter
                    anchors.horizontalCenter: dialCenter.horizontalCenter
                    rotation: (currentHour % 12) * 30 + currentMinute * 0.5
                    Behavior on rotation {
                        RotationAnimation {
                            direction: RotationAnimation.Shortest
                            duration: 200
                        }
                    }
                }

                // Minute Hand
                Rectangle {
                    id: minuteHand
                    width: 3
                    height: 44
                    color: c.subtext0
                    radius: 1.5
                    transformOrigin: Item.Bottom
                    anchors.bottom: dialCenter.verticalCenter
                    anchors.horizontalCenter: dialCenter.horizontalCenter
                    rotation: currentMinute * 6 + currentSecond * 0.1
                    Behavior on rotation {
                        RotationAnimation {
                            direction: RotationAnimation.Shortest
                            duration: 200
                        }
                    }
                }

                // Second Hand
                Rectangle {
                    id: secondHand
                    width: 1.5
                    height: 52
                    color: c.mauve
                    radius: 1
                    transformOrigin: Item.Bottom
                    anchors.bottom: dialCenter.verticalCenter
                    anchors.horizontalCenter: dialCenter.horizontalCenter
                    rotation: currentSecond * 6
                    Behavior on rotation {
                        RotationAnimation {
                            direction: RotationAnimation.Shortest
                            duration: 150
                        }
                    }
                }

                // Center Cap
                Rectangle {
                    width: 8; height: 8; radius: 4
                    color: c.rosewater
                    anchors.centerIn: parent
                }
            }
        }
    }

    // ── Brightness Control Popup Window ──────────────────
    PanelWindow {
        id: brightnessPopupWindow
        WlrLayershell.namespace: "brightness-popup"
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        anchors {
            top: true
            right: true
        }
        margins {
            top: 40 // Just below the top bar
            right: 50 // Aligned under the top bar brightness pill
        }
        implicitWidth: 120
        implicitHeight: 36
        color: "transparent"
        visible: (brightBarScrollArea.containsMouse || brightnessPopupHover.hovered || brightnessPopupMouse.pressed) || brightnessPopupContainer.opacity > 0

        Rectangle {
            id: brightnessPopupContainer
            anchors.fill: parent
            radius: 12
            color: "#ee11111b"
            border.color: c.surfaceBorder
            border.width: 1

            opacity: (brightBarScrollArea.containsMouse || brightnessPopupHover.hovered || brightnessPopupMouse.pressed) ? 1.0 : 0.0
            scale: (brightBarScrollArea.containsMouse || brightnessPopupHover.hovered || brightnessPopupMouse.pressed) ? 1.0 : 0.9
            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            // Highlight top border
            Rectangle {
                anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                height: 1; color: c.surfaceHighlight
                radius: 12
            }

            HoverHandler {
                id: brightnessPopupHover
            }

            Rectangle {
                id: popupSliderBg
                width: 100; height: 6; radius: 3
                color: c.surface0
                anchors.centerIn: parent

                Rectangle {
                    height: 6; radius: 3
                    color: c.yellow
                    width: parent.width * (state.bright / 100.0)
                }

                Rectangle {
                    width: 10; height: 10; radius: 5
                    color: c.text
                    border.color: c.yellow
                    border.width: 1
                    x: (parent.width * (state.bright / 100.0)) - 5
                    y: -2
                }

                MouseArea {
                    id: brightnessPopupMouse
                    anchors.fill: parent
                    preventStealing: true

                    property int pendingPercentage: -1

                    Timer {
                        id: popupThrottleTimer
                        interval: 50
                        running: false
                        repeat: false
                        onTriggered: {
                            if (parent.pendingPercentage !== -1) {
                                Quickshell.execDetached({ command: ["brightnessctl", "set", parent.pendingPercentage + "%"] });
                                parent.pendingPercentage = -1;
                            }
                        }
                    }

                    function updateBrightness(mouse) {
                        var percentage = Math.round(Math.max(1, Math.min(100, (mouse.x / width) * 100)));
                        state.bright = percentage;
                        pendingPercentage = percentage;
                        if (!popupThrottleTimer.running) {
                            Quickshell.execDetached({ command: ["brightnessctl", "set", percentage + "%"] });
                            pendingPercentage = -1;
                            popupThrottleTimer.start();
                        }
                    }

                    onPressed: (mouse) => updateBrightness(mouse)
                    onPositionChanged: (mouse) => {
                        if (pressed) {
                            updateBrightness(mouse);
                        }
                    }
                    onReleased: (mouse) => {
                        var percentage = Math.round(Math.max(1, Math.min(100, (mouse.x / width) * 100)));
                        state.bright = percentage;
                        Quickshell.execDetached({ command: ["brightnessctl", "set", percentage + "%"] });
                        popupThrottleTimer.stop();
                        pendingPercentage = -1;
                    }
                }
            }
        }
    }

    // ── Mini Dashboard Overview Window ───────────────────
    QuickWorkspace {
        id: dashboardWindow
        active: dashboardActive
        systemState: state
        modeState: modeState
        openTasksPanel: function() {
            rightDockCollapseTimer.stop();
            rightDockActive = true;
            todoProc.running = true;
        }
        onActiveChanged: {
            dashboardActive = active;
        }
        onCloseRequested: {
            dashboardActive = false;
        }
    }

    NiriControlCenter {
        id: niriControlCenterWindow
        active: niriControlCenterActive
        systemState: state
        materialState: materialState
        onActiveChanged: {
            niriControlCenterActive = active;
        }
        onCloseRequested: {
            niriControlCenterActive = false;
        }
    }
}
