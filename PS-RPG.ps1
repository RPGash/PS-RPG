# ToDo
# ----
#
# - BUGS
#   - "Sort-Object Name" not working when displaying inventory Items
#       (items are not collected then displayed, but instead written out one by one)
#   
#   
# - TEST
#   -
#   
#   
# - NEXT
#   - at line ~1888 "Set-Variable -Name "$($Character_Prefix)$Tavern_Drink_Bonus_Name" -Value"
#       why update variable? update JSON instead?
#   - buy items in The Anvil & Blade shop
#   - add spells
#   - add item equipment drops from mob loot
#   - add equipment that can be equipped?
#       armour protection, stat bonuses/buffs etc.
#   - add somewhere to buy/sell potions
#   - add some quests in the Tavern
#       mob kill count
#   - change "you are low on health/mana" message to
#       if less than 25%/50% = "you are running low/very low on health/mana"
#       if 50% or above = "you are not at max health" (maybe?)
#   - different message types
#       you hit/strike/bash/wack at mob
#       heals? kills? buffs etc.
#   - [ongoing] an info page available after starting the game
#       game info, PSWriteColour module, GitHub, website, uninstall module,
#       damage calculation = damage * (damage / (damage + armour)),
#       crit chance,
#       CTRL+C warning and file syncing issue (e.g. Google Drive or OneDrive etc.)
#   - consider changing mob crit rate/damage to from fixed 20%/20% to specific % for different mobs
#   - change leaving Home from "Leave" to "Exit"? for consistency
#   - check the following is still used or can be removed/edited
#       New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("");" "*3000
#
# - KNOWN ISSUES
#   - if no JSON file is found, then you start a new game but quit before completing character creation, the game finds an "empty" game file and loads with no character data - FIX is to start a new game? or check for an "empty" file and delete?
#   - On the Travel page, the available locations to travel to does not show the single character highlighted in Green as the choice for that location. e.g. if "Town" is listed, the letter "T" is not Green. All location names are White, but the question does show the correct highlighted characters for hat area.
#   - if a player purchases one drink and gains its buff, kills mobs until one buff left (not necessarily one but the closer to zero the better the exploit), they can go buy another buff and it will extend the original buff for another full duration rather than the first buff expiring after one more fight. both buffs last the full duration. in other words getting a "free" buff.
#   

Trap {
    $Time = Get-Date -Format "HH:mm:ss"
    Add-Content -Path .\error_log.log -value "-Trap Error $Time ----------------------------------"
    Add-Content -Path .\error_log.log -value "$PSItem"
    Add-Content -Path .\error_log.log -value "------------------------------------------------------"
}

Clear-Host
$PSRPG_Version = "v0.1-alpha"

