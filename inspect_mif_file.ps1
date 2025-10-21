# MIF Inspector for ConfigMgr BADMIFS
# Parses Start Group / Class = "..." blocks
# Outputs to D:\MIF_Report.csv

param(
    [Parameter(Mandatory=$true)]
    [string]$MifFilePath
)

$ReportFile = "D:\MIF_Report.csv"

if (!(Test-Path $MifFilePath)) {
    Write-Host "File not found: $MifFilePath"
    exit 1
}

Write-Host "Analyzing $MifFilePath ..."

$ClassCounts = @{}
$CurrentClass = $null

Get-Content -Path $MifFilePath -ReadCount 1000 | ForEach-Object {
    foreach ($line in $_) {

        # Detect new group start
        if ($line -match '^Start Group') {
            $CurrentClass = $null
        }

        # Capture class name
        if ($line -match '^Class\s*=\s*"([^"]+)"') {
            $CurrentClass = $matches[1]
            if (-not $ClassCounts.ContainsKey($CurrentClass)) {
                $ClassCounts[$CurrentClass] = 0
            }
        }

        # Count attributes for the current class
        if ($line -match '^Start Attribute' -and $CurrentClass) {
            $ClassCounts[$CurrentClass]++
        }
    }
}

$Results = $ClassCounts.GetEnumerator() |
    Sort-Object Value -Descending |
    Select-Object @{Name="ClassName";Expression={$_.Key}},
                  @{Name="AttributeCount";Expression={$_.Value}}

Write-Host "`nTop 20 Classes by Attribute Count:"
$Results | Select-Object -First 20 | Format-Table -AutoSize

# Write CSV manually to avoid BOM
"ClassName,AttributeCount" | Out-File -FilePath $ReportFile -Encoding utf8
$Results | ForEach-Object {
    "$($_.ClassName),$($_.AttributeCount)"
} | Out-File -FilePath $ReportFile -Append -Encoding utf8

Write-Host "`nReport written to $ReportFile"
