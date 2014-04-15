@ECHO off
setlocal EnableDelayedExpansion

REM ****** Start needed modules
ECHO INFO: Starting robotInterface.
START robotInterface

ECHO INFO: Starting NIDAQmxReader module.
START NIDAQmxReader
REM ******


REM ****** Get current day for logging purposes
setlocal EnableDelayedExpansion
FOR /F "skip=1 tokens=1-6" %%A IN ('WMIC Path Win32_LocalTime Get Day^,Hour^,Minute^,Month^,Second^,Year /Format:table') DO (
    if "%%B" NEQ "" (
        SET /A FDATE=%%F*10000+%%D*100+%%A
    )
)
REM ******


REM ****** Create log directory and store logs
SET "LOGDIR=../experiments/logs/!FDATE!"
IF NOT EXIST !LOGDIR! (
    ECHO INFO: Creating log directory !LOGDIR!
    MD "!LOGDIR!"
) ELSE (
    ECHO INFO: Log directory exists already
)
REM ******


REM ****** Experiment Parameters
REM Experiment type:
REM         1 - Progressive depth
REM         2 - Receptive field
SET /A EXPTYPE=2
REM Number of experiments to run. Set this!
SET /A NUMEXP=4
SET /A EXPHALF=%NUMEXP%/2
REM ****** 

REM ****** Run Experiment
ECHO INFO: Performing %NUMEXP% experiments
FOR /l %%i IN (1,1,!NUMEXP!) DO (
    ECHO INFO: Starting experiment n.  %%i
    
    ECHO INFO: Starting datadumpers.
    START dataDumper --name /dump_iaittpos --dir ../experiments/data/iaittpos/dump
    START dataDumper --name /dump_iaittexp --dir ../experiments/data/iaittexp/dump
    START dataDumper --name /dump_fingertip --dir ../experiments/data/fingertip/dump
    START dataDumper --name /dump_nano17 --dir ../experiments/data/nano17/dump
    TASKLIST | find "dataDumper"
    
    ECHO INFO: Starting IAITableTopController module.
    
    IF !EXPTYPE! EQU 1 (
        ECHO INFO: Performing progressive depth experiment.
        IF %%i LEQ !EXPHALF! (
            ECHO INFO: Tapping on Left taxel.
            SET STARTTIME=!TIME!
            START /W CMD /c "IAITableTopController --from confIAITableTopController.ini > ../experiments/logs/!FDATE!/trial%%i.log 2>&1"
        ) ELSE (
            ECHO INFO: Tapping on Right taxel.
            SET STARTTIME=!TIME!
            START /W CMD /c "IAITableTopController --from confIAITableTopController-R.ini > ../experiments/logs/!FDATE!/trial%%i.log 2>&1"
        )
    ) ELSE IF !EXPTYPE! EQU 2 (
        ECHO INFO: Performing receptive field experiment.
        SET STARTTIME=!TIME!
        START /W CMD /c "IAITableTopController --from confIAITableTopController.ini > ../experiments/logs/!FDATE!/trial%%i.log 2>&1"
    )

    SET ENDTIME=!TIME!
    ECHO INFO: Experiment n. %%i completed.
    ECHO INFO: Start time: !STARTTIME!
    ECHO INFO: End time: !ENDTIME!
    
    ECHO INFO: Killing dataDumpers.
    TASKKILL /IM dataDumper.exe
)
REM ****** 


REM ****** Kill processes
ECHO INFO: Killing processes.
TASKKILL /IM robotInterface.exe
TASKKILL /IM NIDAQmxReader.exe
REM ******


ECHO INFO: All experiments done.