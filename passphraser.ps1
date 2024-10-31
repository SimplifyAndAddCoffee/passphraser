<#About#><###################################################
#############################################################
### A 'simple' script to generate one or more passwords   ###
### with a specified format using simple English nouns    ###
### and adjectives provided in separate dictionary files. ###
###                                                       ###
### These passwords are in no way intended to be          ###
### cryptographically secure. It just uses Get-Random.    ###
###                                                       ###
### Nor are the default settings meant to be 'secure.'    ###
### This was built with temporary passwords in mind.      ###
#############################################################
############################################################>

<#Planned Features#><########################################
##
## Planned features:
## * Make Database rebuild a separate function and more efficent with hash tables
## * Save DB in lowercase and then capitalize the PW elements at runtime based on selection
## * built-in HIBP check for those very short passwords
## * Windows.Forms GUI with drop downs for element ordering and rebuild/generate buttons
## * Forms update with estimated entropy and cracking time based on selections
## * function call that returns a psobject with n passwords when passed n as a parameter
## * add a max entropy calculation that assumes a blind dictionary brute force attack
## * zxcvbn entropy calcutation integration
## * additional dictionary support and custom import functions
## * cryptographically secure randoms
## * word difficulty rating
## * word commonality rating
## * cool informatics
## * compress-archive and expand-archive when reading/writing csv files
## * pre-formed sentence sructure templates, and randomizer by security level
## 
## Special Thanks to:
##   /r/sysadmin /r/powershell
##   /u/engageant /u/Komnos /u/bis
##   Coffee
##   'The Fuck' Contributors
##        https://github.com/mattparkes/PoShFuck
##        https://github.com/nvbn/thefuck
##   'zxcvbn' Contributors
##        https://github.com/dropbox/zxcvbn
##        https://github.com/trichards57/zxcvbn-cs
##   'Passphraser' author, Lage Berger Jensen
##        https://www.powershellgallery.com/packages/Passphraser
##   'HaveIBeenPwned' creator, Troy Hunt
##        https://haveibeenpwned.com/
##   'HaveIBeenPwned' PS module author Mark Ukotic
##        https://www.powershellgallery.com/packages/HaveIBeenPwned
##    The Electronic Frontier Foundation
## 
############################################################>

<#Variables#><###############################################
## Modify these variables to customize your password format
############################################################>

$digits = 0,1,2,3,4,5,6,7,8,9        ## Why include digits? because stupid arbitrary password requirements that ask for them are so prevalant.
$symbols = '!','@','#','$','%','^','&','*','+','-','='        ## Probably don't use anything that might tamper with invoke-expression. I don't recommend using these unless required.
$nounDictionary = Import-Csv "$PSScriptRoot\dict\11knouns.csv"      ## the full selection of nouns you want considered must be under CSV header "word"
$adjDictionary = Import-Csv "$PSScriptRoot\dict\5kadjectives.csv"        ## the full selection of adjectives you want considered must be under CSV header "word"
$wordMinChars = 5        ## Min/Max Characters per word (both dictionaries)
$wordMaxChars = 10
$FirstCaps = $True     ## Use $True to capitalize the first letter of each word. Otherwise all lowercase.
$delim = ''        ## what goes between elements '' , ' ' , '-' , '.' etc
$quantity = 10     ## How many passwords to generate.

## specify and order the elements to include in the password separated by commas. Indexes start from 0. I tried to make this easy to understand, but it's still on you to get it right.
## valid element types are $digit[i] , $symbol[i] , $adj[i].word , and $noun[i].word . Don't mess with -join $delim. Use "" for the delims variable above if you don't want delims.
$passwordFormat = '$digit[0] , $digit[1] , $digit[2] , $symbol[0] , $adj[0].word , $noun[0].word , $noun[1].word -join $delim'

## These must match the number of elements used in the $passwordFormat expression or entropy calculation will be inaccurate and bad things might happen. IDK.
$numberOfDigits = 3
$numberOfSymbols = 1
$numberOfAdj = 1
$numberOfNouns = 2

<###########################################################
## End of Variables. Do not modify below this line.
############################################################>

