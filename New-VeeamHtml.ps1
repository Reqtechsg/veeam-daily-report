function New-VeeamHtml
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Data.DataTable]
        $DataTable,
    
        # Parameter help description
        [Parameter()]
        [Object]
        $Path,

        [Parameter(Mandatory=$false)]
        [Object]
        $htmlTopFilePath="$($PSScriptRoot)\veeam-report-html-top.txt"
    )

    $summary = $DataTable | Group-Object "Result"

    $htmlTop = (Get-Content $htmlTopFilePath )

    $html = "<!DOCTYPE html><html>" + $htmlTop + "<body>Backup Job Summary - Past 24 Hours<br><br><div><table cellpadding=""0"" cellspacing=""0""><thead><tr>"

    $html = $html + "<th>Job Result</th><th>Number of Jobs</th></tr></thead><tbody>"

    $summary | % {$html = $html + "<tr><td>" + $($_.Name) + "</td><td>" + $($_.Count) + "</td></td>" }

    $html = $html + "</tbody></table></div><br>Backup Job Sessions - Past 24 Hours<br><br><div><table width=""100%"" cellpadding=""0"" cellspacing=""0""><thead><tr>"

    for($i=0 ; $i -le $DataTable.Columns.count-1 ; $i++)
    {
        $html = $html + "<th>" + $DataTable.Columns[$i] + "</th>"
    }

    $html = $html + "</tr></thead><tbody>"

    foreach($row in $DataTable)
    {
        $html = $html + "<tr>"
        for($i=0 ; $i -le $row.ItemArray.Count - 1 ; $i++)
        {
            $html = $html + "<td>" + $row[$i] + "</td>"
        }
        $html = $html + "</tr>"
    }

    #$html  = $html + "</tbody></table></div><br>For more information, login to <a href="""">Veeam Enterprise Manager</a></body></html>" 
    
    $html  = $html + "</tbody></table></div>"

    $html | Out-File $Path
}
