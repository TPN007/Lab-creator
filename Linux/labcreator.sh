menu() {
  clear
  echo "--------------------------"
  echo "- LAB CREATOR v1 (Linux )-"
  echo "--------------------------"
  echo "by CEOS NETWORK"
  echo
  echo "[1] Creer une nouvelle instance"
  echo "[2] Demarrer une instance (dev)"
  echo "[3] Supprimer une instance (dev)"
  echo

  read -p "Choix : " choix

  case $choix in
    1) create_instance ;;
    2) echo "Option 2 non implémentée"; menu ;;
    3) echo "Option 3 non implémentée"; menu ;;
    *) menu ;;
  esac
}

create_instance() {
  clear
  echo "---------------"
  echo "- LAB CREATOR -"
  echo "---------------"
  echo "by CEOS NETWORK"
  echo
  echo "Definition de l'environnement"
  echo
  read -p "Saisir le chemin de l'environnement : " path
  read -p "Saisir le nom du dossier : " dir
  mkdir -p "$path/$dir"
  env="$path/$dir"

  echo 'Vagrant.configure("2") do |config|' > "$env/Vagrantfile"
  step_1
}

step_1() {
  clear
  echo "---------------"
  echo "- LAB CREATOR -"
  echo "---------------"
  echo "by CEOS NETWORK"
  echo
  echo "Choix de l'OS : "
  echo
  echo "[1] Debian"
  echo "[2] Ubuntu"
  echo "[3] Autre"
  echo
  read -p "Choix : " choix_os

  case $choix_os in
    1) os="generic/debian12" ;;
    2) os="ubuntu/jammy64" ;;
    3) read -p "OS : " os ;;
    *) step_1 ;;
  esac

  clear
  echo "---------------"
  echo "- LAB CREATOR -"
  echo "---------------"
  echo "by CEOS NETWORK"
  echo
  echo "Caractéristiques matériel :"
  echo
  read -p "Nom de la machine : " nom
  read -p "CPUs : " cpu
  read -p "RAM (MB) : " ram
  read -p "Adresse IP : " ip
  create_vagrant_file
}

create_vagrant_file() {
  clear
  echo "---------------"
  echo "- LAB CREATOR -"
  echo "---------------"
  echo "by CEOS NETWORK"
  echo
  echo "Création de l'instance :"
  echo
  {
    echo "  config.vm.define \"$nom\" do |$nom|"
    echo "    $nom.vm.box = \"$os\""
    echo "    $nom.vm.hostname = '$nom'"
    echo "    $nom.vm.box_url = \"$os\""
    echo "    $nom.vm.network :private_network, ip: \"$ip\""
    echo "    # $nom.vm.provision"
    echo "  end"
  } >> "$env/Vagrantfile"
  step_2
}

step_2() {
  clear
  echo "---------------"
  echo "- LAB CREATOR -"
  echo "---------------"
  echo "by CEOS NETWORK"
  echo
  read -p "Voulez-vous ajouter une nouvelle instance ? O/N : " inst

  case $inst in
    [Oo]) step_1 ;;
    [Nn]) step_3 ;;
    *) step_2 ;;
  esac
}

step_3() {
  {
    echo "  config.vm.provider \"virtualbox\" do |v|"
    echo "    v.memory = \"$ram\""
    echo "    v.cpus = $cpu"
    echo "  end"
    echo "end"
  } >> "$env/Vagrantfile"

  clear
  echo "---------------"
  echo "- LAB CREATOR -"
  echo "---------------"
  echo "by CEOS NETWORK"
  echo
  echo "Déplacez-vous dans le répertoire de votre projet : $env"
  echo "Lancez votre instance avec la commande : vagrant up"
  echo "Connectez-vous à celle-ci avec : vagrant ssh NomDeLaVM"
  exit 0
}

menu
