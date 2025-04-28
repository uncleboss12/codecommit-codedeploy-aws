#!/bin/bash
yum update -y
yum install python3 -y
pip3 install -r /home/ec2-user/python-app/requirements.txt
