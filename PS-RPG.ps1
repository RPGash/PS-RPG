# ToDo
# ----
#
# - BUGS
#   when there are more than 14 items in your inventory, items 15+ are chopped off
#       because combat messages are clearing the whole line.
#       solution - update inventoDraw_Player_Stats_Windowry after every combat message?
#   
#   
#   
#
# - NEXT
#   
#   
#   
#   random character name
#   pre-built character
#   max character limit = 10
#   more than 10 characters suggest a random name?
#   you hit/strike/bash/wack at mob
#   combine Draw_Player_Stats_Window and Draw_Player_Stats_Info (same as Draw_Mob_Stats_Window_And_Info)
#   [ongoing] an info page available after starting the game
#             (game info, PSWriteColour module, GitHub, website, uninstall module,
#             CTRL+C warning AND FILE SYNCING ISSUE e.g. Google Drive or OneDrive etc.)
#
#
# - KNOWN ISSUES
#   if no JSON file is found, then you start a new game but quit before completing character creation, the game finds an "empty" game file and loads with no character data - FIX is to start a new game
# 
#


Clear-Host
$PSRPG_Version = "v0.1"

#
# Pre-requisite checks and install / import PSWriteColor module - NOT WORKING FOR PowerShell 5.1
#
if(($PSVersionTable).PSEdition -eq "Desktop") {
    Write-Color "You are running ","PS-RPG.ps1 ","with ","Windows PowerShell Desktop version","." -Color DarkGray,Magenta,DarkGray,Blue,DarkGray
    Write-Color "`r`nPS-RPG.ps1 ","only runs with ","PowerShell Core (7+)","." -Color Magenta,DarkGray,Blue,DarkGray
    Write-Color "`r`nDownload and install ","PowerShell Core"," then re-run PS-RPG.ps1 using that version." -Color DarkGray,Blue,DarkGray
    Write-Color "`r`nYou can download ","PowerShell Core ","from Microsoft's Docs page at" -Color DarkGray,Blue,DarkGray
    Write-Color "https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows`r`n`n`n`n`n" -Color Yellow
    Exit
}


if (-not(Test-Path -Path .\PS-RPG.json)) {
    Write-Host "Pre-requisite checks" -ForegroundColor Red
    Write-Host "--------------------" -ForegroundColor Red
    Write-Output "`r`nChecking if PSWriteColor module is installed."
    $PSWriteModule_Install_Check = Get-Module -Name "PSWriteColor" -ListAvailable
    if ($PSWriteModule_Install_Check) {
        Write-Host "PSWriteColor module is installed." -ForegroundColor Green
        $PSWriteModule_Install_Check
        Write-Output "`r`nImporting PSWriteColor module."
        Import-Module -Name "PSWriteColor"
        $Import_PSWriteColor_Module_Check = Get-Module -Name "PSWriteColor"
        if ($Import_PSWriteColor_Module_Check) {
            Write-Host "PSWriteColor module imported." -ForegroundColor Green
        } else {
            Write-Host "PSWriteColor module not imported." -ForegroundColor Red
            Break
        }
        Start-Sleep -Seconds 3 # leave in
    } else {
        Write-Host "PSWriteColor module is not installed." -ForegroundColor Red
        Write-Output "`r`nThis game requires a PowerShell module called PSWriteColor to be installed."
        Write-Output "It allows the game to use coloured console output text for a better experience."
        Write-Output "The module will install as the Current User Scope and does NOT require Admin credentials."
        Write-Output "`r`nMore info about the module can be found from the below links if you"
        Write-Output "wish to research it before deciding to install it on your system."
        Write-Output "`r`nAuthor              - Przemyslaw Klys"
        Write-Output "PowerShell Gallery  - https://www.powershellgallery.com/packages/PSWriteColor/1.0.1"
        Write-Output "GitHub project site - https://github.com/EvotecIT/PSWriteColor"
        Write-Output "More info           - https://evotec.xyz/hub/scripts/pswritecolor/"
        $Install_Module_Check = Read-Host "`r`nDo you want to allow the PSWriteColor module to be installed? [Y/N]"
        if (-not($Install_Module_Check -ieq "y")) {
            Write-Host "`r`nThe PSWriteColor module was NOT installed." -ForegroundColor Red
            Write-Host "Run the script again if you change your mind.`r`n"
            Exit
        }
        Write-Output "`r`nAttempting to install PSWriteColor module."
        Write-Output "Install path will be $ENV:USERPROFILE\Documents\WindowsPowerShell\Modules\."
        Write-Host "Accept the install prompt with either 'Y' or 'A' then Enter to install." -ForegroundColor Green
        Install-Module -Name "PSWriteColor" -Scope CurrentUser
        $PSWriteModule_Install_Check = Get-Module -Name "PSWriteColor" -ListAvailable
        if ($PSWriteModule_Install_Check) {
            Write-Host "PSWriteColor module is installed." -ForegroundColor Green
            $PSWriteModule_Install_Check
            Write-Output "`r`nImporting PSWriteColor module."
            Import-Module -Name "PSWriteColor"
            $Import_PSWriteColor_Module_Check = Get-Module -Name "PSWriteColor"
            if ($Import_PSWriteColor_Module_Check) {
                Write-Host "PSWriteColor module imported." -ForegroundColor Green
            } else {
                Write-Host "PSWriteColor module not imported." -ForegroundColor Red
                Break
            }
        } else {
            Write-Host "`r`nPSWriteColor module did not install correctly." -ForegroundColor Red
            Break
        }
    }
    #
    # game info
    #
    Write-Host -NoNewLine "`r`nPress any key to continue."
    ######################################################################################################################
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    ######################################################################################################################
    Clear-Host
    Write-Color "`r`nInfo" -Color Green
    Write-Color "----" -Color Green
    Write-Color "`r`nWelcome to ", "PS-RPG", ", my 1st RPG text adventure written in PowerShell." -Color Gray,Magenta,Gray
    Write-Color "`r`nAs previously mentioned, the PSWriteColor PowerShell module written by Przemyslaw Klys" -Color Gray
    Write-Color "is required which if you are seeing this message then it has installed and imported successfully." -Color Gray
    Write-Color "`r`nAbsolutely ", "NO ", "info personal or otherwise is collected or sent anywhere or to anybody. " -Color Gray,Red,Gray
    Write-Color "`r`nAll the ", "PS-RPG ", "games files are stored your ", "$PSScriptRoot"," folder which is where you have run the game from. They include:" -Color Gray,Magenta,Gray,Cyan,Gray
    Write-Color "The main PowerShell script            : ", "PS-RPG.ps1" -Color Gray,Cyan
    Write-Color "ASCII art for death messages          : ", "ASCII.txt" -Color Gray,Cyan
    Write-Color "A JSON file that stores all game info : ", "PS-RPG.json ", "(Locations, Mobs, NPCs and Character Stats etc.)" -Color Gray,Cyan,Gray
    Write-Color "`r`nPlayer input options appear in ","green ", "e.g. ", "[Y/N/Q/I] ", "would be ", "yes/no/quit/inventory", "." -Color Gray,Green,Gray,Green,Gray,Green,Gray
    Write-Color "Enter the single character then hit Enter to confirm the choice." -Color Gray
    Write-Color "`r`nWARNING - Quitting the game unexpectedly may cause lose of data." -Color Cyan
    Write-Color "`r`nYou are now ready to play", " PS-RPG", "." -Color Gray,Magenta,Gray

    do {
        do {
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,27;$Host.UI.Write("")
            " "*240
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,27;$Host.UI.Write("")
            Write-Color -NoNewLine "`r`nNo save file found. Are you ready to start playing ", "PS-RPG", "?"," [Y/N/Q]" -Color DarkYellow,Magenta,DarkYellow,Green
            $Ready_To_Play_PSRPG = Read-Host " "
            $Ready_To_Play_PSRPG = $Ready_To_Play_PSRPG.Trim()
        } until ($Ready_To_Play_PSRPG -ieq "y" -or $Ready_To_Play_PSRPG -ieq "n" -or $Ready_To_Play_PSRPG -ieq "q")

        if ($Ready_To_Play_PSRPG -ieq "n" -or $Ready_To_Play_PSRPG -ieq "q") {
            do {
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,27;$Host.UI.Write("")
                " "*240
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,27;$Host.UI.Write("")
                Write-Color -NoNewLine "`r`nDo you want to quit ", "PS-RPG", "?"," [Y/N]" -Color DarkYellow,Magenta,DarkYellow,Green
                $Quit_Game = Read-Host " "
                $Quit_Game = $Quit_Game.Trim()
            } until ($Quit_Game -ieq "y" -or $Quit_Game -ieq "n")
            if ($Quit_Game -ieq "y") {
                Write-Color -NoNewLine "`r`nQuitting ","PS-RPG","." -Color DarkYellow,Magenta,DarkYellow
                Exit
            }
        }
    } until ($Ready_To_Play_PSRPG -ieq 'y')
}


#
# import JSON game info
#
Function Import-JSON {
    $Script:Import_JSON = (Get-Content ".\PS-RPG.json" -Raw | ConvertFrom-Json)
}

#
# save data back to JSON file
#
Function Set-JSON {
    if (-not(Test-Path -Path "$ENV:userprofile\My Drive\PS-RPG\error_log.log")) {
        New-Item -Path "$ENV:userprofile\My Drive\PS-RPG\error_log.log" -ItemType File -Force | Out-Null
    }
    # Implement a retry mechanism with a delay
    $maxRetries = 5
    $retryDelaySeconds = 1
    
    for ($retry = 1; $retry -le $maxRetries; $retry++) {
        try {
            ($Script:Import_JSON | ConvertTo-Json -depth 32) | Set-Content ".\PS-RPG.json" -ErrorAction Stop
            # If successful, Break out of the loop
            Add-Content -Path "$ENV:userprofile\My Drive\PS-RPG\error_log.log" -value "Success attempt #$($retry)"
            Break
        } catch {
            Add-Content -Path "$ENV:userprofile\My Drive\PS-RPG\error_log.log" -value "Error attempt #$($retry) $($_.Exception.Message)"
            if ($retry -lt $maxRetries) {
                Add-Content -Path "$ENV:userprofile\My Drive\PS-RPG\error_log.log" -value "Retrying $($retryDelaySeconds)s"
                Start-Sleep -Seconds $retryDelaySeconds # leave in
            } else {
                Add-Content -Path "$ENV:userprofile\My Drive\PS-RPG\error_log.log" -value "Failed $($maxRetries) attempts"
                # Optionally, take further action like exiting the script or prompting the user
                # Exit 1 # Exit with a non-zero code
            }
        }
    }
}

