resource "aws_instance" "web_server" {
  count                       = 2
  ami                         = "ami-0e04bcbe83a83792e"
  instance_type               = "t2.micro"
  key_name                    = "tbc-lab"
  subnet_id                   = aws_subnet.public_subnets[count.index].id
  associate_public_ip_address = true

  provisioner "remote-exec" {
    inline = [
      "mkdir /home/ubuntu/scripts && sudo mkdir -p /var/www/html/ && mkdir ~/.aws && mkdir /home/ubuntu/workdir/"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./tbc-lab.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "index.html"
    destination = "/home/ubuntu/scripts/index.html"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./tbc-lab.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "eip_failover.sh"
    destination = "/home/ubuntu/scripts/eip_failover.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./tbc-lab.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "script-failover.py"
    destination = "/home/ubuntu/scripts/script-failover.py"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./tbc-lab.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "eip_failover.service"
    destination = "/home/ubuntu/scripts/eip_failover.service"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./tbc-lab.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "credentials"
    destination = "/home/ubuntu/.aws/credentials"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./tbc-lab.pem")
      host        = self.public_ip
    }
  }
  provisioner "file" {
    source      = "change-html.sh"
    destination = "/home/ubuntu/workdir/change-html.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./tbc-lab.pem")
      host        = self.public_ip
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo cp /home/ubuntu/scripts/eip_failover.sh /home/ubuntu/workdir/eip_failover.sh && sudo chmod +x /home/ubuntu/workdir/eip_failover.sh && sudo chmod +x /home/ubuntu/scripts/script-failover.py && sudo mv /home/ubuntu/scripts/script-failover.py /bin/failover && sudo cp /home/ubuntu/scripts/index.html /var/www/html/index.html"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./tbc-lab.pem")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "WebServer-${count.index + 1}"
  }

  user_data = <<-EOF
              #!/bin/bash
              sleep 20
              sudo apt-get update -y
              sudo apt-get install nginx -y
              sudo apt-get install pip -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              sudo systemctl daemon-reload
              sudo systemctl enable eip_failover.service --now
              sudo sed -i 's/Welcome!/Welcome Web server ${count.index + 1}/g' /var/www/html/index.html
              sudo snap install aws-cli --classic
              sudo chmod +x /home/ubuntu/workdir/change-html.sh
              pip install awscli --break-system-packages
              EOF

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  depends_on = [aws_subnet.public_subnets]

}