## build dictionaries. Only really needs to be rebuilt for new session or if variables are changed. It's not super efficient this way but it works and is convenient for experimenting.
$adjList = @()        ## new array for adjectives
foreach($i in $adjDictionary.word){        ## Grabs from "word" column of CSV file. 
    $chars = (Measure-Object -InputObject $i -Character).Characters     ## count the characters in the word
    if($chars -le $wordMaxChars -and $chars -ge $wordMinChars ){        ## Only keep words in the specified length range
        if($i -notlike "*-*" -and $i -notlike "*.*"){        ## exclude hyphenated words and abbreviations
            
            ## String manipulation to capitilaze the first character (or make it all lowercase)
            if( $FirstCaps -eq $True){
                $i = $i.Substring(0,1).ToUpper()+$i.Substring(1).ToLower()
            } else {
                $i = $i.ToLower()
            }
            
            ## we need to create a new object for each word to add to the existing object array. 
            $obj = New-Object -TypeName psobject
            $obj | Add-Member -MemberType NoteProperty -Name word -Value $i
            $obj | Add-Member -MemberType NoteProperty -Name characters -Value $chars        ## Storing the length of each word to help us later
            $adjList += $obj
             
        }
    }
}
$nounList = @()  ## new array for nouns. Works the same way as the above block
foreach($i in $nounDictionary.word){
    $chars = (Measure-Object -InputObject $i -Character).Characters
    if($chars -le $wordMaxChars -and $chars -ge $wordMinChars ){     
        if($i -notlike "*-*" -and $i -notlike "*.*"){

            if( $FirstCaps -eq $True){ 
                $i = $i.Substring(0,1).ToUpper()+$i.Substring(1).ToLower()
            } else {
                $i = $i.ToLower()
            }
            
            $obj = New-Object -TypeName psobject
            $obj | Add-Member -MemberType NoteProperty -Name word -Value $i
            $obj | Add-Member -MemberType NoteProperty -Name characters -Value $chars
            $nounList += $obj
             
        }
    }
}

## Generate Passwords
for($k=1; $k -le $quantity; $k++){        ## Repeat this whole section for each password we want to generate
    $noun = Get-Random $nounList -Count $numberOfNouns    ## We pull the number of words we need  from each dictionary into an indexed array for
    $adj = Get-Random $adjList -Count $numberOfAdj        ## ease of assembly. Using Get-Random -Count ensures that no duplicate words are drawn
    $digit = @(for($i=1; $i -le $numberOfDigits; $i++){(Get-Random $digits)})        ## for digits and symbols we call Get-Random repeatedly for each 
    $symbol = @(for($i=1; $i -le $numberOfSymbols; $i++){(Get-Random $symbols)})     ## to allow us to draw as many duplicate characters as we need

    ## some math nonsense to get accurate entropy figures for each password.
    ## This calculation ensures that a Minimum entropy is guaranteed, even if the total length of the password, Password Format, 
    ## and the word dictionaries it draws from are known/guessed and available to a brute force attacker.
    $nounEntropy = 1 ; $j = 0
    foreach($i in $noun.Characters){        ## we count the characters in each noun used
        $pool = ($nounList | where characters -eq $i | Measure-Object).count        ## We determine the max pool size for words of that length within our dictionary
        $nounEntropy = $nounEntropy * ($pool - $j)        ## For each word we've already drawn from the pool, we subtract one from the pool size before multiplying 
        $j++
    }
    $adjEntropy = 1 ; $j = 0        
    foreach($i in $adj.Characters){        ## Repeat for adjectives
        $pool = ($adjList | where characters -eq $i | Measure-Object).count
        $adjEntropy = $adjEntropy * ($pool - $j)
        $j++
    }
    $digitEntropy = 1
    foreach($i in $digit){        ## For digits we only need to know the number of digits and the pool size. I suppose I could have used exponential math here but this works.
        $pool = ($digits | Measure-Object).count
        $digitEntropy *= $pool
    }
    $symbolEntropy = 1
    foreach($i in $symbol){       ## Repeat for symbols
        $pool = ($symbols | Measure-Object).count
        $symbolEntropy *= $pool
    }
    $combinations = $symbolEntropy * $digitEntropy * $adjEntropy * $nounEntropy        ## Total combinatnions are the product of the above. We ignore delimiters since they add nothing if known.
    $bitsOfEntropy = [Math]::Ceiling([Math]::Log($combinations,2))         ## Log[2](base 10) rounded up for bits of entropy

    ## Output the result!
    $password = Invoke-Expression $passwordFormat        ## All this trouble so we could use invoke-expression here and variablize the formula for manipulation at the top of the script.
    Write-Host $password        ## could have done this on one line but it felt wrong doing all this work and not having a password variable to return for potential integration
    Write-Host 'Minimum of' $bitsOfEntropy 'bits of entropy. ('$combinations.ToString("e2") "possible combinations.)`r`n"        ## Thanks for coming to my TED Talk.
}