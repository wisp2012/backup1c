# параметры общие ++ 
$BAKUPDIR="D:\1C_automatization\BACKUP\"
$CEXE="C:\Program Files (x86)\1cv8\common\1cestart.exe"
# параметры общие --

function ExitAll{
    # Сценарий разрывает все сессии пользователей во всех ИБ на выбранном кластере сервера приложений 1С
    # Если часть сессий остается активными после этого, то он останавливает все рабочие процессы кластера

    # Параметры запуска сценария: адрес сервера, основной порт кластера
    #$SrvAddr = "tcp://y001-ap-01:1640"
    $SrvAddr = "tcp://127.0.0.1"
    ########################################
    $V83Com = New-Object -COMObject "V83.COMConnector"
    # Подключение к агенту сервера

    $ServerAgent = $V83Com.ConnectAgent($SrvAddr)
    $ClusterFound = $FALSE
    #Получим массив кластеров сервера

    $Clasters = $ServerAgent.GetClusters()
    foreach ($Claster in $Clasters){
        # Аутентификация к выбранному кластеру
        # если у пользователя, под которым будет выполняться сценарий нет прав на кластер,
        # можно прописать ниже имя пользователя и пароль администратора кластера

        $ServerAgent.Authenticate($Claster,"","")

        #получаем список сессий кластера и прерываем их
        $Sessions = $ServerAgent.GetSessions($Claster)
        write-host "Разрывается" $Sessions.Count "сессий..."
        foreach ($Session in $Sessions){
        $ServerAgent.TerminateSession($Claster,$Session)}
    	
        if (($Sessions.Count -eq 0)){
        continue}

        # Если часть сессий осталась активной можно остановить рабочие процессы
        # Они перезапустятся автоматически главным менеджером кластера, но без "зависших" сессий

        # Получаем список рабочих процессов кластера
        $WorkingProcesses = $ServerAgent.GetWorkingProcesses($Claster)

        foreach ($WorkingProcess in $WorkingProcesses){
            if ($WorkingProcess.Running -eq 1){
                write-host "Останавливаем процесс с PID =" $WorkingProcess.PID
                #!!!здесь хорошо бы проверить что компьютер с которого запущен сценарий это выбранный в параметрах запуска сервер приложений 1С
                Stop-Process $WorkingProcess.PID -Force}}

    }
    $V83Com = ""
}

function BackUpBase($IbName){
	#Сформируем текущие дату и время
    $NOWDATETIME = Get-Date -UFormat "%Y_%m_%d_%H-%M"
	#Укажем, куда копировать (можно так же параметризовать, чтобы разные базы копировались в разные каталоги)
    $TARGETDIR = $BAKUPDIR
	#Сформируем имя файла резервной копии
    $BAKFN=$TARGETDIR + $IbName + "_" + $NOWDATETIME + ".dt"
	#Сформируем массив параметров
    $PARAMS = ("DESIGNER","/UseHwLicenses+","/S","127.0.0.1\$IbName","/N","ИМЯАДМИНА1С","/P","ПАРОЛЬАДМИНА1С","/DumpIB",$BAKFN)
	#Собственно, поехали
    &$CEXE $PARAMS

}

#Выгонем всех
ExitAll

#Вот эти базы будут скопированы
BackUpBase RingAlpha
BackUpBase MazdaAlpha
BackUpBase RingAcc
BackUpBase RingZup
BackUpBase MazdaHRM
BackUpBase MazdaAcc
BackUpBase RingAcc48
BackUpBase RingHRM48
BackUpBase RingAccNorth
BackUpBase RingHRMNorth