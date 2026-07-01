import QtQuick
import QtQuick.Layouts
import "../styles"

Rectangle {
    id: tile

    // Properties
    property string title: ""
    property string subtitle: ""
    property string iconText: ""
    property string accentColor: "#cba6f7"
    property bool isSelected: false

    signal clicked()

    Colors { id: c }
    Metrics { id: metrics }

    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: metrics.radiusTile

    // Glassmorphism styling based on design spec
    color: isSelected ? "#5911111b" : (mouseArea.containsMouse ? "#3811111b" : "#2111111b")
    border.color: isSelected ? accentColor : (mouseArea.containsMouse ? "rgba(255, 255, 255, 0.40)" : "rgba(255, 255, 255, 0.20)")
    border.width: 1

    // Tactile animation
    scale: mouseArea.pressed ? 0.95 : (isSelected ? 1.02 : (mouseArea.containsMouse ? 1.02 : 1.0))

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }
    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

    // Subtle inner glow
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.color: "#14ffffff"
        border.width: 1
        anchors.margins: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 4

        RowLayout {
            spacing: 8
            Layout.fillWidth: true

            Text {
                text: tile.iconText
                font.pixelSize: 18
                color: tile.accentColor
            }

            Text {
                text: tile.title
                color: tile.isSelected || mouseArea.containsMouse ? tile.accentColor : c.text
                font.pixelSize: 13
                font.bold: true
                Layout.fillWidth: true
                Behavior on color { ColorAnimation { duration: 120 } }
            }
        }

        Text {
            text: tile.subtitle
            color: c.subtext0
            font.pixelSize: 10
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: tile.clicked()
    }
}
