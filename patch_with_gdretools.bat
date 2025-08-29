@echo off
rem Script para baixar GDRETools, extrair e tentar aplicar patch em Spreadsheets.exe usando a pasta overwrites
rem Editar GDRE_URL se quiser apontar para um release/zip específico do GDRETools

setlocal enabledelayedexpansion

rem --- Configuráveis ---
set "GDRE_URL="

set "SCRIPT_DIR=.\"
set "OVERWRITES_DIR=%SCRIPT_DIR%overwrites\"
set "TMP_DIR=%SCRIPT_DIR%gdretools_download"
set "ZIP_PATH=%TMP_DIR%\gdretools.zip"

rem --- Determinar alvo (Spreadsheets.exe) ---
if "%~1"=="" (
    echo Procurando Spreadsheets.exe na pasta principal %SCRIPT_DIR%...
    set "TARGET="
    if exist "%SCRIPT_DIR%Spreadsheets.exe" (
        set "TARGET=%SCRIPT_DIR%Spreadsheets.exe"
    )
) else (
    set "TARGET=%~1"
)
:found_target
if not defined TARGET (
    echo ERRO: Spreadsheets.exe nao foi fornecido nem encontrado.
    echo Passe o caminho como primeiro argumento ou coloque o exe na pasta do script.
    exit /b 2
)

if not exist "%OVERWRITES_DIR%" (
    echo ERRO: pasta overwrites nao encontrada em: %OVERWRITES_DIR%
    exit /b 3
)

echo Alvo: %TARGET%
echo Overwrites: %OVERWRITES_DIR%

