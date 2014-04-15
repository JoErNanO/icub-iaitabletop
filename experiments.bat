@ECHO off
ECHO INFO: Starting robotInterface.
START robotInterface

ECHO INFO: Starting NIDAQmxReader module.
START NIDAQmxReader

FOR %%i IN (1,2,3,4,5,6,7,8) DO (
    ECHO INFO: Starting experiment n.  %%i
    
    ECHO INFO: Starting datadumpers.
    START dataDumper --name /dump_iaittpos --dir ../experiments/data/iaittpos/dump
    START dataDumper --name /dump_iaittexp --dir ../experiments/data/iaittexp/dump
    START dataDumper --name /dump_fingertip --dir ../experiments/data/fingertip/dump
    START dataDumper --name /dump_nano17 --dir ../experiments/data/nano17/dump
    TASKLIST | find "dataDumper"
    
    ECHO INFO: Starting IAITableTopController module.
    IF NOT %%i GEQ 5 (
        ECHO INFO: Tapping on Left taxel.
        SET STARTTIME=%TIME%
        START /W CMD /c "IAITableTopController --from confIAITableTopController.ini > ../experiments/logs/trial%%i.log 2>&1"
    ) ELSE (
        ECHO INFO: Tapping on Right taxel.
        START /W CMD /c "IAITableTopController --from confIAITableTopController-R.ini > ../experiments/logs/trial%%i.log 2>&1"
    )
    SET ENDTIME=%TIME%
    ECHO INFO: Experiment n. %%i completed.
    ECHO INFO: Start time: %STARTTIME%
    ECHO INFO: End time: %ENDTIME%
    
    ECHO INFO: Killing dataDumpers.
    TASKKILL /IM dataDumper.exe
)

ECHO INFO: Killing processes.
TASKKILL /IM robotInterface.exe
TASKKILL /IM NIDAQmxReader.exe

ECHO INFO: All experiments done.