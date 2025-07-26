@echo off
REM Terraform initialization script for Windows
REM Usage: init.bat [environment]
REM Example: init.bat dev

set ENVIRONMENT=%1
if "%ENVIRONMENT%"=="" set ENVIRONMENT=prod

set BACKEND_CONFIG=backend
if not "%ENVIRONMENT%"=="prod" set BACKEND_CONFIG=backend-%ENVIRONMENT%

echo Initializing Terraform with %ENVIRONMENT% backend configuration...

if exist "%BACKEND_CONFIG%.hcl" (
    terraform init -backend-config="%BACKEND_CONFIG%.hcl"
    if %ERRORLEVEL% equ 0 (
        echo Terraform initialized successfully for %ENVIRONMENT% environment!
    ) else (
        echo Failed to initialize Terraform!
        exit /b 1
    )
) else (
    echo Backend configuration file %BACKEND_CONFIG%.hcl not found!
    echo Available configurations:
    dir backend*.hcl 2>nul
    exit /b 1
)
