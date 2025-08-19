import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    
    property string iconText: ""
    property string labelText: ""
    property color iconColor: "#ffffff"
    property color labelColor: "#ffffff"
    property int iconSize: 20
    property int labelSize: 10
    property bool clickable: false
    property bool scrollable: false
    
    signal clicked()
    signal scrollUp()
    signal scrollDown()
    
    spacing: 1
    Layout.alignment: Qt.AlignHCenter
    
    // Icon row
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 2
        
        MouseArea {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            
            enabled: root.clickable || root.scrollable
            
            onClicked: if (root.clickable) root.clicked()
            
            onWheel: event => {
                if (!root.scrollable) return
                if (event.angleDelta.y > 0) root.scrollUp()
                else if (event.angleDelta.y < 0) root.scrollDown()
            }
            
            Text {
                anchors.centerIn: parent
                text: root.iconText
                color: root.iconColor
                font.pixelSize: root.iconSize
            }
        }
    }
    
    // Label row
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 2
        visible: root.labelText !== ""
        
        MouseArea {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            
            enabled: root.clickable || root.scrollable
            
            onClicked: if (root.clickable) root.clicked()
            
            onWheel: event => {
                if (!root.scrollable) return
                if (event.angleDelta.y > 0) root.scrollUp()
                else if (event.angleDelta.y < 0) root.scrollDown()
            }
            
            Text {
                anchors.centerIn: parent
                text: root.labelText
                color: root.labelColor
                font.pixelSize: root.labelSize
                rotation: 0
            }
        }
    }
}