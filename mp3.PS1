[System.Reflection.Assembly]::LoadFile("C:\Program Files\Libraries\taglib-sharp.dll")

$DestinationDirectory = "J:\Music\"
$Directories = Get-ChildItem -Path '\\Vandekande\d\Shared Folder\RSS' -Directory

function Get-Artists
{[CmdletBinding()]
    Param
    
    ( $DirectoryToCheck)

    $FileList = @{}
    
    $Files = Get-ChildItem -Path $DirectoryToCheck -Filter *.mp3
    $ErrorActionPreference = "SilentlyContinue"

    foreach ($file in $Files) {
        $media = [TagLib.File]::Create($file.FullName)

        $FileList.Add($media.Tag.FirstPerformer,'Artist')

    }

    $ErrorActionPreference = "Continue"

    If ( $FileList.Count -eq 1 ) {
        Return $FileList.Keys
    } Else { Return 'Various Artists'}
    
}

ForEach ( $Directory in $Directories ) {
    $Mp3Files = Get-ChildItem -Path $Directory.FullName -Filter *.mp3
    $DeleteDirectory = $False

    foreach ($Mp3file in $Mp3Files) {
        $media = [TagLib.File]::Create($mp3file.FullName)

        $Info = (Get-Culture).TextInfo

        If ( $media.PossiblyCorrupt ) { Remove-Item $Mp3file }
        
        $media.Tag.Title = $Info.ToTitleCase($media.Tag.Title)
        $media.Tag.AlbumArtists = $Info.ToTitleCase($media.Tag.AlbumArtists)
        $media.Tag.Performers = $Info.ToTitleCase($media.Tag.Performers)

        $Artists = $media.Tag.FirstPerformer
        
        $Album = $media.Tag.Album

        $media.Tag.Comment = ''
        $media.Tag.DiscCount = ''
        $media.Tag.Composers = ''
        $media.Tag.Title = $media.Tag.Title.replace("'", '')
 
        $media.Tag.Track  = [int]$media.Tag.Track 

        Write-Host ( "$($media.tag.FirstArtist) - $($media.tag.Title)" ) 

        $media.Save()
        
        $Album = $Album -replace ("\[","")
        $Album = $Album -replace ("\]","")
        $Album = $Album -replace ("[^0-9a-zA-Z-&\']"," ")

        If ($Artists) {
            $NewDirectory = $DestinationDirectory + $Album
        } 
        Else { $NewDirectory = $DestinationDirectory + $Album
            $CheckAlbumArtists = $True  
        }
        
        If (! (Test-Path -Path $NewDirectory ) ) {
            New-Item -Path $NewDirectory  -ItemType directory
        }

        $NewFileName = $Info.ToTitleCase($($media.Tag.Performers -replace '[^a-zA-Z0-9. ]', '.')) + " - " + $( $media.Tag.Title -replace '[^a-zA-Z0-9. ()]', '.' )

        Try {
            $NewFile = Move-Item "$($mp3file.FullName)" -Destination "$NewDirectory\$NewFileName$($mp3file.Extension)" -PassThru
            If ($NewFile ) { 
                $DeleteDirectory = $True
            } 
        } Catch {}

        $PreArtists = $Artists
    }

    If ( $DeleteDirectory ) {
        Remove-Item -Path $Directory.FullName -Recurse -Force
    }

    $ArtistDirectory = Get-Artists -DirectoryToCheck $NewDirectory

    Rename-Item -Path $NewDirectory -NewName "$ArtistDirectory - $($NewDirectory.Replace($DestinationDirectory,''))" 
    
}