Function Install_PSWriteColor {
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
# Pre-requisite checks and install / import PSWriteColor module
#
if (-not(Test-Path -Path .\PS-RPG.json)) {
    # adjust window size
    do {
        Clear-Host
        Write-Color "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -Color DarkYellow
        for ($i = 0; $i -lt 36; $i++) {
            Write-Color "+                                                                                                                                        +" -Color DarkYellow
        }
        Write-Color "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -Color DarkYellow
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 20,10;$Host.UI.Write( "Using the CTRL + mouse scroll wheel forward and back,")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 20,11;$Host.UI.Write( "adjust the font size to make sure the yellow box fits within the screen.")

        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,35;$Host.UI.Write("")
        Write-Color -NoNewLine "+ Adjust font size with ","CTRL + mouse scroll wheel",", then confirm with 'go' and Enter" -Color DarkYellow,Green,DarkYellow
        $Adjust_Font_Size = Read-Host " "
        $Adjust_Font_Size = $Adjust_Font_Size.Trim()
    } until ($Adjust_Font_Size -ieq "go")
    Clear-Host
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
        Install_PSWriteColor
    }
    #
    # game info
    #
    Write-Host -NoNewLine "`r`nPress any key to continue."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Clear-Host
    Write-Color "`r`nInfo" -Color Green
    Write-Color "----" -Color Green
    Write-Color "`r`nWelcome to ", "PS-RPG", ", my 1st RPG text adventure written in PowerShell." -Color DarkGray,Magenta,DarkGray
    Write-Color "`r`nAs previously mentioned, the PSWriteColor PowerShell module written by Przemyslaw Klys" -Color DarkGray
    Write-Color "is required which if you are seeing this message then it has installed and imported successfully." -Color DarkGray
    Write-Color "`r`nAbsolutely ", "NO ", "info personal or otherwise is collected or sent anywhere or to anybody. " -Color DarkGray,Red,DarkGray
    Write-Color "`r`nAll the ", "PS-RPG ", "games files are stored your ", "$PSScriptRoot"," folder which is where you have run the game from. They include:" -Color DarkGray,Magenta,DarkGray,Cyan,DarkGray
    Write-Color "The main PowerShell script            : ", "PS-RPG.ps1" -Color DarkGray,Cyan
    Write-Color "ASCII art for death messages          : ", "ASCII.txt" -Color DarkGray,Cyan
    Write-Color "A JSON file that stores all game info : ", "PS-RPG.json ", "(Locations, Mobs, NPCs and Character Stats etc.)" -Color DarkGray,Cyan,DarkGray
    Write-Color "`r`nPlayer input options appear in ","Green ", "e.g. ", "[Y/N/E/I] ", "would be ", "yes/no/exit/inventory", "." -Color DarkGray,Green,DarkGray,Green,DarkGray,Green,DarkGray
    Write-Color "Enter the single character then hit Enter to confirm the choice." -Color DarkGray
    Write-Color "`r`nWARNING - Quitting the game unexpectedly may cause lose of data." -Color Cyan
    Write-Color "`r`nYou are now ready to play", " PS-RPG", "." -Color DarkGray,Magenta,DarkGray

    do {
        do {
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,35;$Host.UI.Write("")
            Write-Color -NoNewLine "`r`nNo save file found. Are you ready to start playing ", "PS-RPG", "?"," [Y/N/E]" -Color DarkYellow,Magenta,DarkYellow,Green
            $Ready_To_Play_PSRPG = Read-Host " "
            $Ready_To_Play_PSRPG = $Ready_To_Play_PSRPG.Trim()
        } until ($Ready_To_Play_PSRPG -ieq "y" -or $Ready_To_Play_PSRPG -ieq "n" -or $Ready_To_Play_PSRPG -ieq "e")

        if ($Ready_To_Play_PSRPG -ieq "n" -or $Ready_To_Play_PSRPG -ieq "e") {
            do {
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,35;$Host.UI.Write("")
                Write-Color -NoNewLine "`r`nDo you want to quit ", "PS-RPG", "?"," [Y/N]" -Color DarkYellow,Magenta,DarkYellow,Green
                $Quit_Game = Read-Host " "
                $Quit_Game = $Quit_Game.Trim()
            } until ($Quit_Game -ieq "y" -or $Quit_Game -ieq "n")
            if ($Quit_Game -ieq "y") {
                Write-Color -NoNewLine "`r`nExiting ","PS-RPG","." -Color DarkYellow,Magenta,DarkYellow
                Exit
            }
        }
    } until ($Ready_To_Play_PSRPG -ieq "y")
}
# double check module is still installed if JSON file has previously been created, just in case the module has been removed.
if (Test-Path -Path .\PS-RPG.json) {
    $PSWriteModule_Install_Check = Get-Module -Name "PSWriteColor" -ListAvailable
    if ($PSWriteModule_Install_Check) {
        Import-Module -Name "PSWriteColor"
    } else {
        Install_PSWriteColor
    }
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
            # Add-Content -Path "$ENV:userprofile\My Drive\PS-RPG\error_log.log" -value "Success attempt #$($retry)"
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
# player window and stats
#
Function Draw_Player_Window_and_Stats {
    $host.UI.RawUI.ForegroundColor = "DarkGray"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write( "+-----------------------------------------------------+")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,1;$Host.UI.Write( "|                                                     |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,2;$Host.UI.Write( "+-----------------------+-----------------------------+")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,3;$Host.UI.Write( "|                       | Health    :     of          |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,4;$Host.UI.Write( "|                       | Stamina   :     of          |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,5;$Host.UI.Write( "| Name     :            | Mana      :     of          |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,6;$Host.UI.Write( "| Class    :            | Attack    :                 |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,7;$Host.UI.Write( "| Race     :            | Damage    :                 |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,8;$Host.UI.Write( "| Level    :            | Armour    :                 |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,9;$Host.UI.Write( "| Location :            | Dodge     :                 |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,10;$Host.UI.Write("| Gold     :            | Quickness :                 |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,11;$Host.UI.Write("| Total XP :            | Spells    :                 |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,12;$Host.UI.Write("| XP TNL   :            | Healing   :                 |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,13;$Host.UI.Write("+-----------------------+-----------------------------+")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 9,3;$Host.UI.Write($PSRPG_Version)
    $host.UI.RawUI.ForegroundColor = "Magenta"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 2,3;$Host.UI.Write("PS-RPG")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 2,4;$Host.UI.Write("=====")
    $host.UI.RawUI.ForegroundColor = "White"
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
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,8;$Host.UI.Write($Character_Armour)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,9;$Host.UI.Write($Character_Dodge)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,10;$Host.UI.Write($Character_Quickness)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,11;$Host.UI.Write($Character_Spells)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,12;$Host.UI.Write($Character_Healing)
    $host.UI.RawUI.ForegroundColor = "Green"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,3;$Host.UI.Write("$Character_HealthCurrent")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 45,3;$Host.UI.Write("$Character_HealthMax")
    $host.UI.RawUI.ForegroundColor = "Yellow"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,4;$Host.UI.Write("$Character_StaminaCurrent")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 45,4;$Host.UI.Write("$Character_StaminaMax")
    $host.UI.RawUI.ForegroundColor = "Blue"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 38,5;$Host.UI.Write("$Character_ManaCurrent")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 45,5;$Host.UI.Write("$Character_ManaMax")
    $host.UI.RawUI.ForegroundColor = "DarkGray" # set the foreground color back to original colour
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,11;$Host.UI.Write("")
}

Function Game_Info {
    Clear-Host
    Write-Color "+--------------------------------------------------------+" -Color DarkGray
    Write-Color "| Game Info                                              |" -Color DarkGray
    Write-Color "+--------------------------------------------------------+" -Color DarkGray
    Write-Color "| Page 1 - Info                                          |" -Color DarkGray
    Write-Color "| Page 2 - Stat                                          |" -Color DarkGray
    Write-Color "| Page 3 - ????                                          |" -Color DarkGray
    Write-Color "+--------------------------------------------------------+" -Color DarkGray
    do {
        do {
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
            Write-Color -NoNewLine "`r`nSelect Page ","[1/2/3/E]" -Color DarkYellow,Green
            $Game_Info_Page_Choice = Read-Host " "
            $Game_Info_Page_Choice = $Game_Info_Page_Choice.Trim()
        } until ($Game_Info_Page_Choice -ieq "1" -or $Game_Info_Page_Choice -ieq "2" -or $Game_Info_Page_Choice -ieq "3" -or $Game_Info_Page_Choice -ieq "e")
        if ($Game_Info_Page_Choice -ieq "e") {
            Clear-Host
            Draw_Player_Window_and_Stats
            Break
        }
        if ($Game_Info_Page_Choice -ieq "1") {
            Clear-Host
            $PSScriptRoot_Padding = " "*(76 - ($PSScriptRoot | Measure-Object -Character).Characters)
            Write-Color "+-------------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
            Write-Color "| ","Page 1 of 3 - Info","                                                                                                            |" -Color DarkGray,White,DarkGray
            Write-Color "+-------------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
            Write-Color "|                                                                                                                               |" -Color DarkGray,White
            Write-Color "|"," Welcome to ","PS-RPG",", my 1st RPG text adventure written in PowerShell.","                                                           |" -Color DarkGray,White,Magenta,White,DarkGray
            Write-Color "|                                                                                                                               |" -Color DarkGray,White
            Write-Color "| ","As previously mentioned, the PSWriteColor PowerShell module written by Przemyslaw Klys","                                        |" -Color DarkGray,White,DarkGray
            Write-Color "| ","is required which if you are seeing this message then it has installed and imported successfully.","                             |" -Color DarkGray,White,DarkGray
            Write-Color "|                                                                                                                               |" -Color DarkGray,White
            Write-Color "| ","Absolutely ","NO ","info personal or otherwise is collected or sent anywhere or to anybody.","                                         |" -Color DarkGray,White,Red,White,DarkGray
            Write-Color "|                                                                                                                               |" -Color DarkGray,White
            Write-Color "| ","All the ","PS-RPG ","games files are stored your ","$PSScriptRoot"," folder","$PSScriptRoot_Padding|" -Color DarkGray,White,Magenta,White,Cyan,White,DarkGray
            Write-Color "| ","which is where you have run the game from. They include:","                                                                      |" -Color DarkGray,White,DarkGray
            Write-Color "| ","The main PowerShell script            : ","PS-RPG.ps1","                                                                            |" -Color DarkGray,White,Cyan,DarkGray
            Write-Color "| ","ASCII art for death messages          : ","ASCII.txt","                                                                             |" -Color DarkGray,White,Cyan,DarkGray
            Write-Color "| ","A JSON file that stores all game info : ","PS-RPG.json ","(e.g. Locations, Mobs, NPCs and Character Stats etc.)","                     |" -Color DarkGray,White,Cyan,White,DarkGray
            Write-Color "|                                                                                                                               |" -Color DarkGray
            Write-Color "| ","Player input options appear in ","Green ","e.g. ","[Y/N/E/I] ","would be ","yes/no/exit/inventory", "                                            |" -Color DarkGray,White,Green,White,Green,White,Green,DarkGray
            Write-Color "| ","Enter the single character then hit Enter to confirm the choice.","                                                              |" -Color DarkGray,White,DarkGray
            Write-Color "|                                                                                                                               |" -Color DarkGray,White
            Write-Color "|"," WARNING - Quitting the game unexpectedly may cause lose of data.","                                                              |" -Color DarkGray,Cyan,DarkGray
            Write-Color "|                                                                                                                               |" -Color DarkGray,White
            Write-Color "|"," NOTE:"," If you running this game from a location that has an online backup active e.g. Google Drive or OneDrive,","                |" -Color DarkGray,DarkYellow,White,DarkGray
            Write-Color "|"," game saves will take longer due to the file being in use while syncing, so will appear to be slow when refreshing the screen. ","|" -Color DarkGray,White
            Write-Color "+-------------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
        }
        if ($Game_Info_Page_Choice -ieq "2") {
            Clear-Host
            Write-Color "+--------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
            Write-Color "| ","Page 2 of 3 - Stats","                                                                                                      |" -Color DarkGray,White,DarkGray
            Write-Color "+--------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
            Write-Color "|                                                                                                                          |" -Color DarkGray
            Write-Color "+--------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
        }
        if ($Game_Info_Page_Choice -ieq "3") {
            Clear-Host
            Write-Color "+--------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
            Write-Color "| ","Page 3 of 3 - ?????","                                                                                                      |" -Color DarkGray,White,DarkGray
            Write-Color "+--------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
            Write-Color "|                                                                                                                          |" -Color DarkGray
            Write-Color "|                                                                                                                          |" -Color DarkGray
            Write-Color "+--------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
        }
    } until ($Game_Info_Page_Choice -ieq "e")
}

#
# highlights health and or mana potion ID in inventory when available for use
#
Function Inventory_Highlight {
    if ($Selectable_ID_Search -ine "not_set" ){
        $Script:Selectable_ID_Highlight = "DarkGray" # reset Selectable_ID_Highlight so it highlights correct potion IDs in inventory list
        $Script:Selectable_Name_Highlight = "DarkGray" # reset Selectable_Name_Highlight so it highlights correct potion IDs in inventory list
        switch ($Selectable_ID_Search) {
            Health {
                if ($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Name -ilike "*health potion*") {
                    $Script:Selectable_ID_Highlight = "DarkCyan"
                    $Script:Selectable_Name_Highlight = "DarkCyan"
                }
            }
            Mana {
                if ($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Name -ilike "*mana potion*") {
                    $Script:Selectable_ID_Highlight = "DarkCyan"
                    $Script:Selectable_Name_Highlight = "DarkCyan"
                }
            }
            HealthMana {
                if ($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Name -ilike "*mana potion*" -or $Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Name -ilike "*health potion*") {
                    $Script:Selectable_ID_Highlight = "DarkCyan"
                    $Script:Selectable_Name_Highlight = "DarkCyan"
                }
            }
            Junk {
                if ($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.IsJunk -eq $true) {
                    $Anvil_Choice_Sell_Junk_Array.Add($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Name)
                    $Script:Anvil_Choice_Sell_Junk_GoldValue += ($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.GoldValue * $Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Quantity) 
                    $Script:Anvil_Choice_Sell_Junk_Quantity += $Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Quantity
                    $Script:Selectable_ID_Highlight = "DarkCyan"
                    $Script:Selectable_Name_Highlight = "DarkCyan"
                }
            }
            Default {
                $Script:Selectable_ID_Highlight = "DarkGray"
                $Script:Selectable_Name_Highlight = "DarkGray"
            }
        }
    } else {
        $Script:Selectable_ID_Highlight = "DarkGray"
        $Script:Selectable_Name_Highlight = "DarkGray"
    }
}

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
    $Script:Character_Armour         = $Import_JSON.Character.Stats.Armour
    $Script:Character_Dodge          = $Import_JSON.Character.Stats.Dodge
    $Script:Character_Quickness      = $Import_JSON.Character.Stats.Quickness
    $Script:Character_Spells         = $Import_JSON.Character.Stats.Spells
    $Script:Character_Healing        = $Import_JSON.Character.Stats.Healing
    $Script:Gold                     = $Import_JSON.Character.Items.Gold
    $Script:Character_Level          = $Import_JSON.Character.Level
    $Script:Total_XP                 = $Import_JSON.Character.Total_XP
    $Script:XP_TNL                   = $Import_JSON.Character.XP_TNL
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
        $Character_Prefix = "Character_"
        # class bonus
        foreach ($JSON_Item in $import_JSON) {
            $options = $JSON_Item.Level_Up_Bonus.Class.$Character_Class
            $Class_Stats = $options.PSObject.Properties.Name
            foreach ($Class_Stat in $Class_Stats) {
                $add = (Get-Variable -Name character_$Class_Stat).value + ($Import_JSON.Level_Up_Bonus.Class.$Character_Class.$Class_Stat)
                New-Variable -Name "$($Character_Prefix)$Class_Stat" -Value $add -Force
                $Import_JSON.Character.Stats.$Class_Stat = $(Get-Variable -Name character_$Class_Stat).value
            }
        }
        # race bonus
        $Character_Prefix = "Character_"
        foreach ($JSON_Item in $import_JSON) {
            $options = $JSON_Item.Level_Up_Bonus.Race.$Character_Race
            $Race_Stats = $options.PSObject.Properties.Name
            foreach ($Race_Stat in $Race_Stats) {
                $add = (Get-Variable -Name character_$Race_Stat).value + ($Import_JSON.Level_Up_Bonus.Race.$Character_Race.$Race_Stat)
                New-Variable -Name "$($Character_Prefix)$Race_Stat" -Value $add -Force
                $Import_JSON.Character.Stats.$Race_Stat = $(Get-Variable -Name character_$Race_Stat).value
            }
        }
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 13,12;$Host.UI.Write("");" "*6 # clears the TNL value because it shows a negative value while updating

        Set-JSON
        Import-JSON
        Set_Variables
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
        Draw_Player_Window_and_Stats
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,29;$Host.UI.Write("")
        if ($Levels_Levelled_Up -eq "1") {
            $Level_Or_Levels = "level"
        } else {
            $Level_Or_Levels = "levels"
        }
        Write-Color "  Congratulations! ", "You gained ", "$Levels_Levelled_Up ", "$Level_Or_Levels. You are now level ", "$($Import_JSON.Character.Level)","." -Color Cyan,DarkGray,White,DarkGray,White,DarkGray
        
        $Health_Bonus_On_Level_Up    += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.HealthMax + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.HealthMax
        $Stamina_Bonus_On_Level_Up   += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.StaminaMax + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.StaminaMax
        $Mana_Bonus_On_Level_Up      += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.ManaMax + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.ManaMax
        $Damage_Bonus_On_Level_Up    += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.Damage + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.Damage
        $Attack_Bonus_On_Level_Up    += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.Attack + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.Attack
        $Armour_Bonus_On_Level_Up    += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.Armour + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.Armour
        $Dodge_Bonus_On_Level_Up     += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.Dodge + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.Dodge
        $Quickness_Bonus_On_Level_Up += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.Quickness + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.Quickness
        $Spells_Bonus_On_Level_Up    += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.Spells + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.Spells
        $Healing_Bonus_On_Level_Up   += $Import_JSON.Level_Up_Bonus.Class.$Character_Class.Healing + $Import_JSON.Level_Up_Bonus.Race.$Character_Race.Healing
        
        $host.UI.RawUI.ForegroundColor = "Cyan"
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 34,1;$Host.UI.Write("(Class + Race Bonus)")
        $host.UI.RawUI.ForegroundColor = "Green"
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,3;$Host.UI.Write("(+$Health_Bonus_On_Level_Up)")
        $host.UI.RawUI.ForegroundColor = "Yellow"
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,4;$Host.UI.Write("(+$Stamina_Bonus_On_Level_Up)")
        $host.UI.RawUI.ForegroundColor = "Blue"
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,5;$Host.UI.Write("(+$Mana_Bonus_On_Level_Up)")
        $host.UI.RawUI.ForegroundColor = "White"
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,6;$Host.UI.Write("(+$Attack_Bonus_On_Level_Up)")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,7;$Host.UI.Write("(+$Damage_Bonus_On_Level_Up)")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,8;$Host.UI.Write("(+$Armour_Bonus_On_Level_Up)")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,9;$Host.UI.Write("(+$Dodge_Bonus_On_Level_Up)")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,10;$Host.UI.Write("(+$Quickness_Bonus_On_Level_Up)")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,11;$Host.UI.Write("(+$Spells_Bonus_On_Level_Up)")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,12;$Host.UI.Write("(+$Healing_Bonus_On_Level_Up)")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 18,8;$Host.UI.Write("(+$Levels_Levelled_Up)")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 18,11;$Host.UI.Write("(+$($Selected_Mob.XP))")
        
        # Write-Color "  You have gained ", "x Health ","x Stamina ", "and ", "x Mana","." -Color DarkGray,Green,Yellow,DarkGray,Blue,DarkGray
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,31;$Host.UI.Write("")
        Write-Color "  You have also learned ", "x skills","." -Color DarkGray,White,DarkGray
        if ($Levels_Levelled_Up -ne "1") {
            Start-Sleep -Seconds 2 # leave in (shows multiple levels slowly)
        }
        Draw_Player_Window_and_Stats
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
            $Character_Name_Random_Confirm = $false
            do {
                do {
                    Clear-Host
                    if ($($Character_Name | Measure-Object -Character).Characters -gt 10) {
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,9
                        Write-Color "*Your name is too long, your name must be 10 characters or less*" -Color Red
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0
                    }
                    if ($Random_Character_Name_Count -eq 0) {
                        Write-Color "*All random names have been suggested*" -Color Red
                    }
                    Write-Color "What will be your character name?" -Color DarkGray
                    Write-Color "If you cannot think of a name, try searching for one online or enter ","R ","for some random name suggestions." -Color DarkGray,Green,DarkGray
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,8;$Host.UI.Write("")
                    Write-Color -NoNewLine "Enter a name (max 10 characters) or ","R","andom ","[R]" -Color DarkYellow,Green,DarkYellow,Green
                    $Character_Name_Valid = $false # set to false to prevent a character name of " " nothing after entering a name with more than 10 characters
                    $Character_Name = Read-Host " "
                    $Character_Name = $Character_Name.Trim()
                    if (-not($null -eq $Character_Name -or $Character_Name -eq " " -or $Character_Name -eq "")) {
                        $Character_Name_Valid = $true
                    }
                } until ($($Character_Name | Measure-Object -Character).Characters -le 10)
                if ($Character_Name -ieq 'r') {
                    $Random_Character_Name_Count = 0
                    [System.Collections.ArrayList]$Random_Character_Names = ('Igert','Cyne','Aened','Alchred','Altes','Reyny','Wine','Eonild','Conga','Burgiua','Wene','Belia','Ryellia','Ellet','Wyna','Kamin','Bori','Ukhlar','Bifur','Nainan','Akad','Sanzagh','Zuri','Dwoinarv','Azan','Ukras','Ilmin','Banain','Zaghim','Gwali','Zuri','Kada','Urul','Duri','Geda','Throdore','Galdore','Finrandan','Celodhil','Aldon','Endingond','Ebrir','Edhrorod','Findore','Elerwen','Enen','Anelyel','Arwerdas','Findalye','Minerde','Mithrielye','Ilarel','Neladrie','Nerwende')
                    do {
                        if ($Random_Character_Names.Count -eq 0) { # if all random names have been suggested, reset array and break out of loop to ask question again
                            $Random_Character_Name_Count = 0
                            [System.Collections.ArrayList]$Random_Character_Names = ('Igert','Cyne','Aened','Alchred','Altes','Reyny','Wine','Eonild','Conga','Burgiua','Wene','Belia','Ryellia','Ellet','Wyna','Kamin','Bori','Ukhlar','Bifur','Nainan','Akad','Sanzagh','Zuri','Dwoinarv','Azan','Ukras','Ilmin','Banain','Zaghim','Gwali','Zuri','Kada','Urul','Duri','Geda','Throdore','Galdore','Finrandan','Celodhil','Aldon','Endingond','Ebrir','Edhrorod','Findore','Elerwen','Enen','Anelyel','Arwerdas','Findalye','Minerde','Mithrielye','Ilarel','Neladrie','Nerwende')
                            $Character_Name_Random_Confirm = $true
                            Break
                        }
                        $Random_Character_Name = Get-Random -Input $Random_Character_Names
                        do {
                            for ($Position = 0; $Position -lt 10; $Position++) {
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                            }
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
                            if ($Gandalf_Joke -ieq "Gandalf the Gray") {
                                Write-Color "Oh wait. That name has more than 10 characters. You'll have to pick another name, sorry about that =|" -Color DarkGray
                                Write-Color "Where were we..." -Color DarkGray
                            }
                            if ($Character_Name_Random -ieq "n") {
                                $Random_Character_Name_Count += 1
                                switch ($Random_Character_Name_Count) {
                                    1 { Write-Color "What about ", "$Random_Character_Name ", "for your Character's name?" -Color DarkGray,Blue,DarkGray}
                                    2 { Write-Color "How about ", "$Random_Character_Name ", "for your Character's name instead?" -Color DarkGray,Blue,DarkGray}
                                    3 { Write-Color "Okay, how about ", "$Random_Character_Name ", "then?" -Color DarkGray,Blue,DarkGray }
                                    4 { Write-Color "Didn't like that one huh? What about ", "$Random_Character_Name", "?" -Color DarkGray,Blue,DarkGray }
                                    5 { Write-Color "Didn't like that one either? ", "$Random_Character_Name ", "then?" -Color DarkGray,Blue,DarkGray }
                                    6 { Write-Color "$Random_Character_Name", "?" -Color Blue,DarkGray }
                                    7 { Write-Color "$Random_Character_Name", "?" -Color Blue,DarkGray }
                                    8 { Write-Color "$Random_Character_Name", "?" -Color Blue,DarkGray }
                                    9 { Write-Color "You're getting picky now. Let's go with ","$Random_Character_Name", "?" -Color DarkGray,Blue,DarkGray }
                                    10 { Write-Color "You're getting really picky now. Why don't you choose ","$Random_Character_Name", "?" -Color DarkGray,Blue,DarkGray }
                                    11 { Write-Color "Or ","$Random_Character_Name", "?" -Color DarkGray,Blue,DarkGray }
                                    12 { Write-Color "I'm running out of names now. ","$Random_Character_Name", "?" -Color DarkGray,Blue,DarkGray }
                                    13 { Write-Color "If you don't pick this one, i'm choose for you. ","$Random_Character_Name", "." -Color DarkGray,Blue,DarkGray }
                                    14 { Write-Color "WoW, you really didn't like THAT one??? ","$Random_Character_Name", "?" -Color DarkGray,Blue,DarkGray }
                                    15 { Write-Color "Still deciding? ","$Random_Character_Name", "?" -Color DarkGray,Blue,DarkGray }
                                    16 { Write-Color "Can't make up your mind can you? ","$Random_Character_Name", "?" -Color DarkGray,Blue,DarkGray }
                                    17 { Write-Color "This is getting boring. ","$Random_Character_Name", "?" -Color DarkGray,Blue,DarkGray }
                                    18 { Write-Color "*Yawn* ","$Random_Character_Name", "?" -Color DarkGray,Blue,DarkGray }
                                    19 {
                                        Write-Color "Gandalf the Gray", "?" -Color Blue,DarkGray
                                        $Random_Character_Name = "Gandalf the Gray"
                                    }
                                    20 {
                                        if ($Gandalf_Joke -ieq "Gandalf the Gray") {
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("");" "*105
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,1;$Host.UI.Write("");" "*105
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,2;$Host.UI.Write("");" "*105
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
                                            Write-Color "Sorry about the ","Gandalf ","joke, that wasn't very funny." -Color DarkGray,Blue,DarkGray
                                            Write-Color "If you like, i'll let you have ","Gandalf",". ","How about that?" -Color DarkGray,Blue,DarkGray
                                            $Random_Character_Name = "Gandalf"
                                            $Gandalf_Joke = "Gandalf"
                                        } else {
                                            Write-Color "Here is another name... ","$Random_Character_Name", "?" -Color DarkGray,Blue,DarkGray
                                        }
                                    }
                                    Default {
                                        Write-Color "$Random_Character_Name", "?" -Color Blue,DarkGray
                                    }
                                }
                                $Random_Character_Names.Remove($Random_Character_Name)
                            } else {
                                Write-Color "How about ", "$Random_Character_Name ", "for your Character's name? " -Color DarkGray,Blue,DarkGray
                            }
                            $Character_Name = $Random_Character_Name
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,8;$Host.UI.Write("")
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,8;$Host.UI.Write("");" "*105
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,8;$Host.UI.Write("")
                            Write-Color -NoNewLine "Choose this name? ","[Y/N]" -Color DarkYellow,Green
                            $Character_Name_Random = Read-Host " "
                        } until ($Character_Name_Random -ieq "y" -or $Character_Name_Random -ieq "n")
                        if ($Character_Name_Random -ieq "y") {
                            Write-Color -NoNewLine "You have chosen ", "$Character_Name ", "for your Character name, is this correct? ", "[Y/N]" -Color DarkYellow,Blue,DarkYellow,Green
                            $Character_Name_Random = Read-Host " "
                            if ($Character_Name_Random -ieq "y") {
                                $Character_Name_Random_Confirm = $true
                                $Character_Name_Confirm = $true
                                if ($Character_Name -ieq "Gandalf the Gray") {
                                    $Character_Name_Random_Confirm = $false
                                    $Gandalf_Joke = "Gandalf the Gray"
                                }
                            }
                        }
                        if ($Character_Name_Random -ieq "n") {
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,9;$Host.UI.Write("")
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,9;$Host.UI.Write("");" "*105
                        }
                    } until ($Character_Name_Random_Confirm -eq $true)
                }
            } until ($Character_Name_Valid -eq $true)
            if ($Character_Name_Random_Confirm -ieq $false) {
                do {
                    Write-Color -NoNewLine "You have chosen ", "$Character_Name ", "for your Character name, is this correct? ", "[Y/N/E]" -Color DarkYellow,Blue,DarkYellow,Green
                    $Character_Name_Confirm = Read-Host " "
                } until ($Character_Name_Confirm -ieq "y" -or $Character_Name_Confirm -ieq "n" -or $Character_Name_Confirm -eq "e")
                if ($Character_Name_Confirm -ieq "y") {
                    $Character_Name_Confirm = $true
                } else {
                    if ($Character_Name_Confirm -ieq "e") {Exit}
                }
            }
        } until ($Character_Name_Confirm -eq $true)
        $Import_JSON.Character.Name = $Character_Name
        # character info Function while choosing details
        Function Class_Race_Info {
            Clear-Host
            if ($Character_Name) {
                Write-Color "`r`nCharacter Name  : ", "$Character_Name" -Color DarkGray,Blue
                $ClassRaceInfoColours1 = $ClassRaceInfoColours3 = $ClassRaceInfoColours5 = $ClassRaceInfoColours7 = "Green"
                $ClassRaceInfoColours2 = $ClassRaceInfoColours4 = $ClassRaceInfoColours6 = $ClassRaceInfoColours8 = $ClassRaceInfoColours9 = $ClassRaceInfoColours10 = $ClassRaceInfoColours11 = $ClassRaceInfoColours12 = $ClassRaceInfoColours13 = $ClassRaceInfoColours14 = $ClassRaceInfoColours15 = $ClassRaceInfoColours16 = "DarkGray"
            }
            if ($Character_Class) {
                Write-Color "Character Class : ", "$Character_Class" -Color DarkGray,Blue
                $ClassRaceInfoColours1 = $ClassRaceInfoColours3 = $ClassRaceInfoColours5 = $ClassRaceInfoColours7 = "DarkGray"
                $ClassRaceInfoColours9 = $ClassRaceInfoColours11 = $ClassRaceInfoColours13 = $ClassRaceInfoColours15 = "Green"
            }
            if ($Character_Race) {
                Write-Color "Character Race  : ", "$Character_Race" -Color DarkGray,Blue
                $ClassRaceInfoColours1 = $ClassRaceInfoColours2 = $ClassRaceInfoColours3 = $ClassRaceInfoColours4 = $ClassRaceInfoColours5 = $ClassRaceInfoColours6 = $ClassRaceInfoColours7 = $ClassRaceInfoColours8 = $ClassRaceInfoColours9 = $ClassRaceInfoColours10 = $ClassRaceInfoColours11 = $ClassRaceInfoColours12 = $ClassRaceInfoColours13 = $ClassRaceInfoColours14 = $ClassRaceInfoColours15 = $ClassRaceInfoColours16 = "DarkGray"
                if ($Character_Class -eq "Mage") {$ClassRaceInfoColours1 = $ClassRaceInfoColours2 = "Green"}
                if ($Character_Class -eq "Rogue") {$ClassRaceInfoColours3 = $ClassRaceInfoColours4 = "Green"}
                if ($Character_Class -eq "Cleric") {$ClassRaceInfoColours5 = $ClassRaceInfoColours6 = "Green"}
                if ($Character_Class -eq "Warrior") {$ClassRaceInfoColours7 = $ClassRaceInfoColours8 = "Green"}
                if ($Character_Race -eq "Elf") {$ClassRaceInfoColours9 = $ClassRaceInfoColours10 = "Green"}
                if ($Character_Race -eq "Orc") {$ClassRaceInfoColours11 = $ClassRaceInfoColours12 = "Green"}
                if ($Character_Race -eq "Dwarf") {$ClassRaceInfoColours13 = $ClassRaceInfoColours14 = "Green"}
                if ($Character_Race -eq "Human") {$ClassRaceInfoColours15 = $ClassRaceInfoColours16 = "Green"}
            }
            if (-not($Character_Race)){
                Write-Color "`r`nChoose a Class and Race from the below tables." -Color DarkGray
                Write-Color "Bonus values to Character stats are applied after each level up." -Color DarkGray
            }
            Write-Color ""
            Write-Color " Class Base Stats | Health | Stamina | Mana | Armour | Damage | Attack | Dodge | Quickness | Spells | Healing |" -Color DarkGray
            Write-Color "------------------+--------+---------+------+--------+--------+--------+-------+-----------+--------+---------+" -Color DarkGray
            Write-Color " M","age             |   50   |    40   |  80  |    4   |   10   |    4   |    1  |     4     |   10   |    6    |" -Color $ClassRaceInfoColours1,$ClassRaceInfoColours2
            Write-Color " R","ogue            |   60   |    80   |  30  |    6   |   10   |   10   |   10  |    10     |    1   |    4    |" -Color $ClassRaceInfoColours3,$ClassRaceInfoColours4
            Write-Color " C","leric           |   40   |    50   | 100  |    4   |    8   |    2   |    1  |     4     |   10   |   10    |" -Color $ClassRaceInfoColours5,$ClassRaceInfoColours6
            Write-Color " W","arrior          |  100   |   100   |  10  |   10   |    1   |    8   |    8  |     6     |    1   |    4    |" -Color $ClassRaceInfoColours7,$ClassRaceInfoColours8
            Write-Color ""
            Write-Color " Class Bonus      | Health | Stamina | Mana | Armour | Damage | Attack | Dodge | Quickness | Spells | Healing |" -Color DarkGray
            Write-Color "------------------+--------+---------+------+--------+--------+--------+-------+-----------+--------+---------+" -Color DarkGray
            Write-Color " M","age             |   +2   |   +1    |  +4  |   +2   |   +5   |    +4  |   +1  |    +1     |   +5   |   +3    |" -Color $ClassRaceInfoColours1,$ClassRaceInfoColours2
            Write-Color " R","ogue            |   +3   |   +3    |  +2  |   +3   |   +5   |    +5  |   +5  |    +5     |   +1   |   +3    |" -Color $ClassRaceInfoColours3,$ClassRaceInfoColours4
            Write-Color " C","leric           |   +1   |   +2    |  +5  |   +2   |   +4   |    +2  |   +1  |    +1     |   +5   |   +5    |" -Color $ClassRaceInfoColours5,$ClassRaceInfoColours6
            Write-Color " W","arrior          |   +5   |   +5    |  +1  |   +5   |   +1   |    +4  |   +4  |    +3     |   +1   |   +4    |" -Color $ClassRaceInfoColours7,$ClassRaceInfoColours8
            Write-Color ""
            Write-Color " Race Bonus       | Health | Stamina | Mana | Armour | Damage | Attack | Dodge | Quickness | Spells | Healing |" -Color DarkGray
            Write-Color "------------------+--------+---------+------+--------+--------+--------+-------+-----------+--------+---------+" -Color DarkGray
            Write-Color " E","lf              |   +2   |   +4    |  +3  |   +1   |   +4   |    +4  |   +5  |    +5     |   +4   |   +5    |" -Color $ClassRaceInfoColours9,$ClassRaceInfoColours10
            Write-Color " O","rc              |   +4   |   +4    |  +1  |   +4   |   +4   |    +5  |   +3  |    +1     |   +1   |   +1    |" -Color $ClassRaceInfoColours11,$ClassRaceInfoColours12
            Write-Color " D","warf            |   +5   |   +5    |  +1  |   +5   |   +5   |    +5  |   +1  |    +1     |   +1   |   +3    |" -Color $ClassRaceInfoColours13,$ClassRaceInfoColours14
            Write-Color " H","uman            |   +3   |   +3    |  +3  |   +3   |   +3   |    +3  |   +3  |    +3     |   +4   |   +4    |" -Color $ClassRaceInfoColours15,$ClassRaceInfoColours16
            Write-Output "`r"
        }
        # character class choice
        do {
            do {
                $Character_Class = $false
                $Character_Class_Confirm = $false
                
                Class_Race_Info
                
                Write-Color -NoNewLine "Choose your Characters Class ", "[M/R/C/W]" -Color DarkYellow,Green
                $Character_Class = Read-Host " "
            if ($Character_Class -ieq "e") {{Exit}}
            } until ($Character_Class -ieq "m" -or $Character_Class -ieq "r" -or $Character_Class -eq "c" -or $Character_Class -eq "w")
            switch ($Character_Class) {
                m { $Character_Class = "Mage" }
                r { $Character_Class = "Rogue" }
                c { $Character_Class = "Cleric" }
                w { $Character_Class = "Warrior" }
            }
            do {
                Write-Color -NoNewLine "You have chosen a ", "$Character_Class ", "for your Character Class, is this correct? ", "[Y/N/E]" -Color DarkYellow,Blue,DarkYellow,Green
                $Character_Class_Confirm = Read-Host " "
            } until ($Character_Class_Confirm -ieq "y" -or $Character_Class_Confirm -ieq "n" -or $Character_Class_Confirm -eq "e")
            if ($Character_Class_Confirm -ieq "y") {
                $Character_Class_Confirm = $true
            } else {
                if ($Character_Class_Confirm -ieq "e") {Exit}
            }
        } until ($Character_Class_Confirm -eq $true)
        $Import_JSON.Character.Class = $Character_Class
        # character race choice
        do {
            do {
                $Character_Race = $false
                $Character_Race_Confirm = $false
                
                Class_Race_Info
                
                Write-Color -NoNewLine "Choose your Characters Race ", "[E/O/D/H]" -Color DarkYellow,Green
                $Character_Race = Read-Host " "
                if ($Character_Race -ieq "e") {{Exit}}
            } until ($Character_Race -ieq "e" -or $Character_Race -ieq "o" -or $Character_Race -eq "d" -or $Character_Race -eq "h")
            switch ($Character_Race) {
                e { $Character_Race = "Elf";$A_AN = "an" }
                o { $Character_Race = "Orc";$A_AN = "an" }
                d { $Character_Race = "Dwarf";$A_AN = "a" }
                h { $Character_Race = "Human";$A_AN = "a" }
            }
            do {
                Write-Color -NoNewLine "You have chosen $A_AN ", "$Character_Race ", "for your Character Race, is this correct? ", "[Y/N/E]" -Color DarkYellow,Blue,DarkYellow,Green
                $Character_Race_Confirm = Read-Host " "
            } until ($Character_Race_Confirm -ieq "y" -or $Character_Race_Confirm -ieq "n" -or $Character_Race_Confirm -eq "e")
            if ($Character_Race_Confirm -ieq "y") {
                $Character_Race_Confirm = $true
            } else {
                if ($Character_Race_Confirm -ieq "e") {Exit}
            }
        } until ($Character_Race_Confirm -eq $true)
        $Import_JSON.Character.Race = $Character_Race
        # confirm all character choices
        Clear-Host
        Class_Race_Info
        $Update_Character_JSON = $false
        $Update_Character_JSON_Valid = $false
        $Update_Character_JSON_Confirm = $false
        do {
            Write-Color -NoNewLine "Are all your Character details correct? ", "[Y/N/E]" -Color DarkYellow,Green
            $Update_Character_JSON = Read-Host " "
            $Update_Character_JSON = $Update_Character_JSON.Trim()
            if (-not($null -eq $Update_Character_JSON -or $Update_Character_JSON -eq " " -or $Update_Character_JSON -eq "")) {
                $Update_Character_JSON_Valid = $true
            }
        } until ($Update_Character_JSON_Valid -eq $true)
        if ($Update_Character_JSON -ieq "y") {
            $Update_Character_JSON_Confirm = $true
        } else {
            if ($Update_Character_JSON -ieq "e") {Exit}
        }
    } until ($Update_Character_JSON_Confirm -eq $true)
    Set-JSON

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
        $Import_JSON.Character.Stats.Armour         = 4
        $Import_JSON.Character.Stats.Dodge          = 1
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
        $Import_JSON.Character.Stats.Armour         = 6
        $Import_JSON.Character.Stats.Dodge          = 10
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
        $Import_JSON.Character.Stats.Armour         = 4
        $Import_JSON.Character.Stats.Dodge          = 1
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
        $Import_JSON.Character.Stats.Armour         = 10
        $Import_JSON.Character.Stats.Dodge          = 8
        $Import_JSON.Character.Stats.Quickness      = 6
        $Import_JSON.Character.Stats.Spells         = 1
        $Import_JSON.Character.Stats.Healing        = 4
    }
    Set-JSON # save JSON
    Import-JSON
    Set_Variables
    Clear-Host
    Draw_Player_Window_and_Stats
}

#
# draw mob stats
#
Function Draw_Mob_Window_and_Stats {
    $host.UI.RawUI.ForegroundColor = "DarkGray"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,0;$Host.UI.Write( "+-----------------------------------------------+")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,1;$Host.UI.Write( "|                                               |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,2;$Host.UI.Write( "+------------------------+----------------------+")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,3;$Host.UI.Write( "| Health    :     of     | Name  :              |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,4;$Host.UI.Write( "| Stamina   :     of     | Level :              |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,5;$Host.UI.Write( "| Mana      :     of     | Vulnerability : ???  |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,6;$Host.UI.Write( "| Attack    :            | Rare  :              |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,7;$Host.UI.Write( "| Damage    :            | Boss  : ???          |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,8;$Host.UI.Write( "| Armour    :            | Drops : a, b, c???   |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,9;$Host.UI.Write( "| Dodge     :            |         x, y, z???   |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,10;$Host.UI.Write("| Quickness :            |                      |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,11;$Host.UI.Write("| Spells    :            |                      |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,12;$Host.UI.Write("| Healing   :            |                      |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,13;$Host.UI.Write("+------------------------+----------------------+")
    $host.UI.RawUI.ForegroundColor = "Green"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,3;$Host.UI.Write($Selected_Mob_HealthCurrent)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 77,3;$Host.UI.Write($Selected_Mob_HealthMax)
    $host.UI.RawUI.ForegroundColor = "Yellow"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,4;$Host.UI.Write($Selected_Mob_StaminaCurrent)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 77,4;$Host.UI.Write($Selected_Mob_StaminaMax)
    $host.UI.RawUI.ForegroundColor = "Blue"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,5;$Host.UI.Write($Selected_Mob_ManaCurrent)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 77,5;$Host.UI.Write($Selected_Mob_ManaMax)
    $host.UI.RawUI.ForegroundColor = "White"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 58,1;$Host.UI.Write("Mob Info")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,6;$Host.UI.Write($Selected_Mob_Attack)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,7;$Host.UI.Write($Selected_Mob_Damage)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,8;$Host.UI.Write($Selected_Mob_Armour)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,9;$Host.UI.Write($Selected_Mob_Dodge)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,10;$Host.UI.Write($Selected_Mob_Quickness)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,11;$Host.UI.Write($Selected_Mob_Spells)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 70,12;$Host.UI.Write($Selected_Mob_Healing)
    $host.UI.RawUI.ForegroundColor = "Blue"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 91,3;$Host.UI.Write($Selected_Mob_Name)
    $host.UI.RawUI.ForegroundColor = "White"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 91,4;$Host.UI.Write($Selected_Mob_Level)
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 91,6;$Host.UI.Write($Selected_Mob_Rare)
    $host.UI.RawUI.ForegroundColor = "DarkGray" # set the foreground color back to original colour
}

#
# draw info banner for different areas / places/ combat / info etc. max width 105 (left edge of screen to Inventory)
#
Function Draw_Info_Banner {
    $Info_Banner_Padding = " "*(105-3-($Info_Banner | Measure-Object -Character).Characters)
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("")
    Write-Color "+-------------------------------------------------------------------------------------------------------+" -Color DarkGray
    Write-Color "| ","$Info_Banner","$Info_Banner_Padding|" -Color DarkGray,White,DarkGray
    Write-Color "+-------------------------------------------------------------------------------------------------------+" -Color DarkGray
}

#
# displays inventory in combat (top right)
#
Function Draw_Inventory {
    $Inventory_Items_Name_Array = New-Object System.Collections.Generic.List[System.Object]
    $Inventory_Items_Gold_Value_Array = New-Object System.Collections.Generic.List[System.Object]
    $Script:Inventory_Item_Names = $Import_JSON.Character.Items.Inventory.PSObject.Properties.Name
    foreach ($Inventory_Item_Name in $Inventory_Item_Names) {
        if ($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Quantity -gt 0) {
            $Inventory_Items_Name_Array.Add($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Name.Length)
            $Inventory_Items_Gold_Value_Array.Add(($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.GoldValue | Measure-Object -Character).Characters)
        }
    }
    # get max item gold value length
    $Inventory_Items_Gold_Value_Array_Max_Length = ($Inventory_Items_Gold_Value_Array | Measure-Object -Maximum).Maximum
    # calculate top and bottom gold value box width
    if ($Inventory_Items_Gold_Value_Array_Max_Length -le 5) {
        $Inventory_Box_Gold_Value_Width_Top_Bottom = "-"*7
    } else {
        $Inventory_Box_Gold_Value_Width_Top_Bottom = "-"*($Inventory_Items_Gold_Value_Array_Max_Length + 2)
    }
    # calculate middle gold value width
    if ($Inventory_Items_Gold_Value_Array_Max_Length -gt 5 ) {
        $Inventory_Box_Gold_Value_Width_Middle = " "*($Inventory_Items_Gold_Value_Array_Max_Length - 4)
    } else {
        $Inventory_Box_Gold_Value_Width_Middle = " "*1
    }
    
    # get max item name length
    $Inventory_Items_Name_Array_Max_Length = ($Inventory_Items_Name_Array | Measure-Object -Maximum).Maximum
    # calculate top and bottom name width
    $Inventory_Box_Name_Width_Top_Bottom = "-"*($Inventory_Items_Name_Array_Max_Length + 7)
    # calculate middle name width
    $Inventory_Box_Name_Width_Middle = " "*($Inventory_Items_Name_Array_Max_Length - 7)
    
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 106,0;$Host.UI.Write("")
    Write-Color "+--+$Inventory_Box_Name_Width_Top_Bottom+$Inventory_Box_Gold_Value_Width_Top_Bottom+" -Color DarkGray
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 106,1;$Host.UI.Write("")
    Write-Color "|","ID","| ","Inventory","$Inventory_Box_Name_Width_Middle","Qty ","| ","Value","$Inventory_Box_Gold_Value_Width_Middle|" -Color DarkGray,White,DarkGray,White,DarkGray,White,DarkGray,White,DarkGray
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 106,2;$Host.UI.Write("")
    Write-Color "+--+$Inventory_Box_Name_Width_Top_Bottom+$Inventory_Box_Gold_Value_Width_Top_Bottom+" -Color DarkGray
    $Position = 2
    foreach ($Inventory_Item_Name in $Inventory_Item_Names | Sort-Object Name) {
        if ($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Quantity -gt 0) {
            $Position += 1
            # padding for name length
            if ($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Name.Length -lt $Inventory_Items_Name_Array_Max_Length) {
                $Name_Left_Padding = " "*($Inventory_Items_Name_Array_Max_Length - $Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Name.Length)
            } else {
                $Name_Left_Padding = ""
            }
            # padding for quantity
            if ($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Quantity -lt 10) { # quantity less than 10 in inventory (1 digit so needs 2 padding)
                $Quantity_Left_Padding = "  " # less than 10 quantity (1 digit so needs 2 padding)
            } else {
                $Quantity_Left_Padding = " " # more than 9 quantity (2 digits so needs 1 padding)
            }

            if (($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.GoldValue | Measure-Object -Character).Characters -le '5') {
                $Gold_Value_Right_Padding = " "*(6 - ($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.GoldValue | Measure-Object -Character).Characters)
                if ($Inventory_Items_Gold_Value_Array_Max_Length -gt 5 ) {
                    $Gold_Value_Right_Padding = " "*($Inventory_Items_Gold_Value_Array_Max_Length - ($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.GoldValue | Measure-Object -Character).Characters + 1)
                }
            } else {
                $Gold_Value_Right_Padding = " "*($Inventory_Items_Gold_Value_Array_Max_Length - ($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.GoldValue | Measure-Object -Character).Characters + 1)
            }
            # only show potion IDs in inventory
            # if ($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Name -like "*potion*") {
            #     if (($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.ID | Measure-Object -Character).Characters -gt 1) { # if ID is a 2 digits (no extra padding)
            #         $ID_Number = "$($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.ID)"
            #     } else {
            #         $ID_Number = " $($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.ID)" # if ID is a single digit (1 extra $Padding)
            #     }
            # } else { # padding for non-potions (so displays no IDs)
            #     $ID_Number = "  "
            # }
            if (($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.ID | Measure-Object -Character).Characters -gt 1) { # if ID is a 2 digits (no extra padding)
                $ID_Number = "$($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.ID)"
            } else {
                $ID_Number = " $($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.ID)" # if ID is a single digit (1 extra padding)
            }
            Inventory_Highlight
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 106,$Position;$Host.UI.Write("")
            Write-Color "|","$ID_Number","| ","$($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Name)$Name_Left_Padding ",":", "$Quantity_Left_Padding$($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Quantity) ","| ","$($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.GoldValue)$Gold_Value_Right_Padding","|" -Color DarkGray,$Selectable_ID_Highlight,DarkGray,$Selectable_Name_Highlight,DarkGray,White,DarkGray,White,DarkGray
            $Script:Selectable_ID_Highlight = "DarkGray"
            $Script:Selectable_Name_Highlight = "DarkGray"
        }
    }
    $Position += 1
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 106,$Position;$Host.UI.Write("")
    Write-Color "+--+$Inventory_Box_Name_Width_Top_Bottom+$Inventory_Box_Gold_Value_Width_Top_Bottom+" -Color DarkGray
}

#
# sets and asks if a potion should be used
#
Function Inventory_Choice{
    $Script:Selectable_ID_Search = "not_set"
    $Script:Potion_IDs_Array = New-Object System.Collections.Generic.List[System.Object]
    $Potion_IDs_Array.Clear()
    Draw_Inventory
    # if health or mana is not at max - question is asked if one should be used
    $Script:Use_A_Potion = "" # reset so if max health is reached after using a potion, it"s not still set to "y" which causes a skipped turn when viewing the inventory a second time
    if (($Character_HealthCurrent -lt $Character_HealthMax) -or ($Character_ManaCurrent -lt $Character_ManaMax)) {
        $Enough_Health_Potions = "no"
        if ($Character_HealthCurrent -lt $Character_HealthMax) {
            $Script:Inventory_Item_Names = $Import_JSON.Character.Items.Inventory.PSObject.Properties.Name
            foreach ($Inventory_Item_Name in $Inventory_Item_Names) {
                if ($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Name -like "*health potion*" -and $Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Quantity -gt 0) {
                    $Enough_Health_Potions = "yes"
                    $Potion_IDs_Array.Add($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.ID)
                }
            }
        }
        $Enough_Mana_Potions = "no"
        if ($Character_ManaCurrent -lt $Character_ManaMax) {
            foreach ($Inventory_Item_Name in $Inventory_Item_Names) {
                if ($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Name -like "*mana potion*" -and $Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.Quantity -gt 0) {
                    $Enough_Mana_Potions = "yes"
                    $Potion_IDs_Array.Add($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.ID)
                }
            }
        }
        if ($Enough_Health_Potions -eq "no" -and $Enough_Mana_Potions -eq "no") {
        } else {
            do {
                $Script:Info_Banner = "Inventory"
                Draw_Info_Banner
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                if ($Enough_Health_Potions -eq "yes" -and $Enough_Mana_Potions -eq "no") {
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                    Write-Color -NoNewLine "  You are low on ","Health", "." -Color DarkGray,Green,DarkGray
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                    Write-Color -NoNewLine "Use a potion? ", "[Y/N]" -Color DarkYellow,Green
                    $Potion_Choice = "Health"
                    $Script:Selectable_ID_Search = "Health"
                } elseif ($Enough_Mana_Potions -eq "yes" -and $Enough_Health_Potions -eq "no") {
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                    Write-Color -NoNewLine "  You are low on ","Mana", "." -Color DarkGray,Blue,DarkGray
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                    Write-Color -NoNewLine "Use a potion? ", "[Y/N]" -Color DarkYellow,Green
                    $Potion_Choice = "Mana"
                    $Script:Selectable_ID_Search = "Mana"
                } else {
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                    Write-Color -NoNewLine "  You are low on ","Health ","and ","Mana", "." -Color DarkGray,Green,DarkGray,Blue,DarkGray
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                    Write-Color -NoNewLine "Use a potion? ", "[Y/N]" -Color DarkYellow,Green
                    $Potion_Choice = "Health or Mana"
                    $Script:Selectable_ID_Search = "HealthMana"
                }
                $Use_A_Potion = Read-Host " "
                $Script:Use_A_Potion = $Use_A_Potion.Trim()
            } until ($Use_A_Potion -ieq "y" -or $Use_A_Potion -ieq "n")
            if ($Use_A_Potion -ieq "n") { # resets potion ID if not chosen to use one, otherwise on next attack, potions IDs are highlighted
                $Script:Selectable_ID_Search = "not_set"
            }
            if ($Use_A_Potion -ieq "y") {
                do {
                    Draw_Inventory
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                    $Potion_IDs_Array_String = "0"
                    $Potion_IDs_Array_String = $Potion_IDs_Array -join "/"
                    Write-Color -NoNewLine "Enter a $Potion_Choice potion ","ID ","number ", "[e.g. $Potion_IDs_Array_String]" -Color DarkYellow,Green,DarkYellow,Green
                    $Inventory_ID = Read-Host " "
                    $Inventory_ID = $Inventory_ID.Trim()
                } until ($Inventory_ID -in $Potion_IDs_Array)
                
                # get the name of the potion from the ID selected above so the correct potion is used below
                foreach ($Inventory_Item_Name in $Inventory_Item_Names) {
                    if ($Import_JSON.Character.Items.Inventory.$Inventory_Item_Name.ID -eq $Inventory_ID) {
                        $Script:Potion = $Import_JSON.Character.Items.Inventory.$Inventory_Item_Name
                    }
                }
                
                # update current health
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
                Draw_Player_Window_and_Stats
                
                $Script:Selectable_ID_Search = "not_set" # resets ID colour back to DarkGray after a potion has been used the first time
                # update health
                Clear-Host
                Draw_Player_Window_and_Stats # placed here to fix a bug where if the last potion is used in the inventory,
                # it fully refreshes the page. otherwise the inventory window resizes and leaves an additional "bottom line of window" on the screen.
                # e.g.  1  Lesser Health Potion : 35 
                #       -----------------------------------
                # ----> ----------------------------------- <----
                $Script:Info_Banner = "Inventory"
                Draw_Info_Banner
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                if ($Potion.Name -ilike "*health potion*") {
                    if ($Character_HealthMax - $Character_HealthCurrent -ge $Potion.Restores) {
                        # full potion Restores
                        $Script:Character_HealthCurrent = $Character_HealthCurrent + $Potion.Restores
                        Write-Color -NoNewLine "  Your ","$($Potion.Name) ","restores ", "$($Potion.Restores) health","." -Color DarkGray,Green,DarkGray,Green,DarkGray
                        # decrement potion by 1 (updates JSON after battle has finished)
                        $Potion.Quantity -= 1
                    } else {
                        # or if adding additional messages, say "restores 8 health" (remaining amount of health - not full potion Restores)
                        Write-Color -NoNewLine "  Your ","$($Potion.Name) ","restores you to ", "maximum health","." -Color DarkGray,Green,DarkGray,Green,DarkGray
                        # not full potion Restores (or in other words, fill them up to max HP instead of over healing)
                        $Script:Character_HealthCurrent = $Character_HealthMax
                        # decrement potion by 1 (updates JSON after battle has finished)
                        $Potion.Quantity -= 1
                    }
                    $Import_JSON.Character.Stats.HealthCurrent = $Character_HealthCurrent
                }
                # update mana
                if ($Potion.Name -ilike "*mana potion*") {
                    if ($Character_ManaMax - $Character_ManaCurrent -ge $Potion.Restores) {
                        # full potion Restores
                        $Script:Character_ManaCurrent = $Character_ManaCurrent + $Potion.Restores
                        Write-Color -NoNewLine "  Your ","$($Potion.Name) ","restores ", "$($Potion.Restores) mana","." -Color DarkGray,Blue,DarkGray,Blue,DarkGray
                        # decrement potion by 1 (updates JSON after battle has finished)
                        $Potion.Quantity -= 1
                    } else {
                        # or if adding additional messages, say "restores 8 mana" (remaining amount of mana - not full potion Restores)
                        Write-Color -NoNewLine "  Your ","$($Potion.Name) ","restores you to ", "maximum mana","." -Color DarkGray,Blue,DarkGray,Blue,DarkGray
                        # not full potion Restores (or in other words, fill them up to max HP instead of over healing)
                        $Script:Character_ManaCurrent = $Character_ManaMax
                        # decrement potion by 1 (updates JSON after battle has finished)
                        $Potion.Quantity -= 1
                    }
                    $Import_JSON.Character.Stats.ManaCurrent = $Character_ManaCurrent
                }
                Set-JSON
                Import-JSON
                Set_Variables
                Draw_Player_Window_and_Stats # redraws play stats to update health or mana values
                
                if ($In_Combat -eq $true){
                    Draw_Mob_Window_and_Stats
                    Draw_Inventory
                } else {
                    Draw_Inventory
                }
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("");" "*105
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
    Get-Content ..\RPG\ascii.txt
}

#
# random mob from current Location with 10 percentage chance of rare mob
#
Function Random_Mob {
    $Current_Location_Mobs = $Import_JSON.Locations.$Current_Location.Mobs
    $Random_100 = Get-Random -Minimum 1 -Maximum 101
    if ($Random_100 -le 10) { # rare mob (10% of the time)
        $All_Rare_Mobs_In_Current_Location = @()
        $All_Rare_Mobs_In_Current_Location = New-Object System.Collections.Generic.List[System.Object]
        foreach ($Current_Location_Mob in $Current_Location_Mobs) {
            if ($Current_Location_Mob.Rare -ieq "yes") {
                $All_Rare_Mobs_In_Current_Location.Add($Current_Location_Mob)
            }
        }
        $Random_Rare_Mob_In_Current_Location_ID = Get-Random -Minimum 0 -Maximum ($All_Rare_Mobs_In_Current_Location | Measure-Object).count # measure-object added because incorrect number when there is only one rare mob
        $Script:Selected_Mob = $All_Rare_Mobs_In_Current_Location[$Random_Rare_Mob_In_Current_Location_ID]
    } else { # "normal" mob (90% of the time)
        $All_None_Rare_Mobs_In_Current_Location = @()
        $All_None_Rare_Mobs_In_Current_Location = New-Object System.Collections.Generic.List[System.Object]
        foreach ($Current_Location_Mob in $Current_Location_Mobs) {
            if ($Current_Location_Mob.Rare -ieq "no") {
                $All_None_Rare_Mobs_In_Current_Location.Add($Current_Location_Mob)
            }
        }
        $Random_None_Rare_Mob_In_Current_Location_ID = Get-Random -Minimum 0 -Maximum ($All_None_Rare_Mobs_In_Current_Location | Measure-Object).count # measure-object added because incorrect number when there is only one rare mob
        $Script:Selected_Mob = $All_None_Rare_Mobs_In_Current_Location[$Random_None_Rare_Mob_In_Current_Location_ID]
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
    $Script:Selected_Mob_Armour         = $Selected_Mob.Armour
    $Script:Selected_Mob_Dodge          = $Selected_Mob.Dodge
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
    # $Character_HealthCurrent = $Import_JSON.Character.Stats.HealthCurrent
    do {
        Clear-Host
        Draw_Player_Window_and_Stats
        Draw_Mob_Window_and_Stats
        $Script:Info_Banner = "Combat"
        Draw_Info_Banner
        Write-Color -NoNewLine "  You encounter a ","$($Selected_Mob.Name)" -Color DarkGray,Blue
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
        Write-Color -NoNewLine "Do you ","F", "ight or ","E","scape? ", "[F/E]" -Color DarkYellow,Green,DarkYellow,Green,DarkYellow,Green
        $Fight_Or_Escape = Read-Host " "
        $Fight_Or_Escape = $Fight_Or_Escape.Trim()
    } until ($Fight_Or_Escape -ieq "f" -or $Fight_Or_Escape -ieq "e")
    if ($Fight_Or_Escape -ieq "f") {

        $In_Combat = $true
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
        Draw_Player_Window_and_Stats
        Draw_Mob_Window_and_Stats
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
        Write-Color "  You have chosen to fight the ", "$($Selected_Mob.Name)" -NoNewLine -Color DarkGray,Blue,DarkGray
        if ($Character_Quickness -gt $Selected_Mob.Quickness) {
            Write-Color " and your quickness allows you to take the first turn!" -Color DarkGray
            $Player_Turn = $true
        } else {
            Write-Color ", but the ","$($Selected_Mob.Name) ","strikes first." -Color DarkGray,Blue,DarkGray
            $Player_Turn = $false
        }
        do {
            $Script:Info_Banner = "Combat"
            Draw_Info_Banner
            if ($Player_Turn -eq $true) {
                $Continue_Fight = $false
                # ask if the action should be attack, spell or item
                do {
                    # clear health/mana restored message or it stays on screen until end of battle
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                    Write-Color -NoNewLine "A","ttack, cast a ","S","pell or use an ", "I", "tem?"," [A/S/I]" -Color Green,DarkYellow,Green,DarkYellow,Green,DarkYellow,Green
                    $Fight_Choice = Read-Host " "
                    $Fight_Choice = $Fight_Choice.Trim()
                    if ($Fight_Choice -ieq "i") {
                        Inventory_Choice
                        if ($Use_A_Potion -ieq "y") {
                            Break
                        }
                    }
                } until ($Fight_Choice -ieq "a" -or $Fight_Choice -ieq "s")
                # attack choice
                if ($Fight_Choice -ieq "a") {
                    $Script:Info_Banner = "Combat"
                    Draw_Info_Banner
                    $Hit_Chance = ($Character_Attack / $Selected_Mob_Dodge) / 2 * 100
                    # Write-Output "hit chance                : $Hit_Chance"
                    $Random_100 = Get-Random -Minimum 1 -Maximum 101
                    # Write-Output "random 100                : $([Math]::Round($Random_100))"
                    if ($Hit_Chance -ge $Random_100) {
                        # 10% +/- of damage done
                        $Random_PlusMinus10 = Get-Random -Minimum -10 -Maximum 11
                        $Character_Hit_Damage = $Character_Damage*$Random_PlusMinus10/100+$Character_Damage
                        # damage done formula = damage * (damage / (damage + armour))
                        $Character_Hit_Damage = [Math]::Round($Character_Hit_Damage*($Character_Hit_Damage/($Character_Hit_Damage+$Selected_Mob_Armour)))
                        
                        # player crit
                        $Random_Crit_Chance = Get-Random -Minimum 1 -Maximum 101
                        $Crit_Hit = ""
                        if ($Random_Crit_Chance -le 20) { # chance of crit 20%
                            $Crit_Hit = $true
                            $Character_Hit_Damage = [Math]::Round($Character_Hit_Damage*20/100+$Character_Hit_Damage)
                            $Crit_Hit = "critically "
                        }

                        # adjust mobs health by damage amount
                        $Selected_Mob_HealthCurrent = $Selected_Mob_HealthCurrent - $Character_Hit_Damage
                        $Selected_Mob.Health = $Selected_Mob_HealthCurrent
                        if ($Selected_Mob_HealthCurrent -lt 0) {
                            $Selected_Mob_HealthCurrent = 0
                            $Selected_Mob.Health = 0
                        }
                        Draw_Mob_Window_and_Stats
                        if ($First_Turn -eq $true) {
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("");" "*105
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("");" "*105
                        } else {
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("");" "*105
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("");" "*105
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("");" "*105
                        }
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                        Write-Color "  You successfully ",$Crit_Hit,"hit the ","$($Selected_Mob.Name)"," for ","$Character_Hit_Damage ","health." -Color DarkGray,Red,DarkGray,Blue,DarkGray,Red,DarkGray
                    } else {
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("");" "*105
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("");" "*105
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("");" "*105
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                        Write-Color "  You miss the ","$($Selected_Mob.Name)","." -Color DarkGray,Blue,DarkGray
                    }
                }

                # spells
                if ($Fight_Choice -ieq "s") {

                }

                $Player_Turn = $false
            } else {
                # mobs turn
                $Hit_Chance = ($Selected_Mob_Attack / $Character_Dodge) / 2 * 100
                $Random_100 = Get-Random -Minimum 1 -Maximum 101
                if ($Hit_Chance -ge $Random_100) {
                    if ($Character_HealthCurrent -lt 0) {
                        $Script:Character_HealthCurrent = 0
                        $Import_JSON.Character.Stats.Health = 0
                    }
                    # 10% +/- of damage done
                    $Random_PlusMinus10 = Get-Random -Minimum -10 -Maximum 11
                    $Selected_Mob_Hit_Damage = $Selected_Mob.Damage*$Random_PlusMinus10/100+$Selected_Mob.Damage
                    # damage done = damage * (damage / (damage + armour))
                    $Selected_Mob_Hit_Damage = [Math]::Round($Selected_Mob_Hit_Damage*($Selected_Mob_Hit_Damage/($Selected_Mob_Hit_Damage+$Import_JSON.Character.Stats.Armour)))
                    
                    # mob crit
                    $Random_Crit_Chance = Get-Random -Minimum 1 -Maximum 101
                    $Crit_Hit = ""
                    if ($Random_Crit_Chance -le 20) { # chance of crit 20%
                        $Crit_Hit = $true
                        $Selected_Mob_Hit_Damage = [Math]::Round($Selected_Mob_Hit_Damage*20/100+$Selected_Mob_Hit_Damage)
                        $Crit_Hit = "critically "
                    }
                    
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("")
                    Write-Color "  The ","$($Selected_Mob.Name) ",$Crit_Hit,"hits you for ","$Selected_Mob_Hit_Damage ","health." -Color DarkGray,Blue,Red,DarkGray,Red,DarkGray
                    # adjust player health by damage amount
                    $Script:Character_HealthCurrent = $Character_HealthCurrent - $Selected_Mob_Hit_Damage
                    $Import_JSON.Character.Stats.HealthCurrent = $Character_HealthCurrent
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
                    Draw_Player_Window_and_Stats
                } else {
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("")
                    Write-Color "  The ","$($Selected_Mob.Name) ","misses you." -Color DarkGray,Blue,DarkGray
                }
                $Player_Turn = $true
                $Continue_Fight = $true
            }

            # if character health is zero, display death message
            if ($Character_HealthCurrent -le 0) {
                # reset buffs
                $Import_JSON.Character.Buffs.Duration = 0
                $Import_JSON.Character.Buffs.Dropped = $true
                $Import_JSON.Character.Buffs.DrinksPurchased = 0
                Set-JSON
                You_Died
                Read-Host
                exit
            }

            # if mob health is zero, display you killed mob message
            if ($Selected_Mob_HealthCurrent -eq 0) {
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,20;$Host.UI.Write("")
                Write-Color "  You killed the ","$($Selected_Mob.Name) ","and gained ","$($Selected_Mob.XP) XP","!" -Color DarkGray,Blue,DarkGray,Cyan,DarkGray
                # Write-Output "Total XP before : $($Import_JSON.Character.Total_XP)"
                $Import_JSON.Character.Total_XP += $Selected_Mob.XP
                $Total_XP = $Total_XP + $Selected_Mob.XP
                $Import_JSON.Character.XP_TNL -= $Selected_Mob.XP
                $Script:XP_TNL = $XP_TNL - $Selected_Mob.XP
                
                # loot chance
                $Random_100 = Get-Random -Minimum 1 -Maximum 101
                if ($Random_100 -le 20) { # no loot at all (20% chance)
                    Write-Color "  The ", "$($Selected_Mob.Name) ", "did not drop any loot." -Color DarkGray,Blue,DarkGray
                } else { # possible loot (80% chance per item)
                    $Looted_Items = New-Object System.Collections.Generic.List[System.Object]
                    $Loot_Item_Names = $Selected_Mob.Loot.PSObject.Properties.Name
                    foreach ($Loot_Item in $Loot_Item_Names) {
                        $Random_100 = Get-Random -Minimum 1 -Maximum 101
                        if ($Random_100 -le 70) { # chance of each loot type (70%)
                            if ($Looted_Items.Count -gt 0) {
                                $Looted_Items.Add("`r`n ")
                            }
                            if ($Loot_Item -ieq "Gold" ) { # add gold
                                $Random_5 = Get-Random -Minimum 0 -Maximum 6 # 0-5 (e.g. base gold or anything up to x1.5 amount)
                                $Looted_Gold = [Math]::Round(($Random_5/10+1)*$Selected_Mob.Loot.Gold) # gold amount between 1-1.5
                                $Looted_Items.Add("$($Looted_Gold) Gold")
                                # update gold in inventory
                                $Script:Import_JSON.Character.Items.Gold = $Import_JSON.Character.Items.Gold + $Looted_Gold
                                $Script:Gold = $Import_JSON.Character.Items.Gold + $Looted_Gold
                            } else { # add non-gold loot
                                $Looted_Items.Add("1x $($Loot_Item)")
                                # update non-gold items in inventory
                                $Script:Import_JSON.Character.Items.Inventory.$Loot_Item.Quantity = ($Import_JSON.Character.Items.Inventory.$Loot_Item.Quantity += 1)
                                Set-JSON
                            }
                        }
                    }
                    if ($Looted_Items -gt 0) {
                        Write-Color "  The ", "$($Selected_Mob.Name) ", "dropped the following items:" -Color DarkGray,Blue,DarkGray
                        Write-Color "  $($Looted_Items)" -Color DarkGray,White
                        Draw_Inventory
                    } else {
                        Write-Color "  The ", "$($Selected_Mob.Name) ", "did not drop any loot." -Color DarkGray,Blue,DarkGray
                    }
                }


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
                Draw_Player_Window_and_Stats
                Break
            }

            # ask continue fight question after mobs turn
            if ($Continue_Fight -eq $true) {
                do {
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                    Write-Color -NoNewLine "Continue to ","F", "ight or try and ","E","scape? ", "[F/E]" -Color DarkYellow,Green,DarkYellow,Green,DarkYellow,Green
                    $Fight_Or_Escape = Read-Host " "
                    $Fight_Or_Escape = $Fight_Or_Escape.Trim()
                } until ($Fight_Or_Escape -ieq "f" -or $Fight_Or_Escape -ieq "e")
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,26;$Host.UI.Write("");" "*105
            }

            # try to escape (during combat)
            if ($Fight_Or_Escape -ieq "e") {
                # escape formula = Player Q / (Player Q + (Mob Q / 3))
                $Random_Escape_100 = Get-Random -Minimum 1 -Maximum 101
                if ($Random_Escape_100 -le [Math]::Round($Character_Quickness/($Character_Quickness+($Selected_Mob_Quickness/3))*100)) {
                    Clear-Host
                    Draw_Player_Window_and_Stats
                    $Script:Info_Banner = "Combat"
                    Draw_Info_Banner
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                    Write-Color "  You escaped from the ","$($Selected_Mob.Name)","." -Color DarkGray,Blue,DarkGray
                } else {
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                    Write-Color "  You failed to escape the ","$($Selected_Mob.Name)","!" -Color DarkGray,Blue,DarkGray
                    $Fight_Or_Escape = "" # reset so it does not exit the loop and stays in combat
                    $Player_Turn = $false # keeps it the mobs turn after failing to escape
                }
            }
            $First_Turn = $false
        } until ($Fight_Or_Escape -ieq "e")
        if ($Import_JSON.Character.Buffs.Duration -gt 0) {
            $Import_JSON.Character.Buffs.Duration -= 1
            Set-JSON
        }
        if ($Import_JSON.Character.Buffs.Duration -eq 0 -and $Import_JSON.Character.Buffs.Dropped -eq $false) {
            $Import_JSON.Character.Buffs.DrinksPurchased   = 0
            $Import_JSON.Character.Buffs.Dropped           = $true
            # blank set all stats back to original value and set all UnBuffed values back to zero
            $Import_JSON.Character.Stats.HealthMax         = $Import_JSON.Character.Stats.HealthMaxUnBuffed
            $Import_JSON.Character.Stats.ManaMax           = $Import_JSON.Character.Stats.ManaMaxUnBuffed
            $Import_JSON.Character.Stats.Attack            = $Import_JSON.Character.Stats.AttackUnBuffed
            $Import_JSON.Character.Stats.Armour            = $Import_JSON.Character.Stats.ArmourUnBuffed
            $Import_JSON.Character.Stats.Dodge             = $Import_JSON.Character.Stats.DodgeUnBuffed
            $Import_JSON.Character.Stats.HealthMaxUnBuffed = 0
            $Import_JSON.Character.Stats.ManaMaxUnBuffed   = 0
            $Import_JSON.Character.Stats.AttackUnBuffed    = 0
            $Import_JSON.Character.Stats.ArmourUnBuffed    = 0
            $Import_JSON.Character.Stats.DodgeUnBuffed     = 0
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,34;$Host.UI.Write("")
            Write-Color "  Your buffs drop." -Color Cyan
            # update player stat back to original (pre-buffed)
            # $Import_JSON.Character.Stats.$Tavern_Drink_Bonus_Name = $Import_JSON.Character.Stats."$Tavern_Drink_Bonus_Name$UnBuffed"
            # update unbuffed stat back to zero
            # $Import_JSON.Character.Stats."$Tavern_Drink_Bonus_Name$UnBuffed" = 0
            Set_Variables
            Draw_Player_Window_and_Stats
        }
    } elseif ($Fight_Or_Escape -ieq "e") {
        # Escape before combat starts
        Clear-Host
        Draw_Player_Window_and_Stats
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,15;$Host.UI.Write("")
        Write-Output "You escaped from the $($Selected_Mob.Name)! (no combat)"
    }
    $Script:In_Combat = $false
}



Function Travel {
    Clear-Host
    Draw_Player_Window_and_Stats
    # find all linked locations that you can travel to (not including your current location)
    $All_Location_Names = $Import_JSON.Locations.PSObject.Properties.Name
    foreach ($Single_Location in $All_Location_Names) {
        if ($Import_JSON.Locations.$Single_Location.CurrentLocation -eq $true) {
            $All_Linked_Locations = $Import_JSON.Locations.$Single_Location.LinkedLocations.PSObject.Properties.Name
            $All_Linked_Locations_Letters_Array = New-Object System.Collections.Generic.List[System.Object]
            $All_Linked_Locations_List = New-Object System.Collections.Generic.List[System.Object]
            foreach ($Linked_Location in $All_Linked_Locations) {
                $All_Linked_Locations_Letters_Array.Add($Import_JSON.Locations.$Current_Location.LinkedLocations.$Linked_Location) # grabs single character for that building
                $All_Linked_Locations_List.Add($Linked_Location)
                $All_Linked_Locations_List.Add("`r`n ")
            }
        }
    }
    $All_Linked_Locations_Letters_Array = $All_Linked_Locations_Letters_Array -Join "/"
    $All_Linked_Locations_Letters_Array = $All_Linked_Locations_Letters_Array + "/E"
    
    $Script:Info_Banner = "Travel"
    Draw_Info_Banner
    Write-Color "  Your current location is ", "$Current_Location","." -Color DarkGray,White,DarkGray
    Write-Color "`r`n  You can travel to the following locations:" -Color DarkGray
    Write-Color "  $All_Linked_Locations_List" -Color White
    Write-Color " ,------------------------------------------------------." -Color DarkYellow
    Write-Color "(_\  +--------------+  +--------------+  +-------------+ \" -Color DarkYellow
    Write-Color "   | |     ","T","own     |  |  The ","F","orest  |  |  The ","R","iver  | |" -Color DarkYellow,Green,DarkYellow,Green,DarkYellow,Green,DarkYellow
    Write-Color "   | |              |  |              |  |             | |" -Color DarkYellow
    Write-Color "   | |   The Anvil  |  |              |  |             | |" -Color DarkYellow
    Write-Color "   | |   & Blade    |  |            <------>           | |" -Color DarkYellow
    Write-Color "   | |          <------------>        |  |             | |" -Color DarkYellow
    Write-Color "   | |   Tavern     |  |  ????????    |  |  ????????   | |" -Color DarkYellow
    Write-Color "  _| +--------------+  +--------------+  +-------------+ |" -Color DarkYellow
    Write-Color " (_/____________________________________________________/" -Color DarkYellow

    do {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
        Write-Color -NoNewLine "Where do you want to travel to? ", "[$All_Linked_Locations_Letters_Array]" -Color DarkYellow,Green
        $Travel_Choice = Read-Host " "
        $Travel_Choice = $Travel_Choice.Trim()
    } until ($All_Linked_Locations_Letters_Array -match $Travel_Choice)
    
    switch ($Travel_Choice) {
        e {
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("");" "*3000
            break
        }
        t {
            $Import_JSON.Locations.$Current_Location.CurrentLocation = $false
            $Script:Current_Location = "Town"
            $Import_JSON.Locations.Town.CurrentLocation = $true
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("");" "*3000
            Set-JSON
        }
        f {
            $Import_JSON.Locations.$Current_Location.CurrentLocation = $false
            $Script:Current_Location = "The Forest"
            $Import_JSON.Locations."The Forest".CurrentLocation = $true
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("");" "*3000
        }
        r {
            $Import_JSON.Locations.$Current_Location.CurrentLocation = $false
            $Script:Current_Location = "The River"
            $Import_JSON.Locations."The River".CurrentLocation = $true
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("");" "*3000
        }
        Default {
        }
    }
    Set-JSON
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
    Draw_Player_Window_and_Stats
}

#
# draw Town map
#
Function Draw_Town_Map {
    $host.UI.RawUI.ForegroundColor = "DarkYellow"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,0;$Host.UI.Write( "+-----------------------------------------------+")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,0;$Host.UI.Write( "+-----------------------------------------------+")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,1;$Host.UI.Write( "|                     Town        +-----------+ |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,2;$Host.UI.Write( "|                                 | The Anvil | |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,3;$Host.UI.Write( "| +------+                        | & Blade   | |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,4;$Host.UI.Write( "| | Home |                        |           | |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,5;$Host.UI.Write( "| |      |    +--------------+    +-----------+ |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,6;$Host.UI.Write( "| |      |    |    Tavern    |                  |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,7;$Host.UI.Write( "| +------+    |              |                  |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,8;$Host.UI.Write( "|             |              |                  |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,9;$Host.UI.Write( "|             |              |                  |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,10;$Host.UI.Write("|             |              |                  |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,11;$Host.UI.Write("|             |              |                  |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,12;$Host.UI.Write("|             +--------------+                  |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,13;$Host.UI.Write("+-----------------------------------------------+")
    $host.UI.RawUI.ForegroundColor = "White"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 78,1;$Host.UI.Write("Town") # Town
    $host.UI.RawUI.ForegroundColor = "Green"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 96,2;$Host.UI.Write("A") # The Anvil & Blade
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 60,4;$Host.UI.Write("H") # Home
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 75,6;$Host.UI.Write("T") # Tavern
    $host.UI.RawUI.ForegroundColor = "DarkGray" # set the foreground color back to original colour
}

#
# draw The Forest map
#
Function Draw_The_Forest_Map {
    $host.UI.RawUI.ForegroundColor = "DarkYellow"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,0;$Host.UI.Write( "+------------------------------------------------------------+")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,1;$Host.UI.Write( "|                     The Forest            +--------------+ |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,2;$Host.UI.Write( "|                                           |  Tree House  | |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,3;$Host.UI.Write( "|                                           |              | |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,4;$Host.UI.Write( "|                                           |              | |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,5;$Host.UI.Write( "|                                           +--------------+ |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,6;$Host.UI.Write( "|                                                            |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,7;$Host.UI.Write( "|                                                            |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,8;$Host.UI.Write( "|                                                            |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,9;$Host.UI.Write( "|                           +----------+                     |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,10;$Host.UI.Write("|                           | Secret   |                     |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,11;$Host.UI.Write("|                           | Location |                     |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,12;$Host.UI.Write("|      +-----+              +----------+                     |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,13;$Host.UI.Write("|      | Hut |                                               |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,14;$Host.UI.Write("|      |     |                                               |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,15;$Host.UI.Write("|      +-----+                                               |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,16;$Host.UI.Write("+------------------------------------------------------------+")
    $host.UI.RawUI.ForegroundColor = "Green"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 103,2;$Host.UI.Write("T") # Tree House
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 86,10;$Host.UI.Write("S") # Secret Location
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 65,13;$Host.UI.Write("H") # Hut
    $host.UI.RawUI.ForegroundColor = "DarkGray" # set the foreground color back to original colour
}

#
# draw The River map
#
Function Draw_The_River_Map {
    $host.UI.RawUI.ForegroundColor = "DarkYellow"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,0;$Host.UI.Write( "+-------------------------------------------------------------------+")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,1;$Host.UI.Write( "|                     The River                                     |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,2;$Host.UI.Write( "|                                                                   |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,3;$Host.UI.Write( "|                                                                   |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,4;$Host.UI.Write( "|                                                                   |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,5;$Host.UI.Write( "|                                                                   |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,6;$Host.UI.Write( "|                                                                   |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,7;$Host.UI.Write( "|                                              +--------+           |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,8;$Host.UI.Write( "|                                              |  Camp  |           |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,9;$Host.UI.Write( "|                                              |        |           |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,10;$Host.UI.Write("|                                              |        |           |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,11;$Host.UI.Write("|                                              |        |           |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,12;$Host.UI.Write("|                                              +--------+           |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,13;$Host.UI.Write("|                                                                   |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,14;$Host.UI.Write("|                                                                   |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,15;$Host.UI.Write("|                                                                   |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,16;$Host.UI.Write("+-------------------------------------------------------------------+")
    $host.UI.RawUI.ForegroundColor = "Green"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,8;$Host.UI.Write("C") # Camp
    $host.UI.RawUI.ForegroundColor = "DarkGray" # set the foreground color back to original colour
}

#
# visit a shop in whatever location you are in
#
Function Visit_A_Building {
    Clear-Host
    Draw_Player_Window_and_Stats
    # find all linked locations that you can travel to (not including your current location)
    $All_Buildings_In_Current_Location = $Import_JSON.Locations.$Current_Location.Buildings.PSObject.Properties.Name
    $All_Buildings_In_Current_Location_Letters_Array = New-Object System.Collections.Generic.List[System.Object]
    $All_Buildings_In_Current_Location_List = New-Object System.Collections.Generic.List[System.Object]
    foreach ($Building_In_Current_Location in $All_Buildings_In_Current_Location) {
        $All_Buildings_In_Current_Location_Letters_Array.Add($Import_JSON.Locations.$Current_Location.Buildings.$Building_In_Current_Location.$Building_In_Current_Location) # grabs single character for that building
        $All_Buildings_In_Current_Location_List.Add($Building_In_Current_Location)
        $All_Buildings_In_Current_Location_List.Add("`r`n ")
    }
    $All_Buildings_In_Current_Location_Letters_Array_String = $All_Buildings_In_Current_Location_Letters_Array -Join "/"
    $All_Buildings_In_Current_Location_Letters_Array_String = $All_Buildings_In_Current_Location_Letters_Array_String + "/E"

    $Script:Info_Banner = "Visit"
    Draw_Info_Banner
    Write-Color "  Your current location is ", "$Current_Location","." -Color DarkGray,White,DarkGray
    Write-Color "`r`n  You can visit the following buildings:" -Color DarkGray
    Write-Color "  $All_Buildings_In_Current_Location_List" -Color White

    if ($Current_Location -eq "Town") { Draw_Town_Map }
    if ($Current_Location -eq "The Forest") { Draw_The_Forest_Map }
    if ($Current_Location -eq "The River") { Draw_The_River_Map }

    do {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
        Write-Color -NoNewLine "Which building do you want to visit? ", "[$All_Buildings_In_Current_Location_Letters_Array_String]" -Color DarkYellow,Green
        $Building_Choice = Read-Host " "
        $Building_Choice = $Building_Choice.Trim()
    } until ($Building_Choice -ieq "e" -or $Building_Choice -in $All_Buildings_In_Current_Location_Letters_Array)
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("");" "*3000
    # set building name single characters to DarkYellow as they are no longer valid locations to visit
    $host.UI.RawUI.ForegroundColor = "DarkYellow"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 96,2;$Host.UI.Write("A") # The Anvil & Blade
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 60,4;$Host.UI.Write("H") # Home
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 75,6;$Host.UI.Write("T") # Tavern
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")

    # switch choice for Town
    if ($Current_Location -eq "Town") {
        switch ($Building_Choice) {
            e {
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("");" "*3000
                # break
            }
            #
            # Home
            #
            h {
                $host.UI.RawUI.ForegroundColor = "White"
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 60,4;$Host.UI.Write("Home")
                $host.UI.RawUI.ForegroundColor = "DarkYellow"
                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 78,1;$Host.UI.Write("Town")
                do {
                    $Script:Info_Banner = "Home"
                    Draw_Info_Banner
                    $Home_Choice_Letters_Array = New-Object System.Collections.Generic.List[System.Object]
                    if ($Home_Choice -ieq "r" ) { # rested (from choice below), so display fully rested message instead
                        Set-JSON
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
                        Draw_Player_Window_and_Stats
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("");" "*105
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("");" "*105
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                        Write-Color "  You are now fully rested. There is nothing else to do but leave." -Color DarkGray
                        $Home_Choice_Letters_Array.Add("L") # array now only contains L
                    } else {
                        Write-Color "  You are now inside your ","Home","." -Color DarkGray,White,DarkGray
                        if (($Character_HealthCurrent -lt $Character_HealthMax) -or ($Character_ManaCurrent -lt $Character_ManaMax)) {
                            
                            $Fully_Healed = "."
                            $Home_Choice_Letters_Array.Add("R")
                        } else {
                            $Fully_Healed = ", but it looks like you are already fully rested."
                        }
                        $Home_Choice_Letters_Array.Add("L")
                        $Home_Choice_Letters_Array_String = $Home_Choice_Letters_Array -Join "/"
                        Write-Color "  You can rest here and recover your ","health ","and ","mana","$($Fully_Healed)" -Color DarkGray,Green,DarkGray,Blue,DarkGray
                    }
                    do {
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                        if ($Home_Choice_Letters_Array.Contains("R")) {
                            Write-Color -NoNewLine "R","est or ","L","eave? ", "[$Home_Choice_Letters_Array_String]" -Color Green,DarkYellow,Green,DarkYellow,Green
                        } else {
                            Write-Color -NoNewLine "L","eave ", "[$Home_Choice_Letters_Array_String]" -Color Green,DarkYellow,Green
                        }
                        $Home_Choice = Read-Host " "
                        $Home_Choice = $Home_Choice.Trim()
                    } until ($Home_Choice -in $Home_Choice_Letters_Array -or $Home_Choice -ieq "info") # choice check against an array cannot be done after a -join
                    
                    if ($Home_Choice -ieq "r") {
                        $Script:Character_HealthCurrent = $Character_HealthMax
                        $Import_JSON.Character.Stats.HealthCurrent = $Character_HealthCurrent
                    }
                } until ($Home_Choice -ieq "l")
            }
            #
            # Tavern
            #
            t {
                # updates location text colour
                $host.UI.RawUI.ForegroundColor = "White"
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 75,6;$Host.UI.Write("Tavern")
                $host.UI.RawUI.ForegroundColor = "DarkYellow"
                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 78,1;$Host.UI.Write("Town")
                $First_Time_Entered_Tavern = $true
                do {
                    $Script:Info_Banner = "Tavern"
                    Draw_Info_Banner
                    do {
                        if ($First_Time_Entered_Tavern -eq $true) {
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                            Write-Color "  Welcome adventurer, i'm ","$($Import_JSON.Locations.Town.Buildings.Tavern.Owner)"," the owner of this Tavern." -Color DarkGray,Blue,DarkGray
                            Write-Color "  Would you like a ","D","rink? If not, maybe you can spare some time to look at the ","Q","uest board over there." -Color DarkGray,Green,DarkGray,Green,DarkGray
                        }
                        if ($First_Time_Entered_Tavern -eq $false) {
                            for ($Position = 17; $Position -lt 24; $Position++) { # clear some lines from previous widow
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                            }
                            if ($Import_JSON.Character.Buffs.DrinksPurchased -eq 2) {
                                for ($Position = 17; $Position -lt 24; $Position++) { # clear some lines from previous widow
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                }
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                Write-Color "  $($Import_JSON.Locations.Town.Buildings.Tavern.Owner) ","says you've had too many and refuses to serve you until you sober up." -Color Blue,DarkGray
                            }
                            if ($Import_JSON.Character.Buffs.DrinksPurchased -lt 2 -and $Drink_Purchased -eq $false) {
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                Write-Color "  Don't forget to check out the ","Q","uest board." -Color DarkGray,Green,DarkGray
                            }
                            if ($Drink_Purchased -eq $true) {
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                Write-Color "  $($Import_JSON.Locations.Town.Buildings.Tavern.Owner) ","hands you a ","$Tavern_Drink","." -Color Blue,DarkGray,White,DarkGray
                                Write-Color "  You feel strange. You temporarily have the following buffs." -Color DarkGray
                                Write-Color ""
                                if ($Tavern_Drink_Bonus_Name -ieq 'HealthMax') {
                                    $Buff_Bonus_Colour = "Green"
                                } elseif ($Tavern_Drink_Bonus_Name -ieq 'ManaMax') {
                                    $Buff_Bonus_Colour = "Blue"
                                } else {
                                    $Buff_Bonus_Colour = "White"
                                }
                                Write-Color "  Buff Bonus ","+$($Bonus_Stat_Difference) $($Tavern_Drink_Bonus_Name)" -Color DarkGray,$Buff_Bonus_Colour
                                $Drink_Purchased = $false
                            }
                        }
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                        Write-Color -NoNewLine "D","rink, ","Q","uest board, or ", "E","xit ","[D/Q/E]" -Color Green,DarkYellow,Green,DarkYellow,Green,DarkYellow,Green
                        $Tavern_Choice = Read-Host " "
                        $Tavern_Choice = $Tavern_Choice.Trim()
                    } until ($Tavern_Choice -ieq "d" -or $Tavern_Choice -ieq "q" -or $Tavern_Choice -ieq "e")
                    
                    # drinks menu
                    if ($Tavern_Choice -ieq "d") {
                        # do {
                            do {
                                for ($Position = 17; $Position -lt 24; $Position++) { # clear some lines from previous widow
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                }
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                Write-Color "  Please choose from our selection of drinks from the menu." -Color DarkGray
                                Write-Color "`r" -Color DarkGray
                                $Tavern_Drinks_Categorys = $Import_JSON.Locations.Town.Buildings.Tavern.Drinks.PSObject.Properties.Name
                                $Tavern_Drinks_Category_Letters_Array = New-Object System.Collections.Generic.List[System.Object]
                                foreach ($Tavern_Drinks_Category in $Tavern_Drinks_Categorys) {
                                    $Tavern_Drink_Category_First_Character = $Tavern_Drinks_Category.SubString(0,1)
                                    $Tavern_Drink_Category_Other_Character = $Tavern_Drinks_Category.SubString(1)
                                    $Tavern_Drinks_Category_Letters_Array.Add($Tavern_Drink_Category_First_Character)
                                    Write-Color "  $($Tavern_Drink_Category_First_Character)","$($Tavern_Drink_Category_Other_Character)" -Color Green,DarkGray
                                }
                                $Tavern_Drinks_Category_Letters_Array_String = $Tavern_Drinks_Category_Letters_Array -Join "/" # cannot query input choice against an array that has been joined
                                $Tavern_Drinks_Category_Letters_Array_String = $Tavern_Drinks_Category_Letters_Array_String + "/E"
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                Write-Color -NoNewLine "A","les, ","M","eads, ","S","pirits, ","N","on-Alcoholic, ","R","are, or ", "E","xit ","$Tavern_Drinks_Category_Letters_Array_String" -Color Green,DarkYellow,Green,DarkYellow,Green,DarkYellow,Green,DarkYellow,Green,DarkYellow,Green,DarkYellow
                                $Tavern_Drinks_Choice = Read-Host " "
                                $Tavern_Drinks_Choice = $Tavern_Drinks_Choice.Trim()
                            } until ($Tavern_Drinks_Choice -ieq 'e' -or $Tavern_Drinks_Choice -in $Tavern_Drinks_Category_Letters_Array)
                            # drinks menu switch
                            switch ($Tavern_Drinks_Choice) {
                                e {
                                    $Drink_Purchased = $false
                                    Break # or exit?
                                }
                                $Tavern_Drinks_Choice {
                                    if ($Import_JSON.Character.Buffs.DrinksPurchased -lt 2) {
                                        $Drink_Purchased = $true
                                        $Import_JSON.Character.Buffs.DrinksPurchased += 1
                                        for ($Position = 17; $Position -lt 24; $Position++) { # clear some lines from previous widow
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                        }
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                        foreach ($Tavern_Drinks_Category in $Tavern_Drinks_Categorys) {
                                            if ($Tavern_Drinks_Category.SubString(0,1) -eq $Tavern_Drinks_Choice) {
                                                $Tavern_Drinks_Category = $Tavern_Drinks_Category
                                                Break
                                            }
                                        }
                                        $Tavern_Drinks = $Import_JSON.Locations.Town.Buildings.Tavern.Drinks.$Tavern_Drinks_Category.PSObject.Properties.Name
                                        $Tavern_Drink = Get-Random -Input $Tavern_Drinks
                                        $Script:Tavern_Drink_Bonus_Name = $Import_JSON.Locations.Town.Buildings.Tavern.Drinks.$Tavern_Drinks_Category.$Tavern_Drink.Bonus.PSObject.Properties.Name
                                        # update JSON Buffs.Duration based on drink category
                                        $Import_JSON.Character.Buffs.Duration = $Import_JSON.Locations.Town.Buildings.Tavern.Drinks.$Tavern_Drinks_Category.$Tavern_Drink.BuffDuration
                                        $Import_JSON.Character.Buffs.Dropped = $false
                                        switch ($Tavern_Drink_Bonus_Name) {
                                            $Tavern_Drink_Bonus_Name {
                                                $Tavern_Drink_Bonus_Amount = ($Import_JSON.Locations.Town.Buildings.Tavern.Drinks.$Tavern_Drinks_Category.$Tavern_Drink.Bonus).$Tavern_Drink_Bonus_Name
                                                $Character_Prefix = "Character_"
                                                # gets current character stat bonus value (so difference can be calculated below)
                                                $Bonus_Stat_Before = (Get-Variable character_* | Where-Object {$PSItem.Name -like "*$Tavern_Drink_Bonus_Name*"}).value
                                                $Script:UnBuffed = "UnBuffed"
                                                # Set-Variable -Name "$($Character_Prefix)$Tavern_Drink_Bonus_Name$UnBuffed" -Value (Get-Variable -name "$($Character_Prefix)$Tavern_Drink_Bonus_Name").value
                                                # sets the JSON character stat e.g. HealthMaxUnBuffed to the current HealthMax value so the current HealthMax value becomes the buffed value which then can be reverted when the buff drops
                                                # but only if the UnBuffed stat is zero. otherwise if you get a buff, kill something, then get a second buff, the UnBuffed value gets added to again which was not the origianl stat value (e.g. a free perminant stat boost)
                                                if ($Import_JSON.Character.Stats."$Tavern_Drink_Bonus_Name$UnBuffed" -eq '0') {
                                                    $Import_JSON.Character.Stats."$Tavern_Drink_Bonus_Name$UnBuffed" = (Get-Variable -name "$($Character_Prefix)$Tavern_Drink_Bonus_Name").value
                                                }
                                                # sets e.g. the $Character_HealthMaxUnBuffed variable to what was in $Character_HealthMax so it can be retrieved when buff is lost
                                                Set-Variable -Name "$($Character_Prefix)$Tavern_Drink_Bonus_Name" -Value ([Math]::Round((Get-Variable character_* | Where-Object {$PSItem.Name -like "*$Tavern_Drink_Bonus_Name*"}).value * $Tavern_Drink_Bonus_Amount)) -Force
                                                # gets the current buffed character stat so the difference can be displayed in Player Stats window
                                                $Bonus_Stat_After = (Get-Variable character_* | Where-Object {$PSItem.Name -like "*$Tavern_Drink_Bonus_Name*"}).value
                                                $Bonus_Stat_Difference = $Bonus_Stat_After - $Bonus_Stat_Before
                                                # sets the JSON character stat e.g. HealthMax to the current HealthMax value plus the difference (the bonus)
                                                $Import_JSON.Character.Stats."$Tavern_Drink_Bonus_Name" += $Bonus_Stat_Difference
                                                Set-JSON
                                                Set_Variables
                                                Draw_Player_Window_and_Stats
                                                switch ($Tavern_Drink_Bonus_Name) {
                                                    HealthMax {
                                                        $host.UI.RawUI.ForegroundColor = "Green"
                                                        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,3;$Host.UI.Write("(+$Bonus_Stat_Difference)")
                                                    }
                                                    ManaMax {
                                                        $host.UI.RawUI.ForegroundColor = "Blue"
                                                        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,5;$Host.UI.Write("(+$Bonus_Stat_Difference)")
                                                    }
                                                    Attack {
                                                        $host.UI.RawUI.ForegroundColor = "White"
                                                        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,6;$Host.UI.Write("(+$Bonus_Stat_Difference)")
                                                    }
                                                    Armour {
                                                        $host.UI.RawUI.ForegroundColor = "White"
                                                        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,8;$Host.UI.Write("(+$Bonus_Stat_Difference)")
                                                    }
                                                    Dodge {
                                                        $host.UI.RawUI.ForegroundColor = "White"
                                                        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 49,9;$Host.UI.Write("(+$Bonus_Stat_Difference)")
                                                    }
                                                    Default {}
                                                }
                                                $host.UI.RawUI.ForegroundColor = "Cyan"
                                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 42,1;$Host.UI.Write("(Buff Bonus)")
                                            }
                                            Default {}
                                        }
                                    }
                                }
                                Default {}
                            }
                        # } until ($Tavern_Drinks_Choice -ieq 'e')
                    }
                    $First_Time_Entered_Tavern = $false
                } until ($Tavern_Choice -ieq "e")
            }
            #
            # The Anvil & Blade
            #
            a {
                # updates location text colour
                $host.UI.RawUI.ForegroundColor = "White"
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 92,2;$Host.UI.Write("The Anvil")
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 92,3;$Host.UI.Write("& Blade")
                $host.UI.RawUI.ForegroundColor = "DarkYellow"
                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 78,1;$Host.UI.Write("Town")
                $First_Time_Entered_Anvil = $true
                do {
                    $Script:Info_Banner = "The Anvil & Blade"
                    Draw_Info_Banner
                    Draw_Inventory
                    do {
                        if ($First_Time_Entered_Anvil -eq $false) {
                            for ($Position = 17; $Position -lt 24; $Position++) { # clear some lines from previous widow
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                            }
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                            if ($No_Items_To_Sell -eq $true) {
                                Write-Color "  It doesn't look like you have any junk items you want to get rid off." -Color DarkGray
                            }
                            Write-Color "  Anything else i can interest you in?" -Color DarkGray
                        } else {
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                            Write-Color "  Greetings adventurer." -Color DarkGray
                            Write-Color "  I buy and sell Weapons and Armour if you are interested." -Color DarkGray
                        }
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                        Write-Color -NoNewLine "B","uy, ","S","ell, or ", "E","xit ","[B/S/E]" -Color Green,DarkYellow,Green,DarkYellow,Green,DarkYellow,Green
                        $Anvil_Choice = Read-Host " "
                        $Anvil_Choice = $Anvil_Choice.Trim()
                    } until ($Anvil_Choice -ieq "b" -or $Anvil_Choice -ieq "s" -or $Anvil_Choice -ieq "e")
                    
                    # if ($Anvil_Choice -ieq "b") {
                        
                    # }
                    if ($Anvil_Choice -ieq "s") {
                        do {
                            for ($Position = 17; $Position -lt 19; $Position++) { # clear some lines from previous widow
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                            }
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                            Write-Color "  What do you want to get rid of?" -Color DarkGray
                            Write-Color "`r`n  J","unk items" -Color Green,DarkGray
                            Write-Color "  A","rmour" -Color Green,DarkGray
                            Write-Color "  W","eapons" -Color Green,DarkGray
                            Write-Color "  N","othing for now." -Color Green,DarkGray
                            Write-Color "  E","xit The Anvil & Blade." -Color Green,DarkGray
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                            Write-Color -NoNewLine "J","unk, ","A","rmour, ","W","eapons, or ", "E","xit ","[J/A/W/N]" -Color Green,DarkYellow,Green,DarkYellow,Green,DarkYellow,Green,DarkYellow,Green
                            $Anvil_Sell_Choice = Read-Host " "
                            $Anvil_Sell_Choice = $Anvil_Sell_Choice.Trim()
                        } until ($Anvil_Sell_Choice -ieq "j" -or $Anvil_Sell_Choice -ieq "a" -or $Anvil_Sell_Choice -ieq "w" -or $Anvil_Sell_Choice -ieq "n" -or $Anvil_Sell_Choice -ieq "e")
                        if ($Anvil_Sell_Choice -ieq "j") {
                            $Anvil_Choice_Sell_Junk_Array = New-Object System.Collections.Generic.List[System.Object]
                            $Inventory_Item_Names = $Import_JSON.Character.Items.Inventory.PSObject.Properties.Name
                            $Script:Anvil_Choice_Sell_Junk_Quantity = 0 # reset variables so they don't increase next time
                            $Script:Anvil_Choice_Sell_Junk_GoldValue = 0 # reset variables so they don't increase next time
                            $Script:Selectable_ID_Search = "Junk"
                            Draw_Inventory
                            if ($Anvil_Choice_Sell_Junk_Quantity -gt 0) {
                                do {
                                    for ($Position = 17; $Position -lt 24; $Position++) { # clear some lines from previous widow
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                    }
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                    Write-Color "  You have ","$($Script:Anvil_Choice_Sell_Junk_Quantity) ","junk items." -Color DarkGray,DarkCyan,DarkGray
                                    Write-Color "  I will give you ","$($Script:Anvil_Choice_Sell_Junk_GoldValue) ","gold for them." -Color DarkGray,DarkYellow,DarkGray
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                    Write-Color -NoNewLine "Do you agree? ","Y","es or ", "N","o ","[Y/N]" -Color DarkYellow,Green,DarkYellow,Green,DarkYellow,Green
                                    $Anvil_Sell_Junk_Choice = Read-Host " "
                                    $Anvil_Sell_Junk_Choice = $Anvil_Sell_Junk_Choice.Trim()
                                } until ($Anvil_Sell_Junk_Choice -ieq "y" -or $Anvil_Sell_Junk_Choice -ieq "n")
                            } else {
                                $No_Items_To_Sell = $true
                            }
                        }
                        if ($Anvil_Sell_Junk_Choice -ieq "y") { # sells all junk
                            $Import_JSON.Character.Items.Gold = $Import_JSON.Character.Items.Gold + $Anvil_Choice_Sell_Junk_GoldValue
                            foreach (${JunkItem} in ${Anvil_Choice_Sell_Junk_Array}) {
                                $Import_JSON.Character.Items.Inventory.$JunkItem.Quantity = 0
                            }
                            Set-JSON
                            Clear-Host
                            Set_Variables
                            Draw_Player_Window_and_Stats
                            Draw_Town_Map
                            Draw_Info_Banner
                            Draw_Inventory
                            $host.UI.RawUI.ForegroundColor = "DarkYellow"
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 18,10;$Host.UI.Write("(+$($Script:Anvil_Choice_Sell_Junk_GoldValue))")
                        }
                        $Script:Selectable_ID_Search = "not_set"
                        $First_Time_Entered_Anvil = $false
                        if ($Anvil_Sell_Choice -ieq "e") { # leaves The Anvil & Blade
                            Break
                        }
                    }
                    
                } until ($Anvil_Choice -ieq "e")
            }
            # Default {}
        }
    }

    # switch choice for The Forest
    if ($Current_Location -eq "The Forest") {
        switch ($Building_Choice) {
            e {
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("");" "*3000
            }
            h { # Hut
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("");" "*3000
            }
            t { # Tree House
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("");" "*3000
            }
            s { # Secret Location
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("");" "*3000
            }
            # Default {}
        }
    }

    # switch choice for The River
    if ($Current_Location -eq "The River") {
        switch ($Building_Choice) {
            e {
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("");" "*3000
                # break
            }
            c { # Camp
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,14;$Host.UI.Write("");" "*3000
                # break
            }
            # Default {
            # }
        }
    }

    # below is run if Q quit is chosen in any location
    Set-JSON
    Clear-Host
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
    Draw_Player_Window_and_Stats
}

#
# PLACE FUNCTIONS ABOVE HERE
#

#
# check for save data first
#
if (Test-Path -Path .\PS-RPG.json) {
    do {
        Clear-Host
        # display current saved file info
        Import-JSON
        Set_Variables
        Draw_Player_Window_and_Stats
        Draw_Inventory
        do {
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,35;$Host.UI.Write("");" "*105
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,35;$Host.UI.Write("")
            Write-Color -NoNewLine "`r`nPS-RPG.json ","save data found. Load saved data?"," [Y/N/E]" -Color Magenta,DarkYellow,Green
            $Load_Save_Data_Choice = Read-Host " "
            $Load_Save_Data_Choice = $Load_Save_Data_Choice.Trim()
        } until ($Load_Save_Data_Choice -ieq "y" -or $Load_Save_Data_Choice -ieq "n" -or $Load_Save_Data_Choice -ieq "e")
        if ($Load_Save_Data_Choice -ieq "e") {
            Write-Color -NoNewLine "`r`nExiting ","PS-RPG","." -Color DarkYellow,Magenta,DarkYellow
            Exit
        }
        if ($Load_Save_Data_Choice -ieq "y") {
            Import-JSON
            Set_Variables
            Clear-Host
            Draw_Player_Window_and_Stats
        }
        if ($Load_Save_Data_Choice -ieq "n") {
            do {
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,35;$Host.UI.Write("")
                Write-Color -NoNewLine "`r`nStart a new game?"," [Y/N/E]" -Color Magenta,Green
                $Start_A_New_Game = Read-Host " "
                $Start_A_New_Game = $Start_A_New_Game.Trim()
            } until ($Start_A_New_Game -ieq "y" -or $Start_A_New_Game -ieq "n" -or $Start_A_New_Game -ieq "e")
            if ($Start_A_New_Game -ieq "y") {
                # new game
                Create_Character
            }
        }
    } until ($Load_Save_Data_Choice -ieq "y" -or $Start_A_New_Game -ieq "y" -or $Start_A_New_Game -ieq "e")
} else {
    # no JSON file found
    Create_Character
}
if ($Load_Save_Data_Choice -ieq "e" -or $Start_A_New_Game -ieq "e") {
    Write-Color -NoNewLine "`r`nQuitting ","PS-RPG","." -Color DarkYellow,Magenta,DarkYellow
    Exit
}

#
# first thing after character creation / loading saved data
#
# main loop
do {
    do {
        Set-JSON # save JSON
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
        Write-Color -NoNewLine "H", "unt, ","T","ravel, ","V","isit a building, or look at your ","I","nventory? ", "[H/T/V/I]" -Color Green,DarkYellow,Green,DarkYellow,Green,DarkYellow,Green,DarkYellow,Green
        $Hunt_Or_Inventory = Read-Host " "
        $Hunt_Or_Inventory = $Hunt_Or_Inventory.Trim()
    } until ($Hunt_Or_Inventory -ieq "h" -or $Hunt_Or_Inventory -ieq "t" -or $Hunt_Or_Inventory -ieq "v" -or $Hunt_Or_Inventory -ieq "i" -or $Hunt_Or_Inventory -ieq "info")
    switch ($Hunt_Or_Inventory) {
        h {
            Set-JSON # save JSON
            Random_Mob
            Fight_Or_Run
        }
        t {
            Travel
        }
        v {
            Visit_A_Building
        }
        i {
            Clear-Host
            Draw_Player_Window_and_Stats
            Inventory_Choice
        }
        info {
            Game_Info
        }
        # Default {}
    }
} while ($true)


