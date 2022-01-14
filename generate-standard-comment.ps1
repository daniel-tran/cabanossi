# Use this command to enable script running for the local PowerShell session:
# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

<#
.SYNOPSIS
    Returns a string that can be used as a generic comment on an existing post.
.DESCRIPTION
    Prints a string containing a random positive comment, along with other text elements.
    Note that the mention does not automatically link to the target entity on some
    social media platforms such as LinkedIn.
.PARAMETER commentsFile
    The file of preset comments to extract a sample from.
.EXAMPLE
    .\generate-standard-comment.ps1
.EXAMPLE
    .\generate-standard-comment.ps1 -commentsFile .\COMMENTS.txt
.NOTES
    Currently only tested on LinkedIn.
#>

param(
   [string]$commentsFile = ".\COMMENTS.txt"
)

# Random line selecting logic is based on this Microsoft post:
# https://devblogs.microsoft.com/scripting/use-powershell-to-pick-random-winning-users-from-text/
$comment = Get-Content $commentsFile | sort{Get-Random} | select -First 1
"${comment} @Macrohard #technology"
