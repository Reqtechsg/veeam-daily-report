$dataSource1 = "SCPBKSP01\VEEAMSQL2012"
$database1 = "VeeamBackup"
$connString1 = "Server=$dataSource1;Database=$database1;Integrated Security=$true"

$conn1 = New-Object System.Data.SqlClient.SqlConnection
$conn1.ConnectionString = $connString1
$conn1.Open()

$cmd1 = $conn1.CreateCommand()
$cmd1.CommandText = $(Get-Content 'C:\Veeam-Scripts\veeam-report.sql')

$result1 = $cmd1.ExecuteReader()

$table1 = New-Object System.Data.DataTable
$table1.Load($result1)

$conn1.Close()
$conn1.Dispose()

$dataSource2 = "ADPBKSP01\VEEAMSQL2012"
$database2 = "VeeamBackup"
$connString2 = "Server=$dataSource2;Database=$database2;Integrated Security=$true"

$conn2 = New-Object System.Data.SqlClient.SqlConnection
$conn2.ConnectionString = $connString2
$conn2.Open()

$cmd2 = $conn2.CreateCommand()
$cmd2.CommandTimeout = 30
$cmd2.CommandText = $(Get-Content 'C:\Veeam-Scripts\veeam-report.sql')

$result2 = $cmd2.ExecuteReader()

$table2 = New-Object System.Data.DataTable
$table2.Load($result2)

$table1.Merge($table2)
#$table1 | Group-Object -Property result | ft @{Expression={$_.Name};Label='Job Result'}, @{Expression={$_.Count};Label='Number of Jobs'}

$summary = $table1 | Group-Object "Last Result"

$html = "<!DOCTYPE html><html>" + (Get-Content C:\Veeam-Scripts\veeam-report-html-top.txt ) + "<body>Backup Job Summary - Past 24 Hours<br><br><div><table cellpadding=""0"" cellspacing=""0""><thead><tr>"

$html = $html + "<th>Job Result</th><th>Number of Jobs</th></tr></thead><tbody>"

$summary | % {$html = $html + "<tr><td>" + $($_.Name) + "</td><td>" + $($_.Count) + "</td></td>" }

$html = $html + "</tbody></table></div><br>Backup Job Sessions - Past 24 Hours<br><br><div><table width=""100%"" cellpadding=""0"" cellspacing=""0""><thead><tr>"

for($i=0 ; $i -le $table1.Columns.count-1 ; $i++)
{
    $html = $html + "<th>" + $table1.Columns[$i] + "</th>"
}

$html = $html + "</tr></thead><tbody>"

foreach($row in $table1)
{
    $html = $html + "<tr>"
    for($i=0 ; $i -le $row.ItemArray.Count - 1 ; $i++)
    {
        $html = $html + "<td>" + $row[$i] + "</td>"
    }
    $html = $html + "</tr>"
}

$html  = $html + "</tbody></table></div><br>For more information, login to <a href=""https://veeam-ent-mgr.salgrp.sal.sg:9443"">Veeam Enterprise Manager</a></body></html>" 

$html | Out-File C:\Veeam-Scripts\veeam-report.html

$conn2.close()
$conn2.Dispose()

####################################################################################################


#Send Email


Send-MailMessage -From "SAL Veeam Backup <noreply@sal.org.sg>" -To "sirius_req@sal.org.sg" -Subject "SAL Veeam Backup - Daily Notification" -BodyAsHtml (Get-Content C:\Veeam-Scripts\veeam-report.html) -SmtpServer 192.168.0.32