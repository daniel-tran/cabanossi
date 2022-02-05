# Use this command to enable script running for the local PowerShell session:
# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

<#
.SYNOPSIS
    Extracts URL's from an RSS feed to be used as original posts, or even input into generate-standard-post.ps1
.DESCRIPTION
    Two files can be produced when running this script:
    - A cache file, which records all the URL's in an RSS feed.
    - A working set file, which records new URL's from an RSS feed which were not included in the cache file.
    
    Since the cache is always updated whenever this script is run, any new working set items reported in the console
    output will only be displayed once.
.PARAMETER rssFeed
    The URL to the RSS feed.
.PARAMETER appendWorkingSet
    If enabled, adds any new URL's from the RSS feed into the working set. This is the default behaviour.
    
    If disabled, any new URL's from the RSS feed will only be displayed on the console output.
.PARAMETER clearWorkingSet
    If enabled, clears the working set. If the cache is being refreshed with new sites and the $appendWorkingSet
    flag is enabled, the new sites are added to the working set after it has been cleared.
    
    If disabled, the working set is not cleared. This is the default behaviour.
.EXAMPLE
    .\extract-sites-from-rss-feed.ps1 -rssFeed "https://www.technologyreview.com/feed/"
.EXAMPLE
    .\extract-sites-from-rss-feed.ps1 -appendWorkingSet:$False -rssFeed "https://www.technologyreview.com/feed/"
.EXAMPLE
    .\extract-sites-from-rss-feed.ps1 -clearWorkingSet -rssFeed "https://www.technologyreview.com/feed/"
.NOTES
    Currently only tested on LinkedIn.
#>

param(
   [Parameter(Mandatory=$true)]
   [string]$rssFeed,
   [switch]$appendWorkingSet = $true,
   [switch]$clearWorkingSet = $false
)
$ErrorActionPreference = "Stop"

# Normally, an RSS feed URL would be a subdirectory of the base website and would have a forward
# slash included. Manually suffix a forward slash in the unlikely situation that this is not the case.
# But don't add it in if the RSS feed is being provided from an actual XML endpoint.
if ($rssFeed.EndsWith("/") -eq $false -And $rssFeed.EndsWith(".xml") -eq $false) {
    $rssFeed = "${rssFeed}/"
}

$targetSite = [Regex]::Match($rssFeed, "https?:\/\/(.+?)\/").Groups[1].Value
$rssFeedDetails = Invoke-RestMethod -Uri "http://localhost:277?isRssFeed=true&url=${rssFeed}"
$sitesAll = $(Foreach ($siteDetails in $rssFeedDetails.entries) {
    $site = $siteDetails.link
    # Ignore links that point to the primary homepage or the RSS feed site
    if ($site.EndsWith($targetSite) -eq $false -And $site -ne $rssFeed) {
        $site
    }
}) | Sort-Object -Descending | Get-Unique

$rssFolder = "${PSScriptRoot}\data\${targetSite}"
$rssCacheFileName = "${rssFolder}\rss-feed-cache.${targetSite}.txt"
$rssWorkingSetFileName = "${rssFolder}\rss-feed-working-set.${targetSite}.txt"

# Need to check the path before deletion, otherwise an error occurs when trying to delete a non-existing file
if ($clearWorkingSet -And (Test-Path $rssWorkingSetFileName)) {
    New-Item $rssWorkingSetFileName -ItemType File -Force
}

if (Test-Path $rssCacheFileName) {
    # Load the existing cache to determine which items from the RSS feed to ignore
    $rssCache = $(ForEach ($line in Get-Content $rssCacheFileName) {
        $line
    }) | Sort-Object -Descending | Get-Unique
    
    if ($rssCache -ne $null -And $sitesAll -ne $null) {
        Write-Host "**** NEW WORKING SET ITEMS ****" -ForegroundColor Blue -BackgroundColor White
        # Handle any new working set links in the RSS feeds, ignoring anything which the cache has but the RSS feed doesn't
        ForEach ($rssWorkingSetItem in Compare-Object $rssCache $sitesAll | Where-Object SideIndicator -eq "=>") {
            Write-Host $rssWorkingSetItem.InputObject -ForegroundColor DarkGreen -BackgroundColor White
            
            # Persist any new working set links for external use
            if ($appendWorkingSet) {
                Add-Content -Path $rssWorkingSetFileName -Value $rssWorkingSetItem.InputObject
            }
        }
        Write-Host "*******************************" -ForegroundColor Blue -BackgroundColor White
    } else {
        Write-Host "**** NO ITEMS IN RSS FEED OR CACHE IS EMPTY ****" -ForegroundColor Red -BackgroundColor White
    }
} else {
    # If the cache doesn't exist, then all the links are new and therefore part of the working set
    New-Item -Path $rssFolder -ItemType Directory -Force
    Out-File -FilePath $rssWorkingSetFileName -InputObject $sitesAll
}

Out-File -FilePath $rssCacheFileName -InputObject $sitesAll
Write-Host @"
Completed cache update with the latest RSS feed results. You can check these in the following files:

Cache file: ${rssCacheFileName}
Working set: ${rssWorkingSetFileName}
"@ -ForegroundColor Black -BackgroundColor White
