/*
Copyright © 2026 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/spf13/cobra"
	telebot "gopkg.in/telebot.v4"
)

var (
	// TeleToken bot
	TeleToken = os.Getenv("TELE_TOKEN")

	messagesTotal = prometheus.NewCounter(prometheus.CounterOpts{
		Name: "kbot_messages_total",
		Help: "Total number of text messages received by kbot.",
	})
)

// kbotCmd represents the kbot command
var kbotCmd = &cobra.Command{
	Use:     "kbot",
	Aliases: []string{"start"},
	Short:   "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	Run: func(cmd *cobra.Command, args []string) {

		fmt.Printf("kbot %s started", appVersion)

		prometheus.MustRegister(messagesTotal)
		go func() {
			http.Handle("/metrics", promhttp.Handler())
			log.Println("Prometheus metrics available on :8080/metrics")
			if err := http.ListenAndServe(":8080", nil); err != nil {
				log.Printf("metrics server stopped: %v", err)
			}
		}()

		kbot, err := telebot.NewBot(telebot.Settings{
			URL:    "",
			Token:  TeleToken,
			Poller: &telebot.LongPoller{Timeout: 10 * time.Second},
		})

		if err != nil {
			log.Fatalf("Please check TELE_TOKEN env variable. %s", err)
			return
		}

		kbot.Handle(telebot.OnText, func(m telebot.Context) error {

			messagesTotal.Inc()

			log.Printf(m.Message().Payload, m.Text())

			payload := m.Message().Payload

			switch payload {
			case "hello":
				err = m.Send(fmt.Sprintf("Hello I'm Kbot %s", appVersion))
			}
			return err
		})

		kbot.Start()
	},
}

func init() {
	rootCmd.AddCommand(kbotCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// kbotCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// kbotCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
