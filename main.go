package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path"
	"regexp"
	"strconv"

	log "github.com/sirupsen/logrus"

	flag "github.com/spf13/pflag"
	"github.com/surface-security/scanner-go-entrypoint/scanner"
)

type MinimalResult struct {
	Host       string `json:"host"`
	TemplateId string `json:"template-id"`
}

var FILENAME_RE = regexp.MustCompile(`[^\w\d-\._]`)

func main() {
	s := scanner.Scanner{Name: "nuclei"}
	options := s.BuildOptions()
	concurrency := flag.IntP("concurrency", "c", 10, "Number of processes")
	tests := flag.StringSliceP("tests", "t", nil, "tests to perform (as nuclei supports)")
	debug := flag.BoolP("debug", "d", false, "print nuclei output instead of suppressing it")
	scanner.ParseOptions(options)

	if *debug {
		log.SetLevel(log.DebugLevel)
	}

	err := os.MkdirAll(options.Output, 0755)
	if err != nil {
		log.Fatalf("%v", err)
	}

	args := []string{
		"-c", strconv.Itoa(*concurrency),
		"-json",
		"-l", options.Input,
	}
	if !*debug {
		args = append(args, "-silent")
	}
	for _, test := range *tests {
		args = append(args, "-t", test)
	}

	err = s.ExecCaptureOutput(
		func(line string) {
			if *debug {
				log.Debugln(line)
			}
			var res MinimalResult
			err := json.Unmarshal([]byte(line), &res)
			if err != nil {
				log.Errorf("error parsing: %s", line)
				return
			}
			log.Infof("[+] Found %s", res.Host)
			filename := FILENAME_RE.ReplaceAllString(fmt.Sprintf("%s-%s.json", res.Host, res.TemplateId), "_")
			os.WriteFile(path.Join(options.Output, filename), []byte(line), 0666)
		},
		args...,
	)
	if err != nil {
		log.Fatalf("Failed to run scanner: %v", err)
	}
}