#
# player stats window
#
Function Draw_Player_Stats_Window {
    Write-Color "╔═════════════════════════════════════════════════════╗" -Color DarkGray
    Write-Color "║                                                     ║" -Color DarkGray
    Write-Color "╠═══════════════════════╦═════════════════════════════╣" -Color DarkGray
    Write-Color "║                       ║ Health    :     of          ║" -Color DarkGray
    Write-Color "║                       ║ Stamina   :     of          ║" -Color DarkGray
    Write-Color "║ Name     :            ║ Mana      :     of          ║" -Color DarkGray
    Write-Color "║ Class    :            ║ Attack    :                 ║" -Color DarkGray
    Write-Color "║ Race     :            ║ Damage    :                 ║" -Color DarkGray
    Write-Color "║ Level    :            ║ Endurance :                 ║" -Color DarkGray
    Write-Color "║ Location :            ║ Evade     :                 ║" -Color DarkGray
    Write-Color "║ Gold     :            ║ Quickness :                 ║" -Color DarkGray
    Write-Color "║ Total XP :            ║ Spells    :                 ║" -Color DarkGray
    Write-Color "║ XP TNL   :            ║ Healing   :                 ║" -Color DarkGray
    Write-Color "╚═══════════════════════╩═════════════════════════════╝" -Color DarkGray
}



#
# draw player stats info
#
Function Draw_Player_Stats_Info {
    $host.UI.RawUI.ForegroundColor = "Magenta" # changes foreground color
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 2,3;$Host.UI.Write("PS-RPG")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 2,4;$Host.UI.Write("=====")
    $host.UI.RawUI.ForegroundColor = "DarkGray" # changes foreground color
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 9,3;$Host.UI.Write($PSRPG_Version)
    $host.UI.RawUI.ForegroundColor = "White" # changes foreground color
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 2,1;$Host.UI.Write("Player Info")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 13,5;$Host.UI.Write($Character_Name)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 13,5;$Host.UI.Write($Character_Name)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 13,6;$Host.UI.Write($Character_Class)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 13,7;$Host.UI.Write($Character_Race)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 13,8;$Host.UI.Write($Character_Level)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 13,9;$Host.UI.Write($Current_Location)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 13,10;$Host.UI.Write($Gold)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 13,11;$Host.UI.Write($Total_XP)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 13,12;$Host.UI.Write($XP_TNL)

    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,6;$Host.UI.Write($Character_Attack)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,7;$Host.UI.Write($Character_Damage)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,8;$Host.UI.Write($Character_Endurance)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,9;$Host.UI.Write($Character_Evade)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,10;$Host.UI.Write($Character_Quickness)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,11;$Host.UI.Write($Character_Spells)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,12;$Host.UI.Write($Character_Healing)
    $host.UI.RawUI.ForegroundColor = "Green" # changes foreground color
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,3;$Host.UI.Write("$Character_HealthCurrent")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 45,3;$Host.UI.Write("$Character_HealthMax")
    $host.UI.RawUI.ForegroundColor = "Yellow" # changes foreground color
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,4;$Host.UI.Write("$Character_StaminaCurrent")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 45,4;$Host.UI.Write("$Character_StaminaMax")
    $host.UI.RawUI.ForegroundColor = "Blue" # changes foreground color
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,5;$Host.UI.Write("$Character_ManaCurrent")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 45,5;$Host.UI.Write("$Character_ManaMax")
    $host.UI.RawUI.ForegroundColor = "Gray" # set the foreground color back to original colour
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,11;$Host.UI.Write("")
}

Function Game_Info {
    Clear-Host
    Write-Color "╔═════════════════════════════════════════════════════╗" -Color DarkGray
    Write-Color "║ Game Info                                           ║" -Color DarkGray
    Write-Color "╠═════════════════════════════════════════════════════╣" -Color DarkGray
    Write-Color "║ Page 1 - Info                                       ║" -Color DarkGray
    Write-Color "║ Page 2 - Stat                                       ║" -Color DarkGray
    Write-Color "║ Page 3 - ????                                       ║" -Color DarkGray
    Write-Color "╚═════════════════════════════════════════════════════╝" -Color DarkGray
    do {
        do {
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,27;$Host.UI.Write("")
            " "*240
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,27;$Host.UI.Write("")
            Write-Color -NoNewLine "`r`nSelect Page ","[1/2/3/Q]" -Color DarkYellow,Green
            $Game_Info_Page_Choice = Read-Host " "
            $Game_Info_Page_Choice = $Game_Info_Page_Choice.Trim()
        } until ($Game_Info_Page_Choice -ieq "1" -or $Game_Info_Page_Choice -ieq "2" -or $Game_Info_Page_Choice -ieq "3" -or $Game_Info_Page_Choice -ieq "q")
        if ($Game_Info_Page_Choice -ieq "q") {
            Clear-Host
            Draw_Player_Stats_Window
            Draw_Player_Stats_Info
            Break
        }
        if ($Game_Info_Page_Choice -ieq "1") {
            Clear-Host
            Write-Color "╔═════════════════════════════════════════════════════╗" -Color DarkGray
            Write-Color "║ Page 1 of 1 - Info                                  ║" -Color DarkGray
            Write-Color "╠═════════════════════════════════════════════════════╣" -Color DarkGray
            Write-Color "║                                                     ║" -Color DarkGray
            Write-Color "╚═════════════════════════════════════════════════════╝" -Color DarkGray
            Write-Color "`r`nWelcome to ", "PS-RPG", ", my 1st RPG text adventure written in PowerShell." -Color Gray,Magenta,Gray
            Write-Color "`r`nAs previously mentioned, the PSWriteColor PowerShell module written by Przemyslaw Klys" -Color Gray
            Write-Color "is required which if you are seeing this message then it has installed and imported successfully." -Color Gray
            Write-Color "`r`nAbsolutely ", "NO ", "info personal or otherwise is collected or sent anywhere or to anybody. " -Color Gray,Red,Gray
            Write-Color "`r`nAll the ", "PS-RPG ", "games files are stored your ", "$PSScriptRoot"," folder`r`nwhich is where you have run the game from. They include:" -Color Gray,Magenta,Gray,Cyan,Gray
            Write-Color "The main PowerShell script            : ", "PS-RPG.ps1" -Color Gray,Cyan
            Write-Color "ASCII art for death messages          : ", "ASCII.txt" -Color Gray,Cyan
            Write-Color "A JSON file that stores all game info : ", "PS-RPG.json ", "(Locations, Mobs, NPCs and Character Stats etc.)" -Color Gray,Cyan,Gray
            Write-Color "`r`nPlayer input options appear in ","green ", "e.g. ", "[Y/N/Q/I] ", "would be ", "yes/no/quit/inventory", "." -Color Gray,Green,Gray,Green,Gray,Green,Gray
            Write-Color "Enter the single character then hit Enter to confirm the choice." -Color Gray
            Write-Color "`r`nWARNING - Quitting the game unexpectedly may cause lose of data." -Color Cyan
        }
        if ($Game_Info_Page_Choice -ieq "2") {
            Clear-Host
            Write-Color "╔═════════════════════════════════════════════════════╗" -Color DarkGray
            Write-Color "║ Page 2 of 3 - stats                                 ║" -Color DarkGray
            Write-Color "╠═════════════════════════════════════════════════════╣" -Color DarkGray
            Write-Color "║                                                     ║" -Color DarkGray
            Write-Color "╚═════════════════════════════════════════════════════╝" -Color DarkGray
            Write-Color "`r`nStats" -Color Gray,Magenta,Gray
        }
        if ($Game_Info_Page_Choice -ieq "3") {
            Clear-Host
            Write-Color "╔═════════════════════════════════════════════════════╗" -Color DarkGray
            Write-Color "║ Page 3 of 2 - ????                                  ║" -Color DarkGray
            Write-Color "╠═════════════════════════════════════════════════════╣" -Color DarkGray
            Write-Color "║                                                     ║" -Color DarkGray
            Write-Color "╚═════════════════════════════════════════════════════╝" -Color DarkGray
            Write-Color "`r`n????" -Color Gray,Magenta,Gray
        }
    } until ($Game_Info_Page_Choice -ieq "q")
}



#
# highlights health and or mana potion ID in inventory when available for use
#
Function Inventory_Switch {
    if($Selectable_ID_Potion_Search -ine "not_set" ){
        $Script:Selectable_ID_Potion_Highlight = "DarkGray" # reset Selectable_ID_Potion_Highlight so it highlights correct potion IDs in inventory list
        switch ($Selectable_ID_Potion_Search) {
            Health {
                if($Inventory_Item.Name -ilike "*health potion*") {
                    $Script:Selectable_ID_Potion_Highlight = "White"
                }
            }
            Mana {
                if($Inventory_Item.Name -ilike "*mana potion*") {
                    $Script:Selectable_ID_Potion_Highlight = "White"
                }
            }
            HealthMana {
                if($Inventory_Item.Name -ilike "*mana potion*" -or $Inventory_Item.Name -ilike "*health potion*") {
                    $Script:Selectable_ID_Potion_Highlight = "White"
                }
            }
            Default {
                $Script:Selectable_ID_Potion_Highlight = "DarkGray"
            }
        }
    } else {
        $Script:Selectable_ID_Potion_Highlight = "DarkGray"
    }
}

#
# displays inventory out of combat - NOT USED - IN COMBAT USED INSTEAD
#
# Function Display_Inventory_Out_of_Combat {
#     Clear-Host
#     $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
#     Draw_Player_Stats_Window
#     Draw_Player_Stats_Info
#     $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,9;$Host.UI.Write("")
#     $Inventory_Items_Name_Array = New-Object System.Collections.Generic.List[System.Object]
#     $Inventory_Items_Info_Array = New-Object System.Collections.Generic.List[System.Object]
#     $Script:Inventory_Items = $Import_JSON.Character.Items.Inventory

