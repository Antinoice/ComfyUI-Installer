@echo off
:: =======================================
::  ComfyUI Easy Installer
::  Created by: [Antinoice]
::  Date: [10.feb.2025]
:: =======================================
setlocal enabledelayedexpansion

:MENU
cls
echo.
echo ^|-----------------------------------^|
echo ^|      Created by: [Antinoice]      ^|
echo ^|-----------------------------------^|
echo ^|                                   ^|
echo ^|     ComfyUI Easy Install Menu     ^|
echo ^|                                   ^|
echo ^|-----------------------------------^|
echo ^|                                   ^|
echo ^|  Do you want to install ComfyUI?  ^|
echo ^|                                   ^|
echo ^|           [ Y ] Yes               ^|
echo ^|           [ N ] No                ^|
echo ^|                                   ^|
echo ^|-----------------------------------^|
echo.

choice /c YN /n /m "Press Y to install, N to cancel: "

if errorlevel 2 (
    echo Installation aborted.
    timeout /t 2 >nul
    exit /b
)

if errorlevel 1 (
    echo Starting ComfyUI installation...
    timeout /t 2 >nul
)

REM Check if 7-Zip is already installed
where 7z.exe >nul 2>&1
if %errorlevel% EQU 0 (
    for /f "delims=" %%I in ('where 7z.exe') do set "SEVEN_ZIP_PATH=%%I"
    echo 7-Zip is already installed at "!SEVEN_ZIP_PATH!"
    goto SKIP_7ZIP_INSTALL
)

REM Define the expected installation path
set "SEVEN_ZIP_INSTALL_PATH=%ProgramFiles%\7-Zip\7z.exe"

REM If 7-Zip is not installed, download and install it
echo 7-Zip is not installed. Downloading and installing...
curl -L -o 7z2409-x64.exe https://github.com/ip7z/7zip/releases/download/24.09/7z2409-x64.exe

REM Check if the installer was successfully downloaded
if not exist 7z2409-x64.exe (
    echo Failed to download 7-Zip installer. Please check your internet connection.
    exit /b 1
)

REM Run the installer in silent mode
echo Installing 7-Zip...
start /wait 7z2409-x64.exe /S

REM Verify if 7-Zip was successfully installed
if not exist "%SEVEN_ZIP_INSTALL_PATH%" (
    echo Installation of 7-Zip failed. Please install it manually and try again.
    exit /b 1
)

:SKIP_7ZIP_INSTALL
REM Define the expected installation path
set "GIT_INSTALL_PATH=%ProgramFiles%\Git\git-bash.exe"

REM If Git is not installed, download and install it
echo Git is not installed. Downloading and installing...
curl -L -o Git-2.47.1.2-64-bit.exe https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.2/Git-2.47.1.2-64-bit.exe

REM Check if the installer was successfully downloaded
if not exist Git-2.47.1.2-64-bit.exe (
    echo Failed to download Git installer. Please check your internet connection.
    exit /b 1
)

REM Run the installer
echo Installing Git...
start /wait Git-2.47.1.2-64-bit.exe

REM Verify if Git was successfully installed
if not exist "%GIT_INSTALL_PATH%" (
    echo Installation of Git failed. Please install it manually and try again.
    exit /b 1
)

