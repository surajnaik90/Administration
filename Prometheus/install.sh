#On Ubuntu 20.04.5 LTS

#Update repositories
sudo apt update

mkdir prometheus

curl -# -O https://github.com/prometheus/prometheus/releases/download/v2.39.1/prometheus-2.39.1.linux-amd64.tar.gz

tar -xv prometheus-2.39.1.linux-amd64.tar.gz

mv prometheus-2.39.1.linux-amd64 prometheus

cd prometheus

