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
REM Verificar si hay un JAVA_HOME configurado en el sistema
if exist "%JAVA_HOME%\bin\java.exe" (
    echo [INFO] Usando la variable de entorno JAVA_HOME existente: %JAVA_HOME%
) else if exist "C:\Users\jeanc\AppData\Local\JDownloader 2\jre\bin\java.exe" (
    echo [INFO] Configurando JAVA_HOME localmente con el JDK de JDownloader...
    set "JAVA_HOME=C:\Users\jeanc\AppData\Local\JDownloader 2\jre"
    set "PATH=C:\Users\jeanc\AppData\Local\JDownloader 2\jre\bin;%PATH%"
) else (
    where java >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        echo [INFO] Java detectado en la variable PATH del sistema.
    ) else (
        echo [ALERTA] No se detecto una instalacion de Java (JDK). Apache Karaf podria fallar al iniciar.
    )
)
echo.

echo =====================================================================
echo Iniciando Apache Karaf...
echo.
echo Instrucciones utiles en la consola de Karaf:
echo   - Escribe 'bundle:list' para ver los modulos y sus IDs (ej. 53 y 54).
echo   - Escribe 'bundle:stop <ID>' para detener un modulo.
echo   - Escribe 'bundle:start <ID>' para iniciar un modulo.
echo   - Escribe 'system:shutdown -f' para apagar Karaf.
echo =====================================================================
echo.
call .\tools\apache-karaf-4.4.6\bin\karaf.bat
