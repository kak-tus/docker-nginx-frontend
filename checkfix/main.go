package main

import (
	"fmt"
	"os"
	"time"

	jsoniter "github.com/json-iterator/go"
	"github.com/peterbourgon/diskv"
)

type service struct {
	Name        string
	Address     string
	Port        int
	Tags        []string
	Status      string
	ID          string
	Node        string
	NodeAddress string
}

var kv = diskv.New(diskv.Options{
	BasePath: "/tmp",
})

func main() {
	if !(len(os.Args) == 2 && len(os.Args[1]) > 0) {
		os.Exit(1)
	}

	var parsed []service

	err := jsoniter.UnmarshalFromString(os.Args[1], &parsed)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	if len(parsed) == 0 {
		fmt.Fprintln(os.Stdout, "[]")
		os.Exit(0)
	}

	var processed []service
	now := time.Now()

	for _, s := range parsed {
		if s.Status != "critical" {
			delPrevious(s)
			processed = append(processed, s)
			continue
		}

		prev, ok := getPrevious(s)

		if !ok {
			setPrevious(s)
			processed = append(processed, s)
		} else if prev.After(now.Add(-120 * time.Second)) {
			processed = append(processed, s)
		}
	}

	if len(processed) == 0 {
		fmt.Fprintln(os.Stdout, "[]")
		os.Exit(0)
	}

	res, err := jsoniter.Marshal(processed)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	fmt.Fprintln(os.Stdout, string(res))
	os.Exit(0)
}

func getPrevious(s service) (time.Time, bool) {
	key := fmt.Sprintf("checkfix_%s_%s", s.Node, s.ID)

	if !kv.Has(key) {
		return time.Now(), false
	}

	content, err := kv.Read(key)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return time.Now(), false
	}

	res, err := time.Parse(time.RFC3339, string(content))
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return time.Now(), false
	}

	return res, true
}

func setPrevious(s service) {
	now := time.Now()
	key := fmt.Sprintf("checkfix_%s_%s", s.Node, s.ID)

	err := kv.WriteString(key, now.Format(time.RFC3339))
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
	}
}

func delPrevious(s service) {
	key := fmt.Sprintf("checkfix_%s_%s", s.Node, s.ID)

	if !kv.Has(key) {
		return
	}

	err := kv.Erase(key)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
	}
}
