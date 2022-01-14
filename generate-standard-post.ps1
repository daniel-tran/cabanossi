# Use this command to enable script running for the local PowerShell session:
# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

<#
.SYNOPSIS
    Returns a string that can be used as the text component for an original post.
.DESCRIPTION
    Prints a string containing a text quote from a given website, along with other text elements,
    including a link to the website which the quote was sourced from.
    Note that the mention does not automatically link to the target entity on some social media
    platforms such as LinkedIn.
.PARAMETER site
    The website to extract a sentence from. Defaults to the empty string.
.PARAMETER extractFromDescription
    If enabled, the script will select a full sentence from the page, based on the article parser's description.
    This usually returns sentences with a fairly consistent format and relatively unchanging content.
    
    If disabled, the script will select a random sentence from the article as the quoted text. Note that the script
    may not always return a properly formatted sentence, partly due to the presence of HTML tags that need to be stripped
    out. This is the default behaviour.
.PARAMETER workingSetFile
    The file to extract the site from, taking only the first line. Overrides the $site parameter, unless the file doesn't exist.
    Defaults to the empty string.
.EXAMPLE
    .\generate-standard-post.ps1 -site https://nodejs.org/en/knowledge/HTTP/servers/how-to-create-a-HTTP-server/
.EXAMPLE
    .\generate-standard-post.ps1 -workingSetFile .\SITES.txt
.EXAMPLE
    .\generate-standard-post.ps1 -extractFromDescription -site https://nodejs.org/en/knowledge/HTTP/servers/how-to-create-a-HTTP-server/
.NOTES
    Currently only tested on LinkedIn.
#>
param(
   [string]$site = "",
   [switch]$extractFromDescription = $false,
   [string]$workingSetFile = ""
)

if ($workingSetFile -ne "" -and (Test-Path $workingSetFile)) {
   $site = Get-Content $workingSetFile -First 1;
}

$res = Invoke-RestMethod -Uri "http://localhost:277?url=${site}"

if ($res -ne "null" -and $res -ne $null) {
   if ($extractFromDescription -eq $true) {
      $desc = [Regex]::Match( $res.description, "(.+[\.\!\?])").Value
   } else {
      $normalisedRes = $res.content -replace "\<.+?\>"
      # Only interested in full sentences, but isn't always guaranteed
      $descList = ([regex]".+?[\.\!\?]").Matches($normalisedRes)
      $randomIndex = Get-Random -Minimum 0 -Maximum @($descList).length
      $desc = $descList[$randomIndex].Value.trim()
   }
   """${desc}"" @Macrohard #technology`r`n${site}"
} else {
   "ERROR!"
   $res.message
}
