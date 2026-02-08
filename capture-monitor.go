package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"time"
)

type PwNode struct {
	Info struct {
		Props map[string]interface{} `json:"props"`
	} `json:"info"`
}

func isCapturing() bool {
	cmd := exec.Command("pw-dump")
	out, err := cmd.Output()
	if err != nil {
		return false
	}

	var nodes []PwNode
	if err := json.Unmarshal(out, &nodes); err != nil {
		return false
	}

	for _, node := range nodes {
		if class, ok := node.Info.Props["media.class"].(string); ok {
			if class == "Stream/Input/Video" {
				return true
			}
		}
	}
	return false
}

func main() {
	lastState := isCapturing()
	fmt.Println(lastState)

	// Start pw-mon just to detect changes
	cmd := exec.Command("pw-mon", "--color=never")
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Failed to start pw-mon:", err)
		os.Exit(1)
	}
	cmd.Start()

	scanner := bufio.NewScanner(stdout)
	var debounce *time.Timer

	for scanner.Scan() {
		line := scanner.Text()

		// Trigger recheck on any add/remove
		if strings.HasPrefix(line, "added:") || strings.HasPrefix(line, "removed:") {
			if debounce != nil {
				debounce.Stop()
			}
			debounce = time.AfterFunc(50*time.Millisecond, func() {
				state := isCapturing()
				if state != lastState {
					lastState = state
					fmt.Println(state)
				}
			})
		}
	}

	cmd.Wait()
}
