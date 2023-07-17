function Select-Item {
    <#
        .SYNOPSIS
            Select an item from a given list.
        .DESCRIPTION
            This function shows a vertically sorted list of unique items in columns and lets you choose one of them.
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
        [System.Collections.Generic.List[String]]
        $itemList
    )
    begin {
        if ($itemList.Length -eq 1) {
            Return $itemList[0]
        }
        if ($itemList.Count -ne ($itemList | Select-Object -Unique).count) {
            Write-Error "the provided list contains duplicate elements. '$($itemList)'"
            break
        }

        $displayList = foreach ($item in $itemList) {
            [PSCustomObject]@{
                Name        = $item
                Index       = $itemList.IndexOf($item) + 1
                DisplayName = "{0,3} - {1}" -f $($itemList.IndexOf($item) + 1), $item
            }
        }
        $LongestElement = 
        ($displayList | Sort-Object -Property { $_.DisplayName.toString().Length } | Select-Object -Last 1 -ExpandProperty DisplayName).length
        $ConsoleWidth = $Host.UI.RawUI.WindowSize.Width
        $CalculatedColumnCount = [Math]::Floor( $ConsoleWidth / ($LongestElement + 10))
    }
    process {
        if ($displayList.count -le 25) {
            $MaxColumnCount = 1
        }
        elseif ($displayList.count -le 60) {
            $MaxColumnCount = 2
        }
        if ($MaxColumnCount) {
            $DisplayColumnCount = $MaxColumnCount
        }
        else {
            $DisplayColumnCount = $CalculatedColumnCount
        }
        $DisplayItemList = [System.Collections.Generic.List[String]]$($displayList.DisplayName)
        $Rows = [Math]::Ceiling($displayList.count / $DisplayColumnCount)
        $Matrix = New-Object 'object[,]' $DisplayColumnCount, $Rows
        foreach ($Column in @(0..($DisplayColumnCount - 1))) {
            foreach ($Row in @(0..($Rows - 1))) {
                if ($DisplayItemList.Count -gt 0) {
                    $Matrix[$Column, $Row] = $DisplayItemList.Item(0).toString()
                    $DisplayItemList.RemoveAt(0)
                }
            }
        }
        $ColumnList =
        foreach ($Row in @(0..($Rows - 1))) {
            $CompleteRow =
            foreach ($Column in @(0..($DisplayColumnCount - 1))) {
                "{0,-$($LongestElement + 6)}" -f $Matrix[$Column, $Row]
            }
            $CompleteRow -join ' '
        }
        $ColumnList | Out-Host
    }
    end {
        [int]$choice = 0
        do {
            try {
                [int]$choice = Read-Host "`nPlease enter index of the desired item (<Enter> = 0 = cancel)"  -ErrorAction Stop
            }
            catch {
                Write-Warning "Incorrect input! Please choose a numeric value between '0' and '$($displayList.Length )'!"
            } 
        }
        until ($choice -ge 0 -and $choice -le $displayList.Length )
        if ($choice -eq 0) {
            $selectedItem = 'none'
        }
        else {
            $selectedItem = $displayList[$choice - 1].Name
        }
        return $selectedItem
    }
}
