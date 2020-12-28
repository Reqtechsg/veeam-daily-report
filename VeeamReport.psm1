. $PSScriptRoot\Get-VeeamDataTable.ps1
. $PSScriptRoot\New-VeeamHtml.ps1

function Send-VeeamReport
{
    [CmdletBinding()]
    param (  
        # Parameter help description
        [Parameter()]
        [String]
        $VeeamDatabasesJsonFile,

        [Parameter()]
        [String]
        $EmailParametersJsonFile
    )

    # 1.Consolidate data from each Veeam Server
    $veeamDatabases = (Get-Content $VeeamDatabasesJsonFile | ConvertFrom-Json)
    $tableMerge   = New-Object System.Data.DataTable
    $sqlCommand   = $(Get-Content $PSScriptRoot\veeam-report.sql)

    foreach($db in $veeamDatabases)
    {
        $datasource = $db.datasource
        $database = $db.database
        $connectionString = "Server=$datasource;Database=$database;Integrated Security=$true"
        $tableMerge.Merge( $(Get-VeeamDataTable -ConnectionString $connectionString -CommandText $sqlCommand) )
    }

    # 2.Generate HTML message body
    New-VeeamHtml -DataTable $tableMerge -Path $PSScriptRoot\veeam-report.html

    # 3.Send Email
    $emailParameters = $(Get-Content $EmailParametersJsonFile | ConvertFrom-Json)
    $smtpServer      = $emailParameters.smtpServer
    $from            = $emailParameters.from
    $to              = $emailParameters.to
    $subject         = $emailParameters.subject
    $body            = $(Get-Content $PSScriptRoot\veeam-report.html)

    Send-MailMessage -From $from -To $to -Subject $subject -BodyAsHtml $body -SmtpServer $smtpServer
}
