package main

import (
	"os"
	"os/signal"

	"github.com/projectdiscovery/fileutil"
	"github.com/projectdiscovery/gologger"
	"github.com/projectdiscovery/nuclei/v2/pkg/runner"
	"github.com/projectdiscovery/nuclei/v2/pkg/types"
	"github.com/surface-security/scanner-nuclei/pkg/utils"
)

func main() {
	if err := runner.ConfigureOptions(); err != nil {
		gologger.Fatal().Msgf("Could not initialize options: %s\n", err)
	}

	options := utils.ReadConfig()
	runner.ParseOptions(options)

	nucRunner, err := runner.New(options)
	if err != nil || nucRunner == nil {
		gologger.Fatal().Msgf("Could not runner: %s\n", err)
	}

	// Setup graceful exits
	resumeFileName := types.DefaultResumeFilePath()
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	go func() {
		for range c {
			gologger.Info().Msgf("CTRL+C pressed: Exiting\n")
			nucRunner.Close()
			if options.ShouldSaveResume() {
				gologger.Info().Msgf("Creating resume file: %s\n", resumeFileName)
				err := nucRunner.SaveResumeConfig(resumeFileName)
				if err != nil {
					gologger.Error().Msgf("Couldn't create resume file: %s\n", err)
				}
			}
			os.Exit(1)
		}
	}()

	if err := nucRunner.RunEnumeration(); err != nil {
		if options.Validate {
			gologger.Fatal().Msgf("Could not validate templates: %s\n", err)
		} else {
			gologger.Fatal().Msgf("Could not run nuclei: %s\n", err)
		}
	}
	nucRunner.Close()
	// on successful execution remove the resume file in case it exists
	if fileutil.FileExists(resumeFileName) {
		os.Remove(resumeFileName)
	}
}