#     foreach ($Inventory_Item in $Inventory_Items) {
#         if($Inventory_Item.Quantity -gt 0) {
#             $Inventory_Items_Name_Array.Add($Inventory_Item.Name.Length)
#             $Inventory_Items_Info_Array.Add($Inventory_Item.Info.Length)
#             $Inventory_Empty = $false
#         } else {
#             $Inventory_Items_Name_Array.Add(10)
#             $Inventory_Items_Info_Array.Add(10)
#         }
#     }
#     # box window width for name
#     $Inventory_Items_Name_Array_Max_Length = ($Inventory_Items_Name_Array | Measure-Object -Maximum).Maximum
#     $Inventory_Box_Name_Width_Top_Bottom = $Inventory_Items_Name_Array_Max_Length + 7
#     $Inventory_Box_Name_Width_Top_Bottom = "═"*$Inventory_Box_Name_Width_Top_Bottom
#     $Inventory_Box_Name_Width_Middle = $Inventory_Items_Name_Array_Max_Length - 3
#     $Inventory_Box_Name_Width_Middle = " "*$Inventory_Box_Name_Width_Middle
    
#     # box window width for info
#     $Inventory_Items_Info_Array_Max_Length = ($Inventory_Items_Info_Array | Measure-Object -Maximum).Maximum
#     $Inventory_Box_Info_Width_Top_Bottom = $Inventory_Items_Info_Array_Max_Length + 2
#     $Inventory_Box_Info_Width_Top_Bottom = "═"*$Inventory_Box_Info_Width_Top_Bottom
#     $Inventory_Box_Info_Width_Middle = $Inventory_Items_Info_Array_Max_Length - 5
#     $Inventory_Box_Info_Width_Middle = " "*$Inventory_Box_Info_Width_Middle

#     Write-Color "╔══╦$Inventory_Box_Name_Width_Top_Bottom╦$Inventory_Box_Info_Width_Top_Bottom╗" -Color DarkGray
#     Write-Color "║","ID","║ ","Inventory","$Inventory_Box_Name_Width_Middle║"," Info"," $Inventory_Box_Info_Width_Middle ║" -Color DarkGray,White,DarkGray,White,DarkGray,White,DarkGray
#     Write-Color "╠══╬$Inventory_Box_Name_Width_Top_Bottom╬$Inventory_Box_Info_Width_Top_Bottom╣" -Color DarkGray
#     $Position = 11
#     foreach ($Inventory_Item in $Inventory_Items | Sort-Object Name) {
#         if ($Inventory_Item.Quantity -gt 0) {
#             $Position += 1
#             # box width for name
#             if ($Inventory_Item.Name.Length -lt $Inventory_Items_Name_Array_Max_Length) {
#                 $Name_Left_Padding = " "*($Inventory_Items_Name_Array_Max_Length - $Inventory_Item.Name.Length)
#             } else {
#                 $Name_Left_Padding = ""
#             }
#             $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("")
#             if ($Inventory_Item.Quantity -lt 10) { # quantity less than 10 in inventory (1 digit so needs 2 padding)
#                 $Name_Right_Padding = "  "
#             } else {
#                 $Name_Right_Padding = " " # more than 9 quantity (2 digits so needs 1 padding)
#             }
#             # box width for info
#             $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("")
#             if ($Inventory_Item.Info.Length -lt $Inventory_Items_Info_Array_Max_Length) {
#                 $Info_Right_Padding_Number = ($Inventory_Items_Info_Array_Max_Length - $Inventory_Item.Info.Length)
#                 $Info_Right_Padding = " "*$Info_Right_Padding_Number
#             } else {
#                 $Info_Right_Padding = "" # more than 9 quantity (2 digits so needs 1 padding)
#             }
#             # if item is a potion
#             if($Inventory_Item.Name -like "*potion*") {
#                 if(($Inventory_Item.ID | Measure-Object -Character).Characters -gt 1) { # if ID is a 2 digits (no extra padding)
#                     $ID_Number = "$($Inventory_Item.ID)"
#                 } else {
#                     $ID_Number = "$($Inventory_Item.ID) " # if ID is a single digit (1 extra $Padding)
#                 }
#             } else {
#                 $ID_Number = "  "
#             }
#             Inventory_Switch
#             $Item_Info = $Inventory_Item.Info
#             Write-Color "║","$ID_Number","║ $($Inventory_Item.Name)$Name_Left_Padding : ", "$($Inventory_Item.Quantity)$Name_Right_Padding","║ $Item_Info $Info_Right_Padding║" -Color DarkGray,$Selectable_ID_Potion_Highlight,DarkGray,White,DarkGray
#         }
#     }
#     if ($Inventory_Empty -ne $false) {
#         $Position += 1
#         Write-Color "║  ║ no items        ║            ║" -Color DarkGray,Magenta,White,DarkGray
#     }
#     $Position += 1
#     $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("")
#     Write-Color "╚══╩$Inventory_Box_Name_Width_Top_Bottom╩$Inventory_Box_Info_Width_Top_Bottom╝" -Color DarkGray
# }

#
# sets variables
#
Function Set_Variables {
    $Script:Character_Name           = $Import_JSON.Character.Name
    $Script:Character_Class          = $Import_JSON.Character.Class
    $Script:Character_Race           = $Import_JSON.Character.Race
    $Script:Character_HealthCurrent  = $Import_JSON.Character.Stats.HealthCurrent
    $Script:Character_HealthMax      = $Import_JSON.Character.Stats.HealthMax
    $Script:Character_StaminaCurrent = $Import_JSON.Character.Stats.StaminaCurrent
    $Script:Character_StaminaMax     = $Import_JSON.Character.Stats.StaminaMax
    $Script:Character_ManaCurrent    = $Import_JSON.Character.Stats.ManaCurrent
    $Script:Character_ManaMax        = $Import_JSON.Character.Stats.ManaMax
    $Script:Character_Damage         = $Import_JSON.Character.Stats.Damage
    $Script:Character_Attack         = $Import_JSON.Character.Stats.Attack
    $Script:Character_Endurance      = $Import_JSON.Character.Stats.Endurance
    $Script:Character_Evade          = $Import_JSON.Character.Stats.Evade
    $Script:Character_Quickness      = $Import_JSON.Character.Stats.Quickness
    $Script:Character_Spells         = $Import_JSON.Character.Stats.Spells
    $Script:Character_Healing        = $Import_JSON.Character.Stats.Healing
    $Script:Gold                     = $Import_JSON.Character.Items.Gold
    $Script:Character_Level          = $Import_JSON.Character.Level
    $Script:Total_XP                 = $Import_JSON.Character.Total_XP
    $Script:XP_TNL                   = $Import_JSON.Character.XP_TNL
    # $Script:XP_TNL_Calc           = 0
    # $Script:XP_TNL2           = 0
    # sets current Location
    $All_Locations                       = $Import_JSON.Locations.PSObject.Properties.Name
    foreach ($Single_Location in $All_Locations) {
        if ($Import_JSON.Locations.$Single_Location.CurrentLocation -ieq "true") {
            $Script:Current_Location = $Single_Location
        }
    }
}

#
# level up
#
Function Level_Up {
    $Levels_Levelled_Up = 0
    do {
        $Levels_Levelled_Up += 1
        $Script:Character_Level          = $Character_Level + 1
        $Import_JSON.Character.Level     = $Character_Level
        # $XP_TNL_Calc                   = [Math]::Pow(($Character_Level/0.05), 1.7)
        # $Script:XP_TNL                 = [Math]::ceiling($XP_TNL_Calc)
        $Script:Total_XP_For_Next_Level  = [Math]::ceiling([Math]::Pow(($Character_Level/0.2), 1.7))
        $Script:XP_TNL                   = $Total_XP_For_Next_Level + $XP_Difference
        $XP_Difference                   = $XP_Difference + $Total_XP_For_Next_Level
        $Import_JSON.Character.XP_TNL = $XP_TNL
        $prefixes = 'Character_'
        # class bonus
        foreach ($JSON_Item in $import_JSON) {
            $options = $JSON_Item.Level_Up_Bonus.Class.$Character_Class
            $Class_Stats = $options.PSObject.Properties.Name
            foreach ($Class_Stat in $Class_Stats) {
                $add = (Get-Variable -Name character_$Class_Stat).value + ($Import_JSON.Level_Up_Bonus.Class.$Character_Class.$Class_Stat)
                New-Variable -Name "$($prefixes)$Class_Stat" -Value $add -Force
                $Import_JSON.Character.Stats.$Class_Stat = $(Get-Variable -Name character_$Class_Stat).value
            }
        }
        # race bonus
        $prefixes = 'Character_'
        foreach ($JSON_Item in $import_JSON) {
            $options = $JSON_Item.Level_Up_Bonus.Race.$Character_Race
            $Race_Stats = $options.PSObject.Properties.Name
            foreach ($Race_Stat in $Race_Stats) {
                $add = (Get-Variable -Name character_$Race_Stat).value + ($Import_JSON.Level_Up_Bonus.Race.$Character_Race.$Race_Stat)
                New-Variable -Name "$($prefixes)$Race_Stat" -Value $add -Force
                $Import_JSON.Character.Stats.$Race_Stat = $(Get-Variable -Name character_$Race_Stat).value
            }
        }
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 13,12;$Host.UI.Write("")
        " "*6 # clears the TNL value because it shows a negative value while updating

        Set-JSON
        Import-JSON
        Set_Variables
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
        Draw_Player_Stats_Info
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,24;$Host.UI.Write("")
        if ($Levels_Levelled_Up -eq '1') {
            $Level_Or_Levels = 'level'
        } else {
            $Level_Or_Levels = 'levels'
        }
        Write-Color "  Congratulations! ", "You gained ", "$Levels_Levelled_Up ", "$Level_Or_Levels. You are now level ", "$($Import_JSON.Character.Level)","." -Color Cyan,DarkGray,White,DarkGray,White,DarkGray
        
        $Health_Bonus_On_Level_Up    += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.HealthMax + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.HealthMax
        $Stamina_Bonus_On_Level_Up   += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.StaminaMax + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.StaminaMax
        $Mana_Bonus_On_Level_Up      += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.ManaMax + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.ManaMax
        $Damage_Bonus_On_Level_Up    += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.Damage + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.Damage
        $Attack_Bonus_On_Level_Up    += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.Attack + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.Attack
        $Endurance_Bonus_On_Level_Up += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.Endurance + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.Endurance
        $Evade_Bonus_On_Level_Up     += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.Evade + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.Evade
        $Quickness_Bonus_On_Level_Up += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.Quickness + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.Quickness
        $Spells_Bonus_On_Level_Up    += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.Spells + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.Spells
        $Healing_Bonus_On_Level_Up   += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.Healing + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.Healing
        
        $host.UI.RawUI.ForegroundColor = "Cyan" # changes foreground color
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 32,1;$Host.UI.Write("Class + Race Bonus ⇓")
        $host.UI.RawUI.ForegroundColor = "Green" # changes foreground color
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,3;$Host.UI.Write("(+$Health_Bonus_On_Level_Up)")
        $host.UI.RawUI.ForegroundColor = "Yellow" # changes foreground color
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,4;$Host.UI.Write("(+$Stamina_Bonus_On_Level_Up)")
        $host.UI.RawUI.ForegroundColor = "Blue" # changes foreground color
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,5;$Host.UI.Write("(+$Mana_Bonus_On_Level_Up)")
        $host.UI.RawUI.ForegroundColor = "White" # changes foreground color
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,6;$Host.UI.Write("(+$Damage_Bonus_On_Level_Up)")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,7;$Host.UI.Write("(+$Attack_Bonus_On_Level_Up)")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,8;$Host.UI.Write("(+$Endurance_Bonus_On_Level_Up)")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,9;$Host.UI.Write("(+$Evade_Bonus_On_Level_Up)")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,10;$Host.UI.Write("(+$Quickness_Bonus_On_Level_Up)")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,11;$Host.UI.Write("(+$Spells_Bonus_On_Level_Up)")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,12;$Host.UI.Write("(+$Healing_Bonus_On_Level_Up)")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 18,8;$Host.UI.Write("(+$Levels_Levelled_Up)")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 18,11;$Host.UI.Write("(+$($Selected_Mob.XP))")
        
        # Write-Color "  You have gained ", "x Health ","x Stamina ", "and ", "x Mana","." -Color DarkGray,Green,Yellow,DarkGray,Blue,DarkGray
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,26;$Host.UI.Write("")
        Write-Color "  You have also learned ", "x skills","." -Color DarkGray,White,DarkGray
        if ($Levels_Levelled_Up -ne '1') {
            Start-Sleep -Seconds 2
        }
        Draw_Player_Stats_Info
    } until ($XP_Difference -gt 0)
}


