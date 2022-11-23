:: FFconv - FFmpeg script for video converting
:: by undeaddd
@echo off
chcp 65001>nul
setlocal EnableDelayedExpansion
set fdir=%ProgramData%\conv
set path=%path%%fdir%
if "%1"=="-p" (
    echo Open as Administrator 
    set /p pr= "Set priority (1 - IDLE, 5 - BELOWNORMAL, 8 - NORMAL, 6 - ABOVENORMAL, 3 - HIGH):"
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ffmpeg.exe\PerfOptions" /v CPUPriorityClass /t REG_DWORD /d !pr! /f
    pause
)
ffmpeg 2>conv.tmp
for /f %%i in (conv.tmp) do (
    del conv.tmp
    if %%i=="ffmpeg" (
        echo FFmpeg is not installed. Install it automatically?
        choice /c YMC /m "Y - Yes, M - Manual install, C - Close"
        if !errorlevel!==1 (
            md %fdir%
            bitsadmin /transfer "7zip Installing" https://www.7-zip.org/a/7zr.exe "%fdir%\7zr.exe"
            bitsadmin /transfer "FFmpeg Installing" https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-essentials.7z "%fdir%\ffmpeg.7z"
            7zr e ffmpeg.7z ffmpeg.exe -r
            del %fdir%\7zr.exe %fdir%\ffmpeg.7z
        ) else (
            if !errorlevel!==2 (
                explorer "https://ffmpeg.org/download.html"
            )
            exit /b
        )
    )
    goto instEnd
)
:instEnd
if not exist "%~dp0\conv.txt" (
    echo Queue list is not found. Creating..
    (
        echo * Queue list syntax:
        echo * FOLDER; CODEC ^(optional, hevc as default^); RESOLUTION ^(optional^); BITRATE LIMIT ^(optional^)
        echo ---------------------------------------------------------------------------------------------------
        echo * ^< Use asterisk for comments
        echo ---------------------------------------------------------------------------------------------------
        echo * Put a folders with video files below
    ) > conv.txt
    echo Add folders and start script again
    start conv.txt
    pause
    exit /b
)
set vext=*.mp4 *.avi *.divx *.mpg *.mpeg *.mpe *.m1v *.m2v *.mpv2 *.mp2v *.pva *.evo *.m2p *.sfd *.ts *.tp *.trp *.m2t *.m2ts *.mts *.rec *.ssif *.vob *.ifo *.mkv *.mk3d *.webm *.m4v *.mp4v *.mpv4 *.hdmov *.ismv *.mov *.3gp *.3gpp *.3ga *.3g2 *.3gp2 *.flv *.f4v *.ogm *.ogv *.rm *.ram *.rmm *.rmvb *.wmv *.wmp *.wm *.asf *.smk *.bik *.fli *.flc *.flic *.roq *.dsm *.dsv *.dsa *.dss *.y4m *.h264 *.264 *.vc1 *.h265 *.265 *.hm10 *.hevc *.obu *.amv *.wtv *.dvr-ms *.mxf *.ivf *.nut *.dav *.swf
::set aext=*.avs *.vpy *.ac3 *.ec3 *.eac3 *.dts *.dtshd *.dtsma *.aif *.aifc *.aiff *.alac *.amr *.awb *.ape *.apl *.au *.snd *.cda *.aob *.dsf *.dff *.flac *.m4a *.m4b *.aac *.mid *.midi *.rmi *.mka *.weba *.mlp *.mp3 *.mpa *.mp2 *.m1a *.m2a *.mpc *.ofr *.ofs *.ogg *.oga *.ra *.tak *.tta *.wav *.w64 *.wma *.wv *.opus *.spx
set ext=mp4
for /f "usebackq delims=; eol=* tokens=1-4" %%a in ("%~dp0\conv.txt") do (
    if exist "%%a" (
        cd /d "%%a\"
        set c="%%b"
        set s="%%c"
        set mr="%%d"
        if not !c!=="" (set c=-c:v) else (set c=-c:v hevc)
        if not !s!=="" (set s=-s:v) else (set s= )
        if not !mr!=="" (set mr=-maxrate:v) else (set mr= )
        for %%i in (%vext%) do (
            md conv 2>nul
            md backup 2>nul
            title Converting file %%~fi
            ffmpeg -i "%%i" !c! %%b -maxrate:a 64k !s! %%c !mr! %%d "conv\%%~ni.%ext%"
            if exist "conv\%%~ni.%ext%" (move "%%i" backup)
        )
        move conv\* . 2>nul
        rd conv 2>nul
    ) else (echo Folder %%a is not exist.)
)
pause



::        for /f "delims=" %%j in ('ffprobe -i "%%i" -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 2^>^&1') do set dur=%%j
::        set /a dur=dur-6
::        echo !dur!


::-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
::   cd /d FOLDER
::   for %%i in (*.FORMAT) do ("C:\Program Files\ffmpeg\bin\ffmpeg.exe" -i %%i -c:v CODEC -preset PRESET -s:v WxH -b:v BITRATE "zzconv_%%~ni.mp4")
::   presets: ultrafast, superfast, veryfast, faster, fast, medium (default), slow, slower, veryslow, placebo
::   codecs: hevc, h264
::-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
