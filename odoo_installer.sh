#!/bin/bash

# Define variables correctly
projname="odooV14sample2"
python_version="python3"
db_port=5432
db_password="digipg@dm1n"
xmlrpc_port=1234
postgresql="postgresql-10"

# Update system packages
sudo apt update && sudo apt-get dist-upgrade -y

# Ensure the user and group for the project exist
if ! id -u $projname >/dev/null 2>&1; then
    sudo useradd -m -d /opt/$projname -s /bin/bash $projname
fi

# Clone Odoo repository
sudo mkdir -p /opt/$projname
sudo chown $projname:$projname /opt/$projname
sudo -u $projname git clone https://www.github.com/odoo/odoo --depth 1 --branch 14.0 /opt/$projname/$projname
cd /opt/$projname

# Create virtual environment and activate it
sudo -u $projname $python_version -m venv $projname-venv
source $projname-venv/bin/activate

# Install Python dependencies
pip install wheel
pip install -r /opt/$projname/$projname/requirements.txt
pip install Babel decorator docutils ebaysdk feedparser gevent greenlet html2text Jinja2 lxml Mako MarkupSafe mock num2words ofxparse passlib Pillow psutil psycopg2 pydot pyparsing PyPDF2 pyserial python-dateutil python-openid pytz pyusb PyYAML qrcode reportlab requests six suds-jurko vatnumber vobject Werkzeug XlsxWriter xlwt xlrd gdata

# Deactivate virtual environment
deactivate

# Create log directory and set ownership
sudo mkdir -p /var/log/$projname
sudo chown -R $projname:$projname /var/log/$projname

# Create Odoo configuration file
sudo tee /etc/$projname.conf > /dev/null << EOF
[options]
admin_passwd = admin
db_host = localhost
db_port = $db_port
db_user = $projname
db_password = $db_password
logfile = /var/log/$projname/$projname-server.log
addons_path = /opt/$projname/$projname/addons
xmlrpc_port = $xmlrpc_port
log_db = True
log_db_level = warning
log_handler = :INFO
log_level = info
EOF

# Create systemd service file
sudo tee /etc/systemd/system/$projname.service > /dev/null << EOF
[Unit]
Description=$projname Odoo Version 14.0
Requires=$postgresql.service 
After=network.target $postgresql.service 

[Service]
Type=simple
SyslogIdentifier=$projname
PermissionsStartOnly=true
User=$projname
Group=$projname
ExecStart=/opt/$projname/$projname-venv/bin/python3 /opt/$projname/$projname/odoo-bin -c /etc/$projname.conf --logfile /var/log/$projname/$projname-server.log
StandardOutput=journal+console
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon and start Odoo service
sudo systemctl daemon-reload
sudo systemctl start $projname
sudo systemctl restart $projname

# Check status of Odoo service
sudo systemctl status $projname

# Enable Odoo service to start on boot
sudo systemctl enable $projname

