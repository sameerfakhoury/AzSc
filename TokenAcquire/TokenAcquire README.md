### Usage
This is a simple utility script intended for use during offensive Azure lab exercises. Password handling is not fully secure, while credentials won't appear in ConsoleHost_history.txt, they are held as plaintext in memory during execution. This script is intended strictly for legitimate lab use, and the author takes no responsibility for any misuse.

### About 
The script prompts for a UPN and password, then resolves the tenant ID from the domain using .well-known/openid-configuration endpoint. It uses the (ROPC) OAuth flow to request two bearer tokens, one for ARM and one for msGraph. Both tokens are stored as $global variables and printed to the console for immediate use in further enumeration or attack commands.

### Execution
Run the script:
`. .\AzTokenAcquisition.ps1`

Connect using the acquired tokens: `Connect-AzAccount -AccountId $UPN -AccessToken $token -MicrosoftGraphAccessToken $graphToken`