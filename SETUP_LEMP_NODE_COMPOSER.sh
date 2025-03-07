#!/bin/bash

# Function to handle errors
handle_error() {
    echo -e "\e[31mError: $1\e[0m" >&2
    exit 1
}

# Check root privilege
if [ "$(id -u)" -ne 0 ]; then
    handle_error "Please run this script with root privilege"
fi

# Add error handling
set -e

# Define colors
green='\033[0;32m'
plain='\033[0m'

# Update package list
sudo apt update
sudo apt install -y ufw curl nano

# Install Nginx
echo "Installing Nginx..."
sudo apt install -y nginx 
sudo ufw allow 'Nginx HTTPS'

# Install PHP 8.3 and necessary extensions
echo "Installing PHP 8.3 and necessary extensions..."
sudo apt update && sudo apt install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y php8.3 php8.3-common php8.3-fpm php8.3-cli php8.3-gd php8.3-bz2 php8.3-curl php8.3-mbstring php8.3-intl php8.3-xml php8.3-zip php8.3-soap

# Install Composer
echo "Installing Composer..."
sudo apt install -y unzip
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
HASH=`curl -sS https://composer.github.io/installer.sig`
php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('/tmp/composer-setup.php'); } echo PHP_EOL;"
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Install Node.js 20 and npm
echo "Installing Node.js 20 and npm..."
sudo apt install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update
sudo apt install -y nodejs
sudo apt install -y gcc g++ make

# Enable and start Nginx and PHP-FPM services
echo "Enabling and starting Nginx and PHP-FPM services..."
sudo systemctl enable nginx
sudo systemctl enable php8.3-fpm
sudo systemctl start nginx
sudo systemctl start php8.3-fpm

# Inform user about successful installation
echo -e "${green}LEMP stack with PHP 8.3, Nginx, Node.js 20, and Composer has been successfully installed.${plain}"
