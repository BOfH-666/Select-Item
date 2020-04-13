
function Select-Item {
    <#
        .SYNOPSIS
            Select an item from a given list.

        .DESCRIPTION
            This function shows a vertically sorted list of unique items in three columns and lets you choose one of them.

        .PARAMETER  itemList
            Specifies the list of items to choose from

        .EXAMPLE
            PS C:\> Select-Item -itemList 'Peter', 'Paul', 'Mary', 'John', 'George', 'Paul', 'Ringo', 'Mick', 'Keith', 'Ron', 'Charlie'

            This command eliminates the double occurance of Paul and shows the rest of the names including an index number for each of them in three columns.

            1 - Peter             5 - George           8 - Keith
            2 - Paul              6 - Ringo            9 - Ron
            3 - Mary              7 - Mick            10 - Charlie
            4 - John

            Please enter index of the desired item (<Enter> = 0 = cancel):  

        .INPUTS
            System.Array

        .OUTPUTS
            System.String

        .NOTES
            The built in cmdlet Format-Wide provides a way of formatting any given list in columns but the order would be horizontal, which I didn't like. That's why I created this function

        .LINK
            about_functions_advanced

        .LINK
            about_comment_based_help

    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Array]
        $itemList
    )
    $itemList = $itemList | Select-Object -Unique
    $displayList = foreach ($item in $itemList) {
        [PSCustomObject]@{
            Name        = $item
            Index       = $itemList.IndexOf($item) + 1
            DisplayName = "{0,3} - {1}" -f $($itemList.IndexOf($item) + 1), $item
        }
    }

    if ($itemList.Length -gt 3) {
        $FloorThird = [Math]::Floor($itemList.Count / 3)
        $Modulo = $itemList.Count - ($FloorThird * 3 )


        switch ($Modulo) {
            1 {
                $Chunk1 = $displayList | Select-Object -First ( $FloorThird + 1 )
                $Chunk2 = $displayList | Select-Object -Skip  ( $FloorThird + 1 ) -First $FloorThird
                $Chunk3 = $displayList | Select-Object -Last  $FloorThird
            }
            2 {
                $Chunk1 = $displayList | Select-Object -First ( $FloorThird + 1 )
                $Chunk2 = $displayList | Select-Object -Skip  ( $FloorThird + 1 ) -First ( $FloorThird + 1 )
                $Chunk3 = $displayList | Select-Object -Last  $FloorThird
            }
            Default { 
                $Chunk1 = $displayList | Select-Object -First $FloorThird
                $Chunk2 = $displayList | Select-Object -Skip  $FloorThird -First $FloorThird
                $Chunk3 = $displayList | Select-Object -Last  $FloorThird
            }
        }

        $DisplayIndexStartChunk1 = -2
        $ColumnList = $Chunk1 | 
        ForEach-Object {
            [PSCustomObject]@{
                Data         = $_.Name
                Index        = $_.Index
                DisplayName  = $_.DisplayName
                DisplayIndex = $DisplayIndexStartChunk1 += 3
            }
        }
        $DisplayIndexStartChunk2 = -1
        $ColumnList += $Chunk2 | 
        ForEach-Object {
            [PSCustomObject]@{
                Data         = $_.Name
                Index        = $_.Index
                DisplayName  = $_.DisplayName
                DisplayIndex = $DisplayIndexStartChunk2 += 3
            }
        }
        $DisplayIndexStartChunk3 = 0
        $ColumnList += $Chunk3 | 
        ForEach-Object {
            [PSCustomObject]@{
                Data         = $_.Name
                Index        = $_.Index
                DisplayName  = $_.DisplayName
                DisplayIndex = $DisplayIndexStartChunk3 += 3
            }
        }
    }
    elseif ($itemList.Length -eq 1) {
        return $itemList
    }
    else {
        $ColumnList = $displayList
    }
    $ColumnList | Sort-Object -Property DisplayIndex | Format-Wide -Column 3 -Property DisplayName | Out-Host

    [int]$choice = 0
    do {
        try {
            [int]$choice = Read-Host 'Please enter index of the desired item (<Enter> = 0 = cancel)'  -ErrorAction Stop
            Write-Verbose "Select-ItemFromThreeColumnsList `$choice: $choice"
        }
        catch {
            Write-Warning "Incorrect input! Please choose a numeric value between '0' and '$($itemList.Length )'!"
        } 
    }
    until ($choice -ge 0 -and $choice -lt $itemList.Length + 1 )
    if ($choice -eq 0) {
        $selectedItem = 'none'
    }
    else {
        $selectedItem = $itemList[$choice - 1 ] 
    }
    Write-Verbose "Select-ItemFromThreeColumnsList `$selectedItem: $selectedItem"

    return $selectedItem
}

