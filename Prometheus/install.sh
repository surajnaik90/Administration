#On Ubuntu 20.04.5 LTS

#Update repositories
sudo apt update

mkdir prometheus

curl -# -O https://github.com/prometheus/prometheus/releases/download/v2.39.1/prometheus-2.39.1.linux-amd64.tar.gz

tar -xv prometheus-2.39.1.linux-amd64.tar.gz

mv prometheus-2.39.1.linux-amd64 prometheus

cd prometheus

#Create a user to run prometheus: Do no create a home directory, deny shell access to the user account
sudo useradd --no-create-home --shell /bin/false prometheus

#Create config files directory & application state directory
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
