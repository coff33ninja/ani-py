@echo off
REM ---------------------------------------------------------------------------
REM patch.bat - reinstall ani-py from this repo's branch instead of upstream
REM
REM Upstream ani-py is installed from raw.githubusercontent.com/...@main, so it
REM never contains the fixes in this branch. This installer points the download
REM at coff33ninja/ani-py@feat/windows-support and needs ani-py.bat beside it.
REM
REM Usage:
REM   patch.bat              install ani-py + launcher from the patched branch
REM   patch.bat --deps       also install/verify uv, Python, fzf, VLC, mpv, yt-dlp
REM   patch.bat --prefix DIR install under DIR\bin
REM   patch.bat --no-path    skip the per-user PATH update
REM   patch.bat --uninstall  remove the two installed files
REM
REM Options other than --uninstall are passed straight through to install.bat,
REM so anything install.bat supports works here too.
REM ---------------------------------------------------------------------------
setlocal

REM Resolve this script's directory before any shift, because `shift` corrupts
REM %~dp0 inside cmd.
set "SCRIPT_DIR=%~dp0"

if not exist "%SCRIPT_DIR%ani-py.bat" (
  echo error: ani-py.bat must sit next to patch.bat; keeping both in the same folder 1>&2
  exit /b 1
)
if not exist "%SCRIPT_DIR%install.bat" (
  echo error: install.bat must sit next to patch.bat; keeping both in the same folder 1>&2
  exit /b 1
)

REM Pin the source to the patched branch. Override by setting ANI_PY_REPO or
REM ANI_PY_REF before calling if you move the branch.
if not defined ANI_PY_REPO set "ANI_PY_REPO=coff33ninja/ani-py"
if not defined ANI_PY_REF set "ANI_PY_REF=feat/windows-support"

echo Patching ani-py from %ANI_PY_REPO%@%ANI_PY_REF%
if /i "%~1"=="--uninstall" goto :uninstall

call "%SCRIPT_DIR%install.bat" %*
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo patch.bat: install.bat failed with exit code %RC% 1>&2
  exit /b %RC%
)

echo.
echo Done. The installed copy now carries this branch's fixes.
echo Persistent preferences come from the environment, not the script:
echo   setx ANI_PY_PLAYER vlc
echo   setx ANI_PY_MODE dub
exit /b 0

:uninstall
REM Default target, matching install.bat's own default.
if not defined ANI_PY_PREFIX set "ANI_PY_PREFIX=%USERPROFILE%\.local\bin"
echo Removing ani-py from %ANI_PY_PREFIX%
if exist "%ANI_PY_PREFIX%\ani-py" del /q "%ANI_PY_PREFIX%\ani-py"
if exist "%ANI_PY_PREFIX%\ani-py.bat" del /q "%ANI_PY_PREFIX%\ani-py.bat"
echo Removed. The PATH entry is left alone; drop it from your user environment
echo if you no longer want it.
exit /b 0
