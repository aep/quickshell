//@ pragma UseQApplication
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

ShellRoot {
    PanelWindow {
        id: sidebar
        
        anchors {
            left: true
            top: true
            bottom: true
        }
        
        width: 22
        exclusionMode: ExclusionMode.Respect
        
        color: "transparent"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 2
            
            GridLayout {
                columns: 3
                columnSpacing: 0
                rowSpacing: 1
                Layout.alignment: Qt.AlignTop
                
                Repeater {
                    model: 12
                    
                    Text {
                        property int workspaceId: index + 1
                        property bool isActive: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === workspaceId : false
                        
                        Layout.alignment: Qt.AlignCenter
                        text: isActive ? "◼" : "◻"
                        color: isActive ? "#ffffff" : "#666666"
                        font.pixelSize: 8
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Hyprland.dispatch("workspace " + workspaceId)
                        }
                    }
                }
            }
            
                
                Text {
                    anchors.centerIn: parent
                    text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "No window"
                    color: "#ffffff"
                    font.pixelSize: 12
                    rotation: 90
                    transformOrigin: Item.Center
                    
                    Component.onCompleted: {
                        console.log("Window title:", text)
                    }
                }
            
            ColumnLayout {
                Layout.alignment: Qt.AlignBottom
                spacing: 1
                
                Repeater {
                    model: SystemTray.items
                    
                    MouseArea {
                        required property SystemTrayItem modelData
                        
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 22
                        Layout.alignment: Qt.AlignHCenter
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        
                        onClicked: function(event) {
                            if (event.button === Qt.LeftButton) {
                                if (modelData.hasMenu) {
                                    let globalPos = mapToGlobal(event.x, event.y)
									modelData.display(sidebar, globalPos.x, globalPos.y)
								} else {
									modelData.activate()
								}
                            } else if (event.button === Qt.RightButton) {
                                if (modelData.hasMenu) {
                                    let globalPos = mapToGlobal(event.x, event.y)
                                    modelData.display(sidebar, globalPos.x, globalPos.y)
                                } else {
                                    modelData.secondaryActivate()
                                }
                            }
                        }
                        
                        Image {
                            anchors.fill: parent
                            source: {
                                let icon = parent.modelData.icon
                                if (icon.includes("?path=")) {
                                    const [name, path] = icon.split("?path=")
                                    icon = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`
                                }
                                return icon
                            }
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                }
            }
        }
    }
}
