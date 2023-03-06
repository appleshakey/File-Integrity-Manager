Write-Host "What would you like to do?"
Write-Host "A) Collect new Baseline"
Write-Host "B) Begin monitoring files with saved Baseline?"

$response = Read-Host -Prompt "Please Enter A or B"

Write-Host "User entered $($response)"


Function Erase-File-If-Already-Exists(){
	$baselineExists = Test-Path -Path .\baseline.txt 
	if($baselineExists){
		Remove-Item -force baseline.txt
	}	
}

Function Calculate-File-Hash($file_path){
	$file_hash = Get-FileHash -Path $file_path -Algorithm SHA512
	return $file_hash
}


if ($response -eq "A".ToUpper()){
	#CALCULATE THE HASH FROM THE TARGET FILES AND STORE IN BASELINE
	Write-Host "Calculate Hashes, make new baseline.txt" -ForegroundColor Cyan
	Erase-File-If-Already-Exists
	
	#Storing hashes
	$file = get-childitem -Path .\FIM

	foreach($f in $file){
	$hash = Calculate-File-Hash $f.FullName
	"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
	}
	
	
}

elseif ($response -eq "B".ToLower()){
	#BEGIN MONITORING THE FILES WITH SAVED BASELINE
	Write-Host "Read existing baseline.txt, start monitoring files." -ForegroundColor Yellow
	
	#Using dictionary struct
	$filedictionary = @{}
	$filepathandhash = Get-Content -Path baseline.txt
	
	foreach($f in $filepathandhash){
	if ($filedictionary[$f.split("|")[0]] -eq $null){
		$filedictionary.add($f.split("|")[0],$f.split("|")[1])}
	}
	$filedictionary
	#Checking whether files are working
	while ($true){
		Start-Sleep -Seconds 1
		
		$files = Get-Childitem -Path FIM

		foreach($f in $files){
			$hash = Calculate-File-Hash $f.FullName
			"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath baseline.txt -Append
			if ($filedictionary[$hash.Path] -eq $null){
				Write-Host "$($hash.Path) is created"
			}
			
			else{
				if ($filedictionary[$hash.Path] -eq $hash.Hash){}
				else{
					Write-Host "$($hash.path) is changed!"
				}		
			}
			foreach ($key in $filedictionary.keys) {
				$baselinefileexists = Test-Path -Path $key
				if(-Not $baselinefileexists){
					Write-Host "$($key) is deleted"
				}
			}
		}		
		
	}
}
