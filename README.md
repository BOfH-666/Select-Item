# Select-Item
  
I didn't like the order the command "Format-Wide -Column 3" provides. So I created this little function to change the order from horizontal to vertical.
  
**.SYNOPSIS**  
Select an item from a given list.  
  
**.DESCRIPTION**  
This function shows a vertically sorted list of unique items in three columns and lets you choose one of them.    
  
**.PARAMETER  itemList**  
Specifies the list of items to choose from
  
**.EXAMPLE**  

```Powershell
PS C:\> Select-Item -itemList 'Peter', 'Paul', 'Mary', 'John', 'George', 'Paul', 'Ringo', 'Mick', 'Keith', 'Ron', 'Charlie'
```
  
This command eliminates the double occurance of Paul and shows the rest of the names including an index number for each of them in three columns.

```Powershell
        1 - Peter             5 - George           8 - Keith
        2 - Paul              6 - Ringo            9 - Ron
        3 - Mary              7 - Mick            10 - Charlie
        4 - John

        Please enter index of the desired item (<Enter> = 0 = cancel):
```
  
**.INPUTS**  
System.Array  
  
**.OUTPUTS**  
System.String  
  
**.NOTES**  
Author: O.Soyk  
Date:   20200413  
