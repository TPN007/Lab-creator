@echo off
:menu
echo ---------------
echo - LAB CREATOR -
echo ---------------
echo by CEOS NETWORK
echo.
echo [1] Creer une nouvelle instance
echo [2] Supprimer une instance (dev)
echo [3] Initialiser une instance (dev)
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
mkdir %path%\%dir%
set env=%path%\%dir%
REM Creation du Vagrant file
echo Vagrant.configure("2") do ^|config^| > %env%\Vagrantfile
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
echo [1] Debian
echo [2] Ubuntu
echo [3] Autre
echo.
set /p choix_os=Choix :  
if /I '%choix_os%' == '1' set os=generic/debian11
if /I '%choix_os%' == '2' set os=ubuntu/jammy64
if /I '%choix_os%' == '3' set /p os=OS : 
cls
echo ---------------
echo - LAB CREATOR -
echo ---------------
echo by CEOS NETWORK
echo.
echo Caracteristiques materiel :
echo.
set /p nom=Nom de la machine : 
set /p cpu=CPUs : 
set /p ram=RAM : 
set /p ip=Adresse IP : 
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
echo   config.vm.define "%nom%" do ^|%nom%^| >> %env%\Vagrantfile
echo    %nom%.vm.box = "%os%" >> %env%\Vagrantfile
echo    %nom%.vm.hostname = '%nom%' >> %env%\Vagrantfile
echo    %nom%.vm.box_url = "%os%" >> %env%\Vagrantfile
echo    %nom%.vm.network :private_network, ip: "%ip%" >> %env%\Vagrantfile
echo    #%nom%.vm.provision >> %env%\Vagrantfile
echo   end >> %env%\Vagrantfile
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
if /I '%inst%' == 'N' goto step_3

:step_3
echo   config.vm.provider "virtualbox" do ^|v^| >> %env%\Vagrantfile
echo    v.memory = "%ram%" >> %env%\Vagrantfile
echo    v.cpus = %cpu% >> %env%\Vagrantfile
echo   end >> %env%\Vagrantfile
echo end >> %env%\Vagrantfile
cls
echo ---------------
echo - LAB CREATOR -
echo ---------------
echo by CEOS NETWORK
echo.
echo Deplacez-vous dans le repertoire de votre projet
echo Lancez votre instance avec la commande : vagrant init
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

:pre_init_instance
cls
echo ---------------
echo - LAB CREATOR -
echo ---------------
echo by CEOS NETWORK
echo.
echo Initialisation d^'instance
echo.
set /p path=Saisir le chemin de l^'environement : 
set env=%path%
goto init_instance

:init_instance
cls
echo ---------------
echo - LAB CREATOR -
echo ---------------
echo by CEOS NETWORK
echo.
echo Initialisation de l^'instance...
echo.
cd %env%
%PROGRAMFILES%\Vagrant\bin\vagrant init