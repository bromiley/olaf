
############################################################################################
#                                                                                          #
# The sample scripts are not supported under any Microsoft standard support                #
# program or service. The sample scripts are provided AS IS without warranty               #
# of any kind. Microsoft further disclaims all implied warranties including, without       #
# limitation, any implied warranties of merchantability or of fitness for a particular     #
# purpose. The entire risk arising out of the use or performance of the sample scripts     #
# and documentation remains with you. In no event shall Microsoft, its authors, or         #
# anyone else involved in the creation, production, or delivery of the scripts be liable   #
# for any damages whatsoever (including, without limitation, damages for loss of business  #
# profits, business interruption, loss of business information, or other pecuniary loss)   #
# arising out of the use of or inability to use the sample scripts or documentation,       #
# even if Microsoft has been advised of the possibility of such damages                    #
#                                                                                          #
############################################################################################
#                                                                                          #
# Author: Santhosh Sethumadhavan <santhse@microsoft.com>                                   #
#                                                                                          #
############################################################################################ 

Function Get-ReadStatus
{
   <#

    .SYNOPSIS
        Some business requires to track the READ status of the some critical messages. 
        They want to know if the email was delivered to the Mailbox and was read by the user.
        You shall use the message tracking log to find the delivery status of the email and Use this script to find the READ status of the email.

    .DESCRIPTION
        Get-ReadStatus is the function exported by the script.
        The function can be used against On-perm or Online mailboxes. The function returns a Custom Object with the READ status of the email.
        It first searches for the email message in the Inbox with Search filters and if not found, it searches the Entire Mailbox using Search folders.

    .NOTES
        Author         : Santhosh Sethumadhavan (santhse@microsoft.com)
        Prerequisite   : Requires Powershell V3 or Higher.
                       : Requires EWS API 1.2 or higher installed on the machine.

    .PARAMETER MessageID
        MessageID of the message to find the READ status for. The MessageID can be found from the Message tracking logs or from the Message details itself.

    .PARAMETER EmailAddress
        Email address of the user who's mailbox needs to be scanned for the message.

    .PARAMETER Credentials
        Use Get-Credential to pass the Credentials to be used for opening the mailbox.It should have full Mailbox or Impersonation permissions.
        If Credentials are not passed as a parameter, the function uses the logged on user Credentials.

    .PARAMETER Impersonate
        Use this switch if the Credentials has Impersonation Permission. You may have a list of users from On-Perm and Cloud.
        Using a Credential that has Impersonate permission on both On-Perm and Online will make it easier. - https://msdn.microsoft.com/en-us/library/office/dn722376(v=exchg.150).aspx

    .PARAMETER EWSUrl
        EWSUrl to be used for connecting to the mailbox. If this parameter is not mentioned, Autodiscover is used to find the EWS URL.
        When using Autodiscover, it might delay the script. Whenever possible, use this parameter to specify the EWS URL.
        For Exchange Online, use "https://outlook.office365.com/EWS/Exchange.asmx"

    .PARAMETER StartDate
        Start date used in the search filters to search for the message, by default, it searches for a week.
        Usually this parameter is the Message Delivered time, also, using this finds the Item faster on the mailbox.
    
    .PARAMETER EndDate
        If not specified, current date time is used as EndDate.

    .Example
		Import-Module D:\Scripts\GetReadStatus.ps1    
		$EmailAddress = Get-transportservice | Get-MessageTrackingLog -MessageId $MessageID -EventId Deliver -Start $StartDate -End $EndDate -resultsize unlimited | Select -ExpandProperty Recipients
        
        ForEach($Address in $EmailAddress){
		    $Result += Get-ReadStatus $MailboxName -Credential $credentials -Impersonate -server $Server -MessageID $MessageID
    	}
        $Result += Get-ReadStatus $MailboxName -Credential $credentials -Impersonate $Impersonate -server $Server -MessageID $MessageID -StartDate $StartDate
        $Result | Export-csv ReadStatus.csv -noTypeInformation

        Above example, parses the message tracking log to find the recipients using the deliver event and then reports the READ status of the email.

    .Example
		Import-Module D:\Scripts\GetReadStatus.ps1
        $credentials = Get-Credential
        $messageID = ‘EAE70D3DF2CF50408C09D26480FE85A3D2DF4D53@myserver.com’
        $URL = ‘https://outlook.office365.com/EWS/Exchange.asmx’


        $EmailAddress = Get-Content C:\temp\EmailAddress.txt
        $Result = @()
        [INT]$Total = $EmailAddress.Count
        [INT]$i = 0
    
        ForEach($Address in $EmailAddress) {
            $i++
            Write-Progress -Activity "Processing $Address " -Status " $i / $Total "
               $MailboxName = $Address
               $Result += Get-ReadStatus –Emailaddress $MailboxName -Credential $credentials -Impersonate -EWSUrl $URL -MessageID $MessageID -startdate 03/03/2017 -enddate 03/20/2017
        }


        $Result | Export-Csv C:\Temp\Readstatus.csv -NoTypeInformation


    #>

[CmdletBinding()]
Param(

    [Parameter(Mandatory=$TRUE,Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]$MessageID = '',

 	[parameter( ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$true,Mandatory=$true, Position=1)]
    [ValidateNotNullOrEmpty()]
	[Alias('PrimarySmtpAddress')]
	[String]$EmailAddress,

	[parameter( Mandatory=$false, Position=2)]
	[System.Management.Automation.PsCredential]$Credentials,

	[parameter( Mandatory=$false, Position=3)]
	[SWITCH]$Impersonate,

	[parameter( Mandatory=$false, Position=4)]
    [ValidateNotNullOrEmpty()]
	[string]$EWSUrl='',

    [Parameter(Mandatory=$false,Position=6)]
    [ValidateScript({get-date $_})]
    [DATETIME]$StartDate = (Get-Date (get-date).adddays(-7) -Format  (Get-Culture).DateTimeFormat.FullDateTimePattern),
    
    [Parameter(Mandatory=$false, Position=7)]
    [ValidateScript({get-date $_})]
    [DATETIME]$EndDate = (Get-Date (Get-Date -Format  (Get-Culture).DateTimeFormat.FullDateTimePattern)).DateTime

)

try{
    
	$MailboxName = $EmailAddress
    #An User can read the message and mark it as Unread, read the extended properties of the message to find if User Ever read the message
    [BOOL]$IsEverRead = $false
    #Current Read or Unread status of the message
    [BOOL]$ISRead = $false
    #Try searching the inbox first, otherwise create a search folder to search for all messages in the mailbox
    $SearchFolder = $NULL
	[STRING]$EWSDLL = $NULL

    #Number of Items to Get
    [INT]$pageSize =1000
    [INT]$Offset = 0

    #Users may enclose the messageID in <> or may not. Let's add it
    $MessageID = "<$($MessageID.Trim('<','>'))>"

	## Load Managed API dll
	###CHECK FOR EWS MANAGED API, IF PRESENT IMPORT THE HIGHEST VERSION EWS DLL, ELSE EXIT
	$EWSDLL = (($(Get-ItemProperty -ErrorAction SilentlyContinue -Path Registry::$(Get-ChildItem -ErrorAction SilentlyContinue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Exchange\Web Services'|Sort-Object Name -Descending| Select-Object -First 1 -ExpandProperty Name)).'Install Directory') + "Microsoft.Exchange.WebServices.dll")
    
    #This can be ran from Exchange server as well, Do not install EWS API on an Exchange server, instead use the line below
    #$EWSDLL = "c:\Program Files\Microsoft\Exchange Server\V15\Bin\Microsoft.Exchange.WebServices.dll"

	if (Test-Path $EWSDLL){
	    Import-Module $EWSDLL
        Write-Verbose "Found EWS DLL $EWSDLL"
	}else{
	    Write-Host "This script requires the EWS Managed API 1.2 or later." -ForegroundColor Cyan
	    Write-Host "Please download and install the current version of the EWS Managed API from" -ForegroundColor Cyan
	    Write-Host "http://go.microsoft.com/fwlink/?LinkId=255472" -ForegroundColor Cyan
	    Write-Host "" 
	    Write-Host "Exiting Script." -ForegroundColor Red
	    return $NULL
	}

	## Set Exchange Version
	$ExchangeVersion = [Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2010_SP2

	## Create Exchange Service Object
	$service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService($ExchangeVersion)
	
	## Set Credentials to use 
    #Option 1: To use explicit credentials 
    #Option 2: Use the Default (logged On) credentials
	If ($Credentials) {
		
		$psCred = $Credentials
		$creds = New-Object System.Net.NetworkCredential($psCred.UserName.ToString(),$psCred.GetNetworkCredential().password.ToString())
		$service.Credentials = $creds
        Write-Verbose "Using Credentials of $($psCred.UserName.ToString()) to access the mailbox"
		
	}
	Else {
        Write-Verbose "Using Logged on Credentials for this operation"
		#Credentials Option 2
		$service.UseDefaultCredentials = $true
	}


	
	## Find the EWS Url, if it is passed as a parameter, just use it
    #Otherwise, use the Autodiscover method to find the EWS URL for each mailbox. This method is slow as it has to perform the Autodiscovery process for each Mailbox
    
	If ($EWSUrl) {
		
		$uri=[system.URI] $EWSUrl
		$service.Url = $uri
	}
	Else{
		#For Debugging Purposes, uncomment the below lines to Trace the AutoDiscover calls
        #$service.TraceEnabled = $TRUE
		
        $service.AutodiscoverUrl($MailboxName,{$true})
		
        #For O365
        #$uri=[system.URI] 
        #$service.Url = $uri
        
	}

    if(-NOT $service.Url){
        Write-Verbose "Unable to find EWS URL for mailbox $MailboxName"
        Throw "Unable to Find the EWS URL"
    }else{

        Write-Verbose "Using EWS URL $($service.Url.AbsoluteUri)"
    }

	## Optional section for Exchange Impersonation
	If ($Impersonate) {
        Write-Verbose "The credentials used will Impersonate as the user mailbox"
		$service.ImpersonatedUserId = new-object Microsoft.Exchange.WebServices.Data.ImpersonatedUserId([Microsoft.Exchange.WebServices.Data.ConnectingIdType]::SmtpAddress, $MailboxName)

	}	
	
	#Get the properties of the Items
	$PropSet =  new-object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::IsRead)
	$PropSet.add([Microsoft.Exchange.WebServices.Data.ItemSchema]::Subject)
	$PropSet.add([Microsoft.Exchange.WebServices.Data.ItemSchema]::DateTimeReceived)
	$PropSet.add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::Sender)
	$PropSet.add([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::InternetMessageId)
        
	$IsEverReadProp = new-object Microsoft.Exchange.WebServices.Data.ExtendedPropertyDefinition(0xE07,[Microsoft.Exchange.WebServices.Data.MapiPropertyType]::Integer)
    $PropSet.Add($IsEverReadProp)
	
	 
    #Setup the View
    $itemView = new-object Microsoft.Exchange.WebServices.Data.ItemView($pageSize,$Offset,[Microsoft.Exchange.WebServices.Data.OffsetBasePoint]::Beginning)
	$itemView.Traversal = [Microsoft.Exchange.WebServices.Data.ItemTraversal]::Shallow
    $itemView.PropertySet = $PropSet
    
    #Sort objects for quick hit
	$itemView.OrderBy.add([Microsoft.Exchange.WebServices.Data.ItemSchema]::DateTimeReceived,[Microsoft.Exchange.WebServices.Data.SortDirection]::Descending)

    #Search filters, messageID and the dates
    $searchFilterEA1 = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+IsEqualTo(
                        [Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::InternetMessageId,$MessageID) 

    $searchFilterEA2 = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+IsGreaterThanOrEqualTo([Microsoft.Exchange.WebServices.Data.ItemSchema]::DateTimeReceived,
																																		    $StartDate)


    $searchFilterEA3 = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+IsLessThanOrEqualTo([Microsoft.Exchange.WebServices.Data.ItemSchema]::DateTimeReceived,
																																		    $EndDate)

    $oSearchFilters = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+SearchFilterCollection(
                        [Microsoft.Exchange.WebServices.Data.LogicalOperator]::And)
    $oSearchFilters.add($searchFilterEA1)
    $oSearchFilters.add($searchFilterEA2)
    $oSearchFilters.add($searchFilterEA3)

    Write-Verbose "Searching for the message between dates $StartDate - $EndDate"
    #Try the Inbox first

    $oFindItems = $service.FindItems([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Inbox,$oSearchFilters,$itemView)

    If(($oFindItems.Items.Count -gt 1)){
        Write-Verbose "Duplicate Items from the mailbox, its not expected"
        Throw "Duplicate Items from Mailbox"

    }elseif($oFindItems.Items.Count -lt 1){
        Write-Verbose "Item is not Present in Inbox, creating search folder to find the message from all folders"
        #Item not in inbox, search the MsgFolderRoot and all subfolders
        #Create a Search folder
	
        $svFldid = new-object Microsoft.Exchange.WebServices.Data.FolderId([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Root,$MailboxName)
        $SearchFolder = new-object Microsoft.Exchange.WebServices.Data.SearchFolder($service)
        $searchFolder.SearchParameters.RootFolderIds.Add([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::MsgFolderRoot) | Out-Null
        $searchFolder.SearchParameters.Traversal = [Microsoft.Exchange.WebServices.Data.SearchFolderTraversal]::Deep
        $searchFolder.SearchParameters.SearchFilter = $oSearchFilters
        $searchFolder.DisplayName = "TEMP-MSG-ID"
        $searchFolder.Save($svFldid) | Out-Null
        Write-Verbose "Created SearchFolder TEMP-MSG-ID on the Root of mailbox"
        $oFindItems = $SearchFolder.FindItems($oSearchFilters,$itemView)
        
        If(($oFindItems.Items.Count -gt 1)){
            Write-Verbose "Duplicate Items from the mailbox, its not expected"
            Throw "Duplicate Items from Mailbox" 
        }
        elseif($oFindItems.Items.Count -lt 1){
            Write-Verbose "Item not present in Mailbox: $Mailboxname"
            Throw "Item not present in Mailbox: $Mailboxname"
        }
    }else{

        Write-Verbose "Item found from Inbox Folder"
    }
    
	$Item = $oFindItems.Items[0]
    #Read the extended property of the Item to find EverRead value
	$IsEverReadVal = ($item.ExtendedProperties | Select -Property value).value

	If(($IsEverReadVal -band 0x0400) -eq 0x0400){
	 
	    #Write-Host "User had already READ the message"
	    $IsEverRead = $true

	}else{
        $IsEverRead = $false    
    }

	$props = @{ DateTimeReceived  = $Item.DateTimeReceived
					Sender            = $Item.Sender.Name;
					Subject           = $Item.Subject;
					Mailbox			  = $MailboxName
					IsRead            = $item.IsRead
					IsEverRead        = $IsEverRead
                    Error             = $NULL
			  }

    $eitem = New-Object -TypeName PSCustomObject -Property $props
    $service.ImpersonatedUserId = $null
    
    return $eitem
	
}
catch{
	Write-Verbose "Error processing $MailboxName :"
    Write-Verbose $_.Exception
    	$props = @{ DateTimeReceived  = $NULL
					Sender            = $NULL
					Subject           = $NULL
					Mailbox			  = $MailboxName
					IsRead            = $NULL
					IsEverRead        = $NULL
                    Error             = $_.Exception
					}
    
        $eitem = New-Object -TypeName PSCustomObject -Property $props

        return $eitem

}

Finally{
    
    If($SearchFolder.Id){
        Write-Verbose "Deleted the Temp SearchFolder"
        $Searchfolder.Delete([Microsoft.Exchange.WebServices.Data.DeleteMode]::HardDelete)
        Remove-Variable SearchFolder
    }
    If($service){
        $service.ImpersonatedUserId = $null
        Remove-Variable service
    }
    
    

}
#end function 
}

