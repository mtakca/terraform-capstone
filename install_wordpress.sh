#!/bin/bash
dnf update -y
dnf install -y httpd php php-mysqlnd amazon-efs-utils jq

systemctl start httpd
systemctl enable httpd

# Mount EFS
mkdir -p /var/www/html
mount -t efs -o tls ${efs_id}:/ /var/www/html
echo "${efs_id}:/ /var/www/html efs _netdev,tls 0 0" >> /etc/fstab

# Fetch DB Password from Secrets Manager
DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${secret_arn} --query SecretString --output text --region ${region})

# Install WordPress only if not already installed (shared EFS)
if [ ! -f /var/www/html/wp-config.php ]; then
  cd /var/www/html
  wget https://wordpress.org/latest.tar.gz
  tar -xzf latest.tar.gz
  cp -r wordpress/* .
  rm -rf wordpress latest.tar.gz
  
  cp wp-config-sample.php wp-config.php
  sed -i "s/database_name_here/${db_name}/" wp-config.php
  sed -i "s/username_here/${db_user}/" wp-config.php
  sed -i "s/password_here/$DB_PASSWORD/" wp-config.php
  sed -i "s/localhost/${db_host}/" wp-config.php
fi

# Fix permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html
