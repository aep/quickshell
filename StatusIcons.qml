//@ pragma UseQApplication
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    spacing: 1
    
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

	/*
    Process {
        id: wifiProcess
        property bool wifiConnected: false
        property int signalStrength: 0
        
        running: true
        command: ["sh", "-c", "nmcli -t -f WIFI,STATE general; nmcli -t -f IN-USE,SIGNAL device wifi | grep '^\\*' | cut -d: -f2"]
        
        stdout: SplitParser {
            onRead: {
                let lines = data.split('\n')
                wifiProcess.wifiConnected = false
                wifiProcess.signalStrength = 0
                
                for (let line of lines) {
                    if (line.includes('connected')) {
                        wifiProcess.wifiConnected = true
                    } else if (line.match(/^\d+$/)) {
                        wifiProcess.signalStrength = parseInt(line)
                    }
                }
            }
        }
	}
	*/
    
    StatusIndicator {
        iconText: {
            if (!UPower.displayDevice || !UPower.displayDevice.isLaptopBattery) return "⚡"
            let pct = UPower.displayDevice.percentage
            let charging = !UPower.onBattery
            
            if (charging) {
                if (pct > 0.9) return "󰂅"
                else if (pct > 0.7) return "󰂉"
                else if (pct > 0.5) return "󰂇"
                else if (pct > 0.3) return "󰂄"
                else return "󰢟"
            } else {
                if (pct > 0.9) return "󰁹"
                else if (pct > 0.7) return "󰂂"
                else if (pct > 0.5) return "󰂀"
                else if (pct > 0.4) return "󰁾"
                else if (pct > 0.2) return "󰁼"
                else return "󰂎"
            }
        }
        labelText: {
            if (!UPower.displayDevice || !UPower.displayDevice.isLaptopBattery) return ""
            return Math.round(UPower.displayDevice.percentage * 100).toString()
        }
        iconColor: {
            if (!UPower.displayDevice || !UPower.displayDevice.isLaptopBattery) return "#888888"
            let pct = UPower.displayDevice.percentage
            if (pct > 0.2) return "#ffffff"
            else if (pct > 0.1) return "#ffaa00"
            else return "#ff4444"
        }
        labelColor: iconColor
    }
    
    StatusIndicator {
        iconText: {
            let volume = Pipewire.defaultAudioSink?.audio?.volume ?? 0
            let muted = Pipewire.defaultAudioSink?.audio?.muted ?? false
            
            if (muted) return "󰖁"
            else if (volume >= 0.7) return "󰕾"
            else if (volume >= 0.3) return "󰖀"
            else if (volume > 0) return "󰕿"
            else return "󰖁"
        }
        labelText: {
            let volume = Pipewire.defaultAudioSink?.audio?.volume ?? 0
            let muted = Pipewire.defaultAudioSink?.audio?.muted ?? false
            
            if (muted) return "M"
            return Math.round(volume * 100).toString()
        }
        iconColor: {
            let muted = Pipewire.defaultAudioSink?.audio?.muted ?? false
            return muted ? "#666666" : "#ffffff"
        }
        labelColor: iconColor
        clickable: true
        scrollable: true
        
        onClicked: Quickshell.execDetached(["pavucontrol"])
        
        onScrollUp: {
            let sink = Pipewire.defaultAudioSink
            if (!sink?.audio) return
            
            let volumeChange = 0.05
            let currentVolume = sink.audio.volume
            sink.audio.volume = Math.min(1.0, currentVolume + volumeChange)
            
            if (sink.audio.muted && sink.audio.volume > 0) {
                sink.audio.muted = false
            }
        }
        
        onScrollDown: {
            let sink = Pipewire.defaultAudioSink
            if (!sink?.audio) return
            
            let volumeChange = 0.001
            let currentVolume = sink.audio.volume
            sink.audio.volume = Math.max(0.0, currentVolume - volumeChange)
        }
    }

	/*
    StatusIndicator {
        iconText: wifiProcess.wifiConnected ? "󰤨" : "󰤭"
        labelText: wifiProcess.wifiConnected ? wifiProcess.signalStrength.toString() : ""
        iconColor: wifiProcess.wifiConnected ? "#ffffff" : "#666666"
        labelColor: iconColor
        iconSize: 16
	}
	*/
    
    StatusIndicator {
        iconText: {
            if (!Bluetooth.defaultAdapter || !Bluetooth.defaultAdapter.enabled) return "󰂲"
            let connectedDevices = Bluetooth.devices.values.filter(d => d.connected)
            return connectedDevices.length > 0 ? "󰂱" : "󰂯"
        }
        iconColor: {
            if (!Bluetooth.defaultAdapter || !Bluetooth.defaultAdapter.enabled) return "#666666"
            let connectedDevices = Bluetooth.devices.values.filter(d => d.connected)
            return connectedDevices.length > 0 ? "#00aaff" : "#ffffff"
        }
        iconSize: 16
    }
}