rem --- Verificar se o URL foi configurado ---
if "%GDRE_URL%"=="" (
    echo GDRE_URL nao configurado. Tentando obter ultimo release do repo GDRETools/gdsdecomp via API do GitHub...
    for /f "delims=" %%U in ('powershell -NoProfile -Command "Try { $rel = Invoke-RestMethod -Uri 'https://api.github.com/repos/GDRETools/gdsdecomp/releases/latest' -UseBasicParsing -ErrorAction Stop; $asset = $rel.assets | Where-Object { $_.name -match '-windows\.zip$' } | Select-Object -First 1; if ($asset) { Write-Output $asset.browser_download_url } else { Write-Error 'No -windows.zip asset found'; exit 1 } } Catch { exit 1 }"') do set "GDRE_URL=%%U"
    if errorlevel 1 (
        echo ERRO: falha ao consultar a API do GitHub para obter o release com '-windows.zip'.
        exit /b 4
    )
)

if "%GDRE_URL%"=="" (
    echo ERRO: Nao foi possivel determinar GDRE_URL automaticamente. Configure-a manualmente no script.
    exit /b 4
)

echo GDRE_URL: %GDRE_URL%

rem --- Preparar diretório temporario ---
if exist "%TMP_DIR%" rmdir /s /q "%TMP_DIR%"
mkdir "%TMP_DIR%"

rem --- Verifica se gdre_tools.exe ja existe na pasta do script ---
if exist "%SCRIPT_DIR%gdre_tools.exe" (
    echo gdre_tools.exe encontrado na pasta do script. Pulando download e extracao.
) else (
    echo Baixando GDRETools de: %GDRE_URL%
    powershell -Command "Try { Invoke-WebRequest -Uri '%GDRE_URL%' -OutFile '%ZIP_PATH%' -UseBasicParsing -ErrorAction Stop } Catch { exit 1 }"
    if errorlevel 1 (
        echo ERRO: falha ao baixar o arquivo. Verifique o GDRE_URL e conexao de rede.
        exit /b 5
    )

    echo Extraindo zip...
    powershell -Command "Expand-Archive -Path '%ZIP_PATH%' -DestinationPath '%SCRIPT_DIR%' -Force"
    if errorlevel 1 (
        echo ERRO: falha ao extrair o zip
        exit /b 6
    )
)

    set "ARGSEXCLUDE="
    set "ARGSEXCLUDE=!ARGSEXCLUDE! --exclude="res://.godot/imported/Main Menu.png*""
    set "ARGSEXCLUDE=!ARGSEXCLUDE! --exclude="res://.godot/imported/X-Cell Data 1*""
    set "ARGSEXCLUDE=!ARGSEXCLUDE! --exclude="res://.godot/imported/X-Cell Data 2*""
    set "ARGSEXCLUDE=!ARGSEXCLUDE! --exclude="res://.godot/imported/X-Cell Data 3*""
    set "ARGSEXCLUDE=!ARGSEXCLUDE! --exclude="res://.godot/imported/X-Cell Data 4*""
    set "ARGSEXCLUDE=!ARGSEXCLUDE! --exclude="res://.godot/imported/X-Cell Data 5*""
    set "ARGSEXCLUDE=!ARGSEXCLUDE! --exclude="res://.godot/imported/X-Cell Data 6*""
    set "ARGSEXCLUDE=!ARGSEXCLUDE! --exclude="res://.godot/imported/X-Cell Data 7*""
    set "ARGSEXCLUDE=!ARGSEXCLUDE! --exclude="res://.godot/imported/X-Cell Data 8*""
    set "ARGSEXCLUDE=!ARGSEXCLUDE! --exclude="res://.godot/imported/X-Cell Data 9*""

    set "ARGSPATCHGODOTCTEX="
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\Main Menu.png-b55895c46064957492beb5259c8d912a.ctex=res://.godot/imported/Main Menu.png-b55895c46064957492beb5259c8d912a.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 1 - 50.png-2cc5c0e4a4d8d56ec3949e20b80d311e.ctex=res://.godot/imported/X-Cell Data 1 - 50.png-2cc5c0e4a4d8d56ec3949e20b80d311e.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 101 - 150.png-40bae9a87d22e53c93f5334e73dfc85c.ctex=res://.godot/imported/X-Cell Data 101 - 150.png-40bae9a87d22e53c93f5334e73dfc85c.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 151 - 200.png-e5c815bc46bfde0d5c564763c3a504c8.ctex=res://.godot/imported/X-Cell Data 151 - 200.png-e5c815bc46bfde0d5c564763c3a504c8.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 201 - 250.png-0fbf39e3028f6597f71a89150705b6c9.ctex=res://.godot/imported/X-Cell Data 201 - 250.png-0fbf39e3028f6597f71a89150705b6c9.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 251 - 300.png-3b6a54d7fa3d4fdb3d50fba8524d8f1c.ctex=res://.godot/imported/X-Cell Data 251 - 300.png-3b6a54d7fa3d4fdb3d50fba8524d8f1c.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 301 - 350.png-b17b83afd5d0602138fe7e26d9b4adc4.ctex=res://.godot/imported/X-Cell Data 301 - 350.png-b17b83afd5d0602138fe7e26d9b4adc4.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 351 - 400.png-791ad6fc1879b922185b1fc9a8f71ddc.ctex=res://.godot/imported/X-Cell Data 351 - 400.png-791ad6fc1879b922185b1fc9a8f71ddc.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 401 - 450.png-6d5f578b5c2ecc404c0ff6b708ffb26b.ctex=res://.godot/imported/X-Cell Data 401 - 450.png-6d5f578b5c2ecc404c0ff6b708ffb26b.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 451 - 500.png-6c8827e222d899c20a001ddf760b0517.ctex=res://.godot/imported/X-Cell Data 451 - 500.png-6c8827e222d899c20a001ddf760b0517.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 501 - 550.png-9e104195545c81ea49827df85a998cac.ctex=res://.godot/imported/X-Cell Data 501 - 550.png-9e104195545c81ea49827df85a998cac.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 51 - 100.png-25b26eca5ccfa53f167f5daef0477e72.ctex=res://.godot/imported/X-Cell Data 51 - 100.png-25b26eca5ccfa53f167f5daef0477e72.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 551 - 600.png-4d405f5071eeaaa0cef1c3bef35ee78c.ctex=res://.godot/imported/X-Cell Data 551 - 600.png-4d405f5071eeaaa0cef1c3bef35ee78c.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 601 - 650.png-bc6659302aba293a95d7fa7eb37e35f7.ctex=res://.godot/imported/X-Cell Data 601 - 650.png-bc6659302aba293a95d7fa7eb37e35f7.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 651 - 700.png-38d28db679955f4ec6a293e7647d75c6.ctex=res://.godot/imported/X-Cell Data 651 - 700.png-38d28db679955f4ec6a293e7647d75c6.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 701 - 750.png-c9755464f0cb62c75b8761dab3b66c6b.ctex=res://.godot/imported/X-Cell Data 701 - 750.png-c9755464f0cb62c75b8761dab3b66c6b.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 751 - 800.png-590c2d949847a2d8d9243535229ed49a.ctex=res://.godot/imported/X-Cell Data 751 - 800.png-590c2d949847a2d8d9243535229ed49a.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 801 - 850.png-7c58f2b7804b0491837ee8643c713e4f.ctex=res://.godot/imported/X-Cell Data 801 - 850.png-7c58f2b7804b0491837ee8643c713e4f.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 850 - 900.png-19e822119beec65ee4cc55ece7837f22.ctex=res://.godot/imported/X-Cell Data 850 - 900.png-19e822119beec65ee4cc55ece7837f22.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 901 - 950.png-89a69b4f006951bc554f7643645d89da.ctex=res://.godot/imported/X-Cell Data 901 - 950.png-89a69b4f006951bc554f7643645d89da.ctex""
    set "ARGSPATCHGODOTCTEX=!ARGSPATCHGODOTCTEX! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 951 - 1000.png-92174d7ba236c75b1e8625a1812b8628.ctex=res://.godot/imported/X-Cell Data 951 - 1000.png-92174d7ba236c75b1e8625a1812b8628.ctex""
    
    set "ARGSPATCHGODOTMD5="
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\Main Menu.png-b55895c46064957492beb5259c8d912a.md5=res://.godot/imported/Main Menu.png-b55895c46064957492beb5259c8d912a.md5""    
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 1 - 50.png-2cc5c0e4a4d8d56ec3949e20b80d311e.md5=res://.godot/imported/X-Cell Data 1 - 50.png-2cc5c0e4a4d8d56ec3949e20b80d311e.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 101 - 150.png-40bae9a87d22e53c93f5334e73dfc85c.md5=res://.godot/imported/X-Cell Data 101 - 150.png-40bae9a87d22e53c93f5334e73dfc85c.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 151 - 200.png-e5c815bc46bfde0d5c564763c3a504c8.md5=res://.godot/imported/X-Cell Data 151 - 200.png-e5c815bc46bfde0d5c564763c3a504c8.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 201 - 250.png-0fbf39e3028f6597f71a89150705b6c9.md5=res://.godot/imported/X-Cell Data 201 - 250.png-0fbf39e3028f6597f71a89150705b6c9.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 251 - 300.png-3b6a54d7fa3d4fdb3d50fba8524d8f1c.md5=res://.godot/imported/X-Cell Data 251 - 300.png-3b6a54d7fa3d4fdb3d50fba8524d8f1c.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 301 - 350.png-b17b83afd5d0602138fe7e26d9b4adc4.md5=res://.godot/imported/X-Cell Data 301 - 350.png-b17b83afd5d0602138fe7e26d9b4adc4.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 351 - 400.png-791ad6fc1879b922185b1fc9a8f71ddc.md5=res://.godot/imported/X-Cell Data 351 - 400.png-791ad6fc1879b922185b1fc9a8f71ddc.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 401 - 450.png-6d5f578b5c2ecc404c0ff6b708ffb26b.md5=res://.godot/imported/X-Cell Data 401 - 450.png-6d5f578b5c2ecc404c0ff6b708ffb26b.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 451 - 500.png-6c8827e222d899c20a001ddf760b0517.md5=res://.godot/imported/X-Cell Data 451 - 500.png-6c8827e222d899c20a001ddf760b0517.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 501 - 550.png-9e104195545c81ea49827df85a998cac.md5=res://.godot/imported/X-Cell Data 501 - 550.png-9e104195545c81ea49827df85a998cac.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 51 - 100.png-25b26eca5ccfa53f167f5daef0477e72.md5=res://.godot/imported/X-Cell Data 51 - 100.png-25b26eca5ccfa53f167f5daef0477e72.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 551 - 600.png-4d405f5071eeaaa0cef1c3bef35ee78c.md5=res://.godot/imported/X-Cell Data 551 - 600.png-4d405f5071eeaaa0cef1c3bef35ee78c.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 601 - 650.png-bc6659302aba293a95d7fa7eb37e35f7.md5=res://.godot/imported/X-Cell Data 601 - 650.png-bc6659302aba293a95d7fa7eb37e35f7.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 651 - 700.png-38d28db679955f4ec6a293e7647d75c6.md5=res://.godot/imported/X-Cell Data 651 - 700.png-38d28db679955f4ec6a293e7647d75c6.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 701 - 750.png-c9755464f0cb62c75b8761dab3b66c6b.md5=res://.godot/imported/X-Cell Data 701 - 750.png-c9755464f0cb62c75b8761dab3b66c6b.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 751 - 800.png-590c2d949847a2d8d9243535229ed49a.md5=res://.godot/imported/X-Cell Data 751 - 800.png-590c2d949847a2d8d9243535229ed49a.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 801 - 850.png-7c58f2b7804b0491837ee8643c713e4f.md5=res://.godot/imported/X-Cell Data 801 - 850.png-7c58f2b7804b0491837ee8643c713e4f.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 850 - 900.png-19e822119beec65ee4cc55ece7837f22.md5=res://.godot/imported/X-Cell Data 850 - 900.png-19e822119beec65ee4cc55ece7837f22.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 901 - 950.png-89a69b4f006951bc554f7643645d89da.md5=res://.godot/imported/X-Cell Data 901 - 950.png-89a69b4f006951bc554f7643645d89da.md5""
    set "ARGSPATCHGODOTMD5=!ARGSPATCHGODOTMD5! --patch-file="%OVERWRITES_DIR%.godot\imported\X-Cell Data 951 - 1000.png-92174d7ba236c75b1e8625a1812b8628.md5=res://.godot/imported/X-Cell Data 951 - 1000.png-92174d7ba236c75b1e8625a1812b8628.md5""
    
    set "ARGSPATCHASSETS="
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 1 - 50.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 1 - 50.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 51 - 100.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 51 - 100.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 101 - 150.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 101 - 150.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 151 - 200.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 151 - 200.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 201 - 250.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 201 - 250.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 251 - 300.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 251 - 300.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 301 - 350.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 301 - 350.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 351 - 400.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 351 - 400.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 401 - 450.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 401 - 450.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 451 - 500.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 451 - 500.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 501 - 550.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 501 - 550.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 551 - 600.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 551 - 600.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 601 - 650.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 601 - 650.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 651 - 700.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 651 - 700.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 701 - 750.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 701 - 750.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 751 - 800.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 751 - 800.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 801 - 850.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 801 - 850.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 850 - 900.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 850 - 900.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 901 - 950.png.import/=res://Assets/02 XL Window/Data/X-Cell Data 901 - 950.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\02 XL Window\Data\X-Cell Data 951 - 1000.png.import=res://Assets/02 XL Window/Data/X-Cell Data 951 - 1000.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%Assets\04 Main Menu\Main Menu\Main Menu.png.import=res://Assets/04 Main Menu/Main Menu/Main Menu.png.import""
    set "ARGSPATCHASSETS=!ARGSPATCHASSETS! --patch-file="%OVERWRITES_DIR%JSON\Spreadsheet JSON.json=res://JSON/Spreadsheet JSON.json""

    for %%A in ("%TARGET%") do (
        set "T_DIR=%%~dpA"
        set "T_NAME=%%~nA"
        set "T_EXT=%%~xA"
    )
    set "OUTPUT_TARGET=%T_NAME%_patched%T_EXT%"

    echo Executando: gdre_tools.exe

    gdre_tools.exe --headless --pck-patch="%TARGET%" --embed="%TARGET%" %ARGSPATCHGODOTCTEX% %ARGSEXCLUDE% %ARGSPATCHASSETS% --output="%OUTPUT_TARGET%"
    if errorlevel 1 (
        echo ERRO: gdre_tools.exe falhou ao aplicar o patch 2.
        exit /b 9
    )
    rem Se sucesso, substituir exe original e limpar temporarios
    if exist "%OUTPUT_TARGET%"  (
        echo Patch aplicado com sucesso. Substituindo "%TARGET%" por "%OUTPUT_TARGET%"...
        move /Y "%OUTPUT_TARGET%" "%TARGET%" >nul
        if errorlevel 1 (
            echo ERRO: falha ao mover o arquivo patched para o destino.
            exit /b 12
        )

        rem Remover zip temporario e pasta temporaria se existirem
        if exist "%ZIP_PATH%" del /f /q "%ZIP_PATH%"
        if exist "%TMP_DIR%" rmdir /s /q "%TMP_DIR%"

        rem Remover binarios extraidos do gdre_tools se estiverem dentro da pasta do jogo
        if exist "gdre_tools.exe" del /f /q "gdre_tools.exe"
        if exist "gdre_tools.pck" del /f /q "gdre_tools.pck"

        echo Cleanup concluido. Saindo com codigo 0.
        exit /b 0
    )
) else (
    echo ERRO: gdre_tools.exe nao foi encontrado na pasta principal (%SCRIPT_DIR%).
    echo Verifique o conteudo do release; o zip deve conter gdre_tools.exe e gdre_tools.pck.
    exit /b 7
)
