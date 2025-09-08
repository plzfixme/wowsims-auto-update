@echo off
setlocal enabledelayedexpansion

set REPO=wowsims/mop
set VERSION_FILE=version.txt
set ZIP_NAME=wowsimmop-windows.exe.zip
set EXTRACT_DIR=wowsims\mop

:: Чтение локальной версии
set LOCAL_VERSION=
if exist "%VERSION_FILE%" (
  for /f "usebackq delims=" %%A in ("%VERSION_FILE%") do (
    set "LOCAL_VERSION=%%A"
    goto :breakLoop
  )
)
:breakLoop
set LOCAL_VERSION=%LOCAL_VERSION: =%
echo Local version: %LOCAL_VERSION%

:: Получение последней версии с GitHub
for /f "delims=" %%v in (
  'powershell -command "(Invoke-RestMethod -Uri https://api.github.com/repos/%REPO%/releases/latest).tag_name"'
) do set LATEST_VERSION=%%v
echo Latest version: %LATEST_VERSION%

:: Проверка на необходимость обновления
if "%LOCAL_VERSION%"=="%LATEST_VERSION%" (
  goto run
)

:: Формирование URL последнего релиза для скачивания
set DOWNLOAD_URL=https://github.com/%REPO%/releases/latest/download/%ZIP_NAME%
echo Downloading from: %DOWNLOAD_URL%

:: Скачивание архива
powershell -command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%ZIP_NAME%'"

:: Удаление старой распакованной версии и распаковка новой
if exist "%EXTRACT_DIR%" rmdir /s /q "%EXTRACT_DIR%"
powershell -command "Expand-Archive -Path '%ZIP_NAME%' -DestinationPath '%EXTRACT_DIR%' -Force"

:: Удаление архива
del "%ZIP_NAME%"

:: Сохранение новой версии в файл
echo %LATEST_VERSION% > "%VERSION_FILE%"

:run
start "" "%EXTRACT_DIR%\wowsimmop-windows.exe"

exit
