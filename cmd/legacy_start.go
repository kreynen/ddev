package cmd

import (
	"log"

	"github.com/drud/bootstrap/cli/local"
	"github.com/spf13/cobra"
)

// LegacyStartCmd represents the stop command
var LegacyStartCmd = &cobra.Command{
	Use:   "start",
	Short: "Start an application's local services.",
	Long:  `Start will turn on the local containers that were previously stopped for an app.`,
	Run: func(cmd *cobra.Command, args []string) {
		if activeApp == "" {
			log.Fatalln("Must set app flag to dentoe which app you want to work with.")
		}

		app := local.LegacyApp{
			Name:        activeApp,
			Environment: activeDeploy,
		}

		appType, err := local.DetermineAppType(app.AbsPath())
		if err != nil {
			log.Fatal(err)
		}
		app.AppType = appType

		err = app.Start()
		if err != nil {
			log.Fatalln(err)
		}

		err = app.Config()
		if err != nil {
			log.Fatalln(err)
		}
	},
}

func init() {

	LegacyCmd.AddCommand(LegacyStartCmd)

}