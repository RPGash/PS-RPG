<#
ToDo
----

- BUGS
    - 
    
- TEST
    - 
    
- NEXT
    - buy items in the Anvil & Blade shop
    - add spells
    - add item equipment drops from mob loot
    - add equipment that can be equipped?
        armour protection, stat bonuses/buffs etc.
    - add types of damage  e.g. physical, elemental etc.
    - add some quests in the Tavern
        mob kills, fetch quest, item quest
        add more quests
    - add some quests in other locations
    - change "you are low on health/mana" message to
        if less than 25%/50% = "you are running low/very low on health/mana"
        if 50% or above = no message?
    - different message types for
        heals? kills? buffs etc.
    - consider changing mob critical rate/damage to from fixed 20%/20% to specific % for different mobs
    - Game_Information [ongoing] an info page available after starting the game. still to add...
        damage calculation = damage * (damage / (damage + armour)),
        escape chance,
        critical hit chance,

- KNOWN ISSUES
    - if a player purchases one drink and gains its buff, kills mobs until one kill left before it drops (not necessarily one but the closer to zero the better the exploit), they can go buy a second drink (buff) and it will extend the original buff for another full duration rather than the first buff expiring after one more fight. both buffs last the full duration. in other words getting a "free" buff.
#>


#
# install / import PSWriteColor module (if not installed)
#
Function Install_PSWriteColor {
    $PSWriteColor_Online_Version = Find-Module -Name "PSWriteColor"
    Write-Host "PSWriteColor module is not installed." -ForegroundColor Red
    Write-Output "`r`nThis game requires a PowerShell module called PSWriteColor to be installed."
    Write-Output "It allows the game to use coloured console output text for a better experience."
    Write-Output "The module will install as the Current User Scope and does NOT require Admin credentials."
    Write-Output "`r`nMore info about the module can be found from the below links if you"
    Write-Output "wish to research it before deciding to install it on your system."
    Write-Output "`r`nAuthor              - Przemyslaw Klys"
    Write-Output "PowerShell Gallery  - https://www.powershellgallery.com/packages/PSWriteColor/$($PSWriteColor_Online_Version.Version)"
    Write-Output "GitHub project site - https://github.com/EvotecIT/PSWriteColor"
    Write-Output "More info           - https://evotec.xyz/hub/scripts/pswritecolor/"
    $Install_Module_Check = Read-Host "`r`nDo you want to allow the PSWriteColor module to be installed? [Y/N]"
    if (-not($Install_Module_Check -ieq "y")) {
        Write-Host "`r`nThe PSWriteColor module was NOT installed." -ForegroundColor Red
        Write-Host "Run the script again if you change your mind."
        Write-Host ""
        Exit
    }
    Write-Host "Installing PSWriteColor module version $($PSWriteColor_Online_Version.Version)"
    Write-Output "Install path will be $ENV:USERPROFILE\Documents\WindowsPowerShell\Modules\"
    Install-Module -Name "PSWriteColor" -Scope CurrentUser -Confirm:$false -Force
    $PSWriteColor_Installed = Get-Module -Name "PSWriteColor" -ListAvailable
    if ($PSWriteColor_Installed) {
        Write-Host "PSWriteColor module is installed." -ForegroundColor Green
        $PSWriteColor_Installed
        Write-Output "`r`nImporting PSWriteColor module."
        Import-Module -Name "PSWriteColor"
        $PSWriteColor_Installed_Version = Get-Module -Name "PSWriteColor" -ListAvailable
        if ($PSWriteColor_Installed_Version) {
            Write-Host "PSWriteColor module version $($PSWriteColor_Installed_Version.Version) imported." -ForegroundColor Green
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
# import JSON game data
#
Function Import_JSON {
    $Script:Import_JSON = (Get-Content ".\PS-RPG.json" -Raw | ConvertFrom-Json)
}

#
# save data back to JSON file
#
Function Save_JSON {
    if (-not(Test-Path -Path "$ENV:userprofile\My Drive\PS-RPG\error.log")) {
        New-Item -Path "$ENV:userprofile\My Drive\PS-RPG\error.log" -ItemType File -Force | Out-Null
    }
    # Implement a retry mechanism with a delay
    $maxRetries = 5
    $retryDelaySeconds = 1
    
    for ($retry = 1; $retry -le $maxRetries; $retry++) {
        try {
            ($Script:Import_JSON | ConvertTo-Json -depth 32) | Set-Content ".\PS-RPG.json" -ErrorAction Stop
            # If successful, Break out of the loop
            # Add-Content -Path "$ENV:userprofile\My Drive\PS-RPG\error.log" -value "Success attempt #$($retry)" # leave in
            Break
        } catch {
            Add-Content -Path "$ENV:userprofile\My Drive\PS-RPG\error.log" -value "Error attempt #$($retry) $($_.Exception.Message)" # leave in
            if ($retry -lt $maxRetries) {
                Add-Content -Path "$ENV:userprofile\My Drive\PS-RPG\error.log" -value "Retrying $($retryDelaySeconds)s" # leave in
                Start-Sleep -Seconds $retryDelaySeconds # leave in
            } else {
                Add-Content -Path "$ENV:userprofile\My Drive\PS-RPG\error.log" -value "Failed $($maxRetries) attempts" # leave in
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
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 2,4;$Host.UI.Write("======")
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
    # $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,11;$Host.UI.Write("")
}

Function Draw_Game_Information_Banner {
    Write-Color "+--------------------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
    Write-Color "| Game Information                                                                                                                     |" -Color DarkGray
    Write-Color "+--------------------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
    $Game_Information_PSObjects = $Import_JSON.Game_Information.PSObject.Properties.name
    $Script:Game_Info_Tab_Array = New-Object System.Collections.Generic.List[System.Object]
    Write-Color -NoNewLine "|" -Color DarkGray
    foreach ($Game_Info_Object in $Game_Information_PSObjects) {
        if ($Import_JSON.Game_Information.$Game_Info_Object -eq $Game_Info_Object.Substring(0,1)) { # -eq to get exact case match rather than any case but only in first position
            $Game_Info_Letter = $Import_JSON.Game_Information.$Game_Info_Object
            $Game_Info_Rest_of_Word = $Game_Info_Object.Substring(1)
            if ($Game_Info_Page_Choice -ieq $Game_Info_Letter) {
                Write-Color -NoNewLine " $Game_Info_letter","$Game_Info_Rest_of_Word ","|" -Color Green,White,DarkGray
            } else {
                Write-Color -NoNewLine " $Game_Info_letter","$Game_Info_Rest_of_Word |" -Color Green,DarkGray
            }
        } else { # search for case sensitive match in tab name - but only works if there is only one upper case latter word that matches single letter (e.g. not "Shop Stats" and "S")
        [System.String]$myString | Out-Null
        $myString = $Game_Info_Object
        $Game_Info_Letter_Position = $($myString.LastIndexOf($Import_JSON.Game_Information.$Game_Info_Object))
            $Game_Info_Beginning_of_Word = $Game_Info_Object.Substring(0,$Game_Info_Letter_Position)
            $Game_Info_Letter = $Import_JSON.Game_Information.$Game_Info_Object
            $Game_Info_Letter_Position = $Game_Info_Letter_Position + 1
            $Game_Info_Rest_of_Word = $Game_Info_Object.Substring($Game_Info_Letter_Position,($game_info_object | Measure-Object -Character).Characters-$Game_Info_Letter_Position)
            if ($Game_Info_Page_Choice -ieq $Game_Info_Letter) {
                Write-Color -NoNewLine " $Game_Info_Beginning_of_Word","$Game_Info_Letter","$Game_Info_Rest_of_Word ","|" -Color White,Green,White,DarkGray
            } else {
                Write-Color -NoNewLine " $Game_Info_Beginning_of_Word","$Game_Info_Letter","$Game_Info_Rest_of_Word |" -Color DarkGray,Green,DarkGray
            }
        }
        $Game_Info_Tab_Array.Add($Game_Info_Letter)
    }
    Write-Color "`n+--------------------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
    $Script:Game_Info_Tab_Array_String = $Game_Info_Tab_Array -join "/"
}

Function Game_Information {
    Clear-Host
    Draw_Game_Information_Banner
    do {
        do {
            # bit of a hack to clear the screen when exiting the tutorial but still show the game info page
            if ($Tutorial_Choice -ieq "e") {
                $Game_Info_Page_Choice = "" # resets page tab colour to DarkGray
                Clear-Host
                Draw_Game_Information_Banner
                $Script:Tutorial_Choice = ""
            }
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
            Write-Color -NoNewLine "Select ","[$Game_Info_Tab_Array_String]" -Color DarkYellow,Green
            $Game_Info_Page_Choice = Read-Host " "
            $Script:Game_Info_Page_Choice = $Game_Info_Page_Choice.Trim()
        } until ($Game_Info_Page_Choice -in $Game_Info_Tab_Array -or $Game_Info_Page_Choice -ieq "e")
        switch ($Game_Info_Page_Choice) {
            e { # exit
                Clear-Host
                break
            }
            i { # info
                Clear-Host
                Draw_Game_Information_Banner
                $PSScriptRoot_Padding = " "*(83 - ($PSScriptRoot | Measure-Object -Character).Characters)
                if (-not(Test-Path ".\PS-RPG_version.txt")) {
                    $PSRPG_Version_File_Missing = "PS-RPG_version.txt missing!"
                    $PSRPG_Version_File_Missing_Padding = ""
                } else {
                    $PSRPG_Version_File_Missing_Padding = " "*27
                }
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "| Welcome to ","PS-RPG",", my 1st RPG text adventure written in PowerShell.                                                                  |" -Color DarkGray,Magenta,DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "| Absolutely ","NO ","info, personal or otherwise, is collected or sent anywhere or to anybody.                                              |" -Color DarkGray,Red,DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "| All the ","PS-RPG ","games files are stored your ","$PSScriptRoot"," folder$PSScriptRoot_Padding|" -Color DarkGray,Magenta,DarkGray,Cyan,DarkGray
                Write-Color "| which is where you have run the game from. They include:                                                                             |" -Color DarkGray
                Write-Color "| The main PowerShell script            : ","PS-RPG.ps1","                                                                                   |" -Color DarkGray,Cyan,DarkGray
                # Write-Color "| ASCII art for death messages          : ","ASCII.txt","                                                                                    |" -Color DarkGray,Cyan,DarkGray
                Write-Color "| A JSON file that stores all game info : ","PS-RPG.json ","(e.g. Locations, Mobs, NPCs and Character Stats etc.)                            |" -Color DarkGray,Cyan,DarkGray
                Write-Color "| PS-RPG version file                   : ","PS-RPG_version.txt"," (updates with GitHub commits) ","$PSRPG_Version_File_Missing","$PSRPG_Version_File_Missing_Padding                 |" -Color DarkGray,Cyan,DarkGray,Red,DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "| Player input options appear in ","Green ","e.g. ","[Y/N/E/I] ","would be ","yes/no/exit/inventory", "                                                   |" -Color DarkGray,Green,DarkGray,Green,DarkGray,Green,DarkGray
                Write-Color "| Enter the single character then hit Enter to confirm the choice.                                                                     |" -Color DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "|"," WARNING - Quitting the game unexpectedly may cause lose of data.","                                                                     |" -Color DarkGray,Cyan,DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "|"," NOTE:"," If you running this game from a location that has an online backup active e.g. Google Drive or OneDrive,                       |" -Color DarkGray,DarkYellow,DarkGray
                Write-Color "|       game saves will take longer due to the file being in use while syncing, so will appear to be slow when the screen refreshes.   |" -Color DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "+--------------------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
            }
            s { # stats
                Clear-Host
                Draw_Game_Information_Banner
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "| ","Page not implemented yet","                                                                                               |" -Color DarkGray,Red,DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "| sub menu items here...                                                                                                       |" -Color DarkGray
                Write-Color "| MOB STATS | Quest Stats | ????? |                                                                                                    |" -Color DarkGray
                Write-Color "+--------------------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
                Write-Color "| sub sub menu per location ???                                                                                                 |" -Color DarkGray
                Write-Color "| Location 1                                                                                                                  |" -Color DarkGray
                Write-Color "| Mob name | Killed | total xp? |                                                                                            |" -Color DarkGray
                Write-Color "| Rat      | 4      | 840                                                                                                     |" -Color DarkGray
                Write-Color "| Wolf     | 12     | 1236                                                                                                      |" -Color DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "| mob stats | QUESTS STATS | ????? |                                                                                                    |" -Color DarkGray
                Write-Color "+--------------------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
                Write-Color "| quest | completed | ?????                                                                                                     |" -Color DarkGray
                Write-Color "| Rat...      4                                                                                                                |" -Color DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "+--------------------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
            }
            p { # PSWriteColor
                Clear-Host
                Draw_Game_Information_Banner
                $PSWriteColor_Online_Version = Get-Module -Name "PSWriteColor" -ListAvailable
                $PSWriteColor_Name = (Get-Module -Name "PSWriteColor" -ListAvailable | Select-Object Name).Name
                $PSWriteColor_Name_Padding = " "*(113 - ($PSWriteColor_Name | Measure-Object -Character).Characters)
                $PSWriteColor_Author = (Get-Module -Name "PSWriteColor" -ListAvailable | Select-Object Author).Author
                $PSWriteColor_Author_Padding = " "*(113 - ($PSWriteColor_Author | Measure-Object -Character).Characters)
                $PSWriteColor_Copyright = (Get-Module -Name "PSWriteColor" -ListAvailable | Select-Object Copyright).Copyright
                $PSWriteColor_Copyright_Padding = " "*(113 - ($PSWriteColor_Copyright | Measure-Object -Character).Characters)
                $PSWriteColor_Description = (Get-Module -Name "PSWriteColor" -ListAvailable | Select-Object Description).Description
                $PSWriteColor_ModuleBase = (Get-Module -Name "PSWriteColor" -ListAvailable | Select-Object ModuleBase).ModuleBase
                $PSWriteColor_ModuleBase_Padding = " "*(113 - ($PSWriteColor_ModuleBase | Measure-Object -Character).Characters)
                $PSWriteColor_ProjectURI = (Get-Module -Name "PSWriteColor" -ListAvailable | Select-Object ProjectUri).ProjectURI
                $PSWriteColor_ProjectURI_Padding = " "*(112 - ($PSWriteColor_ProjectURI | Measure-Object -Character).Characters)
                $PSWriteColor_Version = (Get-Module -Name "PSWriteColor" -ListAvailable | Select-Object Version).Version
                $PSWriteColor_Version_Padding = " "*(113 - ($PSWriteColor_Version | Measure-Object -Character).Characters)
                $PSWriteColor_Description_Line1 = $PSWriteColor_Description.Substring($PSWriteColor_Description.IndexOf('.')+1).trim()
                $PSWriteColor_Description_Line1_Padding = " "*(113 - ($PSWriteColor_Description_Line1 | Measure-Object -Character).Characters)
                $PSWriteColor_Description_Line2 = $PSWriteColor_Description.Substring(0,$PSWriteColor_Description.IndexOf('.')+1).trim()
                $PSWriteColor_Description_Line2_Padding = " "*(113 - ($PSWriteColor_Description_Line2 | Measure-Object -Character).Characters)
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "| The PSWriteColor PowerShell module used by this game is written by Przemyslaw Klys and is required in order to play the game.        |" -Color DarkGray
                Write-Color "| If you can see this message, then it has installed and imported successfully.                                                        |" -Color DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "| ","Name             :"," $PSWriteColor_Name $PSWriteColor_Name_Padding|" -Color DarkGray,DarkYellow,DarkGray
                Write-Color "| ","Author           :"," $PSWriteColor_Author $PSWriteColor_Author_Padding|" -Color DarkGray,DarkYellow,DarkGray
                Write-Color "| ","Copyright        :"," $PSWriteColor_Copyright $PSWriteColor_Copyright_Padding|" -Color DarkGray,DarkYellow,DarkGray
                Write-Color "| ","Description      :"," $PSWriteColor_Description_Line1 $PSWriteColor_Description_Line1_Padding|" -Color DarkGray,DarkYellow,DarkGray
                Write-Color "|                    $PSWriteColor_Description_Line2 $PSWriteColor_Description_Line2_Padding|" -Color DarkGray
                Write-Color "| ","Installed Path   :"," $PSWriteColor_ModuleBase $PSWriteColor_ModuleBase_Padding","|" -Color DarkGray,DarkYellow,Cyan,DarkGray
                Write-Color "| ","Version          :"," $PSWriteColor_Version $PSWriteColor_Version_Padding|" -Color DarkGray,DarkYellow,DarkGray
                Write-Color "| ","Project URI       :"," $PSWriteColor_ProjectURI $PSWriteColor_ProjectURI_Padding","|" -Color DarkGray,DarkYellow,Cyan,DarkGray
                Write-Color "| ","PowerShell Gallery:"," https://www.powershellgallery.com/packages/PSWriteColor/$($PSWriteColor_Online_Version.Version)","                                                    |" -Color DarkGray,DarkYellow,Cyan,DarkGray
                Write-Color "| ","More info at      :"," https://evotec.xyz/hub/scripts/pswritecolor","                                                                      |" -Color DarkGray,DarkYellow,Cyan,DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "| If you want to remove the PSWriteColor module from your system, quit the game, then run the following command in a console window:   |" -Color DarkGray
                Write-Color "| ","Uninstall-Module -Name PSWriteColor","                                                                                                  |" -Color DarkGray,DarkCyan,DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "| You can confirm if the module has been removed by running the below command. There should be no results when run.                    |" -Color DarkGray
                Write-Color "| ","Get-Module -Name PSWriteColor -ListAvailable","                                                                                         |" -Color DarkGray,DarkCyan,DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "+--------------------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
            }
            l { # my links
                Clear-Host
                Draw_Game_Information_Banner
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "| ","My GitHub PS-RPG URL:"," https://github.com/RPGash/PS-RPG ","(make sure you downloaded it only from this link)                             |" -Color DarkGray,DarkYellow,Cyan,DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "| ","My Website URL      :"," https://RPG-ash.online ","                                                                                        |" -Color DarkGray,DarkYellow,Cyan,DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "+--------------------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
            }
            o { # random
                Clear-Host
                Draw_Game_Information_Banner
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "| ","ASCII art:     "," https://asciiart.website"," (arrows)                                                                                         |" -Color DarkGray,DarkYellow,Cyan,DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "| ","ASCII art:     "," https://ascii.co.uk/art"," (RIP screens)                                                                                     |" -Color DarkGray,DarkYellow,Cyan,DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "| ","ASCII designer:"," https://asciiflow.com","                                                                                                     |" -Color DarkGray
                Write-Color "|                                                                                                                                      |" -Color DarkGray
                Write-Color "+--------------------------------------------------------------------------------------------------------------------------------------+" -Color DarkGray
            }
            t { # tutorial
                Tutorial
                Clear-Host
                $Game_Info_Page_Choice = ""
                Draw_Game_Information_Banner
            }
            Default {}
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
                if ($Import_JSON.Items.$Inventory_Item_Name.Name -ilike "*health potion*") {
                    $Script:Selectable_ID_Highlight = "DarkCyan"
                    $Script:Selectable_Name_Highlight = "DarkCyan"
                }
            }
            Mana {
                if ($Import_JSON.Items.$Inventory_Item_Name.Name -ilike "*mana potion*") {
                    $Script:Selectable_ID_Highlight = "DarkCyan"
                    $Script:Selectable_Name_Highlight = "DarkCyan"
                }
            }
            HealthMana {
                if ($Import_JSON.Items.$Inventory_Item_Name.Name -ilike "*mana potion*" -or $Import_JSON.Items.$Inventory_Item_Name.Name -ilike "*health potion*") {
                    $Script:Selectable_ID_Highlight = "DarkCyan"
                    $Script:Selectable_Name_Highlight = "DarkCyan"
                }
            }
            Junk {
                if ($Import_JSON.Items.$Inventory_Item_Name.IsJunk -eq $true) {
                    $Anvil_Choice_Sell_Junk_Array.Add($Import_JSON.Items.$Inventory_Item_Name.Name)
                    $Script:Anvil_Choice_Sell_Junk_GoldValue += ($Import_JSON.Items.$Inventory_Item_Name.GoldValue * $Import_JSON.Items.$Inventory_Item_Name.Quantity) 
                    $Script:Anvil_Choice_Sell_Junk_Quantity += $Import_JSON.Items.$Inventory_Item_Name.Quantity
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
Function Update_Variables {
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
    $Script:Gold                     = $Import_JSON.Character.Gold
    $Script:Character_Level          = $Import_JSON.Character.Level
    $Script:Total_XP                 = $Import_JSON.Character.Total_XP
    $Script:XP_TNL                   = $Import_JSON.Character.XP_TNL
    # sets current Location
    $All_Locations                   = $Import_JSON.Locations.PSObject.Properties.Name
    foreach ($Single_Location in $All_Locations) {
        if ($Import_JSON.Locations.$Single_Location.Current_Location -ieq "true") {
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
        Save_JSON
        Import_JSON
        Update_Variables
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
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,31;$Host.UI.Write("")
        Write-Color "  You have also learned ", "x skills","." -Color DarkGray,White,DarkGray
        # Start-Sleep -Seconds 2 # leave in (shows multiple levels slowly)
    } until ($XP_Difference -gt 0)
}

#
# create character
#
Function Create_Character {
    Copy-Item -Path .\PS-RPG_new_game.json -Destination .\PS-RPG.json
    Import_JSON
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
                            $Random_Character_Name_Count += 1
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
                } until ($Character_Name_Confirm -ieq "y" -or $Character_Name_Confirm -ieq "n" -or $Character_Name_Confirm -ieq "e")
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
                if ($Character_Class -ieq "Mage") {$ClassRaceInfoColours1 = $ClassRaceInfoColours2 = "Green"}
                if ($Character_Class -ieq "Rogue") {$ClassRaceInfoColours3 = $ClassRaceInfoColours4 = "Green"}
                if ($Character_Class -ieq "Cleric") {$ClassRaceInfoColours5 = $ClassRaceInfoColours6 = "Green"}
                if ($Character_Class -ieq "Warrior") {$ClassRaceInfoColours7 = $ClassRaceInfoColours8 = "Green"}
                if ($Character_Race -ieq "Elf") {$ClassRaceInfoColours9 = $ClassRaceInfoColours10 = "Green"}
                if ($Character_Race -ieq "Orc") {$ClassRaceInfoColours11 = $ClassRaceInfoColours12 = "Green"}
                if ($Character_Race -ieq "Dwarf") {$ClassRaceInfoColours13 = $ClassRaceInfoColours14 = "Green"}
                if ($Character_Race -ieq "Human") {$ClassRaceInfoColours15 = $ClassRaceInfoColours16 = "Green"}
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
            } until ($Character_Class -ieq "m" -or $Character_Class -ieq "r" -or $Character_Class -ieq "c" -or $Character_Class -ieq "w")
            switch ($Character_Class) {
                m { $Character_Class = "Mage" }
                r { $Character_Class = "Rogue" }
                c { $Character_Class = "Cleric" }
                w { $Character_Class = "Warrior" }
            }
            do {
                Write-Color -NoNewLine "You have chosen a ", "$Character_Class ", "for your Character Class, is this correct? ", "[Y/N/E]" -Color DarkYellow,Blue,DarkYellow,Green
                $Character_Class_Confirm = Read-Host " "
            } until ($Character_Class_Confirm -ieq "y" -or $Character_Class_Confirm -ieq "n" -or $Character_Class_Confirm -ieq "e")
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
            } until ($Character_Race -ieq "e" -or $Character_Race -ieq "o" -or $Character_Race -ieq "d" -or $Character_Race -ieq "h")
            switch ($Character_Race) {
                e { $Character_Race = "Elf";$A_AN = "an" }
                o { $Character_Race = "Orc";$A_AN = "an" }
                d { $Character_Race = "Dwarf";$A_AN = "a" }
                h { $Character_Race = "Human";$A_AN = "a" }
            }
            do {
                Write-Color -NoNewLine "You have chosen $A_AN ", "$Character_Race ", "for your Character Race, is this correct? ", "[Y/N/E]" -Color DarkYellow,Blue,DarkYellow,Green
                $Character_Race_Confirm = Read-Host " "
            } until ($Character_Race_Confirm -ieq "y" -or $Character_Race_Confirm -ieq "n" -or $Character_Race_Confirm -ieq "e")
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
    Save_JSON
    #
    # set JSON class stats
    #
    if ($Character_Class -ieq "Mage") {
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
    if ($Character_Class -ieq "Rogue") {
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
    if ($Character_Class -ieq "Cleric") {
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
    if ($Character_Class -ieq "Warrior") {
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
    $Import_JSON.Character_Creation = $true
    Save_JSON
    Import_JSON
    Update_Variables
    Clear-Host
    Draw_Player_Window_and_Stats
}

#
# tutorial
#
Function Tutorial_Exit {
    for ($Position = 17; $Position -lt 36; $Position++) { # clear some lines from previous widow
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
    }
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
    Write-Color "  You have chosen to exit the tutorial." -Color DarkGray
    Write-Color "  You can always start the tutorial again later from the 'info' menu." -Color DarkGray
    do {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
        Write-Color -NoNewLine "E","xit ","[E]" -Color Green,DarkYellow,Green
        $Tutorial_Choice = Read-Host " "
        $Script:Tutorial_Choice = $Tutorial_Choice.Trim()
    } until ($Tutorial_Choice -ieq "e")
    Break
}
Function Tutorial {
    Clear-Host
    $Script:Info_Banner = "Tutorial"
    Draw_Info_Banner
do {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
        Write-Color -NoNewLine "Would you like to start the tutorial? ","[Y/N]" -Color DarkYellow,Green
        $Tutorial_Choice = Read-Host " "
        $Tutorial_Choice = $Tutorial_Choice.Trim()
    } until ($Tutorial_Choice -ieq "y" -or $Tutorial_Choice -ieq "n")
    if ($Tutorial_Choice -ieq "y") { # Tutorial - Welcome
        do {
            $Script:Info_Banner = "Tutorial - Welcome"
            Draw_Info_Banner
            Write-Color "  Welcome to the tutorial." -Color DarkGray
            Write-Color "  This is a simple tutorial to help you get started with the game." -Color DarkGray
            Write-Color "  You will be guided through the basics of the game and how to play." -Color DarkGray
            Write-Color "  Press '","C","' to ","C","ontinue the tutorial or '","E","' to ","E","xit at any time, then hit the enter key to confirm." -Color DarkGray,Green,DarkGray,Green,DarkGray,Green,DarkGray,Green,DarkGray
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
            Write-Color -NoNewLine "C","ontinue or ","E","xit ","[C/E]" -Color Green,DarkYellow,Green,DarkYellow,Green
            $Tutorial_Choice = Read-Host " "
        $Tutorial_Choice = $Tutorial_Choice.Trim()
        } until ($Tutorial_Choice -ieq "c" -or $Tutorial_Choice -ieq "e")
        if ($Tutorial_Choice -ieq "e") {
            Tutorial_Exit
        }
        if ($Tutorial_Choice -ieq "c") { # Tutorial - Choice prompt
            $Script:Info_Banner = "Tutorial - Choice prompt"
            Draw_Info_Banner
            for ($Position = 18; $Position -lt 21; $Position++) { # clear some lines from previous widow
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
            }
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
            Write-Color "  You should already be familar with the choice prompt by now." -Color Cyan
            Write-Color "  It always appears at the bottom of the screen." -Color Cyan
            $host.UI.RawUI.ForegroundColor = "Cyan"
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 16,22;$Host.UI.Write("     .")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 16,23;$Host.UI.Write("      .")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 16,24;$Host.UI.Write("   . ;.")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 16,25;$Host.UI.Write("   .;")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 16,26;$Host.UI.Write("    ;;.")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 16,27;$Host.UI.Write("  ;.;;")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 16,28;$Host.UI.Write("  ;;;;.")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 16,29;$Host.UI.Write("  ;;;;;")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 16,30;$Host.UI.Write("  ;;;;;")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 16,31;$Host.UI.Write("  ;;;;;")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 16,32;$Host.UI.Write("  ;;;;;")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 16,33;$Host.UI.Write("..;;;;;..")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 16,34;$Host.UI.Write(" ':::::' ")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 16,35;$Host.UI.Write("   ':' ")
            do {
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                Write-Color -NoNewLine "C","ontinue or ","E","xit ","[C/E]" -Color Green,DarkYellow,Green,DarkYellow,Green
                $Tutorial_Choice = Read-Host " "
                $Tutorial_Choice = $Tutorial_Choice.Trim()
            } until ($Tutorial_Choice -ieq "c" -or $Tutorial_Choice -ieq "e")
            if ($Tutorial_Choice -ieq "e") {
                Tutorial_Exit
            }
            if ($Tutorial_Choice -ieq "c") { # Tutorial - Player stats
                $Script:Info_Banner = "Tutorial - Player stats"
                Draw_Player_Window_and_Stats
                Draw_Info_Banner
                    for ($Position = 18; $Position -lt 36; $Position++) { # clear some lines from previous widow
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                }
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                Write-Color "  The window in the top left corner of the screen shows your player info and stats." -Color Cyan
                $host.UI.RawUI.ForegroundColor = "Cyan"
                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,5;$Host.UI.Write( "    .")
                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,6;$Host.UI.Write( "  .;;............ ..")
                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,7;$Host.UI.Write( ".;;;;::::::::::::..")
                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,8;$Host.UI.Write(" ':;;:::::::::::: . .")
                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,9;$Host.UI.Write("   ':")
                do {
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                    Write-Color -NoNewLine "C","ontinue or ","E","xit ","[C/E]" -Color Green,DarkYellow,Green,DarkYellow,Green
                    $Tutorial_Choice = Read-Host " "
                    $Tutorial_Choice = $Tutorial_Choice.Trim()
                } until ($Tutorial_Choice -ieq "c" -or $Tutorial_Choice -ieq "e")
                if ($Tutorial_Choice -ieq "e") {
                    Tutorial_Exit
                }
                if ($Tutorial_Choice -ieq "c") { # Tutorial - Mob stats
                    Clear-Host
                    $Script:TutorialMob = $true
                    Get_Random_Mob
                    $Script:TutorialMob = $false
                    Draw_Mob_Window_and_Stats
                    $Script:Info_Banner = "Tutorial - Mob stats"
                    Draw_Info_Banner
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                    Write-Color "  The window in the top middle of the screen shows the mobs info and stats." -Color Cyan
                    $host.UI.RawUI.ForegroundColor = "Cyan"
                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 68,13;$Host.UI.Write(".")
                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 66,14;$Host.UI.Write(".:;:.")
                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 66,16;$Host.UI.Write(" ;;; ")
                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 66,15;$Host.UI.Write(" ;;; ")
                    do {
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                        Write-Color -NoNewLine "C","ontinue or ","E","xit ","[C/E]" -Color Green,DarkYellow,Green,DarkYellow,Green
                        $Tutorial_Choice = Read-Host " "
                        $Tutorial_Choice = $Tutorial_Choice.Trim()
                    } until ($Tutorial_Choice -ieq "c" -or $Tutorial_Choice -ieq "e")
                    if ($Tutorial_Choice -ieq "e") {
                        Tutorial_Exit
                    }
                    if ($Tutorial_Choice -ieq "c") { # Tutorial - Visit map
                        Clear-Host
                        Draw_Town_Map
                        $Script:Info_Banner = "Tutorial - Visit map"
                        Draw_Info_Banner
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                        Write-Color "  The top middle of the screen can also show buildings you can visit in a location." -Color Cyan
                        $host.UI.RawUI.ForegroundColor = "Cyan"
                        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 81,13;$Host.UI.Write(".")
                        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 79,14;$Host.UI.Write(".:;:.")
                        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 79,15;$Host.UI.Write(" ;;; ")
                        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 79,16;$Host.UI.Write(" ;;; ")
                        do {
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                            Write-Color -NoNewLine "C","ontinue or ","E","xit ","[C/E]" -Color Green,DarkYellow,Green,DarkYellow,Green
                            $Tutorial_Choice = Read-Host " "
                            $Tutorial_Choice = $Tutorial_Choice.Trim()
                        } until ($Tutorial_Choice -ieq "c" -or $Tutorial_Choice -ieq "e")
                        if ($Tutorial_Choice -ieq "e") {
                            Tutorial_Exit
                        }
                        if ($Tutorial_Choice -ieq "c") { # Tutorial - Quest log
                            Clear-Host
                            $Script:Info_Banner = "Tutorial - Quest log"
                            Draw_Info_Banner
                            $host.UI.RawUI.ForegroundColor = "DarkGray"
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,0;$Host.UI.Write("+---------------------------------+-------------+")
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,1;$Host.UI.Write("|                                 |             |")
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,2;$Host.UI.Write("+---------------------------------+-------------+")
                            for ($Position = 3; $Position -lt 13; $Position++) {
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,$Position;$Host.UI.Write("|                                 |             |")
                            }
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,13;$Host.UI.Write("+---------------------------------+-------------+")
                            $host.UI.RawUI.ForegroundColor = "White"
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 58,1;$Host.UI.Write("Quest Log")
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,1;$Host.UI.Write("Status")
                            $host.UI.RawUI.ForegroundColor = "DarkGray"
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 58,3;$Host.UI.Write("Sick Elder")
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 58,4;$Host.UI.Write("Rat infestation")
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 58,5;$Host.UI.Write("The Lost Artifact")
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 58,6;$Host.UI.Write("Obsidian Heart")
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 58,7;$Host.UI.Write("Mapping the Wildlands")
                            $host.UI.RawUI.ForegroundColor = "DarkYellow"
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,3;$Host.UI.Write("In Progress")
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,4;$Host.UI.Write("Available")
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,5;$Host.UI.Write("Hand-In")
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,6;$Host.UI.Write("Available")
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,7;$Host.UI.Write("Completed")
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                            Write-Color "  As well as your quest log." -Color Cyan
                            $host.UI.RawUI.ForegroundColor = "Cyan"
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 97,13;$Host.UI.Write(".")
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 95,14;$Host.UI.Write(".:;:.")
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 95,15;$Host.UI.Write(" ;;; ")
                            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 95,16;$Host.UI.Write(" ;;; ")
                            do {
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                Write-Color -NoNewLine "C","ontinue or ","E","xit ","[C/E]" -Color Green,DarkYellow,Green,DarkYellow,Green
                                $Tutorial_Choice = Read-Host " "
                                $Tutorial_Choice = $Tutorial_Choice.Trim()
                            } until ($Tutorial_Choice -ieq "c" -or $Tutorial_Choice -ieq "e")
                            if ($Tutorial_Choice -ieq "e") {
                                Tutorial_Exit
                            }
                            if ($Tutorial_Choice -ieq "c") { # Tutorial - Inventory
                                Clear-Host
                                $Script:Info_Banner = "Tutorial - Inventory"
                                Draw_Info_Banner
                                $host.UI.RawUI.ForegroundColor = "DarkGray"
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 105,0;$Host.UI.Write("+--+---------------------+-------+")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 105,1;$Host.UI.Write("|  |                     |       |")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 105,2;$Host.UI.Write("+--+---------------------+-------+")
                                for ($Position = 3; $Position -lt 7; $Position++) {
                                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 105,$Position;$Host.UI.Write("|  |                     |       |")
                                }
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 105,7;$Host.UI.Write("+--+---------------------+-------+")
                                $host.UI.RawUI.ForegroundColor = "White"
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,1;$Host.UI.Write("ID")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 110,1;$Host.UI.Write("Inventory")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 126,1;$Host.UI.Write("Qty")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 132,1;$Host.UI.Write("Value")
                                $host.UI.RawUI.ForegroundColor = "DarkGray"
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 110,3;$Host.UI.Write("Mana Potion")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 110,4;$Host.UI.Write("Wolf Hides")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 110,5;$Host.UI.Write("Sharp Cat Teeth")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 110,6;$Host.UI.Write("Rat Tails")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 107,3;$Host.UI.Write("6")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,4;$Host.UI.Write("14")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 107,5;$Host.UI.Write("8")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 107,6;$Host.UI.Write("9")
                                $host.UI.RawUI.ForegroundColor = "White"
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 128,3;$Host.UI.Write("1")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 128,4;$Host.UI.Write("5")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 128,5;$Host.UI.Write("8")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 128,6;$Host.UI.Write("2")
                                $host.UI.RawUI.ForegroundColor = "White"
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 132,3;$Host.UI.Write("5")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 132,4;$Host.UI.Write("15")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 132,5;$Host.UI.Write("8")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 132,6;$Host.UI.Write("2")
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                Write-Color "  The window on the right of the screen shows your inventory." -Color Cyan
                                $host.UI.RawUI.ForegroundColor = "Cyan"
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 83,2;$Host.UI.Write("                .")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 83,3;$Host.UI.Write(" .. ............;;.")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 83,4;$Host.UI.Write("  ..::::::::::::;;;;.")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 83,5;$Host.UI.Write(". . ::::::::::::;;:'")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 83,6;$Host.UI.Write("                :'")
                                do {
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                    Write-Color -NoNewLine "C","ontinue or ","E","xit ","[C/E]" -Color Green,DarkYellow,Green,DarkYellow,Green
                                    $Tutorial_Choice = Read-Host " "
                                    $Tutorial_Choice = $Tutorial_Choice.Trim()
                                } until ($Tutorial_Choice -ieq "c" -or $Tutorial_Choice -ieq "e")
                                if ($Tutorial_Choice -ieq "e") {
                                    Tutorial_Exit
                                }
                                if ($Tutorial_Choice -ieq "c") { # Tutorial - Travel
                                    Clear-Host
                                    $Script:Info_Banner = "Tutorial - Travel"
                                    Draw_Info_Banner
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                    Write-Color "  The Travel area shows which locations you can move between." -Color Cyan
                                    Write-Color ""
                                    Write-Color " ,---------------------------------------------------------." -Color DarkYellow
                                    Write-Color "(_\  +-----------------+  +--------------+  +-------------+ \" -Color DarkYellow
                                    Write-Color "   | |    Home ","T","own    |  |  The ","F","orest  |  |  The ","R","iver  | |" -Color DarkYellow,Green,DarkYellow,Green,DarkYellow,Green,DarkYellow
                                    Write-Color "   | |                 |  |              |  |             | |" -Color DarkYellow
                                    Write-Color "   | | Mend & Mana     |  |              |  |             | |" -Color DarkYellow
                                    Write-Color "   | |                 |  |              |  |             | |" -Color DarkYellow
                                    Write-Color "   | | Anvil & Blade   |  |              |  |             | |" -Color DarkYellow
                                    Write-Color "   | |                 |  |            <------>           | |" -Color DarkYellow
                                    Write-Color "   | |             <------------>        |  |             | |" -Color DarkYellow
                                    Write-Color "   | |   Tavern        |  |  ????????    |  |  ????????   | |" -Color DarkYellow
                                    Write-Color "  _| +-----------------+  +--------------+  +-------------+ |" -Color DarkYellow
                                    Write-Color " (_/________________________________________________________/" -Color DarkYellow
                                    $host.UI.RawUI.ForegroundColor = "Cyan"
                                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 62,23;$Host.UI.Write("    .")
                                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 62,24;$Host.UI.Write("  .;;............ ..")
                                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 62,25;$Host.UI.Write(".;;;;::::::::::::..")
                                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 62,26;$Host.UI.Write(" ':;;:::::::::::: . .")
                                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 62,27;$Host.UI.Write("   ':")
                                    do {
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                        Write-Color -NoNewLine "C","ontinue or ","E","xit ","[C/E]" -Color Green,DarkYellow,Green,DarkYellow,Green
                                        $Tutorial_Choice = Read-Host " "
                                        $Tutorial_Choice = $Tutorial_Choice.Trim()
                                    } until ($Tutorial_Choice -ieq "c" -or $Tutorial_Choice -ieq "e")
                                    if ($Tutorial_Choice -ieq "e") {
                                        Tutorial_Exit
                                    }
                                    if ($Tutorial_Choice -ieq "c") { # Tutorial - Combat
                                        Clear-Host
                                        $Script:Info_Banner = "Tutorial - Combat"
                                        Draw_Info_Banner
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                        Write-Color "  Here is where all the combat info is displayed." -Color Cyan
                                        Write-Color ""
                                        Write-Color "  Successfully ","critically ","wack the ","Rat ","for ","7 ","damage." -Color DarkGray,Red,DarkGray,Blue,DarkGray,Red,DarkGray
                                        Write-Color ""
                                        Write-Color "  You killed the ","Rat ","and gained ","160 XP!" -Color DarkGray,Blue,DarkGray,Cyan
                                        Write-Color "  The ","Rat ","dropped the following items:" -Color DarkGray,Blue,DarkGray
                                        Write-Color "  14 Gold" -Color DarkGray
                                        Write-Color "  1x Rat Tails" -Color DarkGray
                                        Write-Color "  1x Rat Guts" -Color DarkGray
                                        Write-Color "  1x Random Loot #1" -Color DarkGray
                                        Write-Color "  1x Random Loot #3" -Color DarkGray
                                        Write-Color "  1x Random Loot #5" -Color DarkGray
                                        Write-Color ""
                                        Write-Color "  Congratulations! ","You gained ","1 ","level. You are now level ","5." -Color Cyan,DarkGray,White,DarkGray,White
                                        $host.UI.RawUI.ForegroundColor = "Cyan"
                                        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 62,23;$Host.UI.Write("    .")
                                        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 62,24;$Host.UI.Write("  .;;............ ..")
                                        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 62,25;$Host.UI.Write(".;;;;::::::::::::..")
                                        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 62,26;$Host.UI.Write(" ':;;:::::::::::: . .")
                                        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 62,27;$Host.UI.Write("   ':")
                                        do {
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                            Write-Color -NoNewLine "E","xit ","[E]" -Color Green,DarkYellow,Green
                                            $Tutorial_Choice = Read-Host " "
                                            $Tutorial_Choice = $Tutorial_Choice.Trim()
                                        } until ($Tutorial_Choice -ieq "e")
                                        if ($Tutorial_Choice -ieq "e") {
                                            $Import_JSON.Tutorial_Complete = $true
                                            Save_JSON
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    } else {
        $Tutorial_Choice = $false
    }
}

#
# introduction tasks
#
Function Draw_Introduction_Tasks {
    # only draw if not fully completed all tasks
    if ($Import_JSON.Introduction_Tasks.In_Progress -eq $true) {
        $Tick = ([char]8730)
        if ($Import_JSON.Introduction_Tasks.Tick_Visit_Home -eq $true)                 { $Tick_Visit_Home              = $Tick }
        if ($Import_JSON.Introduction_Tasks.Tick_Recover_Health_and_Mana -eq $true)    { $Tick_Recover_Health_and_Mana = $Tick }
        if ($Import_JSON.Introduction_Tasks.Tick_Visit_the_Tavern -eq $true)           { $Tick_Visit_the_Tavern        = $Tick }
        if ($Import_JSON.Introduction_Tasks.Tick_Accept_a_Quest -eq $true)             { $Tick_Accept_a_Quest          = $Tick }
        if ($Import_JSON.Introduction_Tasks.Tick_Kill_2_Rats -eq $true)                { $Tick_Kill_2_Rats             = $Tick }
        if ($Import_JSON.Introduction_Tasks.Tick_Hand_in_Completed_Quest -eq $true)    { $Tick_Hand_in_Completed_Quest = $Tick }
        if ($Import_JSON.Introduction_Tasks.Tick_View_Inventory -eq $true)             { $Tick_View_Inventory          = $Tick }
        if ($Import_JSON.Introduction_Tasks.Tick_Visit_Mend_and_Mana -eq $true)        { $Tick_Visit_Mend_and_Mana     = $Tick }
        if ($Import_JSON.Introduction_Tasks.Tick_Purchase_a_Potion -eq $true)          { $Tick_Purchase_a_Potion       = $Tick }
        if ($Import_JSON.Introduction_Tasks.Tick_Go_Hunting -eq $true)                 { $Tick_Go_Hunting              = $Tick }
        if ($Import_JSON.Introduction_Tasks.Tick_Travel_to_another_Location -eq $true) {
            $Tick_Travel_to_another_Location = $Tick
            $Import_JSON.Introduction_Tasks.In_Progress = $false
            Save_JSON
        } else { $Tick_Travel_to_another_Location = " " }
        $host.UI.RawUI.ForegroundColor = "DarkGray"
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,21;$Host.UI.Write("+----------------------------------+")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,22;$Host.UI.Write("|                                  |")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,23;$Host.UI.Write("+----------------------------------+")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,24;$Host.UI.Write("| [ ] Visit Home                   |")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,25;$Host.UI.Write("| [ ] Recover Health and Mana      |")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,26;$Host.UI.Write("| [ ] Visit the Tavern             |")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,27;$Host.UI.Write("| [ ] Accept a Quest               |")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,28;$Host.UI.Write("| [ ] Kill 2 Rats (Cellar quest)   |")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,29;$Host.UI.Write("| [ ] Hand in your completed Quest |")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,30;$Host.UI.Write("| [ ] View your Inventory          |")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,31;$Host.UI.Write("| [ ] Visit the Mend & Mana        |")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,32;$Host.UI.Write("| [ ] Purchase a Potion            |")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,33;$Host.UI.Write("| [ ] Go Hunting                   |")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,34;$Host.UI.Write("| [ ] Travel to another Location   |")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 106,35;$Host.UI.Write("+----------------------------------+")
        $host.UI.RawUI.ForegroundColor = "White"
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 108,22;$Host.UI.Write("Introduction Tasks")
        if ($Import_JSON.Introduction_Tasks.In_Progress -eq $false) {
            $host.UI.RawUI.ForegroundColor = "Green"
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 127,22;$Host.UI.Write([char]8730+" Complete")
        }
        $host.UI.RawUI.ForegroundColor = "Green"
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 109,24;$Host.UI.Write("$Tick_Visit_Home")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 109,25;$Host.UI.Write("$Tick_Recover_Health_and_Mana")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 109,26;$Host.UI.Write("$Tick_Visit_the_Tavern")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 109,27;$Host.UI.Write("$Tick_Accept_a_Quest")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 109,28;$Host.UI.Write("$Tick_Kill_2_Rats")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 109,29;$Host.UI.Write("$Tick_Hand_in_Completed_Quest")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 109,30;$Host.UI.Write("$Tick_View_Inventory")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 109,31;$Host.UI.Write("$Tick_Visit_Mend_and_Mana")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 109,32;$Host.UI.Write("$Tick_Purchase_a_Potion")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 109,33;$Host.UI.Write("$Tick_Go_Hunting")
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 109,34;$Host.UI.Write("$Tick_Travel_to_another_Location")
    }
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
# displays inventory (top right)
#
Function Draw_Inventory {
    if ($Import_JSON.Locations.'Home Town'.Location_Options.Travel -eq $true -and $Import_JSON.Introduction_Tasks.Tick_Accept_a_Quest -eq $true -and $Import_JSON.Introduction_Tasks.Tick_View_Inventory -eq $false) {
        $Import_JSON.Introduction_Tasks.Tick_View_Inventory = $true
        Draw_Introduction_Tasks
        Save_JSON
    }
    $Inventory_Items_Name_Array = New-Object System.Collections.Generic.List[System.Object]
    $Inventory_Items_Gold_Value_Array = New-Object System.Collections.Generic.List[System.Object]
    $Inventory_Items_Info_Array = New-Object System.Collections.Generic.List[System.Object]
    $Script:Inventory_Item_Names = $Import_JSON.Items.PSObject.Properties.Name | Sort-Object
    foreach ($Inventory_Item_Name in $Inventory_Item_Names) {
        if ($Import_JSON.Items.$Inventory_Item_Name.Quantity -gt 0) {
            $Inventory_Items_Name_Array.Add($Import_JSON.Items.$Inventory_Item_Name.Name.Length)
            $Inventory_Items_Gold_Value_Array.Add(($Import_JSON.Items.$Inventory_Item_Name.GoldValue | Measure-Object -Character).Characters)
            $Inventory_Items_Info_Array.Add(($Import_JSON.Items.$Inventory_Item_Name.Info | Measure-Object -Character).Characters)
        }
    }
    # if there are no items in the inventory, set window values so it still draws correctly
    if ($Inventory_Items_Name_Array.Count -eq 0) {
        $Inventory_Items_Name_Array.Add($Import_JSON.Items.$Inventory_Item_Name.Name.Length)
        $Inventory_Items_Gold_Value_Array.Add("1")
        $Inventory_Items_Info_Array.Add("4")
        $Inventory_Is_Empty = $true
    } else {
        $Inventory_Is_Empty = $false
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
    # get max item info length
    $Inventory_Items_Info_Array_Max_Length = ($Inventory_Items_Info_Array | Measure-Object -Maximum).Maximum
    # calculate top and bottom info width
    $Inventory_Box_Info_Width_Top_Bottom = "-"*($Inventory_Items_Info_Array_Max_Length + 2)
    # calculate middle info width
    $Inventory_Box_Info_Width_Middle = " "*($Inventory_Items_Info_Array_Max_Length - 3)
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 106,0;$Host.UI.Write("")
    Write-Color "+--+$Inventory_Box_Name_Width_Top_Bottom+$Inventory_Box_Gold_Value_Width_Top_Bottom+$Inventory_Box_Info_Width_Top_Bottom+" -Color DarkGray
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 106,1;$Host.UI.Write("")
    Write-Color "|","ID","| ","Inventory","$Inventory_Box_Name_Width_Middle","Qty ","| ","Value","$Inventory_Box_Gold_Value_Width_Middle|"," Info","$Inventory_Box_Info_Width_Middle|" -Color DarkGray,White,DarkGray,White,DarkGray,White,DarkGray,White,DarkGray,White,DarkGray
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 106,2;$Host.UI.Write("")
    Write-Color "+--+$Inventory_Box_Name_Width_Top_Bottom+$Inventory_Box_Gold_Value_Width_Top_Bottom+$Inventory_Box_Info_Width_Top_Bottom+" -Color DarkGray
    $Position = 2
    foreach ($Inventory_Item_Name in $Inventory_Item_Names) {
        if ($Import_JSON.Items.$Inventory_Item_Name.Quantity -gt 0 -or $Inventory_Is_Empty -eq $true) {
            $Position += 1
            # padding for name length
            if ($Import_JSON.Items.$Inventory_Item_Name.Name.Length -lt $Inventory_Items_Name_Array_Max_Length) {
                $Name_Left_Padding = " "*($Inventory_Items_Name_Array_Max_Length - $Import_JSON.Items.$Inventory_Item_Name.Name.Length)
            } else {
                $Name_Left_Padding = ""
            }
            # padding for quantity
            if ($Import_JSON.Items.$Inventory_Item_Name.Quantity -lt 10) { # quantity less than 10 in inventory (1 digit so needs 2 padding)
                $Quantity_Left_Padding = "  " # less than 10 quantity (1 digit so needs 2 padding)
            } else {
                $Quantity_Left_Padding = " " # more than 9 quantity (2 digits so needs 1 padding)
            }
            # gold padding
            if (($Import_JSON.Items.$Inventory_Item_Name.GoldValue | Measure-Object -Character).Characters -le '5') {
                $Gold_Value_Right_Padding = " "*(6 - ($Import_JSON.Items.$Inventory_Item_Name.GoldValue | Measure-Object -Character).Characters)
                if ($Inventory_Items_Gold_Value_Array_Max_Length -gt 5 ) {
                    $Gold_Value_Right_Padding = " "*($Inventory_Items_Gold_Value_Array_Max_Length - ($Import_JSON.Items.$Inventory_Item_Name.GoldValue | Measure-Object -Character).Characters + 1)
                }
            } else {
                $Gold_Value_Right_Padding = " "*($Inventory_Items_Gold_Value_Array_Max_Length - ($Import_JSON.Items.$Inventory_Item_Name.GoldValue | Measure-Object -Character).Characters + 1)
            }
            #ID padding
            if (($Import_JSON.Items.$Inventory_Item_Name.ID | Measure-Object -Character).Characters -gt 1) { # if ID is a 2 digits (no extra padding)
                $ID_Number = "$($Import_JSON.Items.$Inventory_Item_Name.ID)"
            } else {
                $ID_Number = " $($Import_JSON.Items.$Inventory_Item_Name.ID)" # if ID is a single digit (1 extra padding)
            }
            # info padding
            if ($Import_JSON.Items.$Inventory_Item_Name.Info.Length -lt $Inventory_Items_Info_Array_Max_Length) {
                $Info_Right_Padding = " "*($Inventory_Items_Info_Array_Max_Length - $Import_JSON.Items.$Inventory_Item_Name.Info.Length)
            } else {
                $Info_Right_Padding = ""
            }
            Inventory_Highlight
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 106,$Position;$Host.UI.Write("")
            # if no items in inventory, else an actual item
            if ($Inventory_Is_Empty -eq $true) {
                Write-Color "|  | Inventory Empty |       |      |" -Color DarkGray
                $Inventory_Is_Empty = $false
                Break
            } else {
                Write-Color "|","$ID_Number","| ","$($Import_JSON.Items.$Inventory_Item_Name.Name)$Name_Left_Padding ",":", "$Quantity_Left_Padding$($Import_JSON.Items.$Inventory_Item_Name.Quantity) ","| ","$($Import_JSON.Items.$Inventory_Item_Name.GoldValue)$Gold_Value_Right_Padding","| $($Import_JSON.Items.$Inventory_Item_Name.Info)$Info_Right_Padding |" -Color DarkGray,$Selectable_ID_Highlight,DarkGray,$Selectable_Name_Highlight,DarkGray,White,DarkGray,White,DarkGray
            }
            $Script:Selectable_ID_Highlight = "DarkGray"
            $Script:Selectable_Name_Highlight = "DarkGray"
        }
    }
    $Position += 1
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 106,$Position;$Host.UI.Write("")
    Write-Color "+--+$Inventory_Box_Name_Width_Top_Bottom+$Inventory_Box_Gold_Value_Width_Top_Bottom+$Inventory_Box_Info_Width_Top_Bottom+" -Color DarkGray
}

# draws the shop potions in the shop window
# same as the Draw_Invenroty but no quantities
# quantity lines commented out in case i add them back in with a limit on how many that can be purchased.
# if quantities are added back in, then a GoldValueSell and GoldValueBuy will need to be added to the JSON file for each item
Function Draw_Shop_Potions {
    $Inventory_Items_Name_Array = New-Object System.Collections.Generic.List[System.Object]
    $Inventory_Items_Gold_Value_Array = New-Object System.Collections.Generic.List[System.Object]
    $Inventory_Items_Info_Array = New-Object System.Collections.Generic.List[System.Object]
    $Script:Inventory_Item_Names = $Import_JSON.Items.PSObject.Properties.Name | Sort-Object
    foreach ($Inventory_Item_Name in $Inventory_Item_Names) {
        if ($Import_JSON.Items.$Inventory_Item_Name."Mend & Mana" -eq $true) {
            $Inventory_Items_Name_Array.Add($Import_JSON.Items.$Inventory_Item_Name.Name.Length)
            $Inventory_Items_Gold_Value_Array.Add(($Import_JSON.Items.$Inventory_Item_Name.GoldValue | Measure-Object -Character).Characters)
            $Inventory_Items_Info_Array.Add(($Import_JSON.Items.$Inventory_Item_Name.Info | Measure-Object -Character).Characters)
        }
    }
    # if there are no items in the inventory, set window values so it still draws correctly
    if ($Inventory_Items_Name_Array.Count -eq 0) {
        $Inventory_Items_Name_Array.Add($Import_JSON.Items.$Inventory_Item_Name.Name.Length)
        $Inventory_Items_Gold_Value_Array.Add("1")
        $Inventory_Items_Info_Array.Add("4")
        $Inventory_Is_Empty = $true
    } else {
        $Inventory_Is_Empty = $false
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
    # $Inventory_Box_Name_Width_Top_Bottom = "-"*($Inventory_Items_Name_Array_Max_Length + 7)
    $Inventory_Box_Name_Width_Top_Bottom = "-"*($Inventory_Items_Name_Array_Max_Length + 2)
    # calculate middle name width
    $Inventory_Box_Name_Width_Middle = " "*($Inventory_Items_Name_Array_Max_Length - 7) # 5
    # get max item info length
    $Inventory_Items_Info_Array_Max_Length = ($Inventory_Items_Info_Array | Measure-Object -Maximum).Maximum
    # calculate top and bottom info width
    $Inventory_Box_Info_Width_Top_Bottom = "-"*($Inventory_Items_Info_Array_Max_Length + 2)
    # calculate middle info width
    $Inventory_Box_Info_Width_Middle = " "*($Inventory_Items_Info_Array_Max_Length - 3)
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 2,18;$Host.UI.Write("")
    # Write-Color "+--+$Inventory_Box_Name_Width_Top_Bottom+$Inventory_Box_Gold_Value_Width_Top_Bottom+$Inventory_Box_Info_Width_Top_Bottom+" -Color DarkGray
    Write-Color "+--+$Inventory_Box_Name_Width_Top_Bottom+$Inventory_Box_Gold_Value_Width_Top_Bottom+$Inventory_Box_Info_Width_Top_Bottom+" -Color DarkGray
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 2,19;$Host.UI.Write("")
    # Write-Color "|","ID","| ","Potions","$Inventory_Box_Name_Width_Middle","Qty ","| ","Value","$Inventory_Box_Gold_Value_Width_Middle|"," Info","$Inventory_Box_Info_Width_Middle|" -Color DarkGray,White,DarkGray,White,DarkGray,White,DarkGray,White,DarkGray,White,DarkGray
    Write-Color "|","ID","| ","Potions","$Inventory_Box_Name_Width_Middle | ","Value","$Inventory_Box_Gold_Value_Width_Middle|"," Info","$Inventory_Box_Info_Width_Middle|" -Color DarkGray,White,DarkGray,White,DarkGray,White,DarkGray,White,DarkGray,White,DarkGray
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 2,20;$Host.UI.Write("")
    # Write-Color "+--+$Inventory_Box_Name_Width_Top_Bottom+$Inventory_Box_Gold_Value_Width_Top_Bottom+$Inventory_Box_Info_Width_Top_Bottom+" -Color DarkGray
    Write-Color "+--+$Inventory_Box_Name_Width_Top_Bottom+$Inventory_Box_Gold_Value_Width_Top_Bottom+$Inventory_Box_Info_Width_Top_Bottom+" -Color DarkGray
    $Position = 20
    foreach ($Inventory_Item_Name in $Inventory_Item_Names) {
        if ($Import_JSON.Items.$Inventory_Item_Name."Mend & Mana" -eq $true) {
            # add potion ID to choice array
            $Elixir_Emporium_Potion_Letters_Array.Add($Import_JSON.Items.$Inventory_Item_Name.ID)
            $Position += 1
            # padding for name length
            if ($Import_JSON.Items.$Inventory_Item_Name.Name.Length -lt $Inventory_Items_Name_Array_Max_Length) {
                $Name_Left_Padding = " "*($Inventory_Items_Name_Array_Max_Length - $Import_JSON.Items.$Inventory_Item_Name.Name.Length)
            } else {
                $Name_Left_Padding = ""
            }
            # padding for quantity
            if ($Import_JSON.Items.$Inventory_Item_Name.Quantity -lt 10) { # quantity less than 10 in inventory (1 digit so needs 2 padding)
                $Quantity_Left_Padding = "  " # less than 10 quantity (1 digit so needs 2 padding)
            } else {
                $Quantity_Left_Padding = " " # more than 9 quantity (2 digits so needs 1 padding)
            }
            # gold padding
            if (($Import_JSON.Items.$Inventory_Item_Name.GoldValue | Measure-Object -Character).Characters -le '5') {
                $Gold_Value_Right_Padding = " "*(6 - ($Import_JSON.Items.$Inventory_Item_Name.GoldValue | Measure-Object -Character).Characters)
                if ($Inventory_Items_Gold_Value_Array_Max_Length -gt 5 ) {
                    $Gold_Value_Right_Padding = " "*($Inventory_Items_Gold_Value_Array_Max_Length - ($Import_JSON.Items.$Inventory_Item_Name.GoldValue | Measure-Object -Character).Characters + 1)
                }
            } else {
                $Gold_Value_Right_Padding = " "*($Inventory_Items_Gold_Value_Array_Max_Length - ($Import_JSON.Items.$Inventory_Item_Name.GoldValue | Measure-Object -Character).Characters + 1)
            }
            #ID padding
            if (($Import_JSON.Items.$Inventory_Item_Name.ID | Measure-Object -Character).Characters -gt 1) { # if ID is a 2 digits (no extra padding)
                $ID_Number = "$($Import_JSON.Items.$Inventory_Item_Name.ID)"
            } else {
                $ID_Number = " $($Import_JSON.Items.$Inventory_Item_Name.ID)" # if ID is a single digit (1 extra padding)
            }
            # info padding
            if ($Import_JSON.Items.$Inventory_Item_Name.Info.Length -lt $Inventory_Items_Info_Array_Max_Length) {
                $Info_Right_Padding = " "*($Inventory_Items_Info_Array_Max_Length - $Import_JSON.Items.$Inventory_Item_Name.Info.Length)
            } else {
                $Info_Right_Padding = ""
            }
            Inventory_Highlight
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 2,$Position;$Host.UI.Write("")
            # if no items in inventory, else an actual item
            if ($Inventory_Is_Empty -eq $true) {
                Write-Color "|  | Inventory Empty |       |      |" -Color DarkGray
                $Inventory_Is_Empty = $false
                Break
            } else {
                # Write-Color "|","$ID_Number","| ","$($Import_JSON.Items.$Inventory_Item_Name.Name)$Name_Left_Padding ",":", "$Quantity_Left_Padding$($Import_JSON.Items.$Inventory_Item_Name.Quantity) ","| ","$($Import_JSON.Items.$Inventory_Item_Name.GoldValue)$Gold_Value_Right_Padding","| $($Import_JSON.Items.$Inventory_Item_Name.Info)$Info_Right_Padding |" -Color DarkGray,$Selectable_ID_Highlight,DarkGray,$Selectable_Name_Highlight,DarkGray,White,DarkGray,White,DarkGray
                Write-Color "|","$ID_Number","| ","$($Import_JSON.Items.$Inventory_Item_Name.Name)$Name_Left_Padding ","| ","$($Import_JSON.Items.$Inventory_Item_Name.GoldValue)$Gold_Value_Right_Padding","| $($Import_JSON.Items.$Inventory_Item_Name.Info)$Info_Right_Padding |" -Color DarkGray,$Selectable_ID_Highlight,DarkGray,$Selectable_Name_Highlight,DarkGray,White,DarkGray,White,DarkGray
            }
            $Script:Selectable_ID_Highlight = "DarkGray"
            $Script:Selectable_Name_Highlight = "DarkGray"
        }
    }
    $Position += 1
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 2,$Position;$Host.UI.Write("")
    # Write-Color "+--+$Inventory_Box_Name_Width_Top_Bottom+$Inventory_Box_Gold_Value_Width_Top_Bottom+$Inventory_Box_Info_Width_Top_Bottom+" -Color DarkGray
    Write-Color "+--+$Inventory_Box_Name_Width_Top_Bottom+$Inventory_Box_Gold_Value_Width_Top_Bottom+$Inventory_Box_Info_Width_Top_Bottom+" -Color DarkGray
}

#
# sets and asks if a potion should be used
#
Function Inventory_Choice {
    $Script:Selectable_ID_Search = "not_set"
    $Script:Potion_IDs_Array = New-Object System.Collections.Generic.List[System.Object]
    $Potion_IDs_Array.Clear()
    Draw_Inventory
    # if health or mana is not at max - question is asked if one should be used
    $Script:Use_A_Potion = "" # reset so if max health is reached after using a potion, it"s not still set to "y" which causes a skipped turn when viewing the inventory a second time
    if (($Character_HealthCurrent -lt $Character_HealthMax) -or ($Character_ManaCurrent -lt $Character_ManaMax)) {
        $Enough_Health_Potions = "no"
        if ($Character_HealthCurrent -lt $Character_HealthMax) {
            $Script:Inventory_Item_Names = $Import_JSON.Items.PSObject.Properties.Name | Sort-Object
            foreach ($Inventory_Item_Name in $Inventory_Item_Names) {
                if ($Import_JSON.Items.$Inventory_Item_Name.Name -like "*health potion*" -and $Import_JSON.Items.$Inventory_Item_Name.Quantity -gt 0) {
                    $Enough_Health_Potions = "yes"
                    $Potion_IDs_Array.Add($Import_JSON.Items.$Inventory_Item_Name.ID)
                }
            }
        }
        $Enough_Mana_Potions = "no"
        if ($Character_ManaCurrent -lt $Character_ManaMax) {
            foreach ($Inventory_Item_Name in $Inventory_Item_Names) {
                if ($Import_JSON.Items.$Inventory_Item_Name.Name -like "*mana potion*" -and $Import_JSON.Items.$Inventory_Item_Name.Quantity -gt 0) {
                    $Enough_Mana_Potions = "yes"
                    $Potion_IDs_Array.Add($Import_JSON.Items.$Inventory_Item_Name.ID)
                }
            }
        }
        if ($Enough_Health_Potions -ieq "no" -and $Enough_Mana_Potions -ieq "no") {
        } else {
            do {
                $Script:Info_Banner = "Inventory"
                Draw_Info_Banner
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                if ($Enough_Health_Potions -ieq "yes" -and $Enough_Mana_Potions -ieq "no") {
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                    Write-Color -NoNewLine "  You are low on ","Health", "." -Color DarkGray,Green,DarkGray
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                    Write-Color -NoNewLine "Use a potion? ", "[Y/N]" -Color DarkYellow,Green
                    $Potion_Choice = "Health"
                    $Script:Selectable_ID_Search = "Health"
                } elseif ($Enough_Mana_Potions -ieq "yes" -and $Enough_Health_Potions -ieq "no") {
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
                    if ($Import_JSON.Items.$Inventory_Item_Name.ID -eq $Inventory_ID) {
                        $Script:Potion = $Import_JSON.Items.$Inventory_Item_Name
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
                Save_JSON
                Import_JSON
                Update_Variables
                Draw_Player_Window_and_Stats # redraws play stats to update health or mana values
                
                if ($In_Combat -eq $true){
                    Draw_Mob_Window_and_Stats
                    Draw_Inventory
                } else {
                    Draw_Inventory
                }
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("");" "*105
                Save_JSON
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
Function Get_Random_Mob {
    # $Script:Import_JSON = (Get-Content ".\PS-RPG.json" -Raw | ConvertFrom-Json)
    if ($TutorialMob -eq $true) { # tutorial example mob
        $Current_Location_Mob_Names = $Import_JSON.Locations."Home Town".Mobs.PSObject.Properties.Name
    } elseif ($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Is_Active -eq $true) { # Home Town Tavern rat quest is active
        $Current_Location = "Home Town"
        $Current_Location_Mob_Names = $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Mobs.PSObject.Properties.Name
    } else { # get mob from current location
        $Current_Location_Mob_Names = $Import_JSON.Locations.$Current_Location.Mobs.PSObject.Properties.Name
    }
    $Random_100 = Get-Random -Minimum 1 -Maximum 101
    if ($Random_100 -le 50) { # rare mob (10% of the time)
        $All_Rare_Mobs_In_Current_Location = @()
        $All_Rare_Mobs_In_Current_Location = New-Object System.Collections.Generic.List[System.Object]
        # loop though all mobs and add to array
        foreach ($Current_Location_Mob_Name in $Current_Location_Mob_Names) {
            if ($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Is_Active -eq $true) { # Home Town Tavern rat quest is active
                $Current_Location_Mob_Name = $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Mobs.$Current_Location_Mob_Name
                $Current_Location_Mob_Name = $Current_Location_Mob_Name.Name
                    # check if mob is rare
                    if ($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Mobs.$Current_Location_Mob_Name.Rare -ieq "yes") {
                        # check if current cellar room is room10 (only where the king should spawn)
                        if ($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.Room10.Current_Location -eq $true) {
                            $All_Rare_Mobs_In_Current_Location.Add($Current_Location_Mob_Name)
                        } else {
                            # if not room10, then add all rare mobs except the king
                            if ($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Mobs.$Current_Location_Mob_Name.Name -inotlike "*king*") {
                                $All_Rare_Mobs_In_Current_Location.Add($Current_Location_Mob_Name)
                            }
                        }
                    }
            } else {
                $Current_Location_Mob_Name = $Import_JSON.Locations.$Current_Location.Mobs.$Current_Location_Mob_Name
                $Current_Location_Mob_Name = $Current_Location_Mob_Name.Name
                    if ($Import_JSON.Locations.$Current_Location.Mobs.$Current_Location_Mob_Name.Rare -ieq "yes") {
                        $All_Rare_Mobs_In_Current_Location.Add($Current_Location_Mob_Name)
                    }
            }
        }
        # select random mob from all collected mobs in array
        $Random_Rare_Mob_In_Current_Location_ID = Get-Random -Minimum 0 -Maximum ($All_Rare_Mobs_In_Current_Location | Measure-Object).count # measure-object added because incorrect number when there is only one rare mob
        $Random_Rare_Mob_In_Current_Location_ID -= 1
        $Script:Selected_Mob = $All_Rare_Mobs_In_Current_Location[$Random_Rare_Mob_In_Current_Location_ID]
        if ($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Is_Active -eq $true) {
            $Script:Selected_Mob = $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Mobs.$Selected_Mob # get cellar mob object from JSON
        } else {
            $Script:Selected_Mob = $Import_JSON.Locations.$Current_Location.Mobs.$Selected_Mob # get current location mob object from JSON
        }
    } else { # "normal" mob (90% of the time)
        $All_None_Rare_Mobs_In_Current_Location = @()
        $All_None_Rare_Mobs_In_Current_Location = New-Object System.Collections.Generic.List[System.Object]
        # loop through all mobs and add to array
        foreach ($Current_Location_Mob_Name in $Current_Location_Mob_Names) {
            if ($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Is_Active -eq $true) { # Home Town Tavern rat quest is active
                $Current_Location_Mob_Name = $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Mobs.$Current_Location_Mob_Name
                $Current_Location_Mob_Name = $Current_Location_Mob_Name.Name
                    if ($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Mobs.$Current_Location_Mob_Name.Rare -ieq "no") {
                        $All_None_Rare_Mobs_In_Current_Location.Add($Current_Location_Mob_Name)
                    }
            } else {
                $Current_Location_Mob_Name = $Import_JSON.Locations.$Current_Location.Mobs.$Current_Location_Mob_Name
                $Current_Location_Mob_Name = $Current_Location_Mob_Name.Name
                    if ($Import_JSON.Locations.$Current_Location.Mobs.$Current_Location_Mob_Name.Rare -ieq "no") {
                        $All_None_Rare_Mobs_In_Current_Location.Add($Current_Location_Mob_Name)
                    }
            }
        }
        # select random mob from all collected mobs in array
        $Random_None_Rare_Mob_In_Current_Location_ID = Get-Random -Minimum 0 -Maximum ($All_None_Rare_Mobs_In_Current_Location | Measure-Object).count # measure-object added because incorrect number when there is only one rare mob
        $Random_None_Rare_Mob_In_Current_Location_ID -= 1
        $Script:Selected_Mob = $All_None_Rare_Mobs_In_Current_Location[$Random_None_Rare_Mob_In_Current_Location_ID]
        if ($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Is_Active -eq $true) {
            $Script:Selected_Mob = $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Mobs.$Selected_Mob # get cellar mob object from JSON
        } else {
            $Script:Selected_Mob = $Import_JSON.Locations.$Current_Location.Mobs.$Selected_Mob # get current location mob object from JSON
        }
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
Function Fight_or_Run {
    # import JSON game info
    Import_JSON
    $Continue_Fight = $false
    $First_Turn = $true
    do {
        Clear-Host
        Save_JSON
        Draw_Introduction_Tasks
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
        Draw_Player_Window_and_Stats
        Draw_Mob_Window_and_Stats
        $Script:Info_Banner = "Combat"
        Draw_Info_Banner
        Write-Color -NoNewLine "  You encounter a ","$($Selected_Mob.Name)" -Color DarkGray,Blue
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
        Write-Color -NoNewLine "Do you ","F", "ight or ","E","scape? ", "[F/E]" -Color DarkYellow,Green,DarkYellow,Green,DarkYellow,Green
        $Fight_or_Escape = Read-Host " "
        $Fight_or_Escape = $Fight_or_Escape.Trim()
    } until ($Fight_or_Escape -ieq "f" -or $Fight_or_Escape -ieq "e")
    if ($Fight_or_Escape -ieq "f") {
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
                        # player critically hits
                        $Random_Crit_Chance = Get-Random -Minimum 1 -Maximum 101
                        $Crit_Hit = ""
                        if ($Random_Crit_Chance -le 20) { # chance of critical hit - less than 20%
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
                            for ($Position = 18; $Position -lt 20; $Position++) { # clear some lines from previous widow
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                            }
                        } else {
                            for ($Position = 17; $Position -lt 20; $Position++) { # clear some lines from previous widow
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                            }
                        }
                        [System.Collections.ArrayList]$Random_Player_Hit_Verb = ("successfully","effectively","adeptly","masterfully","effortlessly","expertly","dexterously","deftly","nimbly","gracefully")
                        $Random_Player_Hit_Verb_Word = Get-Random -Input $Random_Player_Hit_Verb
                        [System.Collections.ArrayList]$Random_Player_Hit = ("cleave","slice","rend","scythe through","carve","lacerate","crush","smash","pound","wack","maul","pierce","impale","skewer","puncture","jab","thrust","hit")
                        $Random_Player_Hit_Word = Get-Random -Input $Random_Player_Hit
                        [System.Collections.ArrayList]$Random_Player_Hit_Health = ("health","hit points","damage","life")
                        $Random_Player_Hit_Health_Word = Get-Random -Input $Random_Player_Hit_Health
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                        Write-Color "  You $Random_Player_Hit_Verb_Word ",$Crit_Hit,"$Random_Player_Hit_Word the ","$($Selected_Mob.Name)"," for ","$Character_Hit_Damage ","$Random_Player_Hit_Health_Word." -Color DarkGray,Red,DarkGray,Blue,DarkGray,Red,DarkGray
                    } else {
                        for ($Position = 17; $Position -lt 20; $Position++) { # clear some lines from previous widow
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                        }
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                        $Get_Random_Player_Miss = Get-Random -Minimum 1 -Maximum 3
                        if ($Get_Random_Player_Miss -eq 1) {
                            [System.Collections.ArrayList]$Random_Player_Miss = ("sidesteps your attack","nimbly dodges your blow","creature ducks out of the way","weaves to avoid your strike","anticipates your move and you miss","dances away from danger","reacts quickly, evading your hit","reflexes are too fast and you miss","gracefully avoids your clumsy attack")
                            $Random_Player_Miss_Word = Get-Random -Input $Random_Player_Miss
                            Write-Color "  The ","$($Selected_Mob.Name) ","$Random_Player_Miss_Word." -Color DarkGray,Blue,DarkGray
                        } else {
                            [System.Collections.ArrayList]$Random_Player_Miss = ("Your swing misses the","Your attack falls short and you miss the","Your blow goes astray missing the","You fail to connect a hit on the","Your strike doesn't land on the","You hit nothing air missing the","A near miss on the","Your weapon whistles past the","The attack glances off the")
                            $Random_Player_Miss_Word = Get-Random -Input $Random_Player_Miss
                            Write-Color "  $Random_Player_Miss_Word ","$($Selected_Mob.Name)","." -Color DarkGray,Blue,DarkGray
                        }
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
                    # mob critically hits
                    $Random_Crit_Chance = Get-Random -Minimum 1 -Maximum 101
                    $Crit_Hit = ""
                    if ($Random_Crit_Chance -le 20) { # chance of critical hit - less than 20%
                        $Crit_Hit = $true
                        $Selected_Mob_Hit_Damage = [Math]::Round($Selected_Mob_Hit_Damage*20/100+$Selected_Mob_Hit_Damage)
                        $Crit_Hit = "critically "
                    }
                    [System.Collections.ArrayList]$Random_Mob_Hit_Verb = ("successfully","effectively","adeptly","masterfully","effortlessly","expertly","dexterously","deftly","nimbly","gracefully")
                    $Random_Mob_Hit_Verb_Word = Get-Random -Input $Random_Mob_Hit_Verb
                    [System.Collections.ArrayList]$Random_Mob_Hit = ("cleave","slice","rend","scythe through","carve","lacerate","crush","smash","pound","wack","maul","pierce","impale","skewer","puncture","jab","thrust","hit")
                    $Random_Mob_Hit_Word = Get-Random -Input $Random_Mob_Hit
                    [System.Collections.ArrayList]$Random_Mob_Hit_Health = ("health","hit points","damage","life")
                    $Random_Mob_Hit_Health_Word = Get-Random -Input $Random_Mob_Hit_Health
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("")
                    Write-Color "  The ","$($Selected_Mob.Name) ","$Random_Mob_Hit_Verb_Word ",$Crit_Hit,"$Random_Mob_Hit_Word you for ","$Selected_Mob_Hit_Damage ","$Random_Mob_Hit_Health_Word." -Color DarkGray,Blue,DarkGray,Red,DarkGray,Red,DarkGray
                    # adjust player health by damage amount
                    $Script:Character_HealthCurrent = $Character_HealthCurrent - $Selected_Mob_Hit_Damage
                    $Import_JSON.Character.Stats.HealthCurrent = $Character_HealthCurrent
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
                    Draw_Player_Window_and_Stats
                } else {
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,19;$Host.UI.Write("")
                    [System.Collections.ArrayList]$Random_Mob_Miss = (" swings and misses you","'s attack falls short and missing you","'s blow goes astray missing you"," fails to connect a hit on you","'s strike doesn't land on you"," hits nothing but air missing you","'s attack whistles past you ear","'s attack glances off you")
                    $Random_Mob_Miss_Word = Get-Random -Input $Random_Mob_Miss
                    Write-Color "  The ","$($Selected_Mob.Name)","$Random_Mob_Miss_Word." -Color DarkGray,Blue,DarkGray
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
                Save_JSON
                You_Died
                Read-Host
                exit
            }
            # if mob health is zero, display you killed mob message
            if ($Selected_Mob_HealthCurrent -eq 0) {
                if ($Import_JSON.Introduction_Tasks.In_Progress -eq $true -and $Import_JSON.Introduction_Tasks.Tick_Purchase_a_Potion -eq $true) {
                    # update introduction task and update Introduction Tasks window
                    $Import_JSON.Introduction_Tasks.Tick_Go_Hunting = $true
                }
                # update mob killed count in JSON
                if ($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Is_Active -eq $true) {
                    $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Mobs.$Selected_Mob_Name.Killed += 1
                    # if Introduction Tasks are still in progress, update the slow intro window Inventory with a tick
                    if ($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Mobs.$Selected_Mob_Name.Killed -ge 2) {
                        $Import_JSON.Introduction_Tasks.Tick_Kill_2_Rats = $true
                        Draw_Introduction_Tasks
                    }
                } else {
                    $Import_JSON.Locations."Home Town".Location_Options.Travel = $true
                    $Import_JSON.Locations.$Current_Location.Mobs.$Selected_Mob_Name.Killed += 1
                }
                Save_JSON
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,20;$Host.UI.Write("")
                Write-Color "  You killed the ","$($Selected_Mob.Name) ","and gained ","$($Selected_Mob.XP) XP","!" -Color DarkGray,Blue,DarkGray,Cyan,DarkGray
                # update xp
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
                                $Script:Import_JSON.Character.Gold = $Import_JSON.Character.Gold + $Looted_Gold
                                $Script:Gold = $Import_JSON.Character.Gold + $Looted_Gold
                                
                            } else { # add non-gold loot
                                # update non-gold items in inventory
                                $Current_Item_Quantity = $Import_JSON.Items.$Loot_Item.Quantity
                                if ($Current_Item_Quantity + $Selected_Mob.Loot.$Loot_Item -gt 99) {
                                    $Import_JSON.Items.$Loot_Item.Quantity = 99
                                    $Max_99_Items = "(MAX 99 items)"
                                } else {
                                    $Script:Import_JSON.Items.$Loot_Item.Quantity = ($Import_JSON.Items.$Loot_Item.Quantity += $Selected_Mob.Loot.$Loot_Item)
                                    $Max_99_Items = ""
                                }
                                $Looted_Items.Add("$($Selected_Mob.Loot.$Loot_Item)x $($Loot_Item) $MAX_99_Items")
                                Save_JSON
                            }
                        }
                    }
                    if ($Looted_Items -gt 0) {
                        Write-Color "  The ", "$($Selected_Mob.Name) ", "dropped the following items:" -Color DarkGray,Blue,DarkGray
                        Write-Color "  $($Looted_Items)" -Color DarkGray
                        Draw_Inventory
                        # if Introduction Tasks are still in progress, update the slow intro window Inventory with a tick
                        if ($Import_JSON.Introduction_Tasks.In_Progress -eq $true) {
                            $Import_JSON.Introduction_Tasks.Tick_View_Inventory = $true
                            Draw_Introduction_Tasks
                        }
                    } else {
                        Write-Color "  The ", "$($Selected_Mob.Name) ", "did not drop any loot." -Color DarkGray,Blue,DarkGray
                    }
                }
                # update mob kill count if quest related
                $Quest_Names = $Import_JSON.Quests.PSObject.Properties.Name
                foreach ($Quest_Name in $Quest_Names) {
                    $Quest_Name = $Import_JSON.Quests.$Quest_Name
                    if ($Selected_Mob_Name -ilike "*$($Quest_Name.Mob)*") {
                        $Quest_Name.Progress += 1
                        if ($Quest_Name.Progress -ge $Quest_Name.Progress_Max) {
                            $Quest_Name.Status = "Hand In"
                        }
                    }
                }
                # update player stats before level up to update gold and XP
                Update_Variables
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
                Draw_Player_Window_and_Stats
                # level up check
                if ($XP_TNL -lt 0) {
                    $Script:XP_Difference = $XP_TNL
                }
                if ($XP_TNL -le 0) {
                    Level_Up
                }
                # update player stats after level up to show stat buffs
                Save_JSON
                Import_JSON
                Update_Variables
                do {
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                    Write-Color -NoNewLine "C","ontinue ","[C]" -Color Green,DarkYellow,Green
                    $Continue_After_Fighting = Read-Host " "
                    $Continue_After_Fighting = $Continue_After_Fighting.Trim()
                } until ($Continue_After_Fighting -ieq "c")
                # mob killed so break out of Fight_or_Run loop (back down to main loop)
                Break
            }
            # ask continue fight question after mobs turn
            if ($Continue_Fight -eq $true) {
                do {
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                    Write-Color -NoNewLine "Continue to ","F", "ight or try and ","E","scape? ", "[F/E]" -Color DarkYellow,Green,DarkYellow,Green,DarkYellow,Green
                    $Continue_Fight_or_Escape = Read-Host " "
                    $Continue_Fight_or_Escape = $Continue_Fight_or_Escape.Trim()
                } until ($Continue_Fight_or_Escape -ieq "f" -or $Continue_Fight_or_Escape -ieq "e")
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,26;$Host.UI.Write("");" "*105
            }
            # try to escape (during combat)
            if ($Continue_Fight_or_Escape -ieq "e") {
                # escape formula = Player Q / (Player Q + (Mob Q / 3))
                $Random_Escape_100 = Get-Random -Minimum 1 -Maximum 101
                if ($Random_Escape_100 -le [Math]::Round($Character_Quickness/($Character_Quickness+($Selected_Mob_Quickness/3))*100)) {
                    Clear-Host
                    Draw_Introduction_Tasks
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
                    Draw_Player_Window_and_Stats
                    $Script:Info_Banner = "Combat"
                    Draw_Info_Banner
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                    Write-Color "  You escaped from the ","$($Selected_Mob.Name)","." -Color DarkGray,Blue,DarkGray
                } else {
                    for ($Position = 17; $Position -lt 18; $Position++) { # clear some lines from previous widow
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                    }
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                    Write-Color "  You failed to escape the ","$($Selected_Mob.Name)","!" -Color DarkGray,Blue,DarkGray
                    $Player_Turn = $false # keeps it the mobs turn after failing to escape
                }
            }
            $First_Turn = $false
        } until ($Continue_Fight_or_Escape -ieq "e")
        if ($Import_JSON.Character.Buffs.Duration -gt 0) {
            $Import_JSON.Character.Buffs.Duration -= 1
            Save_JSON
        }
        if ($Import_JSON.Character.Buffs.Duration -eq 0 -and $Import_JSON.Character.Buffs.Dropped -eq $false) {
            $Import_JSON.Character.Buffs.DrinksPurchased   = 0
            $Import_JSON.Character.Buffs.Dropped           = $true
            # blank set all stats back to original value (if buffed) and set all UnBuffed values back to zero
            $All_Player_Stats_Names = $Import_JSON.Character.Stats.PSObject.Properties.Name
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,33;$Host.UI.Write("")
            foreach ($All_Player_Stats_Name in $All_Player_Stats_Names) {
                if ($All_Player_Stats_Name -like "*UnBuffed*") {
                    $Player_UnBuffed_Stat_Name = $All_Player_Stats_Name
                    if ($Import_JSON.Character.Stats.$Player_UnBuffed_Stat_Name -gt 0) {
                        $Player_Stat = $Player_UnBuffed_Stat_Name.Substring(0,$Player_UnBuffed_Stat_Name.Length-8)
                        $Import_JSON.Character.Stats.$Player_Stat = $Import_JSON.Character.Stats.$Player_UnBuffed_Stat_Name
                        $Import_JSON.Character.Stats.$Player_UnBuffed_Stat_Name = 0
                        Write-Color "  Your $Player_Stat buff drop." -Color Cyan
                    }
                }
            }
            # update player stat back to original (pre-buffed)
            # $Import_JSON.Character.Stats.$Tavern_Drink_Bonus_Name = $Import_JSON.Character.Stats."$Tavern_Drink_Bonus_Name$UnBuffed"
            # update unbuffed stat back to zero
            # $Import_JSON.Character.Stats."$Tavern_Drink_Bonus_Name$UnBuffed" = 0
            Update_Variables
            Draw_Player_Window_and_Stats
        }
    }
    $Script:Escaped_from_Mob = $false
    if ($Fight_or_Escape -ieq "e") { # Escape before combat starts
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
        Write-Output "  You escaped from the $($Selected_Mob.Name)! (no combat)"
        Write-Output ""
        $Script:Escaped_from_Mob = $true
    }
    $Script:In_Combat = $false
}

#
# Travel
#
Function Travel {
    Clear-Host
    Draw_Introduction_Tasks
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
    Draw_Player_Window_and_Stats
    $Script:Info_Banner = "Travel"
    Draw_Info_Banner
    switch ($Current_Location) {
        "Home Town" {
            $Travel_Map_Town_Colour = "DarkYellow"
            $Travel_Map_The_Forest_Colour = "Green"
            $Travel_Map_The_River_Colour = "Green"
        }
        "The Forest" {
            $Travel_Map_Town_Colour = "Green"
            $Travel_Map_The_Forest_Colour = "DarkYellow"
            $Travel_Map_The_River_Colour = "Green"
        }
        'The River' {
            $Travel_Map_Town_Colour = "DarkYellow"
            $Travel_Map_The_Forest_Colour = "DarkYellow"
            $Travel_Map_The_River_Colour = "Green"
        }
        Default {}
    }
    Write-Color "  You can travel to the following locations:" -Color DarkGray
    # find all linked locations that you can travel to (not including your current location)
    $Script:All_Linked_Locations_Letters_Array = New-Object System.Collections.Generic.List[System.Object]
    $Script:Linked_Locations_Name_Array = New-Object System.Collections.Generic.List[System.Object]
    $Linked_Location_Names = $Import_JSON.Locations.$Current_Location.Linked_Locations.PSObject.Properties.Name
    foreach ($Linked_Location_Name in $Linked_Location_Names) {
        $Linked_Location_Letter = $Import_JSON.Locations.$Current_Location.Linked_Locations.$Linked_Location_Name
        if ($Linked_Location_Letter -eq $Linked_Location_Name.Substring(0,1)) { # -eq to get exact case match rather than any case but only in first position
            $Game_Info_Rest_of_Word = $Linked_Location_Name.Substring(1)
            Write-Color -NoNewLine "  $Linked_Location_Letter","$Game_Info_Rest_of_Word" -Color Green,White,DarkGray
        } else { # search for case sensitive match in tab name - but only works if there is only one upper case latter word that matches single letter (e.g. not "Shop Stats" and "S")
        $Linked_Location_Letter_Position = $($Linked_Location_Name.LastIndexOf($Linked_Location_Letter))
            $Game_Info_Beginning_of_Word = $Linked_Location_Name.Substring(0,$Linked_Location_Letter_Position)
            $Linked_Location_Letter_Position = $Linked_Location_Letter_Position + 1
            $Game_Info_Rest_of_Word = $Linked_Location_Name.Substring($Linked_Location_Letter_Position,($Linked_Location_Name | Measure-Object -Character).Characters-$Linked_Location_Letter_Position)
            Write-Color "  $Game_Info_Beginning_of_Word","$Linked_Location_Letter","$Game_Info_Rest_of_Word" -Color DarkGray,Green,DarkGray
        }
        $All_Linked_Locations_Letters_Array.Add($Linked_Location_Letter)
    }
    $All_Linked_Locations_Letters_Array_String = $All_Linked_Locations_Letters_Array -Join "/"
    $All_Linked_Locations_Letters_Array_String = $All_Linked_Locations_Letters_Array_String + "/E"
    Write-Color " ,---------------------------------------------------------." -Color DarkYellow
    Write-Color "(_\  +-----------------+  +--------------+  +-------------+ \" -Color DarkYellow
    Write-Color "   | |    Home ","T","own    |  |  The ","F","orest  |  |  The ","R","iver  | |" -Color DarkYellow,$Travel_Map_Town_Colour,DarkYellow,$Travel_Map_The_Forest_Colour,DarkYellow,$Travel_Map_The_River_Colour,DarkYellow
    Write-Color "   | |                 |  |              |  |             | |" -Color DarkYellow
    Write-Color "   | | Mend & Mana     |  |              |  |             | |" -Color DarkYellow
    Write-Color "   | |                 |  |              |  |             | |" -Color DarkYellow
    Write-Color "   | | Anvil & Blade   |  |              |  |             | |" -Color DarkYellow
    Write-Color "   | |                 |  |            <------>           | |" -Color DarkYellow
    Write-Color "   | |             <------------>        |  |             | |" -Color DarkYellow
    Write-Color "   | |   Tavern        |  |  ????????    |  |  ????????   | |" -Color DarkYellow
    Write-Color "  _| +-----------------+  +--------------+  +-------------+ |" -Color DarkYellow
    Write-Color " (_/________________________________________________________/" -Color DarkYellow
    do {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
        Write-Color -NoNewLine "Where do you want to travel to? ", "[$All_Linked_Locations_Letters_Array_String]" -Color DarkYellow,Green
        $Travel_Choice = Read-Host " "
        $Travel_Choice = $Travel_Choice.Trim()
    } until ($Travel_Choice -eq "E" -or $All_Linked_Locations_Letters_Array -match $Travel_Choice)
    switch ($Travel_Choice) {
        e { # exit
            for ($Position = 14; $Position -lt 35; $Position++) { # clear some lines from previous widow
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
            }
        }
        t { # Home Town
            $Import_JSON.Locations.$Current_Location.Current_Location = $false
            $Script:Current_Location = "Home Town"
            $Import_JSON.Locations."Home Town".Current_Location = $true
            for ($Position = 14; $Position -lt 35; $Position++) { # clear some lines from previous widow
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
            }
            Save_JSON
        }
        f { # The Forest
            # update old current location to false
            $Import_JSON.Locations.$Current_Location.Current_Location = $false
            $Script:Current_Location = "The Forest"
            # update new current location to true
            $Import_JSON.Locations."The Forest".Current_Location = $true
            for ($Position = 14; $Position -lt 35; $Position++) { # clear some lines from previous widow
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
            }
        }
        r { # The River
            $Import_JSON.Locations.$Current_Location.Current_Location = $false
            $Script:Current_Location = "The River"
            $Import_JSON.Locations."The River".Current_Location = $true
            for ($Position = 14; $Position -lt 35; $Position++) { # clear some lines from previous widow
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
            }
        }
        # Default {}
    }
    Save_JSON
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
    Draw_Player_Window_and_Stats
}

#
# draw Home Town map
#
Function Draw_Town_Map {
    $host.UI.RawUI.ForegroundColor = "DarkYellow"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,0;$Host.UI.Write( "+-----------------------------------------------+")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,1;$Host.UI.Write( "|                Home Town        +-----------+ |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,2;$Host.UI.Write( "|                                 | Anvil     | |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,3;$Host.UI.Write( "| +------+                        | & Blade   | |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,4;$Host.UI.Write( "| | Home |                        |           | |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,5;$Host.UI.Write( "| |      |    +--------------+    +-----------+ |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,6;$Host.UI.Write( "| |      |    |    Tavern    |                  |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,7;$Host.UI.Write( "| +------+    |              |                  |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,8;$Host.UI.Write( "|             |              |    +----------+  |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,9;$Host.UI.Write( "|             |              |    | Mend     |  |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,10;$Host.UI.Write("|             |              |    | & Mana   |  |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,11;$Host.UI.Write("|             |              |    +----------+  |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,12;$Host.UI.Write("|             +--------------+                  |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,13;$Host.UI.Write("+-----------------------------------------------+")
    $host.UI.RawUI.ForegroundColor = "White"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 73,1;$Host.UI.Write("Home Town") # Home Town
    $host.UI.RawUI.ForegroundColor = "Green"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,2;$Host.UI.Write("A") # Anvil & Blade
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 60,4;$Host.UI.Write("H") # Home
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 75,6;$Host.UI.Write("T") # Tavern
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,9;$Host.UI.Write("M") # Mend & Mana
    $host.UI.RawUI.ForegroundColor = "DarkGray" # set the foreground color back to original colour
}

# draw Cellar map
Function Draw_Cellar_Map {
                                                                                                                    # +-----------------------------------------------+
                                                                                                                    # |                 Tavern Cellar                 |
                                                                                                                    # |+-----+1+-----+ +-----+3+-----+4+-------------+|
                                                                                                                    # ||  1  +-+  2  | |  3  +-+  4  +-+          5  ||
                                                                                                                    # |+-----+2+--+--+ |     +4+-----+5+-------+     ||
                                                                                                                    # |          2|7   |     |                 |     ||
                                                                                                                    # |+-----+6+--+--+ |     + +-------------+ |     ||
                                                                                                                    # ||  6  +-+  7  | |     | |             | |     ||
                                                                                                                    # |+-----+7+--+--+ +--+--+ |             | +--+--+|
                                                                                                                    # |          7|8     3|9   |     10      |   5|11 |
                                                                                                                    # |        +--+--+8+--+--+9|           10| +--+--+|
                                                                                                                    # |        |  8  +-+  9  +-+10         11+-+ 11  ||
                                                                                                                    # |        +-----+9+-----+ +-------------+ +-----+|
                                                                                                                    # +-----------------------------------------------+
    $host.UI.RawUI.ForegroundColor = "DarkYellow"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,0;$Host.UI.Write( "+-----------------------------------------------+")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,1;$Host.UI.Write( "|                                               |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,2;$Host.UI.Write( "|                                               |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,3;$Host.UI.Write( "|                                               |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,4;$Host.UI.Write( "|                                               |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,5;$Host.UI.Write( "|                                               |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,6;$Host.UI.Write( "|                                               |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,7;$Host.UI.Write( "|                                               |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,8;$Host.UI.Write( "|                                               |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,9;$Host.UI.Write( "|                                               |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,10;$Host.UI.Write("|                                               |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,11;$Host.UI.Write("|                                               |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,12;$Host.UI.Write("|                                               |")
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 56,13;$Host.UI.Write("+-----------------------------------------------+")
    $host.UI.RawUI.ForegroundColor = "White"
    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 74,1;$Host.UI.Write("Tavern Cellar") # Tavern Cellar
    # Function for all rooms ecause they are called twice so not duplicating code
    Function Draw_Cellar_Quest_Room_1 {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 57,2;$Host.UI.Write("+-----+ ") # room 1
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 57,3;$Host.UI.Write("|  1  +-")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 57,4;$Host.UI.Write("+-----+ ")
        if ($Cellar_Quest_Current_Room -eq "1") {
            $host.UI.RawUI.ForegroundColor = "Green"
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,3;$Host.UI.Write("-") # door East
        }
    }
    Function Draw_Cellar_Quest_Room_2 {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,2;$Host.UI.Write(" +-----+ ") # room 2
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,3;$Host.UI.Write("-+  2  | ")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,4;$Host.UI.Write(" +-----+ ")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,5;$Host.UI.Write("    |    ")
        if ($Cellar_Quest_Current_Room -eq "2") {
            $host.UI.RawUI.ForegroundColor = "Green"
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,3;$Host.UI.Write("-") # door West
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 68,5;$Host.UI.Write("|") # door South
        }
    }
    Function Draw_Cellar_Quest_Room_3 {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 72,2;$Host.UI.Write(" +-----+ ") # room 3
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 72,3;$Host.UI.Write(" |  3  +-")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 72,4;$Host.UI.Write(" |     | ")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 72,5;$Host.UI.Write(" |     | ")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 72,6;$Host.UI.Write(" |     | ")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 72,7;$Host.UI.Write(" |     | ")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 72,8;$Host.UI.Write(" +--+--+ ")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 72,9;$Host.UI.Write("    |    ")
        if ($Cellar_Quest_Current_Room -eq "3") {
            $host.UI.RawUI.ForegroundColor = "Green"
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 80,3;$Host.UI.Write("-") # door East
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 76,9;$Host.UI.Write("|") # door South
        }
    }
    Function Draw_Cellar_Quest_Room_4 {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 80,2;$Host.UI.Write(" +-----+ ") # room 4
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 80,3;$Host.UI.Write("-+  4  +-")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 80,4;$Host.UI.Write(" +-----+ ")
        if ($Cellar_Quest_Current_Room -eq "4") {
            $host.UI.RawUI.ForegroundColor = "Green"
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 80,3;$Host.UI.Write("-") # door West
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 88,3;$Host.UI.Write("-") # door East
        }
    }
    Function Draw_Cellar_Quest_Room_5 {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 88,2;$Host.UI.Write( " +-------------+") # room 5
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 88,3;$Host.UI.Write( "-+          5  |")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 88,4;$Host.UI.Write( " +-------+     |")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 97,5;$Host.UI.Write(          "|     |")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 97,6;$Host.UI.Write(          "|     |")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 97,7;$Host.UI.Write(          "|     |")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 97,8;$Host.UI.Write(          "+--+--+")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 97,9;$Host.UI.Write(          "   |   ")
        if ($Cellar_Quest_Current_Room -eq "5") {
            $host.UI.RawUI.ForegroundColor = "Green"
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 88,3;$Host.UI.Write( "-") # door West
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 100,9;$Host.UI.Write("|") # door South
        }
    }
    Function Draw_Cellar_Quest_Room_6 {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 57,6;$Host.UI.Write("+-----+ ") # room 6
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 57,7;$Host.UI.Write("|eXit +-")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 57,8;$Host.UI.Write("+-----+ ")
        if ($Cellar_Quest_Current_Room -eq "6") {
            $host.UI.RawUI.ForegroundColor = "Green"
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,7;$Host.UI.Write("-") # door East
        }
    }
    Function Draw_Cellar_Quest_Room_7 {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,5;$Host.UI.Write("    |   ") # room 7
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,6;$Host.UI.Write(" +--+--+")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,7;$Host.UI.Write("-+  7  |")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,8;$Host.UI.Write(" +--+--+")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,9;$Host.UI.Write("    |   ")
        if ($Cellar_Quest_Current_Room -eq "7") {
            $host.UI.RawUI.ForegroundColor = "Green"
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 68,5;$Host.UI.Write("|") # door North
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,7;$Host.UI.Write("-") # door West
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 68,9;$Host.UI.Write("|") # door South
        }
    }
    Function Draw_Cellar_Quest_Room_8 {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,9;$Host.UI.Write( "    |    ") # room 8
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,10;$Host.UI.Write(" +--+--+ ")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,11;$Host.UI.Write(" |  8  +-")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 64,12;$Host.UI.Write(" +-----+ ")
        if ($Cellar_Quest_Current_Room -eq "8") {
            $host.UI.RawUI.ForegroundColor = "Green"
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 68,9;$Host.UI.Write( "|") # door North
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 72,11;$Host.UI.Write("-") # door East
        }
    }
    Function Draw_Cellar_Quest_Room_9 {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 72,9;$Host.UI.Write( "    |    ") # room 9
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 72,10;$Host.UI.Write(" +--+--+ ")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 72,11;$Host.UI.Write("-+  9  +-")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 72,12;$Host.UI.Write(" +-----+ ")
        if ($Cellar_Quest_Current_Room -eq "9") {
            $host.UI.RawUI.ForegroundColor = "Green"
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 76,9;$Host.UI.Write( "|") # door North
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 72,11;$Host.UI.Write("-") # door West
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 80,11;$Host.UI.Write("-") # door East
        }
    }
    Function Draw_Cellar_Quest_Room_10 {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 80,6;$Host.UI.Write( " +-------------+ ") # room 10
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 80,7;$Host.UI.Write( " |             | ")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 80,8;$Host.UI.Write( " |             | ")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 80,9;$Host.UI.Write( " |     10      | ")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 80,10;$Host.UI.Write(" |             | ")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 80,11;$Host.UI.Write("-+             +-")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 80,12;$Host.UI.Write(" +-------------+ ")
        if ($Cellar_Quest_Current_Room -eq "10") {
            $host.UI.RawUI.ForegroundColor = "Green"
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 80,11;$Host.UI.Write("-") # door West
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 96,11;$Host.UI.Write("-") # door East
        }
    }
    Function Draw_Cellar_Quest_Room_11 {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 96,9;$Host.UI.Write( "    |   ") # room 11
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 96,10;$Host.UI.Write(" +--+--+")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 96,11;$Host.UI.Write("-+  11 |")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 96,12;$Host.UI.Write(" +-----+")
        if ($Cellar_Quest_Current_Room -eq "11") {
            $host.UI.RawUI.ForegroundColor = "Green"
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 100,9;$Host.UI.Write("|") # door North
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 96,11;$Host.UI.Write("-") # door West
        }
    }
    # loop through all cellar rooms, draw all rooms that have been visited in DarkGray, also find current room to draw that room last in White
    foreach ($Cellar_Quest_Room in $Cellar_Quest_Rooms) {
        $Cellar_Quest_Room = $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.$Cellar_Quest_Room
        if ($Cellar_Quest_Room.Current_Location -eq $true) {
            $Script:Cellar_Quest_Current_Room = $Cellar_Quest_Room.Room
        }
        if ($Cellar_Quest_Room.Visited -eq $true) {
            $host.UI.RawUI.ForegroundColor = "DarkGray"
            switch ($Cellar_Quest_Room.Room) {
                1 { Draw_Cellar_Quest_Room_1 }
                2 { Draw_Cellar_Quest_Room_2 }
                3 { Draw_Cellar_Quest_Room_3 }
                4 { Draw_Cellar_Quest_Room_4 }
                5 { Draw_Cellar_Quest_Room_5 }
                6 { Draw_Cellar_Quest_Room_6 }
                7 { Draw_Cellar_Quest_Room_7 }
                8 { Draw_Cellar_Quest_Room_8 }
                9 { Draw_Cellar_Quest_Room_9 }
                10 { Draw_Cellar_Quest_Room_10 }
                11 { Draw_Cellar_Quest_Room_11 }
                Default {}
            }
        }
    }
    # draw current room last in DarkCyan which displays connecting room lines correctly rather than getting overritten by a room drawn after current room
    $host.UI.RawUI.ForegroundColor = "White"
    switch ($Cellar_Quest_Current_Room) {
        1 { Draw_Cellar_Quest_Room_1 }
        2 { Draw_Cellar_Quest_Room_2 }
        3 { Draw_Cellar_Quest_Room_3 }
        4 { Draw_Cellar_Quest_Room_4 }
        5 { Draw_Cellar_Quest_Room_5 }
        6 { Draw_Cellar_Quest_Room_6 }
        7 { Draw_Cellar_Quest_Room_7 }
        8 { Draw_Cellar_Quest_Room_8 }
        9 { Draw_Cellar_Quest_Room_9 }
        10 { Draw_Cellar_Quest_Room_10 }
        11 { Draw_Cellar_Quest_Room_11 }
        Default {}
    }
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
Function Visit_a_Building {
    do {
        Clear-Host
        Draw_Introduction_Tasks
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
        Draw_Player_Window_and_Stats
        $Script:Info_Banner = "Visit"
        Draw_Info_Banner
        # find all linked locations that you can travel to (not including your current location)
        $All_Buildings_In_Current_Location = $Import_JSON.Locations.$Current_Location.Buildings.PSObject.Properties.Name
        $All_Building_Letters_Array = New-Object System.Collections.Generic.List[System.Object]
        $All_Buildings_In_Current_Location_List = New-Object System.Collections.Generic.List[System.Object]
        Write-Color "  You can visit the following buildings:" -Color DarkGray
        # only show Home or Tavern when their Introduction Tasks value is set to true
        foreach ($Building_In_Current_Location in $All_Buildings_In_Current_Location) {
            if ($Import_JSON.Introduction_Tasks.In_Progress -eq $true) {
                if ($Import_JSON.Locations.$Current_Location.Buildings.$Building_In_Current_Location.Introduction_Task -eq $true) {
                    $All_Building_Letters_Array.Add($Import_JSON.Locations.$Current_Location.Buildings.$Building_In_Current_Location.Building_Letter) # grabs single character for that building
                    Write-Color "  $($Building_In_Current_Location.Substring(0,1))","$($Building_In_Current_Location.Substring(1,$Building_In_Current_Location.Length-1))" -Color Green,DarkGray
                    $All_Buildings_In_Current_Location_List.Add($Building_In_Current_Location)
                    $All_Buildings_In_Current_Location_List.Add("`r`n ")
                }
            } else { # otherwise show all buildings in current location after Introduction Tasks is complete and set to false
                $All_Building_Letters_Array.Add($Import_JSON.Locations.$Current_Location.Buildings.$Building_In_Current_Location.Building_Letter) # grabs single character for that building
                Write-Color "  $($Building_In_Current_Location.Substring(0,1))","$($Building_In_Current_Location.Substring(1,$Building_In_Current_Location.Length-1))" -Color Green,DarkGray
                $All_Buildings_In_Current_Location_List.Add($Building_In_Current_Location)
                $All_Buildings_In_Current_Location_List.Add("`r`n ")
            }
        }
        Write-Color "  E","xit" -Color Green,DarkGray
        $All_Buildings_Letters_Array_String = $All_Building_Letters_Array -Join "/"
        $All_Buildings_Letters_Array_String = $All_Buildings_Letters_Array_String + "/E"
        # Write-Color "  $All_Buildings_In_Current_Location_List" -Color White
        if ($Current_Location -ieq "Home Town") { Draw_Town_Map }
        if ($Current_Location -ieq "The Forest") { Draw_The_Forest_Map }
        if ($Current_Location -ieq "The River") { Draw_The_River_Map }
        do {
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
            Write-Color -NoNewLine "Which building do you want to visit? ", "[$All_Buildings_Letters_Array_String]" -Color DarkYellow,Green
            $Building_Choice = Read-Host " "
            $Building_Choice = $Building_Choice.Trim()
        } until ($Building_Choice -ieq "e" -or $Building_Choice -in $All_Building_Letters_Array)
        for ($Position = 17; $Position -lt 34; $Position++) { # clear some lines from previous widow
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
        }
        # set building name single characters to DarkYellow as they are no longer valid locations to visit
        $host.UI.RawUI.ForegroundColor = "DarkYellow"
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,2;$Host.UI.Write("A") # Anvil & Blade
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 60,4;$Host.UI.Write("H") # Home
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 75,6;$Host.UI.Write("T") # Tavern
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,9;$Host.UI.Write("M") # Mend & Mana
        $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
        # switch choice for Home Town
        if ($Current_Location -ieq "Home Town") {
            switch ($Building_Choice) {
                e { # exit
                    for ($Position = 17; $Position -lt 34; $Position++) { # clear some lines from previous widow
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                    }
                }
                h { # home
                    # update building words in location map. white to current building and reset location to dark yellow 
                    $host.UI.RawUI.ForegroundColor = "DarkYellow"
                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 73,1;$Host.UI.Write("Home Town")
                    $host.UI.RawUI.ForegroundColor = "White"
                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 60,4;$Host.UI.Write("Home")
                    do {
                        $Script:Info_Banner = "Home"
                        Draw_Info_Banner
                        $Home_Choice_Letters_Array = New-Object System.Collections.Generic.List[System.Object]
                        if ($Home_Choice -ieq "r" ) { # rested (from choice below), so display fully rested message instead
                            Save_JSON
                            # update introduction task and update Introduction Tasks window
                            $Import_JSON.Introduction_Tasks.Tick_Recover_Health_and_Mana = $true
                            Save_JSON
                            Draw_Introduction_Tasks
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
                            Draw_Player_Window_and_Stats
                            for ($Position = 17; $Position -lt 19; $Position++) { # clear some lines from previous widow
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                            }
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,18;$Host.UI.Write("")
                            Write-Color "  You are now fully rested. There is nothing else to do but leave." -Color DarkGray
                            $Home_Choice_Letters_Array.Add("E") # array now only contains L
                            $Home_Choice_Letters_Array_String = "E"
                        } else {
                            Write-Color "  You are now inside your ","Home","." -Color DarkGray,White,DarkGray
                            if (($Character_HealthCurrent -lt $Character_HealthMax) -or ($Character_ManaCurrent -lt $Character_ManaMax)) {
                                $Fully_Healed = "."
                                $Home_Choice_Letters_Array.Add("R")
                            } else {
                                $Fully_Healed = ", but it looks like you are already fully rested."
                            }
                            $Home_Choice_Letters_Array.Add("E")
                            $Home_Choice_Letters_Array_String = $Home_Choice_Letters_Array -Join "/"
                            Write-Color "  You can rest here to recover your ","health ","and ","mana","$($Fully_Healed)" -Color DarkGray,Green,DarkGray,Blue,DarkGray
                        }
                        do {
                            # update introduction task and update Introduction Tasks window
                            $Import_JSON.Introduction_Tasks.Tick_Visit_Home = $true
                            Save_JSON
                            Draw_Introduction_Tasks
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                            if ($Home_Choice_Letters_Array.Contains("R")) {
                                Write-Color -NoNewLine "R","est or ","E","xit? ", "[$Home_Choice_Letters_Array_String]" -Color Green,DarkYellow,Green,DarkYellow,Green
                            } else {
                                Write-Color -NoNewLine "E","xit ", "[$Home_Choice_Letters_Array_String]" -Color Green,DarkYellow,Green
                            }
                            $Home_Choice = Read-Host " "
                            $Home_Choice = $Home_Choice.Trim()
                        } until ($Home_Choice -in $Home_Choice_Letters_Array -or $Home_Choice -ieq "info") # choice check against an array cannot be done after a -join
                        
                        if ($Home_Choice -ieq "r") {
                            $Script:Character_HealthCurrent = $Character_HealthMax
                            $Script:Character_ManaCurrent = $Character_ManaMax
                            $Import_JSON.Character.Stats.HealthCurrent = $Character_HealthCurrent
                            $Import_JSON.Character.Stats.ManaCurrent = $Character_ManaCurrent
                            # advance introduction to game ()
                            $Import_JSON.Locations."Home Town".Buildings.Tavern.Introduction_Task = $true
                            Save_JSON
                        }
                    } until ($Home_Choice -ieq "e")
                }
                t { # tavern
                    # update building words in location map. white to current building and reset location to dark yellow 
                    $host.UI.RawUI.ForegroundColor = "DarkYellow"
                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 73,1;$Host.UI.Write("Home Town")
                    $host.UI.RawUI.ForegroundColor = "White"
                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 75,6;$Host.UI.Write("Tavern")
                    $First_Time_Entered_Tavern = $true
                    $Exit_Drinks_Menu = $false
                    $Exit_Quest_Board = $false
                    $Drink_Purchased = $false
                    $Quest_Accepted = $false
                    do {
                        $Script:Info_Banner = "Tavern"
                        Draw_Info_Banner
                        do {
                            if ($First_Time_Entered_Tavern -eq $true) {
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                Write-Color "  Welcome adventurer, my name is ","$($Import_JSON.Locations."Home Town".Buildings.Tavern.Owner)",", and i am the owner of this Tavern." -Color DarkGray,Blue,DarkGray
                                Write-Color "  Would you like a ","D","rink? If not, maybe you can spare some time to look at the ","Q","uest board over there." -Color DarkGray,Green,DarkGray,Green,DarkGray
                            }
                            if ($First_Time_Entered_Tavern -eq $false) {
                                for ($Position = 17; $Position -lt 24; $Position++) { # clear some lines from previous widow
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                }
                                if ($Exit_Drinks_Menu -eq $true -and $Import_JSON.Character.Buffs.DrinksPurchased -lt 2 -and $Drink_Purchased -eq $false) {
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                    Write-Color "  Don't forget to check out the ","Q","uest board." -Color DarkGray,Green,DarkGray
                                }
                                if ($Exit_Drinks_Menu -eq $true -and $Drink_Purchased -eq $true) {
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                    Write-Color "  $($Import_JSON.Locations."Home Town".Buildings.Tavern.Owner) ","hands you a ","$Tavern_Drink","." -Color Blue,DarkGray,White,DarkGray
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
                                } elseif ($Exit_Drinks_Menu -eq $true -and $Import_JSON.Character.Buffs.DrinksPurchased -eq 2) {
                                    for ($Position = 17; $Position -lt 24; $Position++) { # clear some lines from previous widow
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                    }
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                    Write-Color "  $($Import_JSON.Locations."Home Town".Buildings.Tavern.Owner) ","says you've had too many and refuses to serve you until you sober up." -Color Blue,DarkGray
                                }
                                if ($Exit_Quest_Board -eq $true -and $Import_JSON.Character.Buffs.DrinksPurchased -lt 2) {
                                    for ($Position = 17; $Position -lt 31; $Position++) { # clear some lines from previous widow
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                    }
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                    if ($Drink_Purchased -eq $true) {
                                        Write-Color "  Maybe another ","D","rink before you leave?" -Color DarkGray,Green,DarkGray
                                    }
                                    Write-Color "  Maybe you'd like a ","D","rink before you leave?" -Color DarkGray,Green,DarkGray
                                }
                                if ($Exit_Quest_Board -eq $true -and $Import_JSON.Character.Buffs.DrinksPurchased -eq 2) {
                                    Write-Color "  Stay safe out there, $($Character_Name)" -Color DarkGray,Green,DarkGray
                                }
                            }
                            if ($First_Time_Entered_Cellar -eq $true) {
                                Draw_Town_Map # re-draw town map after exiting cellar
                                for ($Position = 17; $Position -lt 24; $Position++) { # clear some lines from previous widow
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                }
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                if ($Import_JSON.Quests.'Rat Infestation'.In_Progress -eq $true) {
                                    Write-Color "  $Character_Name",", you have retured from my cellar, how did you get on with those pesky rats?" -Color Blue,DarkGray
                                }
                            }
                            $Tavern_Choice_Letters_Array = New-Object System.Collections.Generic.List[System.Object]
                            Write-Color -LinesBefore 1 "  Purchase a ","D","rink" -Color DarkGray,Green,DarkGray
                            Write-Color "  Look at the ","Q","uest board" -Color DarkGray,Green,DarkGray
                            $Tavern_Choice_Letters_Array.Add("D")
                            $Tavern_Choice_Letters_Array.Add("Q")
                            if ($Import_JSON.Quests."Rat Infestation".In_Progress -eq $true) {
                                Write-Color "  Enter the ","C","ellar" -Color DarkGray,Green,DarkGray
                                $Tavern_Choice_Letters_Array.Add("C")
                            }
                            $Tavern_Choice_Letters_Array.Add("E")
                            $Tavern_Choice_Letters_Array_String = $Tavern_Choice_Letters_Array -join "/"
                            Write-Color "  E","xit" -Color Green,DarkGray
                            # update introduction task and update Introduction Tasks window
                            $Import_JSON.Introduction_Tasks.Tick_Visit_the_Tavern = $true
                            Save_JSON
                            Draw_Introduction_Tasks
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                            Write-Color -NoNewLine "How can i serve you? ","[$Tavern_Choice_Letters_Array_String]" -Color DarkYellow,Green
                            $Tavern_Choice = Read-Host " "
                            $Tavern_Choice = $Tavern_Choice.Trim()
                        } until ($Tavern_Choice -in $Tavern_Choice_Letters_Array)
                        switch ($Tavern_Choice) {
                            # drinks menu
                            d {
                                do {
                                    for ($Position = 17; $Position -lt 24; $Position++) { # clear some lines from previous widow
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                    }
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                    Write-Color "  Please choose from our selection of drinks from the menu." -Color DarkGray
                                    Write-Color "`r" -Color DarkGray
                                    $Tavern_Drinks_Categorys = $Import_JSON.Locations."Home Town".Buildings.Tavern.Drinks.PSObject.Properties.Name
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
                                } until ($Tavern_Drinks_Choice -ieq "e" -or $Tavern_Drinks_Choice -in $Tavern_Drinks_Category_Letters_Array)
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
                                            $Tavern_Drinks = $Import_JSON.Locations."Home Town".Buildings.Tavern.Drinks.$Tavern_Drinks_Category.PSObject.Properties.Name
                                            $Tavern_Drink = Get-Random -Input $Tavern_Drinks
                                            $Script:Tavern_Drink_Bonus_Name = $Import_JSON.Locations."Home Town".Buildings.Tavern.Drinks.$Tavern_Drinks_Category.$Tavern_Drink.Bonus.PSObject.Properties.Name
                                            # update JSON Buffs.Duration based on drink category
                                            $Import_JSON.Character.Buffs.Duration = $Import_JSON.Locations."Home Town".Buildings.Tavern.Drinks.$Tavern_Drinks_Category.$Tavern_Drink.BuffDuration
                                            $Import_JSON.Character.Buffs.Dropped = $false
                                            switch ($Tavern_Drink_Bonus_Name) {
                                                $Tavern_Drink_Bonus_Name {
                                                    $Tavern_Drink_Bonus_Amount = ($Import_JSON.Locations."Home Town".Buildings.Tavern.Drinks.$Tavern_Drinks_Category.$Tavern_Drink.Bonus).$Tavern_Drink_Bonus_Name
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
                                                    Save_JSON
                                                    Update_Variables
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
                                $Exit_Drinks_Menu = $true
                                $Exit_Quest_Board = $false
                                $First_Time_Entered_Cellar = $false
                            }
                            # quest board
                            q {
                                $First_Time_Looking_at_Quest_Board = $true
                                do {
                                    $Script:Info_Banner = "Quest Board"
                                    Draw_Info_Banner
                                    do {
                                        for ($Position = 17; $Position -lt 25; $Position++) { # clear some lines from previous widow
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                        }
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                        if ($First_Time_Looking_at_Quest_Board -eq $true) {
                                            if ($Import_JSON.Character.Buffs.DrinksPurchased -gt 0) {
                                                $Player_Walking_to_Quest_Board = @(
                                                    "You stagger over to the board, bumping into a few chairs along the way.",
                                                    "You stumble over to the board.",
                                                    "You make your way to the board and trip over your own feet."
                                                )
                                            } else {
                                                $Player_Walking_to_Quest_Board = @(
                                                    "You walk to the board to see how many quests are available.",
                                                    "You stride over to the board to check if there are any quests available."
                                                )
                                            }
                                            $Player_Walking_to_Quest_Board = Get-Random -Input $Player_Walking_to_Quest_Board
                                            Write-Color "  $Player_Walking_to_Quest_Board" -Color DarkGray
                                        }
                                        if ($Quest_Accepted -eq $true) {
                                            # update introduction task and update Introduction Tasks window
                                            $Import_JSON.Introduction_Tasks.Tick_Accept_a_Quest = $true
                                            Draw_Introduction_Tasks
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                            for ($Position = 17; $Position -lt 31; $Position++) { # clear some lines from previous widow
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                            }
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                            Write-Color "  $($Import_JSON.Locations."Home Town".Buildings.Tavern.Owner) ","thanks you for accepting the ","$($Quest_Name.Name)"," quest" -Color Blue,DarkGray,White,DarkGray
                                            Write-Color "  and tells you she will let the person know you've accepted it." -Color DarkGray
                                            Write-Color "  Don't forget, you can view quests you've accepted by choosing '","Q","' here or in most other menus." -Color DarkGray,Green,DarkGray
                                            Write-Color ""
                                            $Quest_Name = $($Quest_Name.Name)
                                            $Import_JSON.Quests.$Quest_Name.Available = $false
                                            $Import_JSON.Quests.$Quest_Name.In_Progress = $true
                                            $Import_JSON.Quests.$Quest_Name.Status = "In Progress"
                                            Save_JSON
                                        } else {
                                            for ($Position = 17; $Position -lt 31; $Position++) { # clear some lines from previous widow
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                            }
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                        }
                                        Write-Color "  The following quests are pinned to the board." -Color DarkGray
                                        Write-Color "`r" -Color DarkGray
                                        $Available_Quest_Letters_Array = New-Object System.Collections.Generic.List[System.Object]
                                        $Quest_Names = $Import_JSON.Quests.PSObject.Properties.Name
                                        foreach ($Quest_Name in $Quest_Names) {
                                            $Quest_Name = $Import_JSON.Quests.$Quest_Name
                                            # if Introduction Tasks are active, only show the Rat quest
                                            if ($Import_JSON.Introduction_Tasks.In_Progress -eq $true) {
                                                if ($Quest_Name.Introduction_Task -eq $true) {
                                                    Write-Color "  $($Quest_Name.Quest_Letter)","$($Quest_Name.Name.SubString(1.0)) - ","$($Quest_Name.Status)" -Color Green,DarkGray,DarkYellow
                                                    $Available_Quest_Letters_Array.Add($Quest_Name.Quest_Letter)
                                                }
                                            } else { # else show all quests
                                                if ($Quest_Name.Available -eq $true -or $Quest_Name.Status -ieq "In Progress" -or $Quest_Name.Status -ieq "Hand In") {
                                                    Write-Color "  $($Quest_Name.Quest_Letter)","$($Quest_Name.Name.SubString(1.0)) - ","$($Quest_Name.Status)" -Color Green,DarkGray,DarkYellow
                                                    $Available_Quest_Letters_Array.Add($Quest_Name.Quest_Letter)
                                                }
                                            }
                                        }
                                        $Available_Quest_Letters_Array_String = $Available_Quest_Letters_Array -Join "/"
                                        $Available_Quest_Letters_Array_String = $Available_Quest_Letters_Array_String + "/E"
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                        Write-Color -NoNewLine "View details about a quest, or ","E","xit ","[$Available_Quest_Letters_Array_String]" -Color DarkYellow,Green,DarkYellow,Green
                                        $Tavern_Quest_Board_Choice = Read-Host " "
                                        $Tavern_Quest_Board_Choice = $Tavern_Quest_Board_Choice.Trim()
                                    } until ($Tavern_Quest_Board_Choice -ieq "e" -or $Tavern_Quest_Board_Choice -in $Available_Quest_Letters_Array)
                                    if ($Tavern_Quest_Board_Choice -in $Available_Quest_Letters_Array) {
                                        do {
                                            Draw_Inventory
                                            for ($Position = 17; $Position -lt 28; $Position++) { # clear some lines from previous widow
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                            }
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                            foreach ($Quest_Name in $Quest_Names) {
                                                $Quest_Name = $Import_JSON.Quests.$Quest_Name
                                                if ($Quest_Name.Quest_Letter -ieq $Tavern_Quest_Board_Choice) {
                                                    Break
                                                }
                                            }
                                            Write-Color "  Name        ",": $($Quest_Name.Name)" -Color White,DarkGray
                                            Write-Color "  Description ",": $($Quest_Name.Description)" -Color White,DarkGray
                                            Write-Color "  Reward      ",": $($Quest_Name.Gold_Reward)"," Gold" -Color White,DarkGray,DarkYellow
                                            Write-Color "  Progress    ",": $($Quest_Name.Progress) of $($Quest_Name.Progress_Max)" -Color White,DarkGray
                                            Write-Color "  Status      ",": $($Quest_Name.Status)" -Color White,DarkGray
                                            Write-Color "  Location    ",": $($Quest_Name.Hand_In_Location)" -Color White,DarkGray
                                            Write-Color "  Building    ",": $($Quest_Name.Building)" -Color White,DarkGray
                                            Write-Color "  NPC         ",": $($Quest_Name.Hand_In_NPC)" -Color White,DarkGray
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                            $Tavern_Quest_Info_Choice_Array = New-Object System.Collections.Generic.List[System.Object]
                                            if ($Quest_Name.Status -ieq "In Progress") {
                                                Write-Color -NoNewLine "E","xit ","[E]" -Color Green,DarkYellow,Green
                                                $Tavern_Quest_Info_Choice_Array = "E"
                                            }
                                            if ($Quest_Name.Status -ieq "Available") {
                                                Write-Color -NoNewLine "A","ccept quest or ", "E","xit ","[A/E]" -Color Green,DarkYellow,Green,DarkYellow,Green
                                                $Tavern_Quest_Info_Choice_Array = "A","E"
                                            }
                                            if ($Quest_Name.Status -ieq "Hand In") {
                                                Write-Color -NoNewLine "H","and in quest or ", "E","xit ","[H/E]" -Color Green,DarkYellow,Green,DarkYellow,Green
                                                $Tavern_Quest_Info_Choice_Array = "H","E"
                                            }
                                            $Tavern_Quest_Info_Choice = Read-Host " "
                                            $Tavern_Quest_Info_Choice = $Tavern_Quest_Info_Choice.Trim()
                                        } until ($Tavern_Quest_Info_Choice -in $Tavern_Quest_Info_Choice_Array)
                                        # accept a quest
                                        if ($Tavern_Quest_Info_Choice -ieq "a") {
                                            $Quest_Accepted = $true
                                            $Quest_Name.Status = "In Progress"
                                            $Quest_Name.In_Progress = $true
                                            $Quest_Name.Available = $false
                                            # advance introduction to game
                                            $Import_JSON.Locations."Home Town".Location_Options.Quests = $true
                                        }
                                        # hand in a quest
                                        if ($Tavern_Quest_Info_Choice -ieq "h") {
                                            do {
                                                # advance introduction to game (from Rat quest)
                                                $Import_JSON.Locations."Home Town".Buildings."Mend & Mana".Introduction_Task = $true
                                                # update introduction task and update Introduction Tasks window
                                                $Import_JSON.Introduction_Tasks.Tick_View_Inventory = $true
                                                $Import_JSON.Introduction_Tasks.Tick_Hand_in_Completed_Quest = $true
                                                Save_JSON
                                                Draw_Introduction_Tasks
                                                # reset quest
                                                $Quest_Name.Status = "Available"
                                                $Quest_Name.In_Progress = $false
                                                $Quest_Name.Available = $true
                                                $Quest_Name.Progress = 0
                                                # update gold
                                                $Import_JSON.Character.Gold += $Quest_Name.Gold_Reward
                                                $Script:Gold = $Import_JSON.Character.Gold
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
                                                Draw_Player_Window_and_Stats
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,25;$Host.UI.Write("");" "*105
                                                Write-Color "  Thank you for completing this quest ","$Character_Name",". Here is your reward." -Color DarkGray,Blue,DarkGray
                                                Write-Color "  $($Quest_Name.Gold_Reward) Gold" -Color DarkYellow
                                                # if there are reward items, update inventory
                                                if (-not($Quest_Name.Item_Reward -eq $false)) {
                                                    foreach ($Quest_Hand_In_Item in $Quest_Name.Item_Reward.PSObject.Properties.Name) {
                                                        $Current_Item_Quantity = $Import_JSON.Items.$Quest_Hand_In_Item.Quantity
                                                        if ($Current_Item_Quantity + $Quest_Name.Item_Reward.$Quest_Hand_In_Item -gt 99) {
                                                            $Import_JSON.Items.$Quest_Hand_In_Item.Quantity = 99
                                                            $Max_99_Items = "(MAX 99 items)"
                                                        } else {
                                                            $Import_JSON.Items.$Quest_Hand_In_Item.Quantity += $Quest_Name.Item_Reward.$Quest_Hand_In_Item
                                                            $Max_99_Items = ""
                                                        }
                                                        Write-Color "  x$($Quest_Name.Item_Reward.$Quest_Hand_In_Item) ","$Quest_Hand_In_Item $Max_99_Items" -Color White,DarkGray
                                                    }
                                                }
                                                Draw_Inventory
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                                Write-Color -NoNewLine "E","xit ","[E]" -Color Green,DarkYellow,Green
                                                $Quest_Hand_In_Exit = Read-Host " "
                                                $Quest_Hand_In_Exit = $Quest_Hand_In_Exit.Trim()
                                            } until ($Quest_Hand_In_Exit -ieq "e")
                                        }
                                        Save_JSON
                                    }
                                    $Exit_Quest_Board = $true
                                    $Exit_Drinks_Menu = $false
                                    $First_Time_Looking_at_Quest_Board = $false
                                    $First_Time_Entered_Cellar = $false
                                } until ($Tavern_Quest_Board_Choice -ieq "e")
                            }
                            # enter the Cellar (rat quest)
                            c {
                                $First_Time_Entered_Cellar = $true
                                # set quest as active
                                $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Is_Active = $true
                                # reset cellar rooms visited (resets every time cellar is entered)
                                $Cellar_Quest_Room_Names = $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.PSObject.Properties.Name | Where-Object {$PSItem -ilike "room*"}
                                foreach ($Cellar_Quest_Room_Name in $Cellar_Quest_Room_Names) {
                                    $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.$Cellar_Quest_Room_Name.Visited = $false
                                    $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.$Cellar_Quest_Room_Name.Current_Location = $false
                                }
                                $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.Room6.Visited = $true
                                $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.Room6.Current_Location = $true
                                Save_JSON
                                do {
                                    $Script:Info_Banner = "Tavern Cellar"
                                    Draw_Info_Banner
                                    $Script:Cellar_Quest_Rooms = $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.PSObject.Properties.Name
                                    do {
                                        Add-Content -Path .\error.log -value "------------------------------------------------------------"
                                        for ($Position = 17; $Position -lt 25; $Position++) { # clear some lines from previous widow
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                        }
                                        $Cellar_Quest_Room_Direction_Array = New-Object System.Collections.Generic.List[System.Object]
                                        # loop through all Cellar quest rooms and get room direction letters for current room
                                        foreach ($Cellar_Quest_Room in $Cellar_Quest_Rooms) {
                                            # get current cellar quest room as an object
                                            $Cellar_Quest_Room_Object = $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.$Cellar_Quest_Room
                                            foreach ($Cellar_Quest_Room_Current_Location in $Cellar_Quest_Room_Object) {
                                                if ($Cellar_Quest_Room_Current_Location.Current_Location -eq $true) {
                                                    $Cellar_Quest_Current_Room_Number = $Cellar_Quest_Room_Current_Location.Room
                                                    Add-Content -Path .\error.log -value "Cellar_Quest_Current_Room_Number 1: $Cellar_Quest_Current_Room_Number"
                                                    # get all Linked_Locations room names and loop through 
                                                    $Cellar_Quest_Current_Room_Number_Object = $Cellar_Quest_Room_Current_Location
                                                    foreach ($Cellar_Quest_Room_Name in $Cellar_Quest_Room_Object.LinkedRooms.PSObject.Properties.Name) {
                                                        $Cellar_Quest_Room_Name_Letter = $Cellar_Quest_Room_Object.LinkedRooms.$Cellar_Quest_Room_Name
                                                        # add each Linked_Locations letter (direction) to array
                                                        $Cellar_Quest_Room_Direction_Array.Add($Cellar_Quest_Room_Name_Letter)
                                                    }
                                                }
                                            }
                                            # check if current location is room 6 (the exit) and if Room6's "Current_Location" is $true. if it is, add the "X" choice to the array, then break out of the loop
                                            if ($Cellar_Quest_Room_Current_Location.Room -eq "6" -and $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.Room6.Current_Location -eq $true) {
                                                $Cellar_Quest_Room_Direction_Array.Add("X")
                                                $Cellar_Quest_Room_Direction_Array_String = $Cellar_Quest_Room_Direction_Array -Join "/"
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                                Write-Color "  You walk down the stone cellar steps being careful not to slip on the mold and rat droppings." -Color DarkGray
                                                Write-Color "  It's damp and dark. Your torch barly makes a difference down here." -Color DarkGray
                                                Write-Color -LinesBefore 1 "  Use the four main cardinal directions of a compass to move about in the cellar. ","N",", ","S",", ","E ","and ","W","." -Color DarkGray,Green,DarkGray,Green,DarkGray,Green,DarkGray,Green,DarkGray
                                                Write-Color "  Look for the ","Green ","line (","-"," or ","|",") on the edges of the room walls which indicates a joning room." -Color DarkGray,Green,DarkGray,Green,DarkGray,Green,DarkGray
                                                Write-Color -LinesBefore 1 "  Note:"," to exit the Cellar, move back to this room and enter '","X","' (not the usual 'E')." -Color Red,DarkGray,Green,DarkGray
                                                Break
                                            } elseif ($Cellar_Quest_Current_Room_Number -eq "1") {
                                                for ($Position = 17; $Position -lt 35; $Position++) { # clear some lines from previous widow
                                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                                }
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                                Write-Color "  room 1" -Color DarkGray
                                                Write-Color "  searchroom and find a potion" -Color DarkGray
                                            } elseif ($Cellar_Quest_Current_Room_Number -eq "10") {
                                                for ($Position = 17; $Position -lt 35; $Position++) { # clear some lines from previous widow
                                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                                }
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                                Write-Color "  room 10" -Color DarkGray
                                            } elseif ($Cellar_Quest_Current_Room_Number -eq "11") {
                                                for ($Position = 17; $Position -lt 35; $Position++) { # clear some lines from previous widow
                                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                                }
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                                Write-Color "  room 11" -Color DarkGray
                                                Write-Color "  searchroom and find a potion" -Color DarkGray
                                            } else {
                                                for ($Position = 17; $Position -lt 35; $Position++) { # clear some lines from previous widow
                                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                                }
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                                Write-Color "  all other rooms" -Color DarkGray
                                            }
                                            $Cellar_Quest_Room_Direction_Array_String = $Cellar_Quest_Room_Direction_Array -Join "/"
                                        }
                                        Write-Color "  Cellar_Quest_Current_Room_Number: $Cellar_Quest_Current_Room_Number" -Color DarkGray
                                        Add-Content -Path .\error.log -value "Cellar_Quest_Current_Room_Number 2: $Cellar_Quest_Current_Room_Number"
                                        Draw_Cellar_Map
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                        if ($Cellar_Quest_Room_Current_Location.Room -eq "6" -and $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.Room6.Current_Location -eq $true) {
                                            Write-Color -NoNewLine "Compass direction or e","X","it ","[$Cellar_Quest_Room_Direction_Array_String]" -Color DarkYellow,Green,DarkYellow,Green
                                        } else {
                                            Write-Color -NoNewLine "Compass direction ","[$Cellar_Quest_Room_Direction_Array_String]" -Color DarkYellow,Green
                                        }
                                        $Cellar_Direction = Read-Host " "
                                        $Cellar_Direction = $Cellar_Direction.Trim()
                                    } until ($Cellar_Direction -in $Cellar_Quest_Room_Direction_Array)
                                        switch ($Cellar_Direction) {
                                            $Cellar_Direction {
                                                # if in room 6 (cellar exit), move back into Tavern (only available if in room 6)
                                                if ($Cellar_Direction -ieq "x") {
                                                    # set quest as inactive
                                                    $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Is_Active = $false
                                                    Break
                                                }
                                                # update current location based on direction moved
                                                $Cellar_Quest_Current_Room_Linked_Rooms = $Cellar_Quest_Current_Room_Number_Object.LinkedRooms.PSObject.Properties.Name
                                                Add-Content -Path .\error.log -value "Cellar_Quest_Current_Room_Linked_Rooms: $Cellar_Quest_Current_Room_Linked_Rooms"
                                                foreach ($Cellar_Quest_Current_Room_Linked_Room in $Cellar_Quest_Current_Room_Linked_Rooms) {
                                                    Add-Content -Path .\error.log -value "Cellar_Quest_Current_Room_Linked_Room: $Cellar_Quest_Current_Room_Linked_Room"
                                                    if ($Cellar_Quest_Current_Room_Number_Object.LinkedRooms.$Cellar_Quest_Current_Room_Linked_Room -ieq "$Cellar_Direction") {
                                                        Add-Content -Path .\error.log -value "Cellar_Quest_Current_Room_Number_Object.LinkedRooms.Cellar_Quest_Current_Room_Linked_Room: $($Cellar_Quest_Current_Room_Number_Object.LinkedRooms.$Cellar_Quest_Current_Room_Linked_Room)"
                                                        # set current room to false
                                                        $Cellar_Quest_Current_Room_Number_Object.Current_Location = $false
                                                        Add-Content -Path .\error.log -value "Cellar_Quest_Current_Room_Number_Object: $Cellar_Quest_Current_Room_Number_Object"
                                                        Add-Content -Path .\error.log -value "Cellar_Quest_Current_Room_Number_Object.Current_Location: $($Cellar_Quest_Current_Room_Number_Object.Current_Location)"
                                                        # update new room to current room
                                                        Add-Content -Path .\error.log -value "current location before: $($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.$Cellar_Quest_Current_Room_Linked_Room.Current_Location)"
                                                        Add-Content -Path .\error.log -value "visited before: $($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.$Cellar_Quest_Current_Room_Linked_Room.Visited)"
                                                        $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.$Cellar_Quest_Current_Room_Linked_Room.Current_Location = $true
                                                        $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.$Cellar_Quest_Current_Room_Linked_Room.Visited = $true
                                                        Add-Content -Path .\error.log -value "visited after: $($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.$Cellar_Quest_Current_Room_Linked_Room.Visited)"
                                                        Add-Content -Path .\error.log -value "current location after: $($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.$Cellar_Quest_Current_Room_Linked_Room.Current_Location)"
                                                        # set current room number
                                                        $Cellar_Quest_Current_Room_Number = $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms.$Cellar_Quest_Current_Room_Linked_Room.Room
                                                        Save_JSON
                                                        Import_JSON
                                                    }
                                                }
                                                Get_Random_Mob
                                                Fight_or_Run
                                                Draw_Cellar_Map
                                                $Script:Info_Banner = "Tavern Cellar"
                                                Draw_Info_Banner
                                                do {
                                                    # clears the combat area correctly after either escaping a mob or killing a mob
                                                    if ($Script:Escaped_from_Mob -eq $true) {
                                                        Draw_Cellar_Map
                                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,20;$Host.UI.Write("")
                                                    } else {
                                                        for ($Position = 17; $Position -lt 25; $Position++) { # clear some lines from previous widow
                                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                                        }
                                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                                    }
                                                    do {
                                                        # check if there are any containers in the current room that have not been searched
                                                        $Room_Container_Letters_Array = New-Object System.Collections.Generic.List[System.Object]
                                                        $Container_Names = $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms."Room$Cellar_Quest_Current_Room_Number".Containers.PSObject.Properties.Name
                                                        Add-Content -Path .\error.log -value "====================================================================="
                                                        Add-Content -Path .\error.log -value "Cellar_Quest_Current_Room_Number: $Cellar_Quest_Current_Room_Number"
                                                        Add-Content -Path .\error.log -value "Container_Names: $Container_Names"
                                                        $Container_Found = $false # reset container_found so it can be checked again next loop
                                                        foreach ($Container_Name in $Container_Names) {
                                                            if ($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms."Room$Cellar_Quest_Current_Room_Number".Containers.$Container_Name -eq $true) {
                                                                $Container_Found = $true
                                                                Add-Content -Path .\error.log -value "--Container_Found: $Container_Found true"
                                                            }
                                                            Add-Content -Path .\error.log -value "Container_Found: $Container_Found"
                                                        }
                                                        # if there are any containers in the room that have not been searched, prompt to search
                                                        if ($Container_Found -eq $true) {
                                                            for ($Position = 17; $Position -lt 36; $Position++) { # clear some lines from previous widow
                                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                                            }
                                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                                            Write-Color "  The room contains the following containers." -Color DarkGray
                                                            Add-Content -Path .\error.log -value "The room contains the following containers"
                                                            foreach ($Container_Name in $Container_Names) {
                                                                Add-Content -Path .\error.log -value "Container_Name: $Container_Name"
                                                                if ($Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms."Room$Cellar_Quest_Current_Room_Number".Containers.$Container_Name -eq $true) {
                                                                    Add-Content -Path .\error.log -value "Container_Name 1: true (expected)"
                                                                    Write-Color "  $($Container_Name.Substring(0,1))","$($Container_Name.Substring(1,$Container_Name.Length-1))" -Color Green,DarkGray
                                                                    $Room_Container_Letters_Array.Add($Container_Name.Substring(0,1))
                                                                } else {
                                                                    Add-Content -Path .\error.log -value "Container_Name 1: false (not expected)"
                                                                }
                                                            }
                                                            $Room_Container_Letters_Array_String = $Room_Container_Letters_Array -Join "/"
                                                            $Room_Container_Letters_Array_String = $Room_Container_Letters_Array_String + "/X"
                                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                                            Write-Color -NoNewLine "Search a container or e","X","it? ", "[$Room_Container_Letters_Array_String]" -Color DarkYellow,Green,DarkYellow,Green
                                                            $Cellar_Room_Choice = ""
                                                            $Cellar_Room_Choice = Read-Host " "
                                                            $Cellar_Room_Choice = $Cellar_Room_Choice.Trim()
                                                            switch ($Cellar_Room_Choice) {
                                                                $Cellar_Room_Choice {
                                                                    # if choice is x, don't loot container
                                                                    if ($Cellar_Room_Choice -ieq "x") {
                                                                        # exit the cellar
                                                                        $Cellar_Room_Choice = "x"
                                                                        Break
                                                                    } else { # otherwise loot the container
                                                                        # 50/50 chance of finding something in the container
                                                                        $Random_True_False = Get-Random -InputObject ([bool]$true,[bool]$false)
                                                                        Add-Content -Path .\error.log -value "Cellar_Room_Choice: $Cellar_Room_Choice"
                                                                        Add-Content -Path .\error.log -value "Random_True_False: $Random_True_False"
                                                                        if ($Random_True_False -eq $true) {
                                                                            # update container in JSON to false so it can't be searched again
                                                                            Add-Content -Path .\error.log -value "Container_Names: $Container_Names"
                                                                            foreach ($Container_Name in $Container_Names) {
                                                                                Add-Content -Path .\error.log -value "Container_Name: $Container_Name"
                                                                                if ($Container_Name.Substring(0,1) -ieq $Cellar_Room_Choice) {
                                                                                    Add-Content -Path .\error.log -value "Container_Name.Substring: $($Container_Name.Substring(0,1))"
                                                                                    $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms."Room$Cellar_Quest_Current_Room_Number".Containers.$Container_Name = $false # set container to false so it can't be searched again
                                                                                    $Container_Name_Looted = $Container_Name
                                                                                    Add-Content -Path .\error.log -value "Container_Name 2: false (expected)"
                                                                                } else {
                                                                                    Add-Content -Path .\error.log -value "Container_Name 2: true (not expected)"
                                                                                }
                                                                            }
                                                                            $Random_5 = Get-Random -Minimum 1 -Maximum 6 # random gold value between 1 and 5
                                                                            for ($Position = 17; $Position -lt 25; $Position++) { # clear some lines from previous widow
                                                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                                                            }
                                                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                                                            Write-Color "  The ","$Container_Name_Looted ","contained ","$Random_5 Gold." -Color DarkGray,Blue,DarkGray,DarkYellow
                                                                            $Import_JSON.Character.Gold += $Random_5
                                                                            $Script:Gold = $Import_JSON.Character.Gold
                                                                        } else { # did not find anything in the container
                                                                            for ($Position = 17; $Position -lt 25; $Position++) { # clear some lines from previous widow
                                                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                                                            }
                                                                            # update container in JSON to false so it can't be searched again
                                                                            foreach ($Container_Name in $Container_Names) {
                                                                                if ($Container_Name.Substring(0,1) -ieq $Cellar_Room_Choice) {
                                                                                    $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms."Room$Cellar_Quest_Current_Room_Number".Containers.$Container_Name = $false # set container to false so it can't be searched again
                                                                                    $Container_Name_Looted = $Container_Name
                                                                                }
                                                                            }
                                                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                                                            Write-Color "  The ","$Container_Name_Looted ","did not contain anything." -Color DarkGray,Blue
                                                                            # $Import_JSON.Locations."Home Town".Buildings.Tavern.Cellar.Cellar_Quest.Rooms."Room$Cellar_Quest_Current_Room_Number".Containers.$Container_Name = $false # set container to false so it can't be searched again
                                                                        }
                                                                        Update_Variables
                                                                        Draw_Player_Window_and_Stats
                                                                        Save_JSON
                                                                        Import_JSON
                                                                        do {
                                                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                                                            Write-Color -NoNewLine "C","ontinue 1 ","[C]" -Color Green,DarkYellow,Green
                                                                            $Continue_After_Searching_Container = Read-Host " "
                                                                            $Continue_After_Searching_Container = $Continue_After_Searching_Container.Trim()
                                                                        } until ($Continue_After_Searching_Container -ieq "c")
                                                                    }
                                                                }
                                                                # Default {}
                                                            }
                                                            $Cellar_Room_Choice = "x" # set to x so the loop can be exited. needs to be separate as some rooms have multiple containers
                                                        } else { # all containers in the room have been searched
                                                            $Cellar_Room_Choice = "x" # set to x so the loop can be exited. needs to be separate as some rooms have multiple containers
                                                        }
                                                    } until ($Container_Found -eq $false)
                                                } until ($Cellar_Room_Choice -ieq "x")
                                            }
                                            # Default {}
                                        }
                                        # Get_Random_Mob
                                        # Fight_or_Run
                                } until ($Cellar_Direction -ieq "x")
                            }
                            Default {}
                        }
                        $First_Time_Entered_Tavern = $false
                    } until ($Tavern_Choice -ieq "e")
                }
                #
                # Anvil & Blade
                #
                a {
                    # update building words in location map. white to current building and reset location to dark yellow 
                    $host.UI.RawUI.ForegroundColor = "DarkYellow"
                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 73,1;$Host.UI.Write("Home Town")
                    $host.UI.RawUI.ForegroundColor = "White"
                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,2;$Host.UI.Write("Anvil")
                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,3;$Host.UI.Write("& Blade")
                    $First_Time_Entered_Anvil = $true
                    do {
                        $Script:Info_Banner = "Anvil & Blade"
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
                                Write-Color "  J","unk items" -Color Green,DarkGray
                                Write-Color "  A","rmour" -Color Green,DarkGray
                                Write-Color "  W","eapons" -Color Green,DarkGray
                                Write-Color "  N","othing for now" -Color Green,DarkGray
                                Write-Color "  E","xit the Anvil & Blade" -Color Green,DarkGray
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                Write-Color -NoNewLine "J","unk, ","A","rmour, ","W","eapons, or ", "E","xit ","[J/A/W/N/E]" -Color Green,DarkYellow,Green,DarkYellow,Green,DarkYellow,Green,DarkYellow,Green
                                $Anvil_Sell_Choice = Read-Host " "
                                $Anvil_Sell_Choice = $Anvil_Sell_Choice.Trim()
                            } until ($Anvil_Sell_Choice -ieq "j" -or $Anvil_Sell_Choice -ieq "a" -or $Anvil_Sell_Choice -ieq "w" -or $Anvil_Sell_Choice -ieq "n" -or $Anvil_Sell_Choice -ieq "e")
                            if ($Anvil_Sell_Choice -ieq "j") {
                                $Anvil_Choice_Sell_Junk_Array = New-Object System.Collections.Generic.List[System.Object]
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
                                $Import_JSON.Character.Gold = $Import_JSON.Character.Gold + $Anvil_Choice_Sell_Junk_GoldValue
                                foreach (${JunkItem} in ${Anvil_Choice_Sell_Junk_Array}) {
                                    $Import_JSON.Items.$JunkItem.Quantity = 0
                                }
                                Save_JSON
                                Clear-Host
                                Update_Variables
                                Draw_Introduction_Tasks
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
                                Draw_Player_Window_and_Stats
                                Draw_Town_Map
                                # update building words in location map. white to current building and reset location to dark yellow 
                                $host.UI.RawUI.ForegroundColor = "DarkYellow"
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 73,1;$Host.UI.Write("Home Town")
                                $host.UI.RawUI.ForegroundColor = "White"
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,2;$Host.UI.Write("Anvil")
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,3;$Host.UI.Write("& Blade")
                                Draw_Info_Banner
                                Draw_Inventory
                                $host.UI.RawUI.ForegroundColor = "DarkYellow"
                                $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 18,10;$Host.UI.Write("(+$($Script:Anvil_Choice_Sell_Junk_GoldValue))")
                            }
                            $Script:Selectable_ID_Search = "not_set"
                            $First_Time_Entered_Anvil = $false
                            if ($Anvil_Sell_Choice -ieq "e") { # leaves the Anvil & Blade
                                Break
                            }
                        }
                        
                    } until ($Anvil_Choice -ieq "e")
                }
                m { # Mend & Mana
                    # update building words in location map. white to current building and reset location to dark yellow 
                    $host.UI.RawUI.ForegroundColor = "DarkYellow"
                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 73,1;$Host.UI.Write("Home Town")
                    $host.UI.RawUI.ForegroundColor = "White"
                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,9;$Host.UI.Write("Mend")
                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,10;$Host.UI.Write("& Mana")
                    $First_Time_Entered_Elixir_Emporium = $true
                    do {
                        $Script:Info_Banner = "Mend & Mana"
                        Draw_Info_Banner
                        Draw_Inventory
                        do {
                            if ($First_Time_Entered_Elixir_Emporium -eq $false) {
                                for ($Position = 17; $Position -lt 35; $Position++) { # clear some lines from previous widow
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                }
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                Write-Color "  Maybe there is something else you might like?" -Color DarkGray
                            } else {
                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                Write-Color "  Welcome adventurer." -Color DarkGray
                                Write-Color "  I deal in all kinds of potions. If you are interested, take a look at what i have to offer." -Color DarkGray
                            }
                            # update introduction task and update Introduction Tasks window
                            $Import_JSON.Introduction_Tasks.Tick_Visit_Mend_and_Mana = $true
                            Save_JSON
                            Write-Color -LinesBefore 1 "  P","urchase some postions" -Color Green,DarkYellow
                            Write-Color "  S","ell some postions" -Color Green,DarkYellow
                            Write-Color "  E","xit" -Color Green,DarkYellow
                            Draw_Introduction_Tasks
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                            Write-Color -NoNewLine "P","urchase, ","S","ell, or ", "E","xit ","[P/S/E]" -Color Green,DarkYellow,Green,DarkYellow,Green,DarkYellow,Green
                            $Elixir_Emporium_Choice = Read-Host " "
                            $Elixir_Emporium_Choice = $Elixir_Emporium_Choice.Trim()
                        } until ($Elixir_Emporium_Choice -ieq "p" -or $Elixir_Emporium_Choice -ieq "s" -or $Elixir_Emporium_Choice -ieq "e")
                        if ($Elixir_Emporium_Choice -ieq "p") {
                            $First_Time_Entered_Elixir_Emporium = $true
                            $Script:Info_Banner = "Mend & Mana - Purchase"
                            Draw_Info_Banner
                            do {
                                do {
                                    for ($Position = 17; $Position -lt 19; $Position++) { # clear some lines from previous widow
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                    }
                                    # $Elixir_Emporium_Potion_Name_Array = New-Object System.Collections.Generic.List[System.Object]
                                    $Elixir_Emporium_Potion_Letters_Array = New-Object System.Collections.Generic.List[System.Object]
                                    # $Elixir_Emporium_Choice_Sell_GoldValue = New-Object System.Collections.Generic.List[System.Object]
                                    $Inventory_Item_Names = $Import_JSON.Items.PSObject.Properties.Name | Sort-Object
                                    $Script:Selectable_ID_Search = "HealthMana"
                                    Clear-Host
                                    Draw_Introduction_Tasks
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
                                    Draw_Player_Window_and_Stats
                                    Draw_Town_Map
                                    # update building words in location map. white to current building and reset location to dark yellow 
                                    $host.UI.RawUI.ForegroundColor = "DarkYellow"
                                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 73,1;$Host.UI.Write("Home Town")
                                    $host.UI.RawUI.ForegroundColor = "White"
                                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,9;$Host.UI.Write("Mend")
                                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,10;$Host.UI.Write("& Mana")
                                    Draw_Info_Banner
                                    Draw_Inventory
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                    Draw_Shop_Potions
                                    $Elixir_Emporium_Potion_Letters_Array_String = $Elixir_Emporium_Potion_Letters_Array -Join "/"
                                    $Elixir_Emporium_Potion_Letters_Array_String = $Elixir_Emporium_Potion_Letters_Array_String + "/E"
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("");" "*105
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                    Write-Color -NoNewLine "  Which potion do you want to purchase? " -Color DarkYellow
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                    Write-Color -NoNewLine "ID ","numbers or ", "E","xit ","[$Elixir_Emporium_Potion_Letters_Array_String]" -Color Green,DarkYellow,Green,DarkYellow,Green
                                    $Elixir_Emporium_Purchase_Choice = Read-Host " "
                                    $Elixir_Emporium_Purchase_Choice = $Elixir_Emporium_Purchase_Choice.Trim()
                                } until ($Elixir_Emporium_Purchase_Choice -ieq "e" -or $Elixir_Emporium_Purchase_Choice -in $Elixir_Emporium_Potion_Letters_Array)
                                $Script:Selectable_ID_Search = "not_set"
                                $First_Time_Entered_Elixir_Emporium = $false
                                if ($Elixir_Emporium_Purchase_Choice -ieq "e") {
                                    Break
                                }
                                # ID number chosen
                                switch ($Elixir_Emporium_Purchase_Choice) {
                                    $Elixir_Emporium_Purchase_Choice {
                                        foreach ($Inventory_Item_Name in $Inventory_Item_Names) {
                                            if ($Import_JSON.Items.$Inventory_Item_Name.ID -ieq $Elixir_Emporium_Purchase_Choice) {
                                                $Elixir_Emporium_Purchase_Choice_Potion_Name = $Import_JSON.Items.$Inventory_Item_Name.Name
                                                $Elixir_Emporium_Purchase_Choice_Potion_Quantity = $Import_JSON.Items.$Inventory_Item_Name.Quantity
                                                $Elixir_Emporium_Purchase_Choice_Potion_GoldValue = $Import_JSON.Items.$Inventory_Item_Name.GoldValue
                                                $Elixir_Emporium_Purchase_Choice_Potion_Quantity_Max = 99 - $Elixir_Emporium_Purchase_Choice_Potion_Quantity
                                            }
                                        }
                                        # check if quantity of potion is already at max, display you cannot carry any more
                                        if ($Elixir_Emporium_Purchase_Choice_Potion_Quantity -eq 99) {
                                            do {
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                                Write-Color -NoNewLine "You cannot carry any more ","$Elixir_Emporium_Purchase_Choice_Potion_Name","'s ", "E","xit ","[E]" -Color DarkYellow,DarkCyan,DarkYellow,Green,DarkYellow,Green
                                                $Elixir_Emporium_Purchase_Potion_Quantity_Choice = Read-Host " "
                                                $Elixir_Emporium_Purchase_Potion_Quantity_Choice = $Elixir_Emporium_Purchase_Potion_Quantity_Choice.Trim()
                                            } until ($Elixir_Emporium_Purchase_Potion_Quantity_Choice -ieq "E")
                                        } else { # otherwise ask for quantity
                                            do {
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("");" "*105
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                                Write-Color -NoNewLine "  How many ","$Elixir_Emporium_Purchase_Choice_Potion_Name","'s do you want to purchase?" -Color DarkYellow,DarkCyan,DarkYellow
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                                Write-Color -NoNewLine "Quantity or ", "E","xit ","[1-$Elixir_Emporium_Purchase_Choice_Potion_Quantity_Max/E]" -Color DarkYellow,Green,DarkYellow,Green
                                                # Write-Color -NoNewLine "Quantity or ", "E","xit ","[1-$Potion_Quantity/E]" -Color DarkYellow,Green,DarkYellow,Green
                                                $Elixir_Emporium_Purchase_Potion_Quantity_Choice = Read-Host " "
                                                $Elixir_Emporium_Purchase_Potion_Quantity_Choice = $Elixir_Emporium_Purchase_Potion_Quantity_Choice.Trim()
                                                # check if input is a number or E
                                                if ($Elixir_Emporium_Purchase_Potion_Quantity_Choice -match "^[0-9]+$") {
                                                    $Elixir_Emporium_Purchase_Potion_Quantity_Choice = [int]$Elixir_Emporium_Purchase_Potion_Quantity_Choice
                                                }
                                                if ($null -eq $Elixir_Emporium_Purchase_Potion_Quantity_Choice -or $Elixir_Emporium_Purchase_Potion_Quantity_Choice -eq ""){# sets to null if not a number or E which stops allowing no input
                                                    $Elixir_Emporium_Purchase_Potion_Quantity_Choice = "not_set"
                                                }
                                            } until ($Elixir_Emporium_Purchase_Potion_Quantity_Choice -ieq "E" -or $Elixir_Emporium_Purchase_Potion_Quantity_Choice -le ($Elixir_Emporium_Purchase_Choice_Potion_Quantity_Max))
                                            if ($Elixir_Emporium_Purchase_Potion_Quantity_Choice -ieq "E") { # exit
                                                Break
                                            }
                                            $Elixir_Emporium_Purchase_Choice_Potion_GoldValue = $Elixir_Emporium_Purchase_Potion_Quantity_Choice * $Elixir_Emporium_Purchase_Choice_Potion_GoldValue
                                            # if already at max quantity, disply you cannot carry any more
                                            if ($Elixir_Emporium_Purchase_Choice_Potion_Quantity -eq 99) {
                                                do {
                                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                                    Write-Color -NoNewLine "You cannot carry any more ","$Elixir_Emporium_Purchase_Choice_Potion_Name","'s ", "E","xit ","[E]" -Color DarkYellow,DarkCyan,DarkYellow,Green,DarkYellow,Green
                                                    $Elixir_Emporium_Purchase_Potion_Quantity_Choice = Read-Host " "
                                                    $Elixir_Emporium_Purchase_Potion_Quantity_Choice = $Elixir_Emporium_Purchase_Potion_Quantity_Choice.Trim()
                                                } until ($Elixir_Emporium_Purchase_Potion_Quantity_Choice -ieq "E")
                                            } elseif ($Elixir_Emporium_Purchase_Choice_Potion_GoldValue -gt $Import_JSON.Character.Gold) { # check if player has enough gold
                                                $Elixir_Emporium_Purchase_Need_x_More_Gold = $Elixir_Emporium_Purchase_Choice_Potion_GoldValue - $Import_JSON.Character.Gold
                                                if ($Elixir_Emporium_Purchase_Potion_Quantity_Choice -eq 1) {
                                                    $Single_or_Multiple = ""
                                                } else {
                                                    $Single_or_Multiple = "'s"
                                                }
                                                do {
                                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("");" "*105
                                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                                    Write-Color "  You don't have enough gold to purchase ","$Elixir_Emporium_Purchase_Potion_Quantity_Choice"," $Elixir_Emporium_Purchase_Choice_Potion_Name","$Single_or_Multiple. You need ","$Elixir_Emporium_Purchase_Need_x_More_Gold"," more gold." -Color DarkGray,white,Blue,DarkGray,DarkYellow,DarkGray
                                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                                    Write-Color -NoNewLine "E","xit ","[E]" -Color Green,DarkYellow,Green
                                                    $Elixir_Emporium_Purchase_Potion_Quantity_Choice = Read-Host " "
                                                    $Elixir_Emporium_Purchase_Potion_Quantity_Choice = $Elixir_Emporium_Purchase_Potion_Quantity_Choice.Trim()
                                                } until ($Elixir_Emporium_Purchase_Potion_Quantity_Choice -ieq "E")
                                            } else { # otherwise confirm quantity
                                                do {
                                                    # displaying correct grammar for singular or plural potion
                                                    if ($Elixir_Emporium_Purchase_Potion_Quantity_Choice -eq 1) {
                                                        $Single_or_Multiple = " is"
                                                    } else {
                                                        $Single_or_Multiple = "'s are"
                                                    }
                                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("");" "*105
                                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                                    Write-Color "  $Elixir_Emporium_Purchase_Potion_Quantity_Choice ","$Elixir_Emporium_Purchase_Choice_Potion_Name","$Single_or_Multiple worth ","$Elixir_Emporium_Purchase_Choice_Potion_GoldValue Gold",", do you want to purchase?" -Color White,DarkCyan,DarkGray,DarkYellow,DarkGray
                                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                                    Write-Color -NoNewLine "Y","es or ", "N","o ","[Y/N]" -Color Green,DarkYellow,Green,DarkYellow,Green
                                                    $Elixir_Emporium_Purchase_Potion_Confirm_Choice = Read-Host " "
                                                    $Elixir_Emporium_Purchase_Potion_Confirm_Choice = $Elixir_Emporium_Purchase_Potion_Confirm_Choice.Trim()
                                                } until ($Elixir_Emporium_Purchase_Potion_Confirm_Choice -ieq "Y" -or $Elixir_Emporium_Purchase_Potion_Confirm_Choice -ieq "N")
                                                if ($Elixir_Emporium_Purchase_Potion_Confirm_Choice -ieq "Y") {
                                                    # update items in invenroty and gold
                                                    $Import_JSON.Items.$Elixir_Emporium_Purchase_Choice_Potion_Name.Quantity += $Elixir_Emporium_Purchase_Potion_Quantity_Choice
                                                    $Import_JSON.Character.Gold -= $Elixir_Emporium_Purchase_Choice_Potion_GoldValue
                                                    Save_JSON
                                                    Update_Variables
                                                    # update introduction task and update Introduction Tasks window
                                                    $Import_JSON.Introduction_Tasks.Tick_Purchase_a_Potion = $true
                                                    $Import_JSON.Locations."Home Town".Location_Options.Hunt = $true
                                                    # Introdution Tasks window updated on next loop above
                                                    Save_JSON
                                                }
                                            }
                                        }
                                    }
                                    # Default {}
                                }
                            } until ($Elixir_Emporium_Purchase_Choice -ieq "e")
                        }
                        if ($Elixir_Emporium_Choice -ieq "s") {
                            $First_Time_Entered_Elixir_Emporium = $true
                            $Script:Info_Banner = "Mend & Mana - Sell"
                            Draw_Info_Banner
                            do {
                                do {
                                    for ($Position = 17; $Position -lt 19; $Position++) { # clear some lines from previous widow
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                                    }
                                    $Elixir_Emporium_Potion_Letters_Array = New-Object System.Collections.Generic.List[System.Object]
                                    $Inventory_Item_Names = $Import_JSON.Items.PSObject.Properties.Name | Sort-Object
                                    $Script:Selectable_ID_Search = "HealthMana"
                                    Clear-Host
                                    Draw_Introduction_Tasks
                                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
                                    Draw_Player_Window_and_Stats
                                    Draw_Town_Map
                                    # update building words in location map. white to current building and reset location to dark yellow 
                                    $host.UI.RawUI.ForegroundColor = "DarkYellow"
                                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 73,1;$Host.UI.Write("Home Town")
                                    $host.UI.RawUI.ForegroundColor = "White"
                                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,9;$Host.UI.Write("Mend")
                                    $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 92,10;$Host.UI.Write("& Mana")
                                    Draw_Info_Banner
                                    Draw_Inventory
                                    foreach ($Inventory_Item_Name in $Inventory_Item_Names) {
                                        # if there are potions in inventory, add them to the array
                                        if ($Import_JSON.Items.$Inventory_Item_Name.Name -like "*mana potion*" -or $Import_JSON.Items.$Inventory_Item_Name.Name -like "*health potion*" -and $Import_JSON.Items.$Inventory_Item_Name.Quantity -gt 0) {
                                            $Elixir_Emporium_Potion_Letters_Array.Add($Import_JSON.Items.$Inventory_Item_Name.ID)
                                            # $Elixir_Emporium_Choice_Sell_Quantity.Add($Import_JSON.Items.$Inventory_Item_Name.Quantity)
                                            # $Elixir_Emporium_Choice_Sell_GoldValue.Add($Import_JSON.Items.$Inventory_Item_Name.GoldValue)
                                            $Elixir_Emporium_Potion_Letters_Array_String = $Elixir_Emporium_Potion_Letters_Array -Join "/"
                                            $Elixir_Emporium_Potion_Letters_Array_String = $Elixir_Emporium_Potion_Letters_Array_String + "/E"
                                        }
                                    }
                                    if ($Elixir_Emporium_Potion_Letters_Array.Count -gt 0) { # potions in inventory
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                        Write-Color "  Which potion do you want to sell?" -Color DarkGray
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                        Write-Color -NoNewLine "ID ","numbers or ", "E","xit ","[$Elixir_Emporium_Potion_Letters_Array_String]" -Color Green,DarkYellow,Green,DarkYellow,Green
                                    } else { # no potions so only "E" (no slash)
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                        if ($First_Time_Entered_Elixir_Emporium -eq $true) {
                                            Write-Color "  It doesn't look like you have any potions to sell." -Color DarkGray
                                        } else {
                                            Write-Color "  It doesn't look like you have any more potions to sell." -Color DarkGray
                                        }
                                        $Elixir_Emporium_Potion_Letters_Array_String = "E"
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                        Write-Color -NoNewLine "E","xit ","[$Elixir_Emporium_Potion_Letters_Array_String]" -Color Green,DarkYellow,Green
                                    }
                                    $Elixir_Emporium_Sell_Choice = Read-Host " "
                                    $Elixir_Emporium_Sell_Choice = $Elixir_Emporium_Sell_Choice.Trim()
                                } until ($Elixir_Emporium_Sell_Choice -ieq "e" -or $Elixir_Emporium_Sell_Choice -in $Elixir_Emporium_Potion_Letters_Array)
                                $Script:Selectable_ID_Search = "not_set"
                                $First_Time_Entered_Elixir_Emporium = $false
                                if ($Elixir_Emporium_Sell_Choice -ieq "e") {
                                    Break
                                }
                                # ID number chosen
                                switch ($Elixir_Emporium_Sell_Choice) {
                                    $Elixir_Emporium_Sell_Choice {
                                        foreach ($Inventory_Item_Name in $Inventory_Item_Names) {
                                            if ($Import_JSON.Items.$Inventory_Item_Name.ID -eq $Elixir_Emporium_Sell_Choice) {
                                                $Potion_Quantity = $Import_JSON.Items.$Inventory_Item_Name.Quantity
                                                $Potion_GoldValue = $Import_JSON.Items.$Inventory_Item_Name.GoldValue
                                                Break
                                            }
                                        }
                                        do {
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                            Write-Color "  How many ","$Inventory_Item_Name's"," do you want to sell?" -Color DarkGray,Blue,DarkGray
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                            Write-Color -NoNewLine "Quantity or ", "E","xit ","[1-$Potion_Quantity/E]" -Color DarkYellow,Green,DarkYellow,Green
                                            $Elixir_Emporium_Sell_Potion_Quantity_Choice = Read-Host " "
                                            $Elixir_Emporium_Sell_Potion_Quantity_Choice = $Elixir_Emporium_Sell_Potion_Quantity_Choice.Trim()
                                            # check if input is a number or E
                                            if ($Elixir_Emporium_Sell_Potion_Quantity_Choice -match "^[0-9]+$") {
                                                $Elixir_Emporium_Sell_Potion_Quantity_Choice = [int]$Elixir_Emporium_Sell_Potion_Quantity_Choice
                                            }
                                            if ($null -eq $Elixir_Emporium_Sell_Potion_Quantity_Choice -or $Elixir_Emporium_Sell_Potion_Quantity_Choice -eq ""){# sets to null if not a number or E which stops allowing no input
                                                $Elixir_Emporium_Sell_Potion_Quantity_Choice = "not_set"
                                            }
                                        } until ($Elixir_Emporium_Sell_Potion_Quantity_Choice -ieq "E" -or $Elixir_Emporium_Sell_Potion_Quantity_Choice -le $Potion_Quantity)
                                        if ($Elixir_Emporium_Sell_Potion_Quantity_Choice -ieq "E") { # exit
                                            Break
                                        } else { # quantity confirm
                                            do {
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                                                # displaying correct grammar for singular or plural potion
                                                if ($Elixir_Emporium_Sell_Potion_Quantity_Choice -eq 1) {
                                                    $Single_or_Multiple = ""
                                                } else {
                                                    $Single_or_Multiple = "'s"
                                                }
                                                Write-Color "  $Elixir_Emporium_Sell_Potion_Quantity_Choice ","$($Import_JSON.Items.$Inventory_Item_Name.Name)$Single_or_Multiple"," are worth ","$($Potion_GoldValue*$Elixir_Emporium_Sell_Potion_Quantity_Choice) Gold",", do you want to sell them?" -Color White,DarkCyan,DarkGray,DarkYellow,DarkGray
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                                                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                                                Write-Color -NoNewLine "Y","es or ", "N","o ","[Y/N]" -Color Green,DarkYellow,Green,DarkYellow,Green
                                                $Elixir_Emporium_Sell_Potion_Confirm_Choice = Read-Host " "
                                                $Elixir_Emporium_Sell_Potion_Confirm_Choice = $Elixir_Emporium_Sell_Potion_Confirm_Choice.Trim()
                                            } until ($Elixir_Emporium_Sell_Potion_Confirm_Choice -ieq "Y" -or $Elixir_Emporium_Sell_Potion_Confirm_Choice -ieq "N")
                                            if ($Elixir_Emporium_Sell_Potion_Confirm_Choice -ieq "Y") {
                                                # update items in invenroty and gold
                                                $Import_JSON.Items.$Inventory_Item_Name.Quantity -= $Elixir_Emporium_Sell_Potion_Quantity_Choice
                                                $Import_JSON.Character.Gold += $Potion_GoldValue * $Elixir_Emporium_Sell_Potion_Quantity_Choice
                                                Save_JSON
                                                Update_Variables
                                            }
                                        }
                                    }
                                    # Default {}
                                }
                            } until ($Elixir_Emporium_Sell_Choice -ieq "e")
                            #
                        }
                    } until ($Elixir_Emporium_Choice -ieq "e")
                }
                # Default {}
            }
        }
        # switch choice for The Forest
        if ($Current_Location -ieq "The Forest") {
            switch ($Building_Choice) {
                e { # exit
                    for ($Position = 17; $Position -lt 34; $Position++) { # clear some lines from previous widow
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                    }
                }
                h { # Hut
                    for ($Position = 17; $Position -lt 34; $Position++) { # clear some lines from previous widow
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                    }
                }
                t { # Tree House
                    for ($Position = 17; $Position -lt 34; $Position++) { # clear some lines from previous widow
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                    }
                }
                s { # Secret Location
                    for ($Position = 17; $Position -lt 34; $Position++) { # clear some lines from previous widow
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                    }
                }
                # Default {}
            }
        }
        # switch choice for The River
        if ($Current_Location -ieq "The River") {
            switch ($Building_Choice) {
                e { # exit
                    for ($Position = 17; $Position -lt 34; $Position++) { # clear some lines from previous widow
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                    }
                }
                c { # Camp
                    for ($Position = 17; $Position -lt 34; $Position++) { # clear some lines from previous widow
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                    }
                }
                # Default {}
            }
        }
        # below is run if Q quit is chosen in any location
        Save_JSON
        Clear-Host
        Draw_Introduction_Tasks
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
        Draw_Player_Window_and_Stats
    } until ($Building_Choice -ieq "e")
}

#
# draw quest log
#
Function Draw_Quest_Log {
    Do {
        # $Script:Info_Banner = "Quest Log"
        # Draw_Info_Banner
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 56,0;$Host.UI.Write("")
        Write-Color "+---------------------------------+-------------+" -Color DarkGray
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 56,1;$Host.UI.Write("")
        Write-Color "| ","Quest Log","                       | ","Status","      |" -Color DarkGray,White,DarkGray,White,DarkGray
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 56,2;$Host.UI.Write("")
        Write-Color "+---------------------------------+-------------+" -Color DarkGray
        $Position = 2
        $Available_Quest_Letters_Array = New-Object System.Collections.Generic.List[System.Object]
        $Quest_Names = $Import_JSON.Quests.PSObject.Properties.Name
        $Quest_In_Progress_Count = 0
        foreach ($Quest_Name in $Quest_Names) {
            $Quest_Name = $Import_JSON.Quests.$Quest_Name
            $Quest_Log_Name_Right_Padding = " "*(32 - $Quest_Name.Name.Length)
            $Quest_Log_Status_Right_Padding = " "*(12 - $Quest_Name.Status.Length)
            if ($Quest_Name.Status -ieq "In Progress" -or $Quest_Name.Status -ieq "Hand In") {
                $Quest_In_Progress_Count += 1
                $Position += 1
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 56,$Position;$Host.UI.Write("")
                Write-Color "| ","$($Quest_Name.Quest_Letter)","$($Quest_Name.Name.SubString(1.0))$Quest_Log_Name_Right_Padding| ","$($Quest_Name.Status)$Quest_Log_Status_Right_Padding","|" -Color DarkGray,Green,DarkGray,DarkYellow,DarkGray
                $Available_Quest_Letters_Array.Add($Quest_Name.Quest_Letter)
            }
        }
        $Quest_Log_Extra_Blank_Lines = 10 - $Quest_In_Progress_Count
        for ($index = 0; $index -lt $Quest_Log_Extra_Blank_Lines; $index++) {
            $Position += 1
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 56,$Position;$Host.UI.Write("")
            Write-Color "|                                 |             |" -Color DarkGray
        }
        # if there are no quests, only add "E" to letters string array so it's the only choice
        if ($Quest_Log_Extra_Blank_Lines -eq 10) {
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 58,3;$Host.UI.Write("Quest Log Empty")
            $In_Progress_Quest_Letters_Array_String = $Available_Quest_Letters_Array + "E"
        } else { # or join all the letters together with slashes and add "E" to the end
            $In_Progress_Quest_Letters_Array_String = $Available_Quest_Letters_Array -Join "/"
            $In_Progress_Quest_Letters_Array_String = $In_Progress_Quest_Letters_Array_String + "/E"
        }
        $Position += 1
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 56,$Position;$Host.UI.Write("")
        Write-Color "+---------------------------------+-------------+" -Color DarkGray
        do {
            Save_JSON
            for ($Position = 14; $Position -lt 34; $Position++) { # clear some lines from previous widow
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
            }
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
            Write-Color -NoNewLine "Select a Quest for more info, or ","E","xit ", "[$In_Progress_Quest_Letters_Array_String]" -Color DarkYellow,Green,DarkYellow,Green
            $Quest_Log_Choice = Read-Host " "
            $Quest_Log_Choice = $Quest_Log_Choice.Trim()
        } until ($Quest_Log_Choice -ieq "e" -or $Quest_Log_Choice -in $Available_Quest_Letters_Array)
        switch ($Quest_Log_Choice) {
            e {
                Break
            }
            $Quest_Log_Choice {
                $Script:Info_Banner = "Quest Log Info"
                Draw_Info_Banner
                do {
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                    foreach ($Quest_Name in $Quest_Names) {
                        $Quest_Name = $Import_JSON.Quests.$Quest_Name
                        if ($Quest_Name.Quest_Letter -ieq $Quest_Log_Choice) {
                            Write-Color "  Name        ",": $($Quest_Name.Name)" -Color White,DarkGray
                            Write-Color "  Description ",": $($Quest_Name.Description)" -Color White,DarkGray
                            Write-Color "  Reward      ",": $($Quest_Name.Gold_Reward)"," Gold" -Color White,DarkGray,DarkYellow
                            Write-Color "  Progress    ",": $($Quest_Name.Progress) of $($Quest_Name.Progress_Max)" -Color White,DarkGray
                            Write-Color "  Status      ",": $($Quest_Name.Status)" -Color White,DarkGray
                            Write-Color "  Location    ",": $($Quest_Name.Hand_In_Location)" -Color White,DarkGray
                            Write-Color "  Building    ",": $($Quest_Name.Building)" -Color White,DarkGray
                            Write-Color "  NPC         ",": $($Quest_Name.Hand_In_NPC)" -Color White,DarkGray
                        }
                    }
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                    Write-Color -NoNewLine "E","xit ","[E]" -Color Green,DarkYellow,Green
                    $Quest_Log_Info_Choice = Read-Host " "
                    $Quest_Log_Info_Choice = $Quest_Log_Info_Choice.Trim()
                } until ($Quest_Log_Info_Choice -ieq "e")
            }
            Default {}
        }
    } until ($Quest_Log_Choice -ieq "e")
}

# clears mob window
Function Clear_Mob_Window {
    for ($Position = 0; $Position -lt 14; $Position++) {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 56,$Position;$Host.UI.Write("");" "*49
    }
}


#
# PLACE FUNCTIONS ABOVE HERE
#

Clear-Host

# write any errors out to error.log file
Trap {
    $Time = Get-Date -Format "HH:mm:ss"
    Add-Content -Path .\error.log -value "-Trap Error $Time ----------------------------------" # leave in
    Add-Content -Path .\error.log -value "$PSItem" # leave in
    Add-Content -Path .\error.log -value "------------------------------------------------------" # leave in
}

# get version of PS-RPG from PS-RPG_version.txt (updated via GitHub commits)
if (Test-Path ".\PS-RPG_version.txt") {
    $PSRPG_Version = Get-Content ".\PS-RPG_version.txt" -Raw
} else {
    $PSRPG_Version = "<version file`r`n           missing>"
}

#
# Pre-requisite checks (install / import / update PSWriteColor module)
#
if (-not(Test-Path -Path .\PS-RPG.json)) {
    # adjust window size
    do {
        Clear-Host
        Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor DarkYellow
        for ($index = 0; $index -lt 36; $index++) {
            Write-Host "+                                                                                                                                                              +" -ForegroundColor DarkYellow
        }
        Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor DarkYellow
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 20,10;$Host.UI.Write( "Using the CTRL + mouse scroll wheel forward and back,")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 20,11;$Host.UI.Write( "adjust the font size to make sure the yellow box fits within the screen.")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 2,36;$Host.UI.Write("")
        Write-Host -NoNewline "Adjust font size with CTRL + mouse scroll wheel, then confirm with 'go' and Enter"
        $Adjust_Font_Size = Read-Host " "
        $Adjust_Font_Size = $Adjust_Font_Size.Trim()
    } until ($Adjust_Font_Size -ieq "go")
    Clear-Host
    Write-Host "Pre-requisite checks" -ForegroundColor Red
    Write-Host "--------------------" -ForegroundColor Red
    Write-Output "`r`nChecking if PSWriteColor module is installed."
    $PSWriteColor_Installed = Get-Module -Name "PSWriteColor" -ListAvailable
    # PSWriteColor is installed so import it
    if ($PSWriteColor_Installed) {
        Write-Host "PSWriteColor module is installed." -ForegroundColor Green
        $PSWriteColor_Installed
        $PSWriteColor_Installed_Version = $PSWriteColor_Installed.Version
        Write-Output "`r`nChecing if there is a new version of PSWriteColor."
        # check for new module and update on prompt
        $PSWriteColor_Online_Version = Find-Module -Name "PSWriteColor"
        if ($PSWriteColor_Installed_Version -lt $PSWriteColor_Online_Version.Version) {
            Write-Host "Version available: $($PSWriteColor_Online_Version.Version)" -ForegroundColor Green
            Write-Host "Version installed: $($PSWriteColor_Installed_Version)"
            do {
                Write-Host -NoNewline "`r`nDo you want to update to version $($PSWriteColor_Online_Version.Version)? [Y/N]"
                $Update_PSWriteColor_Choice = Read-Host " "
                $Update_PSWriteColor_Choice = $Update_PSWriteColor_Choice.Trim()
            } until ($Update_PSWriteColor_Choice -ieq "y" -or $Update_PSWriteColor_Choice -ieq "n")
            if ($Update_PSWriteColor_Choice -ieq "y") {
                Write-Output "Updating PSWriteColor module."
                Write-Output "Install path will be $ENV:USERPROFILE\Documents\WindowsPowerShell\Modules\"
                Write-Host "Uninstalling PSWriteColor module Version $PSWriteColor_Installed_Version"
                Uninstall-Module -Name "PSWriteColor" # no confirmation prompt
                Write-Host "Installing PSWriteColor module version $($PSWriteColor_Online_Version.Version)"
                Install-Module -Name "PSWriteColor" -Scope CurrentUser -Confirm:$false -Force
                $Install_PSWrite_Color_ExitCode = $?
                if ($Install_PSWrite_Color_ExitCode -eq $true) {
                    $PSWriteColor_Installed = Get-Module -Name "PSWriteColor" -ListAvailable
                    if ($PSWriteColor_Installed.Version -eq $PSWriteColor_Online_Version.Version) {
                        $PSWriteColor_Installed = Get-Module -Name PSWriteColor -ListAvailable
                        Write-Host "PSWriteColor module version $($PSWriteColor_Installed.Version) installed." -ForegroundColor Green
                        $PSWriteColor_Installed | Format-Table
                    } else {
                        Write-Host "`r`nNo PSWriteColor module installed. Please re-run PS-RPG.ps1" -ForegroundColor Red
                        Exit
                    }
                } else {
                    Write-Host "PSWriteColor module version $($PSWriteColor_Online_Version.Version) FAILED to install. Please re-run PS-RPG.ps1" -ForegroundColor Red
                    Exit
                }
            }
            if ($Update_PSWriteColor_Choice -ieq "n") {
                Write-Output "Not updating PSWriteColor module."
            }
        } else {
            Write-Output "`r`nPSWriteColor module is up-to-date."
        }
        Write-Output "`r`nImporting PSWriteColor module."
        Import-Module -Name "PSWriteColor"
        $PSWriteColor_Installed_Version = Get-Module -Name "PSWriteColor" -ListAvailable
        if ($PSWriteColor_Installed_Version) {
            Write-Host "PSWriteColor module version $($PSWriteColor_Installed_Version.Version) imported." -ForegroundColor Green
        } else {
            Write-Host "PSWriteColor module not imported." -ForegroundColor Red
            Break
        }
        Start-Sleep -Seconds 3 # leave in
    } else { # otherwise ask for module to be installed
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
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
            Write-Color -NoNewLine "No save file found. Are you ready to start playing ", "PS-RPG", "?"," [Y/N/E]" -Color DarkYellow,Magenta,DarkYellow,Green
            $Ready_To_Play_PSRPG = Read-Host " "
            $Ready_To_Play_PSRPG = $Ready_To_Play_PSRPG.Trim()
        } until ($Ready_To_Play_PSRPG -ieq "y" -or $Ready_To_Play_PSRPG -ieq "n" -or $Ready_To_Play_PSRPG -ieq "e")
        if ($Ready_To_Play_PSRPG -ieq "n" -or $Ready_To_Play_PSRPG -ieq "e") {
            do {
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                Write-Color -NoNewLine "Do you want to quit ", "PS-RPG", "?"," [Y/N]" -Color DarkYellow,Magenta,DarkYellow,Green
                $Quit_Game = Read-Host " "
                $Quit_Game = $Quit_Game.Trim()
            } until ($Quit_Game -ieq "y" -or $Quit_Game -ieq "n")
            if ($Quit_Game -ieq "y") {
                Write-Color -NoNewLine "Exiting ","PS-RPG","." -Color DarkYellow,Magenta,DarkYellow
                Exit
            }
        }
    } until ($Ready_To_Play_PSRPG -ieq "y")
}

# double check module is still installed if JSON file has previously been created, just in case the module has been removed.
if (Test-Path -Path .\PS-RPG.json) {
    $PSWriteColor_Installed = Get-Module -Name "PSWriteColor" -ListAvailable
    if ($PSWriteColor_Installed) {
        Import-Module -Name "PSWriteColor"
    } else {
        Install_PSWriteColor
    }
}

#
# check for JSON save file
#
# if the save file has the Character_Creation flag set to false, deletes JSON file (i.e. if character creation was cancelled or not fully completed - safe to delete file)
if (Test-Path -Path .\PS-RPG.json) {
    Import_JSON
    if ($Import_JSON.Character_Creation -eq $false) {
        Remove-Item -Path .\PS-RPG.json
    }
}
# loads save file and validate JSON file is on PowerShell Core edition
if (Test-Path -Path .\PS-RPG.json) {
    # check for powershell core or desktop then validate json data file
    if ($PSVersionTable.PSEdition -ieq "Desktop") { # unable to validata JSON file in PowerShell Desktop edition
        Write-Color -LinesBefore 1 "Unable to validate JSON file because ","PS-RPG.ps1 ","is running under PowerShell 'Desktop' edition." -Color DarkYellow,Magenta,DarkYellow
        Write-Color "Continuing." -Color DarkYellow
        Start-Sleep -Seconds 6 # leave in
    }
    if ($PSVersionTable.PSEdition -ieq "Core") { # check if JSON file is valid under PowerShell Core edition
        $JSON_File_Valid = Test-Json -Path .\PS-RPG.json
        if ($JSON_File_Valid -eq $false) {
            Write-Color -LinesBefore 1 "Invalid ","PS-RPG.json"," file. Please download JSON file again from ","https://github.com/RPGash/PS-RPG ","Exiting." -Color Red,Magenta,Red,Magenta,Red,DarkCyan
            Write-Color "Exiting ","PS-RPG.ps1" -Color Red,Magenta
            Exit
        } else {
            Write-Color "PS-RPG.json"," file is ","valid." -Color Magenta,DarkYellow,Green
            # Start-Sleep -Seconds 1 # pause to show valid JSON message
        }
    }
    do {
        Clear-Host
        # display current saved file info
        Import_JSON
        Update_Variables
        Draw_Player_Window_and_Stats
        Draw_Inventory
        Draw_Introduction_Tasks
        do {
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
            Write-Color -NoNewLine "PS-RPG.json ","save data found. Load saved data?"," [Y/N/E]" -Color Magenta,DarkYellow,Green
            $Load_Save_Data_Choice = Read-Host " "
            $Load_Save_Data_Choice = $Load_Save_Data_Choice.Trim()
        } until ($Load_Save_Data_Choice -ieq "y" -or $Load_Save_Data_Choice -ieq "n" -or $Load_Save_Data_Choice -ieq "e")
        if ($Load_Save_Data_Choice -ieq "e") {
            Write-Color -NoNewLine "Exiting ","PS-RPG","." -Color DarkYellow,Magenta,DarkYellow
            Exit
        }
        if ($Load_Save_Data_Choice -ieq "y") {
            # Import_JSON
            # Update_Variables
            Clear-Host
            Draw_Player_Window_and_Stats
        }
        if ($Load_Save_Data_Choice -ieq "n") {
            do {
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                Write-Color -NoNewLine "Start a new game?"," [Y/N/E]" -Color Magenta,Green
                $Start_A_New_Game = Read-Host " "
                $Start_A_New_Game = $Start_A_New_Game.Trim()
            } until ($Start_A_New_Game -ieq "y" -or $Start_A_New_Game -ieq "n" -or $Start_A_New_Game -ieq "e")
            if ($Start_A_New_Game -ieq "y") {
                # new game
                Create_Character
                Tutorial
            }
        }
    } until ($Load_Save_Data_Choice -ieq "y" -or $Start_A_New_Game -ieq "y" -or $Start_A_New_Game -ieq "e")
} else {
    # no JSON file found
    Create_Character
    Tutorial
}
if ($Load_Save_Data_Choice -ieq "e" -or $Start_A_New_Game -ieq "e") {
    Write-Color -NoNewLine "Quitting ","PS-RPG","." -Color DarkYellow,Magenta,DarkYellow
    Exit
}

#
# first thing after character creation / loading saved data
#
# main loop
do {
    do {
        # clears combat messages
        for ($Position = 17; $Position -lt 36; $Position++) {
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
        }
        Clear_Mob_Window
        # show congrats message on completion of all tasks, but only if Introduction Tasks are still in progress
        if ($Current_Location -eq "The Forest" -and $Import_JSON.Introduction_Tasks.In_Progress -eq $true) {
            # update introduction task and update Introduction Tasks window
            $Import_JSON.Introduction_Tasks.Tick_Travel_to_another_Location = $true
            Draw_Introduction_Tasks
            # Introduction Tasks window drawn on exit of switch statement below            
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,23;$Host.UI.Write("")
            Write-Color "  Congratulations, you have complete all of the Introduction Tasks" -Color Cyan
            Write-Color "  You have gained ","1000xp ","and ","500 Gold","." -Color Cyan,White,Cyan,DarkYellow,Cyan
            # update gold in inventory
            $Script:Import_JSON.Character.Gold = $Import_JSON.Character.Gold + 500
            $Script:Gold = $Import_JSON.Character.Gold + 500
            # update xp
            $Import_JSON.Character.Total_XP += 1000
            $Total_XP = $Total_XP + 1000
            $Import_JSON.Character.XP_TNL -= 1000
            $Script:XP_TNL = $XP_TNL - 1000
            # level up check
            if ($XP_TNL -lt 0) {
                $Script:XP_Difference = $XP_TNL
            }
            if ($XP_TNL -le 0) {
                Level_Up
            }
            # update player stats after level up to show stat buffs
            Save_JSON
            Import_JSON
            Update_Variables
            $host.UI.RawUI.ForegroundColor = "Cyan"
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 84,20;$Host.UI.Write("                .")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 84,21;$Host.UI.Write(" .. ............;;.")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 84,22;$Host.UI.Write("  ..::::::::::::;;;;.")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 84,23;$Host.UI.Write(". . ::::::::::::;;:'")
            $Host.UI.RawUI.CursorPosition  = New-Object System.Management.Automation.Host.Coordinates 84,24;$Host.UI.Write("                :'")
            do {
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                Write-Color -NoNewLine "C","ontinue ","[C]" -Color Green,DarkYellow,Green
                $Continue_After_Completing_Introduction_Tasks = Read-Host " "
                $Continue_After_Completing_Introduction_Tasks = $Continue_After_Completing_Introduction_Tasks.Trim()
            } until ($Continue_After_Completing_Introduction_Tasks -ieq "c")
        } else {
            Draw_Introduction_Tasks
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,0;$Host.UI.Write("")
            Draw_Player_Window_and_Stats
            for ($Position = 17; $Position -lt 36; $Position++) { # clear some lines from previous widow
                $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
            }
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
        }
        Clear_Mob_Window
        $Script:Info_Banner = "Available Options"
        Draw_Info_Banner
        Save_JSON
        for ($Position = 17; $Position -lt 36; $Position++) { # clear some lines from previous widow
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
        }
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
        # display all choice options in location
        $Location_Options = $Import_JSON.Locations.$Current_Location.Location_Options.PSObject.Properties.Name
        $Main_Loop_Choice_Letters_Array = New-Object System.Collections.Generic.List[System.Object]
        # Write-Color ""
        foreach ($LocationOption in $Location_Options) {
            if ($Import_JSON.Locations.$Current_Location.Location_Options.$LocationOption -eq $true) {
                Write-Color "  $($LocationOption.Substring(0,1))","$($LocationOption.Substring(1,$LocationOption.Length-1))" -Color Green,DarkGray
                $Main_Loop_Choice_Letters_Array.Add($LocationOption.Substring(0,1))
            }
        }
        $Main_Loop_Choice_Letters_Array.Add("INFO")
        $Main_Loop_Choice_Letters_Array_String = $Main_Loop_Choice_Letters_Array -Join "/"
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
        Write-Color -NoNewLine "What do you want to do? 1 ", "[$Main_Loop_Choice_Letters_Array_String]" -Color DarkYellow,Green
        $Main_Loop_Choice = Read-Host " "
        $Main_Loop_Choice = $Main_Loop_Choice.Trim()
    } until ($Main_Loop_Choice -in $Main_Loop_Choice_Letters_Array)
    switch ($Main_Loop_Choice) {
        h {
            do {
                Draw_Introduction_Tasks
                Save_JSON
                Get_Random_Mob
                Fight_or_Run
                do {
                    Clear_Mob_Window
                    $Script:Info_Banner = "Available Options"
                    Draw_Info_Banner
                    if ($Escaped_from_Mob -eq $true) {
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,20;$Host.UI.Write("")
                    } else {
                        for ($Position = 17; $Position -lt 36; $Position++) { # clear some lines from previous widow
                            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Position;$Host.UI.Write("");" "*105
                        }
                        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,17;$Host.UI.Write("")
                    }
                    # display all choice options in location
                    $Location_Options = $Import_JSON.Locations.$Current_Location.Location_Options.PSObject.Properties.Name
                    $Main_Loop_Choice_Letters_Array = New-Object System.Collections.Generic.List[System.Object]
                    foreach ($LocationOption in $Location_Options) {
                        if ($Import_JSON.Locations.$Current_Location.Location_Options.$LocationOption -eq $true) {
                            Write-Color "  $($LocationOption.Substring(0,1))","$($LocationOption.Substring(1,$LocationOption.Length-1))" -Color Green,DarkGray
                            $Main_Loop_Choice_Letters_Array.Add($LocationOption.Substring(0,1))
                        }
                    }
                    $Main_Loop_Choice_Letters_Array.Add("INFO")
                    $Main_Loop_Choice_Letters_Array_String = $Main_Loop_Choice_Letters_Array -Join "/"
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("");" "*105
                    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,36;$Host.UI.Write("")
                    Write-Color -NoNewLine "What would you like to do? 2 ", "[H/T/Q/INFO]" -Color DarkYellow,Green
                    $Finish_Combat = Read-Host " "
                    $Finish_Combat = $Finish_Combat.Trim()
                } until ($Finish_Combat -ieq "H" -or $Finish_Combat -ieq "T" -or $Finish_Combat -ieq "Q" -or $Finish_Combat -ieq "INFO" -or $Finish_Combat -ieq "V")
                if ($Finish_Combat -ieq "Q") {
                    Draw_Quest_Log
                    $Script:Continue_Fighting = $true
                }
                if ($Finish_Combat -ieq "H") {
                    $Script:Continue_Fighting = $true
                }
                if ($Finish_Combat -ieq "T"){
                    $Script:Continue_Fighting = $false
                    Travel
                    # Break
                }
                if ($Finish_Combat -ieq "V") {
                    Visit_a_Building
                    $Script:Continue_Fighting = $false
                    # Break
                }
                if ($Finish_Combat -ieq "INFO") {
                    Game_Information
                    $Script:Continue_Fighting = $false
                    # Break
                }
            } while ($Continue_Fighting -eq $true)
        }
        t {
            Travel
        }
        v {
            Visit_a_Building
        }
        q {
            Draw_Quest_Log
        }
        i {
            Draw_Inventory
        }
        info {
            Game_Information
        }
        # Default {}
    }
} while ($true)