#
# create character
#
Function Create_Character {
    Copy-Item -Path .\PS-RPG_new_game.json -Destination .\PS-RPG.json
    Import-JSON
    do {
        $Character_Class = $false
        $Character_Class_Confirm = $false
        $Character_Race = $false
        $Character_Race_Confirm = $false
        $Character_Name = $false
        $Character_Name_Valid = $false
        $Character_Name_Confirm = $false
    
        # character name loop
        do {
            $Character_Name = $false
            $Character_Name_Valid = $false
            $Character_Name_Confirm = $false
            do {
                Clear-Host
                Write-Color -NoNewLine "Enter your Characters Name" -Color DarkYellow
                ######################################################################################################################
                $Character_Name = Read-Host " "
                # $Character_Name = "Loop"
                ######################################################################################################################
    
                $Character_Name = $Character_Name.Trim()
                if (-not($null -eq $Character_Name -or $Character_Name -eq " " -or $Character_Name -eq "")) {
                    $Character_Name_Valid = $true
                }
            } until (
                $Character_Name_Valid -eq $true
            )
            do {
                Write-Color -NoNewLine "You have chosen ", "$Character_Name ", "for your Character name, is this correct? ", "[Y/N/Q]" -Color DarkYellow,Blue,DarkYellow,Green
                ######################################################################################################################
                $Character_Name_Confirm = Read-Host " "
                # $Character_Name_Confirm = "y"
                ######################################################################################################################
    
            } until (
                $Character_Name_Confirm -ieq "y" -or $Character_Name_Confirm -ieq "n" -or $Character_Name_Confirm -eq "q"
            )
            if ($Character_Name_Confirm -ieq "y") {
                $Character_Name_Confirm = $true
            } else {
                if ($Character_Name_Confirm -ieq "q") {Exit}
            }
        } until (
            $Character_Name_Confirm -eq $true
        )
        $Import_JSON.Character.Name = $Character_Name
    
        # character info Function while choosing details
        Function Class_Race_Info {
            Clear-Host
            if ($Character_Name) {
                Write-Color "`r`nCharacter Name  : ", "$Character_Name" -Color Gray,Blue
                $ClassRaceInfoColours1 = $ClassRaceInfoColours3 = $ClassRaceInfoColours5 = $ClassRaceInfoColours7 = "Green"
                $ClassRaceInfoColours2 = $ClassRaceInfoColours4 = $ClassRaceInfoColours6 = $ClassRaceInfoColours8 = $ClassRaceInfoColours9 = $ClassRaceInfoColours10 = $ClassRaceInfoColours11 = $ClassRaceInfoColours12 = $ClassRaceInfoColours13 = $ClassRaceInfoColours14 = $ClassRaceInfoColours15 = $ClassRaceInfoColours16 = "Gray"
            }
            if ($Character_Class) {
                Write-Color "Character Class : ", "$Character_Class" -Color Gray,Blue
                $ClassRaceInfoColours1 = $ClassRaceInfoColours3 = $ClassRaceInfoColours5 = $ClassRaceInfoColours7 = "Gray"
                $ClassRaceInfoColours9 = $ClassRaceInfoColours11 = $ClassRaceInfoColours13 = $ClassRaceInfoColours15 = "Green"
            }
            if ($Character_Race) {
                Write-Color "Character Race  : ", "$Character_Race" -Color Gray,Blue
                $ClassRaceInfoColours1 = $ClassRaceInfoColours2 = $ClassRaceInfoColours3 = $ClassRaceInfoColours4 = $ClassRaceInfoColours5 = $ClassRaceInfoColours6 = $ClassRaceInfoColours7 = $ClassRaceInfoColours8 = $ClassRaceInfoColours9 = $ClassRaceInfoColours10 = $ClassRaceInfoColours11 = $ClassRaceInfoColours12 = $ClassRaceInfoColours13 = $ClassRaceInfoColours14 = $ClassRaceInfoColours15 = $ClassRaceInfoColours16 = "Gray"
                if ($Character_Class -eq "Mage") {$ClassRaceInfoColours1 = $ClassRaceInfoColours2 = "Green"}
                if ($Character_Class -eq "Rogue") {$ClassRaceInfoColours3 = $ClassRaceInfoColours4 = "Green"}
                if ($Character_Class -eq "Cleric") {$ClassRaceInfoColours5 = $ClassRaceInfoColours6 = "Green"}
                if ($Character_Class -eq "Warrior") {$ClassRaceInfoColours7 = $ClassRaceInfoColours8 = "Green"}
                if ($Character_Race -eq "Elf") {$ClassRaceInfoColours9 = $ClassRaceInfoColours10 = "Green"}
                if ($Character_Race -eq "Orc") {$ClassRaceInfoColours11 = $ClassRaceInfoColours12 = "Green"}
                if ($Character_Race -eq "Dwarf") {$ClassRaceInfoColours13 = $ClassRaceInfoColours14 = "Green"}
                if ($Character_Race -eq "Human") {$ClassRaceInfoColours15 = $ClassRaceInfoColours16 = "Green"}
            }
            if(-not($Character_Race)){
                Write-Color "`r`nChoose a Class and Race from the below tables." -Color Gray
                Write-Color "Bonus values to Character stats are applied after each level up." -Color Gray
            }
            Write-Color " " -Color Gray
            Write-Color " Class Base Stats | Health | Stamina | Mana  | Endurance | Damage | Attack | Evade | Quickness | Spells | Healing " -Color Gray
            Write-Color "------------------------------------------------------------------------------------------------" -Color Gray
            Write-Color " M","age             |   50   |    40   |   80  |     4     |   10   |   4   |    1  |   4   |   10   |   6     " -Color $ClassRaceInfoColours1,$ClassRaceInfoColours2
            Write-Color " R","ogue            |   60   |    80   |   30  |     6     |   10   |   10   |   10  |  10   |    1   |   4     " -Color $ClassRaceInfoColours3,$ClassRaceInfoColours4
            Write-Color " C","leric           |   40   |    50   |  100  |     4     |    8   |   2   |    1  |   4   |   10   |   10    " -Color $ClassRaceInfoColours5,$ClassRaceInfoColours6
            Write-Color " W","arrior          |  100   |   100   |   10  |    10     |    1   |   8   |    8  |   6   |    1   |   4     " -Color $ClassRaceInfoColours7,$ClassRaceInfoColours8
            Write-Color ""
            Write-Color " Class Bonus      | Health | Stamina | Mana  | Endurance | Damage | Attack | Evade | Quickness | Spells | Healing " -Color Gray
            Write-Color "------------------------------------------------------------------------------------------------" -Color Gray
            Write-Color " M","age             |   +2   |   +1    |   +4  |     +2    |   +5   |   +4   |   +1  |   +1   |   +5   |   +3    " -Color $ClassRaceInfoColours1,$ClassRaceInfoColours2
            Write-Color " R","ogue            |   +3   |   +3    |   +2  |     +3    |   +5   |   +5   |   +5  |   +5   |   +1   |   +3    " -Color $ClassRaceInfoColours3,$ClassRaceInfoColours4
            Write-Color " C","leric           |   +1   |   +2    |   +5  |     +2    |   +4   |   +2   |   +1  |   +1   |   +5   |   +5    " -Color $ClassRaceInfoColours5,$ClassRaceInfoColours6
            Write-Color " W","arrior          |   +5   |   +5    |   +1  |     +5    |   +1   |   +4   |   +4  |   +3   |   +1   |   +4    " -Color $ClassRaceInfoColours7,$ClassRaceInfoColours8
            Write-Color ""
            Write-Color " Race Bonus       | Health | Stamina | Mana  | Endurance | Damage | Attack | Evade | Quickness | Spells | Healing " -Color Gray
            Write-Color "------------------------------------------------------------------------------------------------" -Color Gray
            Write-Color " E","lf              |   +2   |   +4    |   +3  |     +1    |   +4   |   +4   |   +5  |   +5   |   +4   |   +5    " -Color $ClassRaceInfoColours9,$ClassRaceInfoColours10
            Write-Color " O","rc              |   +4   |   +4    |   +1  |     +4    |   +4   |   +5   |   +3  |   +1   |   +1   |   +1    " -Color $ClassRaceInfoColours11,$ClassRaceInfoColours12
            Write-Color " D","warf            |   +5   |   +5    |   +1  |     +5    |   +5   |   +5   |   +1  |   +1   |   +1   |   +3    " -Color $ClassRaceInfoColours13,$ClassRaceInfoColours14
            Write-Color " H","uman            |   +3   |   +3    |   +3  |     +3    |   +3   |   +3   |   +3  |   +3   |   +4   |   +4    " -Color $ClassRaceInfoColours15,$ClassRaceInfoColours16
            Write-Output "`r"
        }
    
        # character class choice
        do {
            do {
                $Character_Class = $false
                $Character_Class_Confirm = $false
                
                Class_Race_Info
                
                Write-Color -NoNewLine "Choose your Characters Class ", "[M/R/C/W]" -Color DarkYellow,Green
                ######################################################################################################################
                $Character_Class = Read-Host " "
                # $Character_Class = "r"
                ######################################################################################################################
    
            if ($Character_Class -ieq "q") {{Exit}}
            } until (
                $Character_Class -ieq "m" -or $Character_Class -ieq "r" -or $Character_Class -eq "c" -or $Character_Class -eq "w"
            )
            switch ($Character_Class) {
                m { $Character_Class = "Mage" }
                r { $Character_Class = "Rogue" }
                c { $Character_Class = "Cleric" }
                w { $Character_Class = "Warrior" }
            }
            do {
                Write-Color -NoNewLine "You have chosen a ", "$Character_Class ", "for your Character Class, is this correct? ", "[Y/N/Q]" -Color DarkYellow,Blue,DarkYellow,Green
                ######################################################################################################################
                $Character_Class_Confirm = Read-Host " "
                # $Character_Class_Confirm = "y"
                ######################################################################################################################
    
            } until (
                $Character_Class_Confirm -ieq "y" -or $Character_Class_Confirm -ieq "n" -or $Character_Class_Confirm -eq "q"
            )
            if ($Character_Class_Confirm -ieq "y") {
                $Character_Class_Confirm = $true
            } else {
                if ($Character_Class_Confirm -ieq "q") {Exit}
            }
        } until (
            $Character_Class_Confirm -eq $true
        )
        $Import_JSON.Character.Class = $Character_Class
    
        # character race choice
        do {
            do {
                $Character_Race = $false
                $Character_Race_Confirm = $false
                
                Class_Race_Info
                
                Write-Color -NoNewLine "Choose your Characters Race ", "[E/O/D/H]" -Color DarkYellow,Green
                ######################################################################################################################
                $Character_Race = Read-Host " "
                # $Character_Race = "d"
                ######################################################################################################################
    
                if ($Character_Race -ieq "q") {{Exit}}
            } until (
                $Character_Race -ieq "e" -or $Character_Race -ieq "o" -or $Character_Race -eq "d" -or $Character_Race -eq "h"
            )
            switch ($Character_Race) {
                e { $Character_Race = "Elf";$A_AN = "an" }
                o { $Character_Race = "Orc";$A_AN = "an" }
                d { $Character_Race = "Dwarf";$A_AN = "a" }
                h { $Character_Race = "Human";$A_AN = "a" }
            }
            do {
                Write-Color -NoNewLine "You have chosen $A_AN ", "$Character_Race ", "for your Character Race, is this correct? ", "[Y/N/Q]" -Color DarkYellow,Blue,DarkYellow,Green
                ######################################################################################################################
                $Character_Race_Confirm = Read-Host " "
                # $Character_Race_Confirm = "y"
                ######################################################################################################################
    
            } until (
                $Character_Race_Confirm -ieq "y" -or $Character_Race_Confirm -ieq "n" -or $Character_Race_Confirm -eq "q"
            )
            if ($Character_Race_Confirm -ieq "y") {
                $Character_Race_Confirm = $true
            } else {
                if ($Character_Race_Confirm -ieq "q") {Exit}
            }
        } until (
            $Character_Race_Confirm -eq $true
        )
        $Import_JSON.Character.Race = $Character_Race
        
        # confirm all character choices
        Clear-Host
        Class_Race_Info
        $Update_Character_JSON = $false
        $Update_Character_JSON_Valid = $false
        $Update_Character_JSON_Confirm = $false
        do {
            Write-Color -NoNewLine "Are all your Character details correct? ", "[Y/N/Q]" -Color DarkYellow,Green
            ######################################################################################################################
            $Update_Character_JSON = Read-Host " "
            # $Update_Character_JSON = "y"
            ######################################################################################################################
    
            $Update_Character_JSON = $Update_Character_JSON.Trim()
            if (-not($null -eq $Update_Character_JSON -or $Update_Character_JSON -eq " " -or $Update_Character_JSON -eq "")) {
                $Update_Character_JSON_Valid = $true
            }
        } until (
            $Update_Character_JSON_Valid -eq $true
        )
        if ($Update_Character_JSON -ieq "y") {
            $Update_Character_JSON_Confirm = $true
        } else {
            if ($Update_Character_JSON -ieq "q") {Exit}
        }
    } until (
        $Update_Character_JSON_Confirm -eq $true
    )
    Set-JSON # TEMP?

    # TEMP FO TESTING
    # set JSON character stats and items
    #
    # $Import_JSON.Character.Level                         = 1
    # $Import_JSON.Character.Total_XP                      = 0
    # $Import_JSON.Character.XP_TNL                        = 163
    # $Import_JSON.Character.Items.Gold                    = 100
    # $Import_JSON.Character.Items.Inventory | Where-Object {$PSItem.Name -eq "Small Health Potion"} | ForEach-Object {$PSItem.Quantity = 10}
    # $Import_JSON.Character.Items.Inventory | Where-Object {$PSItem.Name -eq "Small Mana Potion"} | ForEach-Object {$PSItem.Quantity = 10}

    #
    # set JSON class stats
    #
    if ($Character_Class -eq "Mage") {
        $Import_JSON.Character.Stats.HealthCurrent  = 50
        $Import_JSON.Character.Stats.HealthMax      = 50
        $Import_JSON.Character.Stats.StaminaCurrent = 40
        $Import_JSON.Character.Stats.StaminaMax     = 40
        $Import_JSON.Character.Stats.ManaCurrent    = 80
        $Import_JSON.Character.Stats.ManaMax        = 80
        $Import_JSON.Character.Stats.Damage         = 10
        $Import_JSON.Character.Stats.Attack         = 4
        $Import_JSON.Character.Stats.Endurance      = 4
        $Import_JSON.Character.Stats.Evade          = 1
        $Import_JSON.Character.Stats.Quickness      = 4
        $Import_JSON.Character.Stats.Spells         = 10
        $Import_JSON.Character.Stats.Healing        = 6
    }
    if ($Character_Class -eq "Rogue") {
        $Import_JSON.Character.Stats.HealthCurrent  = 60
        $Import_JSON.Character.Stats.HealthMax      = 60
        $Import_JSON.Character.Stats.StaminaCurrent = 80
        $Import_JSON.Character.Stats.StaminaMax     = 80
        $Import_JSON.Character.Stats.ManaCurrent    = 10
        $Import_JSON.Character.Stats.ManaMax        = 30
        $Import_JSON.Character.Stats.Damage         = 10
        $Import_JSON.Character.Stats.Attack         = 10
        $Import_JSON.Character.Stats.Endurance      = 6
        $Import_JSON.Character.Stats.Evade          = 10
        $Import_JSON.Character.Stats.Quickness      = 10
        $Import_JSON.Character.Stats.Spells         = 1
        $Import_JSON.Character.Stats.Healing        = 4
    }
    if ($Character_Class -eq "Cleric") {
        $Import_JSON.Character.Stats.HealthCurrent  = 40
        $Import_JSON.Character.Stats.HealthMax      = 40
        $Import_JSON.Character.Stats.StaminaCurrent = 50
        $Import_JSON.Character.Stats.StaminaMax     = 50
        $Import_JSON.Character.Stats.ManaCurrent    = 100
        $Import_JSON.Character.Stats.ManaMax        = 100
        $Import_JSON.Character.Stats.Damage         = 8
        $Import_JSON.Character.Stats.Attack         = 2
        $Import_JSON.Character.Stats.Endurance      = 4
        $Import_JSON.Character.Stats.Evade          = 1
        $Import_JSON.Character.Stats.Quickness      = 4
        $Import_JSON.Character.Stats.Spells         = 10
        $Import_JSON.Character.Stats.Healing        = 10
    }
    if ($Character_Class -eq "Warrior") {
        $Import_JSON.Character.Stats.HealthCurrent  = 100
        $Import_JSON.Character.Stats.HealthMax      = 100
        $Import_JSON.Character.Stats.StaminaCurrent = 100
        $Import_JSON.Character.Stats.StaminaMax     = 100
        $Import_JSON.Character.Stats.ManaCurrent    = 10
        $Import_JSON.Character.Stats.ManaMax        = 10
        $Import_JSON.Character.Stats.Damage         = 1
        $Import_JSON.Character.Stats.Attack         = 8
        $Import_JSON.Character.Stats.Endurance      = 10
        $Import_JSON.Character.Stats.Evade          = 8
        $Import_JSON.Character.Stats.Quickness      = 6
        $Import_JSON.Character.Stats.Spells         = 1
        $Import_JSON.Character.Stats.Healing        = 4
    }
    Set-JSON # save JSON
    Import-JSON
    Set_Variables
    Clear-Host
    Draw_Player_Stats_Window
    Draw_Player_Stats_Info
}





