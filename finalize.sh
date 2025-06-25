#!/bin/bash

set -e

echo "🌌 Démarrage du script d'installation intelligent..."

read -rp "Voulez-vous débuter l'installation ? [O/N] " choice
if [[ ! $choice =~ ^[Oo]$ ]]; then
    echo "Installation annulée."
    exit 0
fi

# Fonction pour check et installer Flatpak si absent
install_flatpak() {
    if ! command -v flatpak &>/dev/null; then
        echo "📦 Flatpak non trouvé, installation en cours..."
        sudo apt update && sudo apt install -y flatpak
    else
        echo "✅ Flatpak déjà installé"
    fi
}

# Fonction pour installer Git si absent
install_git() {
    if ! command -v git &>/dev/null; then
        echo "📦 Git non trouvé, installation en cours..."
        sudo apt update && sudo apt install -y git
    else
        echo "✅ Git déjà installé"
    fi
}

# Fonction pour ajouter Flathub si absent
add_flathub() {
    if ! flatpak remotes | grep -q flathub; then
        echo "🛰️ Ajout du dépôt Flathub..."
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    else
        echo "✅ Flathub déjà configuré"
    fi
}

# Fonction pour installer Flatpak apps si manquantes
install_flatpak_apps() {
    apps=(
        "org.prismlauncher.PrismLauncher"
        "org.DolphinEmu.dolphin-emu"
        "org.citra_emu.citra"
        "org.vinegarhq.Sober"
    )
    for app in "${apps[@]}"; do
        if flatpak list | grep -q "$app"; then
            echo "✅ Flatpak $app déjà installé"
        else
            echo "⬇️ Installation de $app..."
            flatpak install -y flathub "$app"
        fi
    done
}

# Fonction pour installer les snaps si manquants
install_snap_apps() {
    snaps=(
        "opera"
        "spotify"
        "discord"
        "steam"
    )
    for snap_app in "${snaps[@]}"; do
        if snap list | grep -q "^$snap_app "; then
            echo "✅ Snap $snap_app déjà installé"
        else
            echo "⬇️ Installation Snap $snap_app..."
            sudo snap install "$snap_app"
        fi
    done
}

# Modifier GRUB timeout à -1 si nécessaire
set_grub_timeout() {
    grub_file="/etc/default/grub"
    if grep -q 'GRUB_TIMEOUT=-1' "$grub_file"; then
        echo "✅ Timeout GRUB déjà réglé à infini (-1)"
    else
        echo "⏳ Mise à jour du timeout GRUB à -1..."
        sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=-1/' "$grub_file"
        echo "🔄 Mise à jour de la configuration GRUB..."
        sudo update-grub
    fi
}

# Installer le thème GRUB si pas déjà fait
install_grub_theme() {
    theme_dir="/boot/grub/themes/Cipher"
    if [ -d "$theme_dir" ]; then
        echo "✅ Thème GRUB Cipher déjà installé"
    else
        echo "🎨 Installation du thème GRUB Cipher..."
        install_git  # Installer git si nécessaire
        git clone https://github.com/voidlhf/StarRailGrubThemes.git /tmp/StarRailGrubThemes
        sudo mkdir -p /boot/grub/themes
        sudo cp -r /tmp/StarRailGrubThemes/assets/themes/Cipher /boot/grub/themes/
        sudo sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/Cipher/theme.txt"|' /etc/default/grub
        sudo update-grub
        rm -rf /tmp/StarRailGrubThemes
    fi
}

# Afficher le wallpaper (à adapter si tu veux)
set_wallpaper() {
    wallpaper_path="$HOME/Images/wallpeper.jpg"
    if [ -f "$wallpaper_path" ]; then
        echo "🖼️ Wallpaper trouvé ici : $wallpaper_path"
        # Exemple pour GNOME :
        # gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper_path"
    else
        echo "⚠️ Wallpaper non trouvé dans $wallpaper_path"
    fi
}

# ----- EXECUTION -----
install_flatpak
install_git
add_flathub
install_flatpak_apps
install_snap_apps
set_grub_timeout
install_grub_theme
set_wallpaper

echo "🌟 Script terminé, enjoy ton setup !"
read -n 1 -s -r -p "Appuie sur une touche pour quitter..."
echo

