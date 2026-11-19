import os
import shutil
import subprocess
from pathlib import Path

VAGRANT_DEFAULT = Path(r"C:\Program Files\Vagrant\bin\vagrant.exe")


def effacer_ecran() -> None:
    os.system("cls" if os.name == "nt" else "clear")


def afficher_banniere(version: str = "") -> None:
    effacer_ecran()
    titre = f"- LAB CREATOR {version} -".strip() if version else "- LAB CREATOR -"
    bordure = "-" * len(titre)
    print(bordure)
    print(titre)
    print(bordure)
    print("by CEOS NETWORK\n")


def lister_interfaces_bridge() -> None:
    vbox_default = Path(r"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe")
    vbox_cmd = str(vbox_default) if vbox_default.exists() else shutil.which("VBoxManage")

    if not vbox_cmd:
        print("[!] VBoxManage introuvable. Saisissez le nom de l'interface manuellement.")
        return

    try:
        subprocess.run([vbox_cmd, "list", "bridgedifs"], check=False)
    except OSError as e:
        print(f"[!] Impossible d'executer VBoxManage : {e}")


def choisir_os() -> str:
    os_map = {
        "1": "debian/bookworm64",
        "2": "alvistack/debian-13",
        "3": "bento/ubuntu-24.04",
    }

    while True:
        afficher_banniere()
        print("Choix de l'OS :\n")
        print("[1] Debian 12 Bookworm")
        print("[2] Debian 13 Trixie")
        print("[3] Ubuntu")
        print("[4] Autre\n")

        choix = input("Choix : ").strip()
        if choix in os_map:
            return os_map[choix]
        if choix == "4":
            return input("OS : ").strip()


def configurer_reseau() -> dict:
    while True:
        effacer_ecran()
        print("Configuration Reseau :")
        print("[1] Interne / NAT")
        print("[2] Par pont (Bridge)\n")

        choix = input("Choix : ").strip()

        if choix == "1":
            print()
            ip = input("Adresse IP : ").strip()
            return {"mode": "internal", "ip": ip}

        if choix == "2":
            print("\nInterfaces reseau disponibles :\n")
            lister_interfaces_bridge()
            print()
            bridge_interface = input("Nom exact de l interface : ").strip()

            while True:
                print("\nConfiguration IP :\n")
                print("[1] DHCP")
                print("[2] IP statique\n")
                ip_mode = input("Choix : ").strip()

                if ip_mode == "1":
                    return {
                        "mode": "bridge",
                        "ip_mode": "dhcp",
                        "bridge_interface": bridge_interface,
                    }
                if ip_mode == "2":
                    print()
                    ip = input("Adresse IP : ").strip()
                    netmask = input("Masque reseau : ").strip()
                    gateway = input("Passerelle : ").strip()
                    dns = input("DNS : ").strip()
                    return {
                        "mode": "bridge",
                        "ip_mode": "static",
                        "bridge_interface": bridge_interface,
                        "ip": ip,
                        "netmask": netmask,
                        "gateway": gateway,
                        "dns": dns,
                    }


def configurer_instance(vagrantfile: Path) -> tuple[str, str]:
    os_box = choisir_os()

    afficher_banniere()
    print("Caracteristiques Materiel :\n")
    nom = input("Nom de la machine : ").strip()
    cpu = input("CPUs : ").strip()
    ram = input("RAM (MB) : ").strip()
    disk = input("Taille du disque (Go) : ").strip()

    reseau = configurer_reseau()

    afficher_banniere()
    print("Creation de l instance :\n")

    lignes = [
        f'  config.vm.define "{nom}" do |{nom}|',
        f'   {nom}.vm.box = "{os_box}"',
        f"   {nom}.vm.hostname = '{nom}'",
    ]

    if reseau["mode"] == "internal":
        lignes.append(
            f'   {nom}.vm.network "private_network", ip: "{reseau["ip"]}", virtualbox__intnet: true'
        )
    elif reseau["mode"] == "bridge":
        if reseau["ip_mode"] == "dhcp":
            lignes.append(
                f'   {nom}.vm.network "public_network", bridge: "{reseau["bridge_interface"]}"'
            )
        elif reseau["ip_mode"] == "static":
            lignes.append(
                f'   {nom}.vm.network "public_network", bridge: "{reseau["bridge_interface"]}", '
                f'ip: "{reseau["ip"]}", netmask: "{reseau["netmask"]}"'
            )

    lignes.extend([
        f"   #{nom}.vm.provision",
        f'   {nom}.vm.disk :disk, name: "disk", size: "{disk}GB", primary: true',
        "  end",
    ])

    with vagrantfile.open("a", encoding="utf-8") as f:
        f.write("\n".join(lignes) + "\n")

    return ram, cpu


