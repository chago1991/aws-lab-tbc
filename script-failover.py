#!/usr/bin/env python3

import os
import argparse


instance1 = "i-0f2648a12ef28c23f" 
instance2 = "i-0d38416edef75b294"


fip = "18.184.144.210"


assign_fip_instance1 = "aws ec2 associate-address --instance-id %s --public-ip %s --allow-reassociation" % (instance1, fip)
assign_fip_instance2 = "aws ec2 associate-address --instance-id %s --public-ip %s --allow-reassociation" % (instance2, fip)

def setup_fallback_instance():
    """Move Elastic IP to the secondary instance"""
    os.system(assign_fip_instance2)

def setup_main_instance():
    """Move Elastic IP back to the primary instance"""
    os.system(assign_fip_instance1)

if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser(description="AWS Failover Tool")
    ap.add_argument("--main", help="Move to main node", action="store_true", default=False)
    ap.add_argument("--fallback", help="Move to fallback node", action="store_true", default=False)
    args = vars(ap.parse_args())
    if args["fallback"]:
        setup_fallback_instance()
    if args["main"]:
        setup_main_instance()