# TEST
######################################################################################################################
# $Character_HealthCurrent       = 60
# $Character_ManaCurrent         = 10
######################################################################################################################


#
# draw mob stats
#
Function Draw_Mob_Stats_Window_And_Info {
    $host.UI.RawUI.ForegroundColor = "DarkGray" # changes foreground color
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,0;$Host.UI.Write("╔═══════════════════════════════════════════════╗")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,1;$Host.UI.Write("║                                               ║")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,2;$Host.UI.Write("╠════════════════════════╦══════════════════════╣")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,3;$Host.UI.Write("║ Health    :     of     ║ Name  :              ║")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,4;$Host.UI.Write("║ Stamina   :     of     ║ Level :              ║")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,5;$Host.UI.Write("║ Mana      :     of     ║ Vulnerability : ???  ║")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,6;$Host.UI.Write("║ Attack    :            ║ Rare  :              ║")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,7;$Host.UI.Write("║ Damage    :            ║ Boss  : ???          ║")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,8;$Host.UI.Write("║ Endurance :            ║ Drops : a, b, c???   ║")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,9;$Host.UI.Write("║ Evade     :            ║         x, y, z???   ║")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,10;$Host.UI.Write("║ Quickness :            ║                      ║")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,11;$Host.UI.Write("║ Spells    :            ║                      ║")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,12;$Host.UI.Write("║ Healing   :            ║                      ║")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,13;$Host.UI.Write("╚════════════════════════╩══════════════════════╝")

    $host.UI.RawUI.ForegroundColor = "Green" # changes foreground color
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,3;$Host.UI.Write($Selected_Mob_HealthCurrent)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 77,3;$Host.UI.Write($Selected_Mob_HealthMax)
    $host.UI.RawUI.ForegroundColor = "Yellow" # changes foreground color
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,4;$Host.UI.Write($Selected_Mob_StaminaCurrent)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 77,4;$Host.UI.Write($Selected_Mob_StaminaMax)
    $host.UI.RawUI.ForegroundColor = "Blue" # changes foreground color
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,5;$Host.UI.Write($Selected_Mob_ManaCurrent)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 77,5;$Host.UI.Write($Selected_Mob_ManaMax)
    
    $host.UI.RawUI.ForegroundColor = "White" # changes foreground color
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 58,1;$Host.UI.Write("Mob Info")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,6;$Host.UI.Write($Selected_Mob_Attack)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,7;$Host.UI.Write($Selected_Mob_Damage)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,8;$Host.UI.Write($Selected_Mob_Endurance)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,9;$Host.UI.Write($Selected_Mob_Evade)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,10;$Host.UI.Write($Selected_Mob_Quickness)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,11;$Host.UI.Write($Selected_Mob_Spells)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,12;$Host.UI.Write($Selected_Mob_Healing)
    $host.UI.RawUI.ForegroundColor = "Blue" # changes foreground color
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 91,3;$Host.UI.Write($Selected_Mob_Name)
    $host.UI.RawUI.ForegroundColor = "White" # changes foreground color
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 91,4;$Host.UI.Write($Selected_Mob_Level)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 91,6;$Host.UI.Write($Selected_Mob_Rare)
    $host.UI.RawUI.ForegroundColor = "Gray" # set the foreground color back to original colour
}


