@echo off
title Lanzador de Proyecto OSGi - Karaf
echo =====================================================================
echo           Lanzador Automatizado de OSGi y Apache Karaf
echo =====================================================================
echo.

REM Asegurar que nos paramos en la carpeta donde esta este archivo .bat
cd /d "%~dp0"

echo [1/3] Compilando y empaquetando los bundles OSGi...
powershell -ExecutionPolicy Bypass -File .\build_bundles.ps1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] La compilacion de los bundles ha fallado.
    pause
    exit /b %ERRORLEVEL%
)
echo.

echo [2/3] Desplegando bundles en la carpeta de carga en caliente (deploy)...
copy /y greeting-service.jar tools\apache-karaf-4.4.6\deploy\ >nul
copy /y greeting-client.jar tools\apache-karaf-4.4.6\deploy\ >nul
echo Bundles copiados a Karaf 'deploy/'.
echo.

echo [3/3] Configurando variables de entorno de Java...

REM Caso 1: Verificar si JAVA_HOME esta configurado y es valido
if "%JAVA_HOME%"=="" goto CHECK_LOCAL
if not exist "%JAVA_HOME%\bin\java.exe" goto CHECK_LOCAL
echo [INFO] Usando la variable de entorno JAVA_HOME existente: %JAVA_HOME%
goto JAVA_OK

:CHECK_LOCAL
REM Caso 2: Usar JDK local de JDownloader si existe
if not exist "C:\Users\jeanc\AppData\Local\JDownloader 2\jre\bin\java.exe" goto CHECK_PATH
echo [INFO] Configurando JAVA_HOME localmente con el JDK de JDownloader...
set "JAVA_HOME=C:\Users\jeanc\AppData\Local\JDownloader 2\jre"
set "PATH=C:\Users\jeanc\AppData\Local\JDownloader 2\jre\bin;%PATH%"
goto JAVA_OK

:CHECK_PATH
REM Caso 3: Verificar si java ya esta en el PATH
where java >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [INFO] Java detectado en la variable PATH del sistema.
    goto JAVA_OK
)

echo [ALERTA] No se detecto una instalacion de Java (JDK). Apache Karaf podria fallar al iniciar.

:JAVA_OK
echo.
echo =====================================================================
echo Iniciando Apache Karaf...
echo.
echo Instrucciones utiles en la consola de Karaf:
echo   - Escribe 'bundle:list' para ver los modulos y sus IDs (ej. 53 y 54).
echo   - Escribe 'bundle:stop ^<ID^>' para detener un modulo.
echo   - Escribe 'bundle:start ^<ID^>' para iniciar un modulo.
echo   - Escribe 'system:shutdown -f' para apagar Karaf.
echo =====================================================================
echo.
call .\tools\apache-karaf-4.4.6\bin\karaf.bat