def creer_environnement() -> None:
    vagrant_cmd = str(VAGRANT_DEFAULT) if VAGRANT_DEFAULT.exists() else (shutil.which("vagrant") or "vagrant")

    afficher_banniere()
    print("Definition de l'environement\n")

    fileroute = input("Saisir le chemin de l environement : ").strip()
    dossier = input("Saisir le nom du dossier : ").strip()

    env_path = Path(fileroute) / dossier
    env_path.mkdir(parents=True, exist_ok=True)

    vagrantfile = env_path / "Vagrantfile"
    vagrantfile.write_text('Vagrant.configure("2") do |config|\n', encoding="utf-8")

    ram, cpu = "1024", "1"
    while True:
        ram, cpu = configurer_instance(vagrantfile)

        afficher_banniere()
        print("Voulez-vous ajouter une nouvelle instance ?")
        reponse = input("O/N : ").strip().upper()
        if reponse not in ("O", "Y"):
            break

    bloc_provider = [
        '  config.vm.provider "virtualbox" do |v|',
        f'   v.memory = "{ram}"',
        f"   v.cpus = {cpu}",
        "  end",
        "end",
    ]
    with vagrantfile.open("a", encoding="utf-8") as f:
        f.write("\n".join(bloc_provider) + "\n")

    afficher_banniere()
    print(f"Deplacez-vous dans le repertoire de votre projet : {env_path}")
    print("Lancez votre instance avec la commande : vagrant up")
    print("Connectez vous a celle-ci avec : vagrant ssh NomDeLaVM")

    # ========================================
    # INSTALLATION AUTOMATIQUE DES VM
    # ========================================
    print("\n------------------------------")
    print("- INSTALLATION DES INSTANCES -")
    print("------------------------------\n")

    init = input("Voulez-vous initialiser les instances Vagrant ? [O/N] : ").strip().upper()
    if init == "N":
        return
    if init not in ("O", "Y"):
        print("Choix invalide.")
        return

    print(f"\nRepertoire actuel : {env_path}\n")
    print("Lancement de Vagrant...\n")

    resultat = subprocess.run([vagrant_cmd, "up"], cwd=env_path, check=False)
    if resultat.returncode != 0:
        print("\nUne erreur est survenue lors de l'initialisation.")
        return

    print("\n------------------------------")
    print("- INITIALISATION TERMINEE -")
    print("------------------------------\n")

    # ========================================
    # DEMANDE DE CONNEXION SSH
    # ========================================
    connexion = input("Voulez-vous vous connecter a une VM ? [O/N] : ").strip().upper()
    if connexion == "N":
        return
    if connexion not in ("O", "Y"):
        print("Choix invalide.")
        return

    print("\nInstances disponibles :\n")
    subprocess.run([vagrant_cmd, "status"], cwd=env_path, check=False)

    print()
    vm_name = input("Nom de la VM : ").strip()
    if vm_name:
        subprocess.run([vagrant_cmd, "ssh", vm_name], cwd=env_path, check=False)


def menu_principal() -> None:
    if os.name == "nt":
        os.environ["PATH"] = (
            r"C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem;C:\Program Files\Vagrant\bin;"
            + os.environ.get("PATH", "")
        )
        os.environ["ComSpec"] = r"C:\Windows\System32\cmd.exe"

    vagrant_cmd = str(VAGRANT_DEFAULT) if VAGRANT_DEFAULT.exists() else (shutil.which("vagrant") or "vagrant")

    while True:
        afficher_banniere("v2")
        print("[1] Creer une nouvelle instance")
        print("[2] Demarrer une instance (dev)")
        print("[3] Supprimer une instance (dev)\n")

        subprocess.run([vagrant_cmd, "--version"], check=False)
        choix = input("Choix : ").strip()
        if choix == "1":
            creer_environnement()
            break
        elif choix in ("2", "3"):
            continue


if __name__ == "__main__":
    try:
        menu_principal()
    except KeyboardInterrupt:
        print("\nOperation annulee.")
    except Exception as e:
        print(f"\n[!] Erreur inattendue : {e}")
    finally:
        input("\nAppuyez sur Entree pour quitter...")