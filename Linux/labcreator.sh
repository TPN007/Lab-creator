#!/bin/bash

# Fichier de log pour save les actions effectuées
LOG_FILE="/var/log/lab_creator.log"

# Fonction pour écrire des messages dans le fichier log
log_message() {
  local level="$1"    # Niveau du message (INFO, ERROR, etc...)
  local message="$2"  # Message à enregistrer
  echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" >> "$LOG_FILE"
}

# Initialisation des logs et création du fichier de log si inexistant
init_log() {
  if [ ! -e "$LOG_FILE" ]; then
    sudo touch "$LOG_FILE"       # Création du fichier de log
    sudo chmod 644 "$LOG_FILE"   # Permissions pour permettre l'écriture
  fi
  log_message "INFO" "Démarrage du script LAB CREATOR."
}

# Affiche le menu principal et gère les options
afficher_menu() {
  clear
  echo "====================="
  echo "= LAB CREATOR v2.2 ="
  echo "====================="
  echo "Développé par CEOS NETWORK"
  echo
  echo "1) Créer une instance"
  echo "2) Lancer une instance"
  echo "3) Supprimer une instance"
  echo "4) Quitter"
  echo
  # Lecture de l'option choisie par l'utilisateur
  read -p "Sélectionnez une option : " choix
  case "$choix" in
    1) creer_instance ;;   # Appelle la fonction pour créer une instance
    2) demarrer_instance ;;
    3) supprimer_instance ;;
    4) exit 0 ;;             
    *)                       # Gère les choix invalides
      echo "Option invalide."
      sleep 2
      afficher_menu ;;
  esac
}

# fonction pour créer une nouvelle instance
creer_instance() {
  clear
  echo "------------------------"
  echo "= Création d'une instance ="
  echo "------------------------"
  echo "Par CEOS NETWORK"
  echo
  echo "Configuration de l'environnement"
  echo
  # Demande des informations sur le chemin et le dossier
  read -p "Entrez le chemin du répertoire : " chemin
  read -p "Nom du dossier : " dossier

  # Vérifie si le répertoire existe
  if [ -d "$chemin/$dossier" ]; then
    log_message "INFO" "Le répertoire $chemin/$dossier existe déjà. Aucun répertoire créé."
    echo "Le répertoire existe déjà. Aucun répertoire créé."
  else
    # Création du répertoire s'il n'existe pas
    mkdir -p "$chemin/$dossier" 2>> "$LOG_FILE"
    if [ $? -ne 0 ]; then
      log_message "ERROR" "Échec de création du répertoire $chemin/$dossier."
      echo "Erreur : Impossible de créer le répertoire. Consultez $LOG_FILE."
      return
    fi
    log_message "INFO" "Répertoire $chemin/$dossier créé avec succès."
    echo "Répertoire créé avec succès."
  fi

  # On défini ici l'environnement de travail
  environnement="$chemin/$dossier"
  log_message "INFO" "Répertoire de travail défini : $environnement."
  echo "Vagrant.configure(\"2\") do |config|" > "$environnement/Vagrantfile" # Initialisation du fichier Vagrantfile
  log_message "INFO" "Fichier Vagrantfile initialisé."
  choix_os # Appelle la fonction pour choisir l'OS a installer
}

# Fonction pour sélectionner le système d'exploitation
choix_os() {
  clear
  echo "------------------------"
  echo "= Choix du système OS ="
  echo "------------------------"
  echo "1) Debian"
  echo "2) Ubuntu"
  echo "3) Autre"
  echo
  read -p "Sélectionnez un OS : " os_choisi
  case "$os_choisi" in
    1) os="generic/debian12" ;;
    2) os="ubuntu/jammy64" ;;
    3) read -p "Entrez le nom de l'OS : " os ;;
    *) choix_os ;;               # Relance le menu en cas de choix invalide
  esac
  log_message "INFO" "Système d'exploitation sélectionné : $os."
  configuration_machine # Passe à la configuration de la machine
}

# Fonction pour configurer les paramètres de la machine
configuration_machine() {
  clear
  echo "------------------------"
  echo "= Configuration matériel ="
  echo "------------------------"
  echo
  # Demande des informations matérielles
  read -p "Nom de la machine : " nom_machine
  read -p "Nombre de CPUs : " cpu
  read -p "Mémoire (en MB) : " ram
  read -p "Adresse IP : " ip
  creer_fichier_vagrant # Appelle la fonction pour générer le Vagrantfile
}

# Fonction pour créer le fichier Vagrantfile avec les paramètres spécifiés
creer_fichier_vagrant() {
  {
    echo "  config.vm.define \"$nom_machine\" do |$nom_machine|"
    echo "    $nom_machine.vm.box = \"$os\""
    echo "    $nom_machine.vm.hostname = \"$nom_machine\""
    echo "    $nom_machine.vm.network :private_network, ip: \"$ip\""
    echo "  end"
    echo "  config.vm.provider \"virtualbox\" do |v|"
    echo "    v.memory = \"$ram\""
    echo "    v.cpus = $cpu"
    echo "  end"
    echo "end"
  } >> "$environnement/Vagrantfile"
  if [ $? -eq 0 ]; then
    log_message "INFO" "Fichier Vagrantfile créé avec succès dans $environnement."
    echo "Fichier Vagrantfile généré avec succès."
  else
    log_message "ERROR" "Échec de création du Vagrantfile dans $environnement."
    echo "Erreur : Impossible de créer le fichier Vagrantfile. Consultez $LOG_FILE."
  fi
}

# Fonction pour lancer une instance existante ou qui vient d'être créer
demarrer_instance() {
  clear
  echo "------------------------"
  echo "= Lancer une instance ="
  echo "------------------------"
  echo
  read -p "Entrez le chemin vers le dossier de l'instance : " chemin_instance
  if [ ! -d "$chemin_instance" ]; then
    log_message "ERROR" "Répertoire $chemin_instance introuvable."
    echo "Erreur : Le répertoire spécifié n'existe pas."
    return
  fi
  cd "$chemin_instance" && vagrant up 2>> "$LOG_FILE"
  if [ $? -eq 0 ]; then
    log_message "INFO" "Instance démarrée avec succès dans $chemin_instance."
    echo "Instance démarrée avec succès."
  else
    log_message "ERROR" "Échec du démarrage de l'instance dans $chemin_instance."
    echo "Erreur : Échec du démarrage de l'instance. Consultez $LOG_FILE."
  fi
}

# Fonction pour supprimer une instance si existante 
supprimer_instance() {
  clear
  echo "------------------------"
  echo "= Supprimer une instance ="
  echo "------------------------"
  echo
  read -p "Entrez le chemin vers le dossier de l'instance à supprimer : " chemin_instance
  if [ ! -d "$chemin_instance" ]; then
    log_message "ERROR" "Répertoire $chemin_instance introuvable."
    echo "Erreur : Le répertoire spécifié n'existe pas."
    return
  fi
  cd "$chemin_instance" && vagrant destroy -f 2>> "$LOG_FILE"
  if [ $? -eq 0 ]; then
    rm -rf "$chemin_instance"
    log_message "INFO" "Instance supprimée avec succès dans $chemin_instance."
    echo "Instance supprimée avec succès."
  else
    log_message "ERROR" "Échec de la suppression de l'instance dans $chemin_instance."
    echo "Erreur : Échec de la suppression de l'instance. Consultez $LOG_FILE."
  fi
}

# Lancement du script et on initie le fichier log
init_log
afficher_menu