#
# displays inventory in combat (top right)
#
Function Display_Inventory_In_Combat {
    $Inventory_Items_Name_Array = New-Object System.Collections.Generic.List[System.Object]
    $Script:Inventory_Items = $Import_JSON.Character.Items.Inventory
    foreach ($Inventory_Item in $Inventory_Items) {
        if($Inventory_Item.Quantity -gt 0) {
            $Inventory_Items_Name_Array.Add($Inventory_Item.Name.Length)
        }
    }
    $Inventory_Items_Name_Array_Max_Length = ($Inventory_Items_Name_Array | Measure-Object -Maximum).Maximum
    $Inventory_Box_Name_Width_Top_Bottom = $Inventory_Items_Name_Array_Max_Length + 7
    $Inventory_Box_Name_Width_Top_Bottom = "═"*$Inventory_Box_Name_Width_Top_Bottom
    $Inventory_Box_Name_Width_Middle = $Inventory_Items_Name_Array_Max_Length - 3
    $Inventory_Box_Name_Width_Middle = " "*$Inventory_Box_Name_Width_Middle
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 106,0;$Host.UI.Write("")
    Write-Color "╔══╦$Inventory_Box_Name_Width_Top_Bottom╗" -Color DarkGray
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 106,1;$Host.UI.Write("")
    Write-Color "║ID║ ","Inventory","$Inventory_Box_Name_Width_Middle║" -Color DarkGray,White,DarkGray
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 106,2;$Host.UI.Write("")
    Write-Color "╠══╬$Inventory_Box_Name_Width_Top_Bottom╣" -Color DarkGray
    $Position = 2
    foreach ($Inventory_Item in $Inventory_Items | Sort-Object Name) {
        if ($Inventory_Item.Quantity -gt 0) {
            $Position += 1
            if ($Inventory_Item.Name.Length -lt $Inventory_Items_Name_Array_Max_Length) {
                $Name_Left_Padding = " "*($Inventory_Items_Name_Array_Max_Length - $Inventory_Item.Name.Length)
            } else {
                $Name_Left_Padding = ""
            }
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 106,$Position;$Host.UI.Write("")
            if ($Inventory_Item.Quantity -lt 10) { # quantity less than 10 in inventory (1 digit so needs 2 padding)
                $Name_Right_Padding = "  "
            } else {
                $Name_Right_Padding = " " # more than 9 quantity (2 digits so needs 1 padding)
            }
            if($Inventory_Item.Name -like "*potion*") {
                if(($Inventory_Item.ID | Measure-Object -Character).Characters -gt 1) { # if ID is a 2 digits (no extra padding)
                    $ID_Number = "$($Inventory_Item.ID)"
                } else {
                    $ID_Number = "$($Inventory_Item.ID) " # if ID is a single digit (1 extra $Padding)
                }
            } else {
                $ID_Number = "  "
            }
            Inventory_Switch
            Write-Color "║","$ID_Number","║ $($Inventory_Item.Name)$Name_Left_Padding : ", "$($Inventory_Item.Quantity)$Name_Right_Padding","║" -Color DarkGray,$Selectable_ID_Potion_Highlight,DarkGray,White,DarkGray
            $Script:Selectable_ID_Potion_Highlight = "DarkGray"
        }
    }
    $Position += 1
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 106,$Position;$Host.UI.Write("")
    Write-Color "╚══╩$Inventory_Box_Name_Width_Top_Bottom╝" -Color DarkGray
}

#
# displays inventory out of combat (below player stats window)
#
#
# sets and asks if a potion should be used
#
Function Inventory_Choice{
    $Script:Selectable_ID_Potion_Search = "not_set"
    $Script:Potion_IDs_Array = New-Object System.Collections.Generic.List[System.Object]
    $Potion_IDs_Array.Clear()
    Display_Inventory_In_Combat
    # if health or mana is not at max - question is asked if one should be used
    if (($Character_HealthCurrent -lt $Character_HealthMax) -or ($Character_ManaCurrent -lt $Character_ManaMax)) {
        $Enough_Health_Potions = "no"
        if ($Character_HealthCurrent -lt $Character_HealthMax) {
            $Enough_Health_Potions = $Import_JSON.Character.Items.Inventory | Where-Object {$PSItem.Name -like "*health potion*" -and $PSItem.Quantity -gt 0}
            if ($Enough_Health_Potions.Quantity -gt 0){
                $Enough_Health_Potions | ForEach-Object { $Potion_IDs_Array.Add($PSItem.ID) }
                $Enough_Health_Potions = "yes"
            } else {
                $Enough_Health_Potions = "no"
            }
        }
        $Enough_Mana_Potions = "no"
        if ($Character_ManaCurrent -lt $Character_ManaMax) {
            $Enough_Mana_Potions = $Import_JSON.Character.Items.Inventory | Where-Object {$PSItem.Name -like "*mana potion*" -and $PSItem.Quantity -gt 0}
            if ($Enough_Mana_Potions.Quantity -gt 0) {
                $Enough_Mana_Potions | ForEach-Object { $Potion_IDs_Array.Add($PSItem.ID) }
                $Enough_Mana_Potions = "yes"
            } else {
                $Enough_Mana_Potions = "no"
            }
        }
        if ($Enough_Health_Potions -eq "no" -and $Enough_Mana_Potions -eq "no") {
        } else {
            do {
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,28;$Host.UI.Write("")
                " "*120
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,28;$Host.UI.Write("")
                if ($Enough_Health_Potions -eq "yes" -and $Enough_Mana_Potions -eq "no") {
                    Write-Color -NoNewLine "You are low on ","Health", ". Use a potion? ", "[Y/N]" -Color DarkYellow,Green,DarkYellow,Green
                    $Potion_Choice = "Health"
                    $Script:Selectable_ID_Potion_Search = "Health"
                } elseif ($Enough_Mana_Potions -eq "yes" -and $Enough_Health_Potions -eq "no") {
                    Write-Color -NoNewLine "You are low on ","Mana",". Use a potion? ", "[Y/N]" -Color DarkYellow,Blue,DarkYellow,Green
                    $Potion_Choice = "Mana"
                    $Script:Selectable_ID_Potion_Search = "Mana"
                } else {
                    Write-Color -NoNewLine "You are low on ","Health"," and ","Mana",". Use a potion? ", "[Y/N]" -Color DarkYellow,Green,DarkYellow,Blue,DarkYellow,Green
                    $Potion_Choice = "Health or Mana"
                    $Script:Selectable_ID_Potion_Search = "HealthMana"
                }
                $Use_A_Potion = Read-Host " "
                $Use_A_Potion = $Use_A_Potion.Trim()
            } until ($Use_A_Potion -ieq "y" -or $Use_A_Potion -ieq "n")
            if ($Use_A_Potion -ieq "y") {
                do {
                    Display_Inventory_In_Combat
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,28;$Host.UI.Write("")
                    " "*120
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,28;$Host.UI.Write("")
                    $Potion_IDs_Array_String = "0"
                    $Potion_IDs_Array_String = $Potion_IDs_Array -join "/"
                    Write-Color -NoNewLine "Enter a $Potion_Choice potion ","ID ","number ", "[e.g. $Potion_IDs_Array_String]" -Color DarkYellow,Green,DarkYellow,Green
                    $Inventory_ID = Read-Host " "
                    $Inventory_ID = $Inventory_ID.Trim()
                } until ($Inventory_ID -in $Potion_IDs_Array)
                
                # $Inventory_Items | Where-Object {$PSItem.ID -eq $Inventory_ID}
                $Potion = $Inventory_Items | Where-Object {$PSItem.ID -eq $Inventory_ID}
                # update current health
                # Clear-Host
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
                Draw_Player_Stats_Info
                # $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,9;$Host.UI.Write("")

                $Script:Selectable_ID_Potion_Search = "not_set" # resets ID colour back to DarkGray after a potion has been used the first time
                # update health
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                " "*105 # length of combat messages
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                " "*105 # length of combat messages
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                if ($Potion.Name -ilike "*health potion*") {
                    if ($Character_HealthMax - $Character_HealthCurrent -ge $Potion.Restores) {
                        # full potion Restores
                        $Script:Character_HealthCurrent = $Character_HealthCurrent + $Potion.Restores
                        Write-Color -NoNewLine "  Your ","$($Potion.Name) ","restores ", "$($Potion.Restores) ","health." -Color Gray,Blue,Gray,Green,Gray
                        # decrement potion by 1 (updates JSON after battle has finished)
                        $Import_JSON.Character.Items.Inventory | Where-Object {$PSItem.Name -eq $Potion.Name} | ForEach-Object {$PSItem.Quantity = ($PSItem.Quantity -1)}
                    } else {
                        # or if adding additional messages, say "restores 8 health" (remaining amount of health - not full potion Restores)
                        Write-Color -NoNewLine "  Your ","$($Potion.Name) ","restores you to ", "maximum ","health." -Color Gray,Blue,Gray,Green,Gray,Green,Gray
                        # not full potion Restores (or in other words, fill them up to max HP instead of over healing)
                        $Script:Character_HealthCurrent = $Character_HealthMax
                        # decrement potion by 1 (updates JSON after battle has finished)
                        $Import_JSON.Character.Items.Inventory | Where-Object {$PSItem.Name -eq $Potion.Name} | ForEach-Object {$PSItem.Quantity = ($PSItem.Quantity -1)}
                    }
                    $Import_JSON.Character.Stats.HealthCurrent = $Character_HealthCurrent
                }
                # update mana
                if ($Potion.Name -ilike "*mana potion*") {
                    if ($Character_ManaMax - $Character_ManaCurrent -ge $Potion.Restores) {
                        # full potion Restores
                        $Script:Character_ManaCurrent = $Character_ManaCurrent + $Potion.Restores
                        Write-Color -NoNewLine "  Your ","$($Potion.Name) ","restores ", "$($Potion.Restores) ","mana." -Color Gray,Blue,Gray,Blue,Gray
                        # decrement potion by 1 (updates JSON after battle has finished)
                        $Import_JSON.Character.Items.Inventory | Where-Object {$PSItem.Name -eq $Potion.Name} | ForEach-Object {$PSItem.Quantity = ($PSItem.Quantity -1)}
                    } else {
                        # or if adding additional messages, say "restores 8 mana" (remaining amount of mana - not full potion Restores)
                        Write-Color -NoNewLine "  Your ","$($Potion.Name) ","restores you to maximum mana." -Color Gray,Blue,Gray,Green,Gray
                        # not full potion Restores (or in other words, fill them up to max HP instead of over healing)
                        $Script:Character_ManaCurrent = $Character_ManaMax
                        # decrement potion by 1 (updates JSON after battle has finished)
                        $Import_JSON.Character.Items.Inventory | Where-Object {$PSItem.Name -eq $Potion.Name} | ForEach-Object {$PSItem.Quantity = ($PSItem.Quantity -1)}
                    }
                    $Import_JSON.Character.Stats.ManaCurrent = $Character_ManaCurrent
                }
                Set-JSON
                Import-JSON
                Set_Variables
                Draw_Player_Stats_Info # redraws play stats to update health or mana values
                
                if($In_Combat -eq $true){
                    Draw_Mob_Stats_Window_And_Info
                    Display_Inventory_In_Combat
                } else {
                    Display_Inventory_In_Combat
                }
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("")
                " "*120
                Set-JSON
            }
        }
    }
}

