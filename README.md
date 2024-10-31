# passphraser
'simple' powershell script for generating new secure passwords / passphrases

DISCLAIMER: I am not a cryptography expert and if I have to tell you not to use this to roll your own crypto, then you shouldn't be using this.

Draws upon locally defined dictionaries of different language parts of speech to form natural-sounding word 
combinations that are easy to remmeber, type, and recite. Entropy calculations are given assuming worst-case
scenario of a brute force attacker knowing both the format and dictionaries used. 

Example output with default configuration of 3 digits, 1 symbol, 1 adjective (5-10 ch long), and 2 nouns (5-10ch long)
from a list of 5k most commonly used adjectives and 10k most commonly used nouns in the English language:


>/>passphraser.ps1
>957*PracticalInversionCanister
>Minimum of 44 bits of entropy. ( 1.52e+013 possible combinations.)
>
>232^DefectiveLeastNonsense
>Minimum of 44 bits of entropy. ( 1.50e+013 possible combinations.)
>
>905%EmaciatedEquivalentSugar
>Minimum of 44 bits of entropy. ( 1.01e+013 possible combinations.)
>
>656&FriendlyHegemonyTariff
>Minimum of 45 bits of entropy. ( 1.89e+013 possible combinations.)
>
>768$RidiculousEvensongDeadline
>Minimum of 44 bits of entropy. ( 1.46e+013 possible combinations.)
>
>226%FunctionalLarkspurKenya
>Minimum of 44 bits of entropy. ( 1.29e+013 possible combinations.)
>
>717*SeasonableHighballIntonation
>Minimum of 44 bits of entropy. ( 9.79e+012 possible combinations.)
>
>264&OppositeCrudityGlitter
>Minimum of 45 bits of entropy. ( 1.94e+013 possible combinations.)
>
>206-HauntingFlutterSumac
>Minimum of 44 bits of entropy. ( 1.69e+013 possible combinations.)
>
>612%ExteriorMaiestieSecretary
>Minimum of 44 bits of entropy. ( 1.68e+013 possible combinations.)
>
><#Planned Features#><########################################
>##
>## Planned features:
>## * Make Database rebuild a separate function and more efficent with hash tables
>## * Save DB in lowercase and then capitalize the PW elements at runtime based on selection
>## * built-in HIBP check for those very short passwords
>## * Windows.Forms GUI with drop downs for element ordering and rebuild/generate buttons
>## * Forms update with estimated entropy and cracking time based on selections
>## * function call that returns a psobject with n passwords when passed n as a parameter
>## * add a max entropy calculation that assumes a blind dictionary brute force attack
>## * zxcvbn entropy calcutation integration
>## * additional dictionary support and custom import functions
>## * cryptographically secure randoms
>## * word difficulty rating
>## * word commonality rating
>## * cool informatics
>## * compress-archive and expand-archive when reading/writing csv files
>## * pre-formed sentence sructure templates, and randomizer by security level
>## 
>## Special Thanks to:
>##   /r/sysadmin /r/powershell
>##   /u/engageant /u/Komnos /u/bis
>##   Coffee
>##   'The Fuck' Contributors
>##        https://github.com/mattparkes/PoShFuck
>##        https://github.com/nvbn/thefuck
>##   'zxcvbn' Contributors
>##        https://github.com/dropbox/zxcvbn
>##        https://github.com/trichards57/zxcvbn-cs
>##   'HaveIBeenPwned' creator, Troy Hunt
>##        https://haveibeenpwned.com/
>##   'HaveIBeenPwned' PS module author Mark Ukotic
##        https://www.powershellgallery.com/packages/HaveIBeenPwned
##    The Electronic Frontier Foundation
## 
############################################################>
