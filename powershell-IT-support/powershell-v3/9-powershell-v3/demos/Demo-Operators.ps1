#requires -version 3.0

#demo PowerShell Operators

#region Comparison Operators

5 -gt 3
100 -lt 90
11 -le 11
$i = Get-Random -Minimum 1 -Maximum 10
$i -eq 7

#not case sensitive
"jeff" -eq "JEFF"
#although you can make it so
"jeff" -ceq "JEFF"

$s = "PowerShell"
#using a wildcard
$s -like "*shell"

#using regular expressions
$s -match "shell"
$s -match "shell$"

#compare array membership
$arr = "a","b","c","d"
$arr -contains "e"
$arr -contains "d"
$arr -notcontains "e"

#sometimes you go the other way
"a" -in $arr
"x" -in $arr
"x" -notin $arr

#these only work with simple values, not objects
$p = Get-Process
$p -contains "notepad"

$p.name -contains "notepad"
$p.name -contains "lsass"
cls
#endregion

#region Arithmetic Operators
5*4
5+4
5/4
5%4

#use parens to control execution
10+2/4*5-2
((10+2)/(4*5))-2

cls
#endregion

#region Logical Operators
(4 -ge 2) -AND (10 -lt 100)
(4 -ge 8) -AND (10 -lt 100)
(4 -ge 8) -OR (10 -lt 100)

#true only if one expression is true and one is false
(4 -ge 8) -XOR (10 -lt 100)

#Reverse things
-Not (100 -gt 1)
#you'll also see it written this way
!(100 -gt 1)

#a more practical example
if (-Not (Test-Path "C:\Required")) {
    Write-Host "Creating C:\Required" -ForegroundColor Cyan
    #I don't really want to create the folder
    Mkdir "C:\Required" -whatif
}
cls
#endregion

#region Assignment Operators
$x = 123 ; $x
$x += 2 ; $x
$x -= 23 ; $x
$x /= 3 ; $x
$x++ ; $x
$x-- ; $x

#endregion

#region Type Operators

"jeff" -is [string]
$dt = Get-Date
$dt -is [string]
$dt -is [datetime]
$dt -isnot [datetime]
#be careful
$x = "10"
$x*4
$x -is [int]
($x -as [int])*4
#Better to define the right type from the beginning
$x = 10 ; $x*4
#but using -as can come in handy
$d = Read-Host "Enter an expiration date"
$d
$d -is [datetime]
$d -as [datetime]
#even better set the type from the very beginning
[datetime]$d = Read-Host "Enter an expiration date"
$d

cls
#endregion

#region Special Operators
1..10
90..75
1..10 | foreach {
 Write-Host "Adding JoeTest-$_" -ForegroundColor DarkMagenta
 #net user "JoeTest-$_" "P@ssword" /add /domain
}

$cmd="get-service"
$cmd
&$cmd

#or use with scriptblocks
$sb={get-service w* | where {$_.status -eq 'stopped'}}
$sb
&$sb

1kb
1mb
2.3MB + 4.2GB
(Get-CimInstance win32_logicaldisk -Filter "deviceid='c:'" -Property Freespace).Freespace/1gb
#combine for a quick and dirty disk check
$df = {(Get-CimInstance win32_logicaldisk -Filter "deviceid='c:'" -Property Freespace).Freespace/1gb}
&$df

cls
#endregion

#region Split/Join
$t = "PowerShell will rule the world"
-split $t

$n = "alice;bob;carol;david"
$n | gm
$n.Split(";")
$names = $n -split ";"
$names
foreach ($name in $names) {
    Write-Host "Creating folder for $name" -ForegroundColor Green
    mkdir "C:\Users\$Name" -WhatIf
}

$parts = 7,"BK","**","us",3
$pass = -join $parts
$parts -join "~"

cls
#endregion