#
# displays a death ASCII picture
#
Function You_Died {
    Clear-Host
    Get-Content .\ascii.txt
}



#
# random mob from current Location with 10 percentage chance of rare mob
#
Function Random_Mob {
    $Current_Location_Mobs = $Import_JSON.Locations.$Current_Location.Mobs
    $Random_100 = Get-Random -Minimum 1 -Maximum 100
    if ($Random_100 -lt 11) {
        $All_Rare_Mobs_In_Current_Location = $Current_Location_Mobs | Where-Object {$PSItem.Rare -eq $true} # equals
        $Random_Rare_Mob_In_Current_Location = Get-Random -Minimum 0 -Maximum ($All_Rare_Mobs_In_Current_Location | Measure-Object).count # measure-object added because incorrect number when there is only one rare mob
        $Script:Selected_Mob = $All_Rare_Mobs_In_Current_Location[$Random_Rare_Mob_In_Current_Location]
    } else {
        $All_None_Rare_Mobs_In_Current_Location = $Current_Location_Mobs | Where-Object {$PSItem.Rare -ne $true} # does not equal
        $Random_None_Rare_Mob_In_Current_Location = Get-Random -Minimum 0 -Maximum ($All_None_Rare_Mobs_In_Current_Location | Measure-Object).count
        $Script:Selected_Mob = $All_None_Rare_Mobs_In_Current_Location[$Random_None_Rare_Mob_In_Current_Location]
    }
    $Script:Selected_Mob_Name           = $Selected_Mob.Name
    $Script:Selected_Mob_Level          = $Selected_Mob.Level
    $Script:Selected_Mob_HealthCurrent  = $Selected_Mob.Health
    $Script:Selected_Mob_HealthMax      = $Selected_Mob.Health
    $Script:Selected_Mob_StaminaCurrent = $Selected_Mob.Stamina
    $Script:Selected_Mob_StaminaMax     = $Selected_Mob.Stamina
    $Script:Selected_Mob_ManaCurrent    = $Selected_Mob.Mana
    $Script:Selected_Mob_ManaMax        = $Selected_Mob.Mana
    $Script:Selected_Mob_Attack         = $Selected_Mob.Attack
    $Script:Selected_Mob_Damage         = $Selected_Mob.Damage
    $Script:Selected_Mob_Endurance      = $Selected_Mob.Endurance
    $Script:Selected_Mob_Evade          = $Selected_Mob.Evade
    $Script:Selected_Mob_Quickness      = $Selected_Mob.Quickness
    $Script:Selected_Mob_Spells         = $Selected_Mob.Spells
    $Script:Selected_Mob_Healing        = $Selected_Mob.Healing
    $Script:Selected_Mob_Rare           = $Selected_Mob.Rare
}



#
# fight a mob or run
#
Function Fight_Or_Run {
    # import JSON game info
    Import-JSON
    $Continue_Fight = $false
    $First_Turn = $true
    $Inventory_Visible = $false
    # $Character_HealthCurrent = $Import_JSON.Character.Stats.HealthCurrent
    do {
        Clear-Host
        Draw_Player_Stats_Window
        Draw_Player_Stats_Info
        # $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,9;$Host.UI.Write("")
        Draw_Mob_Stats_Window_And_Info
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("")
        Write-Color "╔═══════════════════════════════════════════════════════════════════════════════════════════════════════╗" -Color DarkGray
        Write-Color "║ ","Combat","                                                                                                ║" -Color DarkGray,White,DarkGray
        Write-Color "╚═══════════════════════════════════════════════════════════════════════════════════════════════════════╝" -Color DarkGray
        Write-Color -NoNewLine "  You encounter a ","$($Selected_Mob.Name)" -Color Gray,Blue
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,28;$Host.UI.Write("")
        Write-Color -NoNewLine "Do you ","F", "ight or ","R","un away? ", "[F/R]" -Color DarkYellow,Green,DarkYellow,Green,DarkYellow,Green
        $Fight_Or_Run_Away = Read-Host " "
        $Fight_Or_Run_Away = $Fight_Or_Run_Away.Trim()
    } until ($Fight_Or_Run_Away -ieq "f" -or $Fight_Or_Run_Away -ieq "r")
    if ($Fight_Or_Run_Away -ieq "f") {
        $In_Combat = $true
        # Clear-Host
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
        Draw_Player_Stats_Window
        Draw_Player_Stats_Info
        Draw_Mob_Stats_Window_And_Info
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
        Write-Color "  You have chosen to fight the ", "$($Selected_Mob.Name)",", " -NoNewLine -Color Gray,Blue,Gray
        if ($Character_Quickness -gt $Selected_Mob.Quickness) {
            Write-Color "and your quickness allows you to take the first turn!" -Color Gray
            $Player_Turn = $true
        } else {
            Write-Color "but the ","$($Selected_Mob.Name) ","strikes first." -Color Gray,Blue,Gray
            $Player_Turn = $false
        }
        do {
            if ($Player_Turn -eq $true) {
                $Continue_Fight = $false
                # ask if the action should be attack, spell or item
                do {
                    # clear health/mana restored message or it stays on screen until end of battle
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,28;$Host.UI.Write("")
                    " "*120
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,28;$Host.UI.Write("")
                    Write-Color -NoNewLine "A","ttack, cast a ","S","pell or use an ", "I", "tem?"," [A/S/I]" -Color Green,DarkYellow,Green,DarkYellow,Green,DarkYellow,Green
                    $Fight_Choice = Read-Host " "
                    $Fight_Choice = $Fight_Choice.Trim()
                    if ($Fight_Choice -ieq "i") {
                        $Inventory_Visible = $true
                        Inventory_Choice
                        Break
                    }
                } until ($Fight_Choice -ieq "a" -or $Fight_Choice -ieq "s")
                # attack choice
                if ($Fight_Choice -ieq "a") {
                    
                    $Hit_Chance = ($Character_Attack / $Selected_Mob_Evade) / 2 * 100
                    # Write-Output "hit chance                : $Hit_Chance"
                    $Random_100 = Get-Random -Minimum 1 -Maximum 100
                    # Write-Output "random 100                : $([math]::Round($Random_100))"
                    if ($Hit_Chance -ge $Random_100) {
                        $Selected_Mob_HealthCurrent = $Selected_Mob_HealthCurrent - $Character_Damage
                        $Selected_Mob.Health = $Selected_Mob_HealthCurrent
                        if ($Selected_Mob_HealthCurrent -lt 0) {
                            $Selected_Mob_HealthCurrent = 0
                            $Selected_Mob.Health = 0
                        }
                        Draw_Mob_Stats_Window_And_Info
                        if ($Inventory_Visible -eq $true) {
                            Display_Inventory_In_Combat
                        }
                        if ($First_Turn -eq $true) {
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                            " "*240
                        } else {
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                            " "*360
                        }
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                        Write-Color "  You successfully hit the ","$($Selected_Mob.Name)"," for ","$Character_Damage ","health." -Color Gray,Blue,Gray,Red,Gray
                    } else {
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                        " "*360
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                        Write-Color "  You miss the ","$($Selected_Mob.Name)","." -Color Gray,Blue,Gray
                    }
                }

                # spells
                if ($Fight_Choice -ieq "s") {

                }

                $Player_Turn = $false
            } else {
                # mobs turn
                $Hit_Chance = ($Selected_Mob_Attack / $Character_Evade) / 2 * 100
                $Random_100 = Get-Random -Minimum 1 -Maximum 100
                if ($Hit_Chance -ge $Random_100) {
                    if ($Character_HealthCurrent -lt 0) {
                        $Script:Character_HealthCurrent = 0
                        $Import_JSON.Character.Stats.Health = 0
                    }
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("")
                    Write-Color "  The ","$($Selected_Mob.Name) ","hits you for ","$($Selected_Mob.Damage) ","health." -Color Gray,Blue,Gray,Red,Gray
                    $Script:Character_HealthCurrent = $Character_HealthCurrent - $Selected_Mob.Damage
                    $Import_JSON.Character.Stats.HealthCurrent = $Character_HealthCurrent
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
                    Draw_Player_Stats_Window
                    Draw_Player_Stats_Info
                } else {
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("")
                    Write-Color "  The ","$($Selected_Mob.Name) ","misses you." -Color Gray,Blue,Gray
                }
                $Player_Turn = $true
                $Continue_Fight = $true
            }

            # if character health is zero, display death message
            if ($Character_HealthCurrent -le 0) {
                You_Died
                Read-Host
                exit
            }

            # if mob health is zero, display you killed mob message
            if ($Selected_Mob_HealthCurrent -eq 0) {
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,20;$Host.UI.Write("")
                Write-Color "  You killed the ","$($Selected_Mob.Name) ","and gained ","$($Selected_Mob.XP) XP","!" -Color Gray,Blue,Gray,Cyan,Gray
                # Write-Output "Total XP before : $($Import_JSON.Character.Total_XP)"
                $Import_JSON.Character.Total_XP += $Selected_Mob.XP
                $Total_XP = $Total_XP + $Selected_Mob.XP
                $Import_JSON.Character.XP_TNL -= $Selected_Mob.XP
                $Script:XP_TNL = $XP_TNL - $Selected_Mob.XP
                
                
                if ($XP_TNL -lt 0) {
                    $Script:XP_Difference = $XP_TNL
                }
                if ($XP_TNL -le 0) {
                    Level_Up
                }
                Set-JSON
                Import-JSON
                Set_Variables
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
                # Draw_Player_Stats_Window
                Draw_Player_Stats_Info
                Break
            }

            # ask continue fight question after mobs turn
            if ($Continue_Fight -eq $true) {
                do {
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,28;$Host.UI.Write("")
                    " "*120
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,28;$Host.UI.Write("")
                    Write-Color -NoNewLine "Continue to ","F", "ight or try and ","R","un away? ", "[F/R]" -Color DarkYellow,Green,DarkYellow,Green,DarkYellow,Green
                    $Fight_Or_Run_Away = Read-Host " "
                    $Fight_Or_Run_Away = $Fight_Or_Run_Away.Trim()
                } until ($Fight_Or_Run_Away -ieq "f" -or $Fight_Or_Run_Away -ieq "r")
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,26;$Host.UI.Write("")
                " "*120
            }
            $First_Turn = $false
        } until ($Fight_Or_Run_Away -ieq "r")
        
        # run away (during combat)
        if ($Fight_Or_Run_Away -ieq "r") {
            Clear-Host
            Draw_Player_Stats_Window
            Draw_Player_Stats_Info
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,15;$Host.UI.Write("")
            Write-Output "You ran from $($Selected_Mob.Name)! (during combat)"
        }
    } elseif ($Fight_Or_Run_Away -ieq "r") {
        # run away before combat starts
        Clear-Host
        Draw_Player_Stats_Window
        Draw_Player_Stats_Info
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,15;$Host.UI.Write("")
        Write-Output "You ran from $($Selected_Mob.Name)! (no combat)"
    }
    $Script:In_Combat = $false
}



