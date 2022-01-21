# Cabanossi :pig:

PowerShell scripts that generate "original" posts for social media.

All you have to do is set it up, run the scripts, copy the console output and post it on social media! It's that's easy!

## Dependencies

1. PowerShell 5.1 or higher (version 5.1 should be included with Windows 10 by default)
2. Node 16.13.2 or higher
3. Npm 8.1.2 or higher (should already be included with the standard Node installer)

**It should also be noted that this has only been tested on Windows 10.**

## Setup

1. Run `article-parser-server\setup-article-parser-server.bat`. This only needs to be done once, as long as you don't remove the `article-parser-server\node_modules` folder.
2. Run `setup-article-parser-server.bat`. This will start a local web server that is utilised by some of the scripts, and can be stopped by pressing Control + C, then Y.
3. In a PowerShell session, you may need run the following command for permission to run scripts: `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process`

## Usage

### Generate comments

This script simply selects a random pre-written comment from a file, with options to specifying mentions and hashtags.

Example:
```powershell
.\generate-standard-comment.ps1 -mentions "@Macrohard" -hashtags "#technology #software"
```

Example output:
```
Marvelous! @Macrohard #technology #software
```

For more information about this script, run the folllowing command: `Get-Help -Detailed .\generate-standard-comment.ps1`

### Generate posts 

This script takes a quote from a given website to produce text for a (hopefully convincing) semi-legitimate looking original post.
Similar to `generate-standard-comment.ps1`, you can specify mentions and hashtags to include in the post.

Example:
```powershell
.\generate-standard-post.ps1 -site https://news.microsoft.com/2009/07/22/microsoft-releases-windows-7-and-windows-server-2008-r2/ -mentions "@Macrohard" -hashtags "#technology #software"
```

Example output:
```
"With the completion of this development phase, industry partners are readying products in time for the Windows 7 and Windows Server 2008 R2 worldwide general launches." @Macrohard #technology #software
https://news.microsoft.com/2009/07/22/microsoft-releases-windows-7-and-windows-server-2008-r2/
```

For more information about this script, run the folllowing command: `Get-Help -Detailed .\generate-standard-post.ps1`

### Obtain articles from RSS feed

This script extracts article links from an RSS feed and stores the result in a file. This data can be used as input into `generate-standard-post.ps1`.

Example:
```powershell
.\extract-sites-from-rss-feed.ps1 -rssFeed https://www.technologyreview.com/feed/
```

Example output (found under "\data\www.technologyreview.com\rss-feed-working-set.www.technologyreview.com.txt"):
```
https://www.technologyreview.com/2022/01/13/1043591/scaling-with-low-code-to-accelerate-digital-transformation/
https://www.technologyreview.com/2022/01/13/1043582/western-digitals-journey-to-build-business-resiliency-through-cloud-and-erp-transformations/
https://www.technologyreview.com/2022/01/13/1043573/cybersecurity-and-the-new-era-of-ecosystems/
https://www.technologyreview.com/2022/01/13/1043565/cybersecurity-is-now-a-boardroom-priority/
https://www.technologyreview.com/2022/01/13/1043556/cybersecurity-2022-predictions/
https://www.technologyreview.com/2022/01/13/1043537/automation-journey-of-bupa-global/
```

For more information about this script, run the folllowing command: `Get-Help -Detailed .\extract-sites-from-rss-feed.ps1`

### Interactive mode?

This script encapsulates the behaviour of the other PowerShell scripts, allowing users to invoke them without having to manually navigate around folders or open text files.
You can also specify mentions and hashtags to include in the generated comments and posts.

Example:
```powershell
.\generate-content-interactive.ps1
```

For more information about this script, run the folllowing command: `Get-Help -Detailed .\generate-content-interactive.ps1`

## FAQ

### Q. What are these concepts of "cache" and "working sets" referring to in `extract-sites-from-rss-feed.ps1`?

In summary:
- **Cache** = All the known items gathered from a specific RSS feed. The working set will not be updated with entries that already exist here.
- **Working set** = All the valid items from an RSS feed that are yet to be consumed. Items removed from this file are considered as "consumed".

Depending on the contents/existence of these files when the script is run, the following behaviours are expected:

|                                    |No cache/Cache is empty        |Cache exists                 |
|------------------------------------|-------------------------------|-----------------------------|
|No working set/working set is empty |RSS feed is accessed for the first time; Cache and working set are initialised with the same contents|Working set is updated with any new items from the RSS feed which aren't already in the cache|
|Working set exists                  |Cache is regenerated without modifying the working set|Cache and working set are updated with any new items from the RSS feed|

### Q. Why use PowerShell?

The language was haphazardly chosen for this project at around 10 o'clock once upon a night. So there's no particular reason for using PowerShell, although in hindsight, I'd say it was a fairly decent choice, all things considered.

### Q. Why does `generate-standard-comment.ps1` need to source comment data from a file?

The idea was that you could have different data sets on your local machine, and then run the script using a different file for a specific context.

For example, you might have one file with professional or more articulated comments for use on LinkedIn, but another file can contain more casual comments for platforms like Twitter or Instagram.

### Q. If the article-parser-server is written in JavaScript, why not write the scripts in JavaScript as well?

During the very early stages of the `generate-standard-post.ps1`, it used to depend on a free web service that would provide data about a particular web page, so just using PowerShell was sufficient. Unfortunately, this web service has ceased and is no longer accessible by simply calling the `Invoke-WebRequest` commandlet.
Luckily, there are npm modules that can more or less facilitate the same functionality, which eventually led to the article-parser-server. 
In that regard, the use of JavaScript was mostly an after-the-fact replacement for an existing part of the PowerShell scripts, and there's probably not too much value gained here by rewriting the scripts in a different language.

### Q. Why does `extract-sites-from-rss-feed.ps1` store data as lines in a file instead of using a data format such as YAML, XML or JSON?

Appending data to a specific file is more straightforward when all the data in a file is organised as rows. If the data was organised as a JSON object, appending data means reading the entire file, parsing it as an object, adding the new entry to the object and writing the object back into the file.

Also, `extract-sites-from-rss-feed.ps1` doesn't need to access a specific data entry, so the need for indexing individual items isn't necessary.
