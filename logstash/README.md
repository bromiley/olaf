# OLAF - Logstash Configs

## Description

This folder holds Logstash configuration file(s) for automatic ingestion of O365 logs. Due to some of the different formats of the logs, here are some config settings you should be aware of:

| # | Option | Description |
| - | - | - |
| 1 | `<tsv_monitor>` | Folder to monitor for TSV logs (typically generated from Web UI) |
| 2 | `<csv_monitor>` | Folder to monitor for CSV logs (typically generated from PowerShell) |
| 3 | `<elk_server>` | Your Elastic server address |
| 4 | `<elk_server_port>` | Your Elastic server port |
| 5 | `<pointer_to_maxmind_db>` | The local MaxMind DB for geolocation |
