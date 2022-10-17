#On Ubuntu 20.04.5 LTS

#Update repositories
sudo apt update

mkdir -p prometheus

curl -LO https://github.com/prometheus/prometheus/releases/download/v2.39.1/prometheus-2.39.1.linux-amd64.tar.gz

#-f is necessary oherwise it won't read archive
tar -xvf prometheus-2.39.1.linux-amd64.tar.gz

mv prometheus-2.39.1.linux-amd64 prometheus

cd prometheus

#Create a user to run prometheus: Do no create a home directory, deny shell access to the user account
sudo useradd --no-create-home --shell /bin/false prometheus

#Create config files directory & application state directory
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

#Make prometheus user the owner of prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

//Copy binaries to ust/local/bindirectory
sudo cp prometheus/prometheus-2.39.1.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus/prometheus-2.39.1.linux-amd64/promtool /usr/local/bin/

#Make promeheus the owner of those directories
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool


#Copy config files to /etc directory
sudo cp -r prometheus/prometheus-2.39.1.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus/prometheus-2.39.1.linux-amd64/console_libraries /etc/prometheus

#Make prometheus the owner of those directories
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

#Copy the prometheus.yml to /etc directory
sudo cp prometheus.yml /etc/prometheus/prometheus.yml

#Change the ownership
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

#Copy the prometheus service file & update the ownership
sudo cp prometheus.service /etc/systemd/system/prometheus.service
sudo chown prometheus:prometheus /etc/systemd/system/prometheus.service

#Reload the systemd and start the prometheus service
sudo systemctl daemon-reload
sudo systemctl start prometheus

#Check the prometheus service
sudo systemctl status prometheus

#Access the prometheus service
#http://<prometheus-ip>:9090/graph
