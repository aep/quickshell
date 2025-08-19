import Quickshell
import QtQuick

PanelWindow {
    id: root
    
    property string text: ""
    
    visible: text !== ""
    
    width: tooltipText.implicitWidth + 10
    height: tooltipText.implicitHeight + 6
    
    exclusionMode: ExclusionMode.Ignore
    
    anchors.left: false
    anchors.right: false  
    anchors.top: false
    anchors.bottom: false
    anchors.horizontalCenter: true
    anchors.verticalCenter: true
    
	color: "#333333"

    Rectangle {
        anchors.fill: parent
        color: "#333333"
        border.color: "#666666"
        border.width: 1
        radius: 3
        
        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: root.text
            color: "#ffffff"
            font.pixelSize: 12
        }
    }
    
    Component.onCompleted: {
        console.log("Tooltip created")
    }
    
    onTextChanged: {
        console.log("Tooltip text changed:", text)
    }
    
    onVisibleChanged: {
        console.log("Tooltip visibility changed:", visible)
    }
}
