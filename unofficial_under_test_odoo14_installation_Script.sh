#!/bin/bash

#make sure you are in root mode in terminal
#sudo -i

# Update system packages
sudo apt update && sudo apt-get dist-upgrade -y



# Clone Odoo repository
git clone https://www.github.com/odoo/odoo --depth 1 --branch 14.0 /opt/odooV14/odooV14
cd /opt/odooV14

# Create virtual environment and activate it
python3 -m venv odooV14-venv
source odooV14-venv/bin/activate

# Install Python dependencies
pip3 install wheel
pip3 install -r /opt/odooV14/odooV14/requirements.txt
pip3 install Babel decorator docutils ebaysdk feedparser gevent greenlet html2text Jinja2 lxml Mako MarkupSafe mock num2words ofxparse passlib Pillow psutil psycopg2 pydot pyparsing PyPDF2 pyserial python-dateutil python-openid pytz pyusb PyYAML qrcode reportlab requests six suds-jurko vatnumber vobject Werkzeug XlsxWriter xlwt xlrd gdata

# Deactivate virtual environment and exit user session
deactivate
#exit

# Create log directory
sudo mkdir /var/log/odooV14
sudo chown -R odooV14: /var/log/odooV14

# Create Odoo configuration file
sudo tee /etc/odooV14.conf > /dev/null << EOF
[options]
admin_passwd = admin
db_host = localhost
db_port = 5432
db_user = odooV14
db_password = digipg@dm1n
pg_path = /opt/PostgreSQL/10/bin
logfile = /var/log/odooV14/odooV14-server.log
addons_path = /opt/odooV14/odooV14/addons,/opt/odooV14/odooV14/custom_apps,/opt/odooV14/odooV14/test_apps
xmlrpc_port = 1234
log_db = True
log_db_level = warning
log_handler = :INFO
log_level = info
EOF

# Create systemd service file
sudo tee /etc/systemd/system/odooV14.service > /dev/null << EOF

[Unit]
Description=odooV14 Briq Version 14.0.1 12/20/2020 Source Code
Requires=postgresql-10.service 
After=network.target postgresql-10.service 

[Service]
Type=simple
SyslogIdentifier=odooV14
PermissionsStartOnly=true
User=odooV14
Group=odooV14
ExecStart=/opt/odooV14/odooV14-venv/bin/python3 /opt/odooV14/odooV14/odoo-bin -c /etc/odooV14.conf --logfile /var/log/odooV14/odooV14-server.log
StandardOutput=journal+console
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon and start Odoo service
sudo systemctl daemon-reload
sudo systemctl start odooV14
sudo systemctl restart odooV14

# Check status of Odoo service
sudo systemctl status odooV14

# Enable Odoo service to start on boot
#sudo systemctl enable odooV14

