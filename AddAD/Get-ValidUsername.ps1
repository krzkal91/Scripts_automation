
function Get-ValidUsername {
    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$firstname,
        [Parameter(Mandatory)]
        [string]$secondname
    )

        $global:i = 1
        $firstname = $firstname.Trim() -replace "å","a" -replace "æ","a" -replace "ø","o" -replace " ", "" -replace "-", ""
        $secondname = $secondname.Trim() -replace "å","a" -replace "æ","a" -replace "ø","o" -replace "-", " "
        $secondname = $secondname.Split(" ")[0]
        $len = $firstname.Length +$secondname.Length 
        [System.Array]$lis = Get-ADUser -Filter * | select -ExpandProperty samaccountname
        
            while($global:i -le $firstname.Length) {
                $newname = ($firstname.Substring(0, $i)) + $secondname
                if(!$lis.Contains($newname)) { 
                    return $newname 
                }
                if($global:i -eq $firstname.Length -and $lis.Contains($newname)) {
                    Write-Error "No username compliant with the username policy avilable. Please consult with HR and create manually"
                    return $null
                }
                $global:i += 1
            }

}
