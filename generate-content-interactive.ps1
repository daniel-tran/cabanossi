# Use this command to enable script running for the local PowerShell session:
# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

<#
.SYNOPSIS
    An interactive CLI that can generate comments and posts, as well as pull sites from an RSS feed.
.DESCRIPTION
    An interactive wrapper script that encapsulates the behaviour of the other
    PowerShell scripts in one central command line interface.
.PARAMETER workingSetFile
    The file to extract the site from, taking only the first line. Defaults to the empty string.
.PARAMETER mentions
    The mentions used to refer to specific entities like people or companies. Defaults to the empty string.
.PARAMETER hashtags
    The hashtags used to tag the post with categories. Defaults to the empty string.
.EXAMPLE
    .\generate-content-interactive.ps1
.EXAMPLE
    .\generate-content-interactive.ps1 -workingSetFile .\rss-feed-working-set.www.technologyreview.com.txt
.EXAMPLE
    .\generate-content-interactive.ps1 -mentions "@Snuckeys" -hashtags "#food"
.NOTES
    Currently only tested on LinkedIn.
#>

param(
   [string]$workingSetFile = "",
   [string]$mentions = "",
   [string]$hashtags = ""
)

$keyRun = ""
$keyRunFromUrl = "u"
$keyComment = "c"
$keyDelete = "d"
$keyQuit = "q"
$keyLoadFile = "l"
$keyRefreshWorkingSet = "r"
$keySetMentions = "m"
$keySetHashtags = "h"
$action = $keyRun

$rssFeedsFile = "${PSScriptRoot}\data\rss-feeds.txt"

while ($action -ne $keyQuit) {
    if ($workingSetFile -eq "") {
        Write-Host "Warning! Working set file is not defined, some actions will not be usable until one is loaded." -ForegroundColor Yellow
    }

    $action = Read-Host @"

Enter next action
  <enter> = generate standard post from "${workingSetFile}"
  ${keySetMentions} = set mentions (current: "${mentions}")
  ${keySetHashtags} = set hashtags (current: "${hashtags}")
  ${keyRunFromUrl} = generate standard post from user-provided URL
  ${keyComment} = generate standard comment
  ${keyRefreshWorkingSet} = refresh working set from RSS feed
  ${keyLoadFile} = load working set file
  ${keyDelete} = delete current site from "${workingSetFile}"
  ${keyQuit} = quit

"@;
    if ($action -ieq $keyRun) {
        if ($workingSetFile -ne "") {
            .\generate-standard-post.ps1 -workingSetFile $workingSetFile -mentions $mentions -hashtags $hashtags
        } else {
            Write-Host "Error: A working set file has not been loaded yet!" -ForegroundColor Red
        }

    } elseif ($action -ieq $keySetMentions) {
        $mentions = Read-Host "Enter the new mentions to include in generated comments and posts"
        Write-Host "Success! Comments and posts generated will now include the following mentions: ${mentions}" -ForegroundColor Green

    } elseif ($action -ieq $keySetHashtags) {
        $hashtags = Read-Host "Enter the new hashtags to include in generated comments and posts"
        Write-Host "Success! Comments and posts generated will now include the following hashtags: ${hashtags}" -ForegroundColor Green

    } elseif ($action -ieq $keyRunFromUrl) {
        $site = Read-Host "Enter a URL to extract a quote from"
        .\generate-standard-post.ps1 -site $site -mentions $mentions -hashtags $hashtags

    } elseif ($action -ieq $keyComment) {
        .\generate-standard-comment.ps1 -mentions $mentions -hashtags $hashtags

    } elseif ($action -ieq $keyDelete) {
        if ($workingSetFile -ne "") {
            $fileContents = Get-Content $workingSetFile
            # If the file only has one line of actual data, PowerShell will read it as an array of characters instead of
            # an array containing a single string. Thus, different processing occurs to account for this behaviour.
            if (($fileContents | Measure-Object).Count -gt 1) {
                ($fileContents | Select-Object -Skip 1) | Set-Content $workingSetFile
            } else {
                Set-Content $workingSetFile -Value $null
            }
            Write-Host "Removed top-most entry in ${workingSetFile}" -ForegroundColor Cyan
        } else {
            Write-Host "Error: A working set file has not been loaded yet!" -ForegroundColor Red
        }

    } elseif ($action -ieq $keyLoadFile) {
        Write-Host "Working set files currently stored:" -ForegroundColor Cyan
        Get-ChildItem -Path "${PSScriptRoot}\data\rss-feed-working-set.*.txt" -Recurse | Select-Object -ExpandProperty FullName
        Write-Host "Working set file is currently set to:`r`n${workingSetFile}" -ForegroundColor Cyan
        $workingSetFile = Read-Host "Enter a file name to use (use full path name, including extension)"
        Write-Host "Success! Working set file has been updated." -ForegroundColor Green

    } elseif ($action -ieq $keyRefreshWorkingSet) {
        if (Test-Path $rssFeedsFile) {
            Write-Host "RSS feeds previously used:" -ForegroundColor Cyan
            Get-Content -Path $rssFeedsFile
        }
        $rssFeed = Read-Host "Enter a URL corresponding to an RSS feed"
        .\extract-sites-from-rss-feed.ps1 -appendWorkingSet -rssFeed $rssFeed
        # Relies on users manually updating the file to remove invalid RSS feeds
        $shouldRememberRssFeed = Read-Host "Should ${rssFeed} be remembered for later use (y/n)?"
        if ($shouldRememberRssFeed -ieq "y" -or $shouldRememberRssFeed -ieq "yes") {
            Add-Content -Path $rssFeedsFile -Value $rssFeed
            Write-Host "${rssFeed} will now be shown as a previously used RSS feed in future refreshes" -ForegroundColor Cyan
        }

    } elseif ($action -ieq $keyQuit) {
        Write-Host "Ending interactive session..." -ForegroundColor Cyan
    } else {
        Write-Host "Invalid action: ${action}" -ForegroundColor Red
    }
}
