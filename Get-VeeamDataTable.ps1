function Get-VeeamDataTable
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [Object]
        $ConnectionString,
    
        # Parameter help description
        [Parameter()]
        [Object]
        $CommandText
    )

    $cnn = New-Object System.Data.SqlClient.SqlConnection
    $cnn.ConnectionString = $ConnectionString
    $cnn.Open()

    $cmd = $cnn.CreateCommand()
    $cmd.CommandText = $CommandText

    $result = $cmd.ExecuteReader()

    $table = New-Object System.Data.DataTable
    $table.Load($result)

    $cnn.Close()
    $cnn.Dispose()

    return @(,$table)
}
