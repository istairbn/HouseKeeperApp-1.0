<#
    .Synopsis
    This cleans the Temp Files for Windows
    
    .Parameter LogFilePrefix
    The Prefix before the dated name
    
    .Example
    Get-LogFileName -TEST
    
    .Notes
    
    .Link
    www.excelian.com
#>
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Medium')]
    Param (
    [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)]
    [string]
    $Days = 7
    )

$TimeFrame = (Get-Date).AddDays(-$Days)
$Users = Get-ChildItem C:\Users

Function ConvertTo-LogscapeJSON{
        <#            .Synopsis            This converts an object to a Logscape compatibile JSON String, plus a timestamp                    .Parameter Input            The Object needing conversion            .Parameter TimeStamp            Remove Timestamp - Boolean            .Example            Get-HpcClusterOverview | ConvertTo-LogscapeJSON            .Notes            .Link            www.excelian.com        #>        [CmdletBinding()]    Param(    [Parameter(Mandatory=$True,ValueFromPipeline=$True)]    [System.Object]    $Input,

    [Parameter(Mandatory=$False,ValueFromPipeline=$True)]    [bool]    $Timestamp = $True
    )

    If($Input.Count -ne 0){
        $STAMP = Get-Date -Format "yyyy/MM/dd HH:mm:ss zzz"
        $Input = $Input | ConvertTo-Json -Compress

        $OutString = $Input.Replace("{","{ ").Replace("}"," }").Replace("\/","")
        $OutString = $OutString -Replace ":(\d+),",':"$1",'
        $OutString = $OutString -Replace ":(\d+) }",':"$1" }'

        $Collection = $OutString | Select-String -AllMatches -Pattern 'Date\((\d+)\)' |Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value

        $Map = @{}

        ForEach($Element in $Collection){
            $Number = $Element.TrimEnd(")").TrimStart("Date(")
            $RequiredDate = ConvertFrom-UnixTime $Number
            $NewDate = Get-Date -Date $RequiredDate -Format "yyyy/MM/dd HH:mm:ss"
            $NewKey = $Element.ToString()
            $NewValue = $NewDate.ToString()

            Try{
            $Map.Add($NewKey,$NewValue)
            }
            Catch [System.ArgumentException] {
                Write-Verbose "$NewKey already added"
            } 
        }

        ForEach($Target in $Map.GetEnumerator()){
            $OutString = $OutString.Replace($($Target.Name),$($Target.Value))
        }

        If($Timestamp -eq $True){
            $OutString = $STAMP + " " + $OutString
        }

        Write-Output $OutString

    }}

Function ConvertFrom-UnixTime{
    <#        .Synopsis        This converts a Unix time uinto a Powershell Date object                .Parameter UnixTime        The Unix Time needing conversion        .Example        Convert-From-UnixTime        .Notes        .Link        www.excelian.com    #>    

    [CmdletBinding()]
    
    Param(
    [Parameter (Mandatory=$True,Position=1,ValueFromPipeline=$True)] 
    [Long]
    $UnixTime
    )

    $origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
    $ReadableDate = $origin.AddMilliseconds($UnixTime)

    Write-Output $ReadableDate
}

ForEach($User in $users){
    $Folder = "$($User.FullName)\AppData\Local\Temp"
    If(Test-Path $folder){
        $TempContents = Get-ChildItem $Folder
        ForEach($File in $TempContents){
            $FileTarget = $File.LastAccessTime
            $Remove = $false
            If($FileTarget -lt $TimeFrame){
                $Remove = $True
                Remove-Item -Path $File.FullName -Recurse -Force -ErrorAction Continue 
            }
            $Object = New-Object -TypeName PsObject -Property @{Name=$File.FullName;LastAccessed=$FileTarget;DeleteTime=$TimeFrame;Remove=$Remove}
            $Object | ConvertTo-LogscapeJson
        }
    }
}

