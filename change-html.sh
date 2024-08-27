#!/bin/bash
CLOUDFRONT_URL=$(aws cloudfront list-distributions --query "DistributionList.Items[*].{DomainName:DomainName}" --output text)
sudo sed -i "s|https:///itsworking.jpeg|https://${CLOUDFRONT_URL}/itsworking.jpeg|g" /var/www/html/index.html
sudo systemctl restart nginx.service