REM Download ComfyUI
echo [33mDownloading ComfyUI...[0m
curl -L -o ComfyUI_windows_portable_nvidia.7z https://github.com/comfyanonymous/ComfyUI/releases/download/v0.3.27/ComfyUI_windows_portable_nvidia.7z

:ARCHIVE_NAME
set "ARCHIVE_NAME=ComfyUI_windows_portable_nvidia.7z"

echo.
echo ^|-----------------------------------^|
echo ^|                                   ^|
echo ^|     SELECT DRIVE TO CONTINUE      ^|
echo ^|                                   ^|
echo ^|-----------------------------------^|
echo.

REM Prompt user to select a drive
:DRIVE_SELECTION
set /p "DRIVE=Enter the drive letter where you want to extract (C, D, E, F, G): "
set "DRIVE=%DRIVE:~0,1%"

REM Validate drive
if not exist "%DRIVE%:\" (
    echo Invalid drive letter or drive does not exist. Please enter a valid drive.
    goto DRIVE_SELECTION
)

REM Check if 7-Zip is installed and find its path
set "SEVEN_ZIP_PATH="
for /f "delims=" %%I in ('where 7z.exe 2^>nul') do set "SEVEN_ZIP_PATH=%%I"

REM If 7-Zip is not found in PATH, check Program Files locations
if not defined SEVEN_ZIP_PATH (
    if exist "%ProgramFiles%\7-Zip\7z.exe" set "SEVEN_ZIP_PATH=%ProgramFiles%\7-Zip\7z.exe"
    if exist "%ProgramFiles(x86)%\7-Zip\7z.exe" set "SEVEN_ZIP_PATH=%ProgramFiles(x86)%\7-Zip\7z.exe"
)

REM If still not found, show an error
if not defined SEVEN_ZIP_PATH (
    echo Error: 7-Zip is not installed or not found in PATH.
    exit /b 1
)

echo Using 7-Zip from: %SEVEN_ZIP_PATH%
echo Extracting .7z file...

REM Extract the archive
"%SEVEN_ZIP_PATH%" x "%ARCHIVE_NAME%" -o"%DRIVE%:\" -y

REM Check if extraction was successful
if not exist "%DRIVE%:\ComfyUI_windows_portable" (
    echo Extraction failed. Please check the archive and try again.
    exit /b 1
)

echo.
echo ^|-----------------------------------^|
echo.

REM Change directory to the target location
cd /d "%DRIVE%:\ComfyUI_windows_portable"

REM UPDATE_AND_CONFIGURATION
echo [33mUpdate ComfyUI[0m
cd update
..\python_embeded\python.exe -m pip install --upgrade pip
..\python_embeded\python.exe -m pip install -r "%DRIVE%:\ComfyUI_windows_portable\ComfyUI\requirements.txt"
..\python_embeded\python.exe .\update.py ..\ComfyUI\
if exist update_new.py (
  move /y update_new.py update.py
  echo Running updater again since it got updated.
  ..\python_embeded\python.exe .\update.py ..\ComfyUI\ --skip_self_update
)

REM Install torch
..\python_embeded\pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
echo Torch installed.

REM Install cuDNN
..\python_embeded\pip install nvidia-cudnn-cu12
echo cuDNN installed.

REM Install Numpy-2
..\python_embeded\python.exe -m pip install "numpy<2"
echo Numpy installed.

REM Install xformers
..\python_embeded\python.exe -m pip install xformers
echo xformers installed.

REM Install ONNX
..\python_embeded\python.exe -m pip install onnx
echo ONNX installed.

REM Install ONNXruntime-gpu
..\python_embeded\python.exe -m pip install onnxruntime-gpu --upgrade
echo ONNXruntime installed.

REM Install Insightface
..\python_embeded\python.exe -m pip install insightface==0.7.3
echo Insightface installed.

REM =======================================
REM Add Python dependencies to PATH
REM =======================================
echo Adding Python dependencies to PATH...
set "PYTHON_PATH=%DRIVE%:\ComfyUI_windows_portable\python_embeded"
set "PYTHON_SCRIPTS_PATH=%DRIVE%:\ComfyUI_windows_portable\python_embeded\Scripts"

REM Check if paths already exist in PATH
echo %PATH% | find /i "%PYTHON_PATH%" >nul
if errorlevel 1 (
    setx PATH "%PYTHON_PATH%;%PATH%"
)

echo %PATH% | find /i "%PYTHON_SCRIPTS_PATH%" >nul
if errorlevel 1 (
    setx PATH "%PYTHON_SCRIPTS_PATH%;%PATH%"
)

echo Python dependencies added to PATH.

REM Navigate to custom_nodes folder
cd "%DRIVE%:\ComfyUI_windows_portable\ComfyUI\custom_nodes"

REM Clone ComfyUI-Manager
echo [33mInstalling ComfyUI-Manager...[0m
git clone https://github.com/ltdrdata/ComfyUI-Manager.git >nul 2>&1
echo [33mInstalling additional nodes...[0m

REM Get the path and call install-manager-for-portable-version.bat file
cd ComfyUI-Manager\scripts
call "install-manager-for-portable-version.bat"

REM Install Insightface
cd /d "%DRIVE%:\ComfyUI_windows_portable\python_embeded"
curl -L -o "insightface-0.7.3-cp312-cp312-win_amd64.whl" "https://huggingface.co/antinoice/Insightface/resolve/main/insightface-0.7.3-cp312-cp312-win_amd64.whl"
python.exe -m pip install insightface-0.7.3-cp312-cp312-win_amd64.whl

REM Install Insightface models
mkdir "%DRIVE%:\ComfyUI_windows_portable\ComfyUI\models\insightface" >nul 2>&1
cd /d "%DRIVE%:\ComfyUI_windows_portable\ComfyUI\models\insightface" >nul 2>&1

curl -L -o "inswapper_128.onnx" "https://huggingface.co/antinoice/inswapper/resolve/main/inswapper_128.onnx"
curl -L -o "GFPGANv1.4.onnx" "https://huggingface.co/antinoice/GFPGANv1.4/resolve/main/GFPGANv1.4.onnx"
curl -L -o "buffalo_l.zip" "https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l.zip"

:: Распаковка buffalo_l
cd /d "%DRIVE%:\ComfyUI_windows_portable\ComfyUI\models\insightface
"%SEVEN_ZIP_PATH%" x "buffalo_l.zip" -o"buffalo_l" -y
del "buffalo_l.zip"
echo Insightface models installed.

:MODELS_INSTALLATION
REM Get the path of the current script's directory
set "BASE_DIR=%DRIVE%:\ComfyUI_windows_portable\"

:SDXL_MODEL_INSTALATION
REM Ask user if they want to download SDXL model
echo.
echo ^|-----------------------------------^|
echo ^|    Install NewEra SDXL model?     ^|
echo ^|-----------------------------------^|
echo ^|           [ Y ] Yes               ^|
echo ^|           [ N ] No                ^|
echo ^|-----------------------------------^|
echo.

choice /c YN /n /m "Press Y to install, N to skip: "

if errorlevel 2 (
    echo Skipped.
    timeout /t 2 >nul
    goto PONY_DIFFUSION_V6_XL_MODEL_INSTALATION
) 

if errorlevel 1 (
    echo Starting SDXL installation...
    timeout /t 2 >nul
)

REM Download and install SDXL model
cd /d "%BASE_DIR%ComfyUI\models\checkpoints"
echo Downloading SDXL model...
curl -L -o "neweraXL_v10.safetensors" "https://huggingface.co/antinoice/NewEraXL/resolve/main/neweraXL_v10.safetensors?download=true"
echo SDXL model is installed!

:PONY_DIFFUSION_V6_XL_MODEL_INSTALATION
REM Ask user if they want to download SDXL model
echo.
echo ^|-----------------------------------^|
echo ^|        Install PONY model?        ^|
echo ^|      (Pony Diffusion V6 XL)       ^|
echo ^|-----------------------------------^|
echo ^|           [ Y ] Yes               ^|
echo ^|           [ N ] No                ^|
echo ^|-----------------------------------^|
echo.

choice /c YN /n /m "Press Y to install, N to skip: "

if errorlevel 2 (
    echo Skipped.
    timeout /t 2 >nul
    goto FLUX_SCHNELL_INSTALATION
) 

if errorlevel 1 (
    echo Starting PONY Diffusion installation...
    timeout /t 2 >nul
)

REM Download and install SDXL model
cd /d "%BASE_DIR%ComfyUI\models\checkpoints"
echo Downloading PONY Diffusion model...
curl -L -o "pony_diffusion_v6_xl.safetensors" "https://civitai.com/api/download/models/290640?type=Model&format=SafeTensor&size=pruned&fp=fp16"
echo PONY Diffusion model is installed!

:FLUX_SCHNELL_INSTALATION
REM Ask user if they want to download Flux Shuttle model
echo.
echo ^|-----------------------------------^|
echo ^|    Install Flux Schnell model?    ^|
echo ^|-----------------------------------^|
echo ^|           [ Y ] Yes               ^|
echo ^|           [ N ] No                ^|
echo ^|-----------------------------------^|
echo.

choice /c YN /n /m "Press Y to install, N to skip: "

if errorlevel 2 (
    echo Skipped.
    timeout /t 2 >nul
    goto FLUX_SHUTTLE_INSTALATION
)

if errorlevel 1 (
    echo Starting Flux Schnell installation...
    timeout /t 2 >nul
)

REM Download and install Flux Schnell model
if not exist "%BASE_DIR%ComfyUI\models\unet" mkdir "%BASE_DIR%ComfyUI\models\unet"
cd /d "%BASE_DIR%ComfyUI\models\unet"
echo Downloading Flux Schnell model...
curl -L -o "flux1-schnell-Q4_K_S.gguf" "https://huggingface.co/lllyasviel/FLUX.1-schnell-gguf/resolve/main/flux1-schnell-Q4_K_S.gguf?download=true"
echo Flux Schnell model is installed!

:FLUX_SHUTTLE_INSTALATION
REM Ask user if they want to download Flux Shuttle model
echo.
echo ^|-----------------------------------^|
echo ^|    Install Flux Shuttle model?    ^|
echo ^|-----------------------------------^|
echo ^|           [ Y ] Yes               ^|
echo ^|           [ N ] No                ^|
echo ^|-----------------------------------^|
echo.

choice /c YN /n /m "Press Y to install, N to skip: "

if errorlevel 2 (
    echo Skipped.
    timeout /t 2 >nul
    goto FLUX_DEV_INSTALATION
)

if errorlevel 1 (
    echo Starting Flux Shuttle installation...
    timeout /t 2 >nul
)

REM Download and install Flux Shuttle model
echo Downloading Flux Shuttle model...
curl -L -o "shuttle-jaguar-Q4_K_S.gguf" "https://huggingface.co/shuttleai/shuttle-jaguar/resolve/main/gguf/shuttle-jaguar-Q4_K_S.gguf?download=true"
echo Flux Shuttle model is installed!

:FLUX_DEV_INSTALATION
REM Ask user if they want to download Flux Dev model
echo.
echo ^|-----------------------------------^|
echo ^|   Install Flux Dev Q4_K_S model?  ^|
echo ^|-----------------------------------^|
echo ^|           [ Y ] Yes               ^|
echo ^|           [ N ] No                ^|
echo ^|-----------------------------------^|
echo.

choice /c YN /n /m "Press Y to install, N to skip: "

if errorlevel 2 (
    echo Skipped.
    timeout /t 2 >nul
    goto BASE_COMPONENTS_INSTALLATION
)

if errorlevel 1 (
    echo Starting Flux Dev installation...
    timeout /t 2 >nul
)

REM Download and install Flux Dev model
echo Downloading Flux Dev model...
curl -L -o "flux1-dev-Q4_K_S.gguf" "https://huggingface.co/lllyasviel/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q4_K_S.gguf?download=true"
echo Flux Dev model is installed!

echo.
echo ^|-----------------------------------^|
echo.

:BASE_COMPONENTS_INSTALLATION
REM Ask user if they want to download Flux Dev model
echo.
echo ^|-----------------------------------^|
echo ^|      Install base components?     ^|
echo ^|     (VAE,Clip,Upscale models)     ^|
echo ^|-----------------------------------^|
echo ^|            [ Y ] Yes              ^|
echo ^|            [ N ] No               ^|
echo ^|-----------------------------------^|
echo.

choice /c YN /n /m "Press Y to install, N to skip: "

if errorlevel 2 (
    echo Skipped.
    timeout /t 2 >nul
    goto COMPONENTS_INSTALLED
)

if errorlevel 1 (
    echo Starting Base Components installation...
    timeout /t 2 >nul
)

:SDXL_VAE_INSTALATION
REM Download VAE file
echo Downloading VAE files...
cd /d "%BASE_DIR%ComfyUI\models\vae"
curl -L -o "sdxl_vae.safetensors" "https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors?download=true"
echo sdxl_vae.safetensors - Fully installed!

:FLUX_VAE_INSTALATION
REM Download VAE file
echo Downloading VAE files...
curl -L -o "diffusion_pytorch_model.safetensors" "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/vae/diffusion_pytorch_model.safetensors?download=true"
echo diffusion_pytorch_model.safetensors - Fully installed!

:FLUX_Clip_INSTALATION
REM Download CLIP files
echo Downloading CLIP files...
cd /d "%BASE_DIR%ComfyUI\models\clip"
curl -L -o "clip_l.safetensors" "https://huggingface.co/lllyasviel/flux_text_encoders/resolve/main/clip_l.safetensors?download=true"
curl -L -o "clip_g.safetensors" "https://huggingface.co/calcuis/sd3.5-large-gguf/resolve/main/clip_g.safetensors?download=true"
curl -L -o "t5xxl_fp8_e4m3fn.safetensors" "https://huggingface.co/lllyasviel/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors?download=true"
curl -L -o "t5xxl_fp16.safetensors" "https://huggingface.co/lllyasviel/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors?download=true"
echo Clip text encoder models fully installed!

:Upscale_models_INSTALATION
REM Download upscale model
echo Downloading Upscale_models files...
cd /d "%BASE_DIR%ComfyUI\models\upscale_models"
curl -L -o "1x-Focus.pth" "https://huggingface.co/antinoice/Upscallers/resolve/main/2x-BSRGAN.pth?download=true"
curl -L -o "2x-BSRGAN.pth" "https://huggingface.co/antinoice/Upscallers/resolve/main/2x-BSRGAN.pth?download=true"
curl -L -o "4x-PSNR.pth" "https://huggingface.co/antinoice/Upscallers/resolve/main/4x-PSNR.pth?download=true"
curl -L -o "4x-UltraSharp.pth" "https://huggingface.co/antinoice/Upscallers/resolve/main/4x-UltraSharp.pth"
curl -L -o "4x_NMKD-Siax_200k" "https://huggingface.co/antinoice/Upscallers/resolve/main/4x_NMKD-Siax_200k.pth"
echo Upscale models partially installed!

:COMPONENTS_INSTALLED
REM Final - all is installed!
echo.
echo ^|-----------------------------------^|
echo ^|                                   ^|
echo ^|  Congratulations!                 ^|
echo ^|  ComfyUI is installed! Enjoy!     ^|
echo ^|  Stay with Antinoice for more!    ^|
echo ^|                                   ^|
echo ^|-----------------------------------^|
echo.
pause
exit /b