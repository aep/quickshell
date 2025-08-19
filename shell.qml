//@ pragma UseQApplication
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

ShellRoot {
    
    Process {
        id: wifiProcess
        property bool wifiConnected: false
        
        running: true
        command: ["nmcli", "-t", "-f", "WIFI,STATE", "general"]
        
        stdout: SplitParser {
            onRead: {
                let lines = data.split('\n')
                for (let line of lines) {
                    if (line.includes('connected')) {
                        wifiProcess.wifiConnected = true
                        return
                    }
                }
                wifiProcess.wifiConnected = false
            }
        }
    }
    PanelWindow {
        id: sidebar
        
        anchors {
            right: true
            top: true
            bottom: true
		}

		margins {
			left: 2
		}
        
        implicitWidth: 20
        
        exclusionMode: ExclusionMode.Auto
        
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
						property bool hasWindows: {
                            if (!Hyprland.workspaces) return false
                            let workspace = Hyprland.workspaces.values.find(ws => ws.id === workspaceId)
							if (!workspace) return false
							return true
                        }
                        property bool hasUrgent: {
                            if (!Hyprland.toplevels) return false
                            return Hyprland.toplevels.values.some(client => 
                                client.workspace && client.workspace.id === workspaceId && client.urgent
                            )
                        }
                        
                        Layout.alignment: Qt.AlignCenter
                        text: {
                            if (hasUrgent) return "◼"
                            if (isActive) return "◼"
                            if (hasWindows) return "◼"
                            return "◻"
                        }
                        color: {
                            if (hasUrgent) return "#ff6666"
                            if (isActive) return "#ffffff"
                            if (hasWindows) return "#aaaaaa"
                            return "#333333"
                        }
                        font.pixelSize: 8
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Hyprland.dispatch("workspace " + workspaceId)
                        }
                    }
                }
            }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2
                    Layout.leftMargin: 0
                    Layout.rightMargin: 0
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                    color: "#666"
				}


            ColumnLayout {
                Layout.alignment: Qt.AlignBottom
                spacing: 1
                
                Item {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 30
                    Layout.alignment: Qt.AlignHCenter
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 0
                        
                        Text {
                            id: hourText
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: String(new Date().getHours()).padStart(2, '0')
                            color: "#ffffff"
                            font.pixelSize: 16
                        }
                        
                        Text {
                            id: minuteText
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: String(new Date().getMinutes()).padStart(2, '0')
                            color: "#ffffff"
                            font.pixelSize: 12
                        }
                    }
                    
                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: {
                            let now = new Date()
                            hourText.text = String(now.getHours()).padStart(2, '0')
                            minuteText.text = String(now.getMinutes()).padStart(2, '0')
                        }
                    }
				}

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2
                    Layout.leftMargin: 0
                    Layout.rightMargin: 0
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                    color: "#666"
				}
                

            Item {
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                
                Text {
                    anchors.centerIn: parent
                    text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
                    color: "#ffffff"
                    font.pixelSize: 14
                    rotation: 90
                    transformOrigin: Item.Center
                    width: parent.height
                    wrapMode: Text.NoWrap
                    elide: Text.ElideMiddle
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
			}



                
                StatusIcons {
                    id: statusIcons
                }
                
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
                        
                        Item {
                            anchors.fill: parent
                            
                            Image {
                                id: trayIcon
                                anchors.fill: parent
                                source: {
                                    let icon = parent.parent.modelData.icon
                                    if (icon.includes("?path=")) {
                                        const [name, path] = icon.split("?path=")
                                        icon = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`
                                    }
                                    return icon
                                }
                                fillMode: Image.PreserveAspectFit
                                visible: false
                            }
                            
                            Desaturate {
                                anchors.fill: trayIcon
                                source: trayIcon
                                desaturation: 1.0
                            }
                        }
                    }
                }
            }
        }
    }
}