Function Travel {
    Clear-Host
    Draw_Player_Stats_Window
    Draw_Player_Stats_Info
    # find all linked locations that you can travel to (not including your current location)
    $All_Location_Names = $Import_JSON.Locations.PSObject.Properties.Name
    foreach ($Single_Location in $All_Location_Names) {
        if ($Import_JSON.Locations.$Single_Location.CurrentLocation -eq $true) {
            $All_Linked_Locations = $Import_JSON.Locations.$Single_Location.LinkedLocations.PSObject.Properties.Name
            $All_Linked_Locations_Letters_Array = New-Object System.Collections.Generic.List[System.Object]
            $All_Linked_Locations_List = New-Object System.Collections.Generic.List[System.Object]
            foreach ($Linked_Location in $All_Linked_Locations) {
                $All_Linked_Locations_Letters_Array.Add($Import_JSON.Locations.$Current_Location.LinkedLocations.$Linked_Location)
                $All_Linked_Locations_List.Add($Linked_Location)
                $All_Linked_Locations_List.Add("`r`n ")
            }
        }
    }
    $All_Linked_Locations_Letters_Array = $All_Linked_Locations_Letters_Array -Join '/'
    $All_Linked_Locations_Letters_Array = $All_Linked_Locations_Letters_Array + "/Q"
    # $Script:Import_JSON = (Get-Content ".\PS-RPG.json" -Raw | ConvertFrom-Json)

    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("")
    Write-Color "╔═════════════════════════════════════════════════════╗" -Color DarkGray
    Write-Color "║ ","Travel","                                              ║" -Color DarkGray,White,DarkGray
    Write-Color "╚═════════════════════════════════════════════════════╝" -Color DarkGray
    Write-Color "  Your current location is ", "$Current_Location","." -Color DarkGray,White,DarkGray
    Write-Color "`r`n  You can travel to the following locations:" -Color DarkGray
    Write-Color "`r`n  $All_Linked_Locations_List" -Color White
    do {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,28;$Host.UI.Write("")
        " "*120
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,28;$Host.UI.Write("")
        Write-Color -NoNewLine "Where do you want to travel too? ", "[$All_Linked_Locations_Letters_Array]" -Color DarkYellow,Green
        $Travel_Choice = Read-Host " "
        $Travel_Choice = $Travel_Choice.Trim()
    } until ($Travel_Choice -ieq "q" -or $All_Linked_Locations_Letters_Array -match $Travel_Choice )
    
    switch ($Travel_Choice) {
        q {
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("")
            " "*1560
            break
        }
        t {
            $Import_JSON.Locations.$Current_Location.CurrentLocation = $false
            $Current_Location = "Town"
            $Import_JSON.Locations.Town.CurrentLocation = $true
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("")
            " "*1560
            Set-JSON
        }
        f {
            $Import_JSON.Locations.$Current_Location.CurrentLocation = $false
            $Current_Location = "The Forest"
            $Import_JSON.Locations.'The Forest'.CurrentLocation = $true
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("")
            " "*1560
        }
        r {
            $Import_JSON.Locations.$Current_Location.CurrentLocation = $false
            $Current_Location = "The River"
            $Import_JSON.Locations.'The River'.CurrentLocation = $true
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("")
            " "*1560
        }
        Default {
        }
    }
    Set-JSON
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
    Draw_Player_Stats_Window
    Draw_Player_Stats_Info
}



#
# place Functions above here
#



#
# check for save data first
#
if (Test-Path -Path .\PS-RPG.json) {
    do {
        Clear-Host
        # display current saved file player stats
        Import-JSON
        Set_Variables
        Draw_Player_Stats_Window
        Draw_Player_Stats_Info
        Display_Inventory_In_Combat
        
        do {
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,27;$Host.UI.Write("")
            " "*240
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,27;$Host.UI.Write("")
            Write-Color -NoNewLine "`r`nPS-RPG.json ","save data found. Load saved data?"," [Y/N/Q]" -Color Magenta,DarkYellow,Green
            $Load_Save_Data_Choice = Read-Host " "
            $Load_Save_Data_Choice = $Load_Save_Data_Choice.Trim()
        } until ($Load_Save_Data_Choice -ieq "y" -or $Load_Save_Data_Choice -ieq "n" -or $Load_Save_Data_Choice -ieq "q")
        if ($Load_Save_Data_Choice -ieq "q") {
            Write-Color -NoNewLine "`r`nQuitting ","PS-RPG","." -Color DarkYellow,Magenta,DarkYellow
            Exit
        }
        if ($Load_Save_Data_Choice -ieq "y") {
            Import-JSON
            Set_Variables
            Clear-Host
            Draw_Player_Stats_Window
            Draw_Player_Stats_Info
        }
        if ($Load_Save_Data_Choice -ieq "n") {
            do {
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,27;$Host.UI.Write("")
                " "*240
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,27;$Host.UI.Write("")
                Write-Color -NoNewLine "`r`nStart a new game?"," [Y/N/Q]" -Color Magenta,Green
                $Start_A_New_Game = Read-Host " "
                $Start_A_New_Game = $Start_A_New_Game.Trim()
            } until ($Start_A_New_Game -ieq "y" -or $Start_A_New_Game -ieq "n" -or $Start_A_New_Game -ieq "q")
            if ($Start_A_New_Game -ieq "y") {
                # new game
                Create_Character
            }
        }
    } until ($Load_Save_Data_Choice -ieq "y" -or $Start_A_New_Game -ieq "y" -or $Start_A_New_Game -ieq "q")
} else {
    # no JSON file found
    Create_Character
}
if ($Load_Save_Data_Choice -ieq "q" -or $Start_A_New_Game -ieq "q") {
    Write-Color -NoNewLine "`r`nQuitting ","PS-RPG","." -Color DarkYellow,Magenta,DarkYellow
    Exit
}



#
# first thing after character creation / loading saved data
#
# main loop
do {
    do {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,28;$Host.UI.Write("")
        " "*120
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,28;$Host.UI.Write("")
        Write-Color -NoNewLine "H", "unt, ","T","ravel, or look at your ","I","nventory? ", "[H/T/I]" -Color Green,DarkYellow,Green,DarkYellow,Green,DarkYellow,Green
        $Hunt_Or_Inventory = Read-Host " "
        $Hunt_Or_Inventory = $Hunt_Or_Inventory.Trim()
    } until ($Hunt_Or_Inventory -ieq "h" -or $Hunt_Or_Inventory -ieq "t" -or $Hunt_Or_Inventory -ieq "i" -or $Hunt_Or_Inventory -ieq "info")
    switch ($Hunt_Or_Inventory) {
        h {
            Set-JSON # save JSON
            Random_Mob
            Fight_Or_Run
            Break
        }
        i {
            Clear-Host
            Draw_Player_Stats_Window
            Draw_Player_Stats_Info
            Inventory_Choice
            Break
        }
        t {
            Travel
            Break
        }
        info {
            Game_Info
            Break
        }
        Default {}
    }
} while ($true)



