# Activities Log Event Details

*Thanks to CrowdStrike for publishing [an article](https://www.crowdstrike.com/blog/hiding-in-plain-sight-using-the-office-365-activities-api-to-investigate-business-email-compromises/) on the O365 Activities API.*

## Parent Log Format

| # | Field Name | Description | Data Type |
| - | - | - | - |
| 1 | Timestamp | Event timestamp | ISO8601 |
| 2 | AppIdType | Client | String |
| 3 | ActivityIdType | Type of activity | String |
| 4 | ActivityItemId | EWS ID of activity object | String |
| 5 | ActivityCreationTime | Activity-created timestamp | ISO8601 |
| 6 | ClientSessionId | Client-Generated Session Identifier | String |
| 7 | CustomProperties | Activity-specific properties | JSON |

### AppIdType Fields

| # | AppIdType | Application |
| - | - | - |
| 1 | Exchange | Exchange Online |
| 2 | IMAP | IMAP4 Client |
| 3 | Lync | Lync/Skype for Business |
| 4 | MacMail | MacOS Mail |
| 5 | MacOutlook | MacOS Outlook |
| 6 | Mobile | Mobile browser |
| 7 | Other | Other ?? |
| 8 | Outlook | Windows Outlook |
| 9 | POP3 | POP3 Client |
| 10 | Web | Outlook via Web Access |

### ActivityIdType Fields

| # | ActivityIdType | Description |
| - | - | - |
| 1 | AcceptCalendarEvent | Accept calendar event |
| 2 | AcceptedMeetingRequest | Accept meeting request |
| 3 | CancelMeeting | Cancel a meeting |
| 4 | ClutterNotificationSent | ? |
| 5 | ContactCreated | Contact created |
| 6 | CopyItem | Item copied |
| 7 | CreateAppointment | Appointment created |
| 8 | CreateFolder | Folder created |
| 9 | CreateTask | Task created |
| 10 | DeclineCalendarEvent | Calendar event declined |
| 11 | DeclinedMeetingRequest | Meeting request declined |
| 12 | Delete | Delete an item |
| 13 | DeleteCalendarEvent | Delete calendar event |
| 14 | DeleteFolder | Delete folder |
| 15 | DraftCreated | Message draft created |
| 16 | Error | |
| 17 | FavoriteFolder | Folder added as a favorite |
| 18 | Flag | Flag applied to message |
| 19 | FlagCleared | Flag cleared from message |
| 20 | Forward | Message forwarded |
| 21 | GetUserUnifiedGroups | |
| 22 | Logon | Logon |
| 23 | MarkAsRead | Message marked as read |
| 24 | MarkAsUnread | Message marked as unread |
| 25 | MarkMessageAsClutter | Mark message as clutteer |
| 26 | MarkMessageAsNotClutter | Remove clutter mark from message |
| 27 | MessageDelivered | Message delivered |
| 28 | MessageSent | Message sent |
| 29 | Move | Message moved |
| 30 | NewMessage | New message created |
| 31 | ReadingPaneDisplayEnd | A message was deselected in the reading pane |
| 32 | ReadingPaneDisplayStart | A message was opened in the reading pane |
| 33 | Reply | Message replied |
| 34 | ReplyAll | Message replied to all |
| 35 | SearchQueryExecute | Search query was executed |
| 36 | SearchRefinersDisplay | |
| 37 | SearchRequestEnd | |
| 38 | SearchResult | Results from a search |
| 39 | SearchSessionStart | A search session was initiated |
| 40 | SearchSuggestionDisplay | |
| 41 | SendMeetingRequest | Meeting request sent |
| 42 | ServerLogon | O365 Outlook mailbox login event |
| 43 | SetConversationAlwaysClutterState | Set a mail conversation to always clutter |
| 44 | TentativeMeetingRequest | Reply tentative to a meeting request |
| 45 | TentativelyAcceptCalendarEvent | Tentatively accept a calendar invite |
| 46 | UpdateCalendarEvent | Update a calendar event |

#### AcceptCalendarEvent CustomProperties

| # | Key | Description | Format |
| - | - | - | - |
| 1 | EventType | ? (Guessing if single or series) | String |
| 2 | SendMeetingResponse | True/false is response was sent to request | Boolean |
| 3 | GlobalObjectId | Global Object ID ? | Hex |

#### AcceptedMeetingRequest CustomProperties

| # | Key | Description | Format |
| - | - | - | - |
| 1 | SeriesId | Meeting series ID (if applicable) | String |
| 2 | ProposeNewTime | If new time was proposed | Boolean |
| 3 | ItemClass | ? | String |
| 4 | GlobalOjbectId | Global Object ID ? | Hex

#### CancelMeeting CustomProperties

| # | Key | Description | Format |
| - | - | - | - |
| 1 | SeriesId | Meeting series ID (if applicable) | String |
| 2 | ItemClass | ? | String |
| 3 | GlobalObjectId | Global Object ID ? | Hex

#### ClutterNotificationSent CustomProperties

| # | Key | Description | Format |
| - | - | - | - |
| 1 | InternetMessageId | Internet Message ID | String |
| 2 | DigestType | Digest Type | String |
| 3 | CreationFolder | Creation folder | String |
| 4 | NotificationType | Notification Type | String |
| 5 | MessageGuid | Message GUID | String |

#### ContactCreated CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### CopyItem CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### CreateAppointment CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### CreateFolder CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### CreateTask CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### DeclineCalendarEvent CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### DeclinedMeetingRequest CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### Delete CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### DeleteCalendarEvent CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### DeleteFolder CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### DraftCreated CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### Error CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### FavoriteFolder CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### Flag CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### FlagCleared CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### Forward CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### GetUserUnifiedGroups CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### Logon CustomProperties

| # | Key | Description | Format |
| - | - | - | - |
| 1 | Layout | ?? | String |
| 2 | InferenceUiReady | ?? | Integer |
| 3 | InferenceUiOnKeyName | ?? | Integer |
| 4 | Flights | Capabilities ?? | Comma-separated list |
| 5 | Timezone | Timezone | String |
| 6 | IPAddress | Client IP Address | IP Address |
| 7 | Browser | Browser user agent | User-agent |

#### MarkAsRead CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

##### MarkAsUnread CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### MarkMessageAsClutter CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### MarkMessageAsNotClutter CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### MessageDelivered CustomProperties

| # | Key | Description | Format |
| - | - | - | - |
| 1 | From | From | String |
| 2 | DelieveredToInbox | Delivered to Inbox | Boolean |
| 3 | InferenceClassification | ?? (Focused?) | String |
| 4 | DeliveredFolderType | ?? (Inbox?) | String |
| 5 | AddressingGroupMessage | ?? (None?) | String |
| 6 | ItemClass | Item class | String |
| 7 | Recipients | Message recipients | Semi-colon separated list of email addresses |
| 8 | ConversationId | Conversation ID | String |
| 9 | isReply | Is the message a reply | Boolean |
| 10 | MessageCardContext | ?? | ?? |
| 11 | MessageGuid | Message GUID | GUID |
| 12 | ExchangeApplicationFlags | Exchange Application Flags | Integer |
| 13 | ReceivedTime | Message received time | Date (MM/DD/YYYY HH:MM:SS AM/PM) |
| 14 | DeliveredViaBcc | Delivered via BCC | Boolean |
| 15 | DeliveredToClutter | Delivered to Clutter Folder | Boolean |
| 16 | DeliveredFolderId | ID of folder that message was delivered to | String |
| 17 | OrgAuthAs | ?? | ?? |
| 18 | SentTime | Time when message was sent | ISO8601 |
| 19 | IsGroupEscalationMessage | ?? | ?? |
| 20 | Hashtags | ?? | ?? |
| 21 | SenderSmtpAddress | Sender's SMTP address | Email Address |
| 22 | IsMentioned | ?? | ?? |
| 23 | InternetMessageId | ?? | ?? |
| 24 | MessageClientInfo | ?? | ?? |
| 25 | Subject | Message subject | String |

#### MessageSent CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### Move CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### NewMessage CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### ReadingPaneDisplayEnd CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### ReadingPaneDisplayStart CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### Reply CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### ReplyAll CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### SearchQueryExecute CustomProperties

| # | Key | Description | Format |
| - | - | - | - |
| 1 | SearchSessionId | Search Session ID | GUID |
| 2 | IsSuggestion | Is Suggestion | Integer |
| 3 | RetrieveRefiners | ? | Integer |

#### SearchRefinersDisplay CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### SearchRequestEnd CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### SearchResult CustomProperties

| # | Key | Description | Format |
| - | - | - | - |
| 1 | Folders | Folders Searched | Base64 |
| 2 | Ver | Version | Integer |
| 3 | MaxRes | Max Results (??) | Integer |
| 4 | App | Application used | String |
| 5 | Pos | ?? | Integer
| 6 | Item | ?? | Integer
| 7 | NetworkPresenceLocation | Network Presence Location (??) | String |
| 8 | Params | ?? | String |
| 9 | ResIds | Resulting messages from search | Comma-separated string list of hex message IDs |
| 10 | Sid | SearchSessionID | GUID |
| 11 | Query | Search query | XML |
| 12 | Rid | Result ID (??) | GUID |
| 13 | AltResIds | Alternate result ID(s) (??) | GUID |
| 14 | Trunc | Truncated (??) | Boolean |

#### SearchSessionStart CustomProperties

| # | Key | Description | Format |
| - | - | - | - |
| 1 | SearchSessionId | Search Session ID | GUID |
| 2 | ConversionErrors | ?? |
| 3 | MissingProperties | ?? |

#### SearchSuggestionsDisplay CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### SendMeetingRequest CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### ServerLogon CustomProperties

| # | Key | Description | Format |
| - | - | - | - |
| 1 | UserName | User name | String |
| 2 | ExceptionInfo | Exception details if logon failed | |
| 3 | NetworkPresenceLocation | Network presence location | String |
| 4 | Result | Logon result | String |
| 5 | UserAgent | User-agent of client | String (User-Agent) |
| 6 | ClientIP | Client IP Address | String (IP Address)

#### SetConversationAlwaysClutterState CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### TentativeMeetingRequest CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### TentativelyAcceptCalendarEvent CustomProperties

| # | Key | Description | Format |
| - | - | - | - |

#### UpdateCalendarEvent CustomProperties

| # | Key | Description | Format |
| - | - | - | - |