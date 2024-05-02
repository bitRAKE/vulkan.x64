#
#	Retrieve just the Vulkan XML API Registry:
#
$destDir = (Get-Location).Path
$baseUrl = "https://raw.githubusercontent.com/KhronosGroup/Vulkan-Docs/main/"
$logFile = Join-Path $destDir ".gitignore"


# List of partial paths
$partialPaths = @(
    "LICENSE.adoc",
    "xml/registry.rnc",
    "xml/video.xml",
    "xml/vk.xml"
)

# Check if log file exists, create if not
if (-Not (Test-Path $logFile)) {
    New-Item -Path $logFile -ItemType File
}

# Initialize an array to hold log entries
$logEntries = @()
# don't store generated file
$logEntries += "vk.inc"

# Loop through each partial path
foreach ($partialPath in $partialPaths) {
    try {
        # Construct the full URL, ensure correct slash for URLs
        $url = $baseUrl + $partialPath.Replace('\', '/')

        # Extract file name from URL
        $fileName = [System.IO.Path]::GetFileName($partialPath)

        # Full path to save the file
        $filePath = Join-Path $destDir $fileName

        # Download the file
        Invoke-WebRequest -Uri $url -OutFile $filePath

	$logEntries += $fileName
    } catch {
        Write-Error "Failed to download $url. Error: $_"
        break
    }
}

# Check if all files were downloaded and log only if successful
if ($logEntries.Count -eq $partialPaths.Count) {
    # Overwrite the log file with all successful entries
    Set-Content -Path $logFile -Value $logEntries
    Write-Host "All files downloaded and logged successfully."
} else {
    Write-Host "Some files failed to download, log not updated."
}

#	fasmg vk.g
#	copy vk.inc ..\
# <make needed changes>
#	git diff vk.inc ..\vk.inc >win.patch
# <apply changes>
#	git apply win.patch vk.inc ..\vk.inc
