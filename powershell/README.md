# OLAF - PowerShell

## Description

This folder contains a set of PowerShell commands and scripts that my be useful in collecting or parsing data from O365 instances. Credit given where due.

### Shout Outs

Huge thanks to Adam Harrison for his [blog post](https://blog.1234n6.com/2018/07/investigating-office365-account_12.html) that provided new scripts and details on O365 analysis.

---

## Enable Audit Logs

As mentioned in the webcast, you want to enable audit logging on accounts if Microsoft has not already turned this on for you. Here's a sample command to enable on all mailboxes (thanks to Adam Harrison for sharing this one):

`Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditEnabled $true`

Unfortunately, at this stage, we need to enable specific owner actions to audit as well. Here's a built-out command to enable specific actions:

`Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditOwner @{Add="MailboxLogin","HardDelete","SoftDelete","FolderBind","Update","Move","MoveToD eletedItems","SendAs","SendOnBehalf","Create"}`

---

## Data Collection

Search through Unified Audit Logs for date range (pulls all results):

`Search-UnifiedAuditLog -StartDate [YYYY-MM-DD] -EndDate [YYYY-MM-DD]`

Search through Unified Audit Logs for date range and a specific user:

`Search-UnifiedAuditLog -StartDate <yyyy-mm-dd> -EndDate <yyyy-mm-dd> -UserIds <user_account>`

You can take the two queries above and filter further if you want too, using log-specific parameters. Here's a few examples:

| # | Option | Description |
| - | - | - |
| 1 | `-Operations` | Specify logs for a specific operation. Good examples here include "New-InboxRule", "Set-InboxRule", and/or "Set-Mailbox" |
| 2 | `-IPAddresses` | Specify a single or list (comma-separated) list of IPs that you specifically want to pull logs from. Useful for second- or third-stage analysis when you have IPs to pivot off of. |
| 3 | `-ResultSize` | Specify the output result size; I use 5000 as a default; these logs can get large (also export will cap at this limit) |
| 4 | ` | Export-CSV` | Pipe logs to `Export-CSV` to get them in a CSV format, which can then be ingested using other tools |

---

## Complete Scripts

| # | Script Name | Description | Link |
| - | - | - | - |
| 1 | GetReadStatus.ps1 | Get the "True" read status of an email | [Link](https://blogs.technet.microsoft.com/santhse/get-readstatus/) |