# Audit Log Details

## Parent Log Format

| # | Field Name | Description | Data Type |
| - | - | - | - |
| 1 | CreationDate | Event timestamp | ISO8601 |
| 2 | UserIds | User ID associated with activity | String |
| 3 | Operations | O365 Operations | String |
| 4 | AuditData | Operation-specific audit data | JSON |

### Operations Fields

| # | Field Name | Description |
| - | - | - |
| 1 | FilePreviewed | |
| 2 | FolderCreated | |
| 3 | FolderModified | |
| 4 | HardDelete | |
| 5 | MailboxLogin | |
| 6 | New-InboxRule | |
| 7 | PasswordLogonInitialAuthUsingPassword | |
| 8 | SearchQueryPerformed | |
| 9 | SearchResultReturned | |
| 10 | Set-InboxRule | |
| 11 | Set-Mailbox | |
| 12 | SoftDelete | |
| 13 | UserLoggedIn | |
| 14 | UserLoginFailed | |

#### FilePreviewed AuditData

| # | Field Name | Description | Type |
| - | - | - | - |

#### FolderCreated AuditData

| # | Field Name | Description | Type |
| - | - | - | - |

#### FolderModified AuditData

| # | Field Name | Description | Type |
| - | - | - | - |

#### HardDelete AuditData

| # | Field Name | Description | Type |
| - | - | - | - |

#### MailboxLogin AuditData

| # | Field Name | Description | Type |
| - | - | - | - |

#### New-InboxRule AuditData

| # | Field Name | Description | Type |
| - | - | - | - |

#### Set-Mailbox AuditData

| # | Field Name | Description | Type |
| - | - | - | - |

#### SoftDelete AuditData

| # | Field Name | Description | Type |
| - | - | - | - |

#### UserLoggedIn AuditData

| # | Field Name | Description | Type |
| - | - | - | - |

#### UserLoginFailed AuditData

| # | Field Name | Description | Type |
| - | - | - | - |