@echo off
:menu
echo ------------------
echo - LAB CREATOR v2 -
echo ------------------
echo by CEOS NETWORK
echo.
echo [1] Creer une nouvelle instance
echo [2] Demarrer une instance (dev)
echo [3] Supprimer une instance (dev)
echo.

set /p choix=Choix : 
if /I '%choix%'=='1' goto create_instance
if /I '%choix%'=='2' goto menu
if /I '%choix%'=='3' goto menu
goto menu

:create_instance
cls
echo ---------------
echo - LAB CREATOR -
echo ---------------
echo by CEOS NETWORK
echo.
echo Definition de l^'environement
echo.
set /p path=Saisir le chemin de l environement : 
set /p dir=Saisir le nom du dossier : 
mkdir "%path%\%dir%"
set env=%path%\%dir%
REM Creation du Vagrant file
echo Vagrant.configure("2") do ^|config^| > "%env%\Vagrantfile"
goto step_1

:step_1
cls
echo ---------------
echo - LAB CREATOR -
echo ---------------
echo by CEOS NETWORK
echo.
echo Choix de l^'OS : 
echo.
echo [1] Debian 12 Bookworm
echo [2] Debian 13 Trixie
echo [3] Ubuntu
echo [4] Autre
echo.
set /p choix_os=Choix :  
if /I '%choix_os%' == '1' set os=debian/bookworm64
if /I '%choix_os%' == '2' set os=alvistack/debian-13
if /I '%choix_os%' == '3' set os=bento/ubuntu-24.04
if /I '%choix_os%' == '4' set /P os=OS :
cls
echo ---------------
echo - LAB CREATOR -
echo ---------------
echo by CEOS NETWORK
echo.
echo Caracteristiques Materiel :
echo.
set /p nom=Nom de la machine : 
set /p cpu=CPUs : 
set /p ram=RAM (MB) : 
set /p disk=Taille du disque (Go) :

REM ========================================
REM CONFIGURATION RESEAU
REM ========================================

:network_config
cls
echo Configuration Reseau : 
echo [1] Interne / NAT
echo [2] Par pont (Bridge)
echo.

set /p network=Choix :

if "%network%"=="1" goto network_internal
if "%network%"=="2" goto network_bridge
goto network_config

:network_internal
set "network_mode=internal"
echo.
set /p ip=Adresse IP :
goto create_vagrant_file

:network_bridge
set "network_mode=bridge"
echo.
echo Interfaces reseau disponibles :
echo.
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" list bridgedifs
echo.
set /p bridge_interface=Nom exact de l interface :
echo.
echo Configuration IP :
echo.
echo [1] DHCP
echo [2] IP statique
echo.
set /p ip_mode=Choix :

if "%ip_mode%"=="1" goto network_dhcp
if "%ip_mode%"=="2" goto network_static
goto network_bridge

:network_dhcp
set "ip_mode=dhcp"
goto create_vagrant_file

:network_static
set "ip_mode=static"
echo.
set /p ip=Adresse IP :
set /p netmask=Masque reseau :
set /p gateway=Passerelle :
set /p dns=DNS :
goto create_vagrant_file

:create_vagrant_file
cls
echo ---------------
echo - LAB CREATOR -
echo ---------------
echo by CEOS NETWORK
echo.
echo Creation de l instance :
echo.
echo   config.vm.define "%nom%" do ^|%nom%^| >> "%env%\Vagrantfile"
echo    %nom%.vm.box = "%os%" >> "%env%\Vagrantfile"
echo    %nom%.vm.hostname = '%nom%' >> "%env%\Vagrantfile"

REM Configuration reseau

if "%network_mode%"=="internal" (
    echo    %nom%.vm.network "private_network", ip: "%ip%", virtualbox__intnet: true >> "%env%\Vagrantfile"
)

if "%network_mode%"=="bridge" (
    if "%ip_mode%"=="dhcp" (
        echo    %nom%.vm.network "public_network", bridge: "%bridge_interface%" >> "%env%\Vagrantfile"
    )
    if "%ip_mode%"=="static" (
        echo    %nom%.vm.network "public_network", bridge: "%bridge_interface%", ip: "%ip%", netmask: "%netmask%" >> "%env%\Vagrantfile"
    )
)

echo    #%nom%.vm.provision >> "%env%\Vagrantfile"
echo    %nom%.vm.disk :disk, name: "disk", size: "%disk%GB", primary: true >> "%env%\Vagrantfile"
echo   end >> "%env%\Vagrantfile"
goto step_2

:step_2
cls
echo ---------------
echo - LAB CREATOR -
echo ---------------
echo by CEOS NETWORK
echo.
echo Voulez-vous ajouter une nouvelle instance ?
set /p inst=O/N : 
if /I '%inst%' == 'O' goto step_1
if /I '%inst%' == 'Y ' goto step_1
if /I '%inst%' == 'N' goto step_3

:step_3
echo   config.vm.provider "virtualbox" do ^|v^| >> "%env%\Vagrantfile"
echo    v.memory = "%ram%" >> "%env%\Vagrantfile"
echo    v.cpus = %cpu% >> "%env%\Vagrantfile"
echo   end >> "%env%\Vagrantfile"
echo end >> "%env%\Vagrantfile"
cls
echo ---------------
echo - LAB CREATOR -
echo ---------------
echo by CEOS NETWORK
echo. 
echo Deplacez-vous dans le repertoire de votre projet : %env%
echo Lancez votre instance avec la commande : vagrant up
echo Connectez vous a celle-ci avec : vagrant ssh NomDeLaVM
exit
REM echo Provisionning
REM echo.
REM echo [1] Modifier le fichier
REM echo [2] Ne pas faire de provisionning
REM echo.
REM set /p prov=Choix : 
REM if /I '%prov%' == '1' code %env%\Vagrantfile
REM if /I '%prov%' == '2' goto init_instance
