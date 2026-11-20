@echo off
setlocal EnableExtensions
pushd "%~dp0" || exit /b 1
set "FIELD_TEST_DIR=%TEMP%\FIELD_TI_validacao_%RANDOM%_%RANDOM%"
mkdir "%FIELD_TEST_DIR%" || exit /b 1
set "FIELD_CHECK=%FIELD_TEST_DIR%\autoteste.json"
set "FIELD_RECORD=%FIELD_TEST_DIR%\resultado.txt"
set "FIELD_EXE=%CD%\FIELD_TI_1.3.7.exe"
>"%FIELD_RECORD%" echo FIELD TI 1.3.7 - %DATE% %TIME% - %COMPUTERNAME%
ver >>"%FIELD_RECORD%"
start "" /wait "%FIELD_EXE%" --self-check "%FIELD_CHECK%"
if errorlevel 1 goto failed
powershell -NoProfile -Command "$ErrorActionPreference='Stop'; $c=Get-Content -Raw -LiteralPath $env:FIELD_CHECK | ConvertFrom-Json; if ($c.version -ne '1.3.7' -or !$c.ui -or !$c.frozen -or !$c.webview2_dll) {exit 1}"
if errorlevel 1 goto failed
>>"%FIELD_RECORD%" echo Autoteste do pacote: passou.
start "" "%FIELD_EXE%"
echo Realize as verificacoes no FIELD TI. Volte a esta janela para registrar cada resultado.
call :item "A janela abriu e identificou o equipamento?"
call :item "Rede: DNS, latencia, download e upload possuem evidencias?"
call :item "Rede: se houve falha, repetiu a etapa e preservou a tentativa inicial?"
call :item "SSD: identificou o volume, a integridade do arquivo e a cobertura SMART?"
call :item "RAM: o resultado mostra amostra, padroes e divergencias?"
call :item "CPU e bateria: os resultados correspondem aos sensores disponiveis?"
call :item "Tela e teclado: a avaliacao manual ficou registrada?"
call :item "Cancelamento: a etapa parou e exibiu Cancelado?"
call :item "Laudo: salvou e conferiu HTML e JSON da mesma RAT?"
goto finish
:item
echo %~1
choice /c SFP /n /m "[S] Verificado  [F] Falhou  [P] Pendente ou nao aplicavel: "
if errorlevel 3 (>>"%FIELD_RECORD%" echo PENDENTE/N.A. - %~1) else if errorlevel 2 (>>"%FIELD_RECORD%" echo FALHOU - %~1) else (>>"%FIELD_RECORD%" echo VERIFICADO PELO TECNICO - %~1)
exit /b
:failed
>>"%FIELD_RECORD%" echo FALHOU - autoteste do pacote.
:finish
type "%FIELD_RECORD%"
echo Registro: "%FIELD_RECORD%"
pause
popd
