@echo off
setlocal enabledelayedexpansion

:: Menu principal
:menu
cls
echo =====================
echo = LAB CREATOR v2.3 =
echo =====================
echo.
echo [1] Creer une instance
echo [2] Lancer une instance
echo [3] Supprimer une instance
echo [4] Quitter
echo.

set /p choix="Selectionnez une option : "
if "%choix%"=="1" goto creer_instance
if "%choix%"=="2" goto demarrer_instance
if "%choix%"=="3" goto supprimer_instance
if "%choix%"=="4" exit /b 0
echo Option invalide. Veuillez reessayer.
pause
goto menu

:: Creer une instance
:creer_instance
cls
echo ----------------------------
echo = Creation d'une instance =
echo ----------------------------
echo.

set /p chemin="Entrez le chemin du repertoire : "
set /p dossier="Nom du dossier : "
set env=%chemin%\%dossier%

if exist %env% (
    echo Le repertoire existe deja. Aucun repertoire cree.
    pause
    goto menu
) else (
    mkdir "%env%"
    if errorlevel 1 (
        echo Erreur : Impossible de creer le repertoire.
        pause
        goto menu
    )
)

echo Vagrant.configure("2") do ^|config^| > "%env%\Vagrantfile"
echo Fichier Vagrantfile initialise avec succes.
goto choix_os

:: Choisir l'OS
:choix_os
cls
echo ---------------------
echo = Choix du systeme OS =
echo ---------------------
echo.
echo [1] Debian
echo [2] Ubuntu
echo [3] Autre
echo.

set /p os_choisi="Selectionnez un OS : "
if "%os_choisi%"=="1" (
    set os=generic/debian12
) else if "%os_choisi%"=="2" (
    set os=ubuntu/jammy64
) else if "%os_choisi%"=="3" (
    set /p os="Entrez le nom de l'OS : "
) else (
    echo Choix invalide. Veuillez reessayer.
    pause
    goto choix_os
)

goto config_machine

:: Configurer la machine
:config_machine
cls
echo ---------------------------
echo = Configuration materielle =
echo ---------------------------
echo.

set /p nom_machine="Nom de la machine : "
set /p cpu="Nombre de CPUs : "
set /p ram="Memoire (en MB) : "

:: Configuration du disque
set /p disk_size="Taille du disque (en Go) : "

:: Configuration du réseau
goto config_network

:config_network
cls
echo ---------------------------
echo = Configuration reseau =
echo ---------------------------
echo.
echo [1] DHCP (automatique)
echo [2] Adresse IP fixe
echo.

set /p choix_network="Selectionnez une option reseau : "
if "%choix_network%"=="1" (
    set network_type=dhcp
    set ip=""

) else if "%choix_network%"=="2" (
    set network_type=static
    set /p ip="Entrez l'adresse IP fixe : "
) else (
    echo Choix invalide. Veuillez reessayer.
    pause
    goto config_network
)

goto creer_vagrantfile

:: Creer le fichier Vagrantfile
:creer_vagrantfile
(
    echo   config.vm.define "%nom_machine%" do ^|%nom_machine%^|
    echo     %nom_machine%.vm.box = "%os%"
    echo     %nom_machine%.vm.hostname = "%nom_machine%"
    if "%network_type%"=="dhcp" (
        echo     %nom_machine%.vm.network "public_network", type: "dhcp"
    ) else (
        echo     %nom_machine%.vm.network "public_network", ip: "%ip%"
    )
    echo   end
    echo   config.vm.provider "virtualbox" do ^|v^|
    echo     v.memory = "%ram%"
    echo     v.cpus = %cpu%
    echo     v.customize ["modifyvm", :id, "--vram", "16"]  :: Modification ici
    echo   end
    echo end
) >> "%env%\Vagrantfile"

:: Redimensionner le disque
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" createhd --filename "%env%\%nom_machine%.vdi" --size %disk_size%000
if errorlevel 1 (
    echo Erreur : Impossible de configurer le disque.
    pause
    goto menu
)

echo Fichier Vagrantfile et disque configures avec succes.
pause
goto menu

:: Lancer une instance
:demarrer_instance
cls
echo ------------------------
echo = Lancer une instance =
echo ------------------------
echo.
set /p chemin_instance="Entrez le chemin du repertoire de l'instance : "
cd /d "%chemin_instance%"
echo Lancement de l'instance avec vagrant up...
vagrant up
pause

:: Supprimer une instance
:supprimer_instance
cls
echo ------------------------
echo = Supprimer une instance =
echo ------------------------
echo.
set /p chemin_instance="Entrez le chemin du repertoire de l'instance : "
cd /d "%chemin_instance%"
echo Suppression de l'instance avec vagrant destroy...
vagrant destroy -f
pause