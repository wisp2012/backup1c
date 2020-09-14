function Download_File ($si_UserName, $si_Password, $si_Source_Path, $si_Target_Path){
$oi_Credentials = New-Object System.Net.NetworkCredential($si_UserName,$si_Password)
$oi_Web_Client = New-Object System.Net.WebClient
$oi_Web_Client.Credentials = $oi_Credentials
$oi_Web_Client.DownloadFile($si_Source_Path, $si_Target_Path)
while($oi_Web_Client.IsBusy){}
}

Clear-Host;
$curDir = $MyInvocation.MyCommand.Definition | split-path -parent
$curDir = $curDir + "\"
$server = "111.222.33.4" #FTP сайт
$flagfoldername = "/1C/flag.txt" #удаленная папка с флаг-файлом
$flagurl = "ftp://$server$flagfoldername" #url для закачки флага
$cffoldername = "/1C/GK.cf" #удаленная папка с файлом кофигурации
$cfurl = "ftp://$server$cffoldername" #url для закачки файла конфигурации
$login = "MYFTPUSER" #ftp-логин
$password = "MYFTPPWD" #ftp-пароль
$flagfile = $curDir + "flag.txt"
$cffile = $curDir + "GK.cf" #файл с конфигурацией на локальном диске

$SERVERNAME="127.0.0.1"
$CEXE="C:\Program Files (x86)\1cv8\common\1cestart.exe"
$ADMINNAME="1CUSER"
$ADMINPASS="1CPWD"

function UpdateCf($IBNameLocal){
    &$CEXE 'DESIGNER' '/S' $SERVERNAME'\'$IBNameLocal '/N' $ADMINNAME '/P' $ADMINPASS '/LoadCfg' $cffile '/UpdateDBCfg' '-Server' 
}

function FileExist($fpath){
    $isfile = Test-Path $fpath    
    return ($isfile -eq "True") 
}

#собственно, начало выполнения скрипта
if (FileExist $flagfile){
    Remove-Item $flagfile
}

if (FileExist $cffile){
    Remove-Item $cffile
}

Download_File $login $password $flagurl $flagfile

if (FileExist $flagfile){
    Download_File $login $password $cfurl $cffile
    if (FileExist $cffile){#стартуем обновление
        UpdateCf "MazdaAlpha"
	UpdateCf "RingAlpha"
    }
}