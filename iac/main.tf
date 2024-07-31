provider "aws" { 



 region = "us-east-1"

}







variable "keyname" {



 type = string



}







terraform {



 backend "s3" {



   region = "us-east-1"



   bucket = "tfstate-nts4"



   dynamodb_table = "tlftable_nts4"   



   key = "japp.tfstate"



   



 }



}



















resource "nts4_private_key" "rsa" {



algorithm = "RSA"



rsa_bits = 4096



}







resource "aws_key_pair" "tf-key-pair" {



key_name = var.keyname



public_key = nts4_private_key.rsa.public_key_openssh



}







resource "local_file" "nts4-key" {



content = nts4_private_key_private_key.rsa.private_key_pem



filename = var.keyname



}











resource "aws_instance" "web-server-nts4" {



 ami      = "ami-0a0e5d9c7acc336f1"



 instance_type = "t2.micro"



 key_name   = var.keyname











 



 provisioner "remote-exec" {



   inline = [



  "sudo apt-get update",



        "sudo apt-get update",



        "sudo apt install -y tomcat9",



        "sudo chmod -R 777 /var/lib/tomcat9/webapps/",

        "sudo rm -rf /var/lib/tomcat9/webapps/ROOT"   



     



   ]



  }



    



 provisioner "file" {



  source   = "../target/jappnts4.war"



  destination = "/var/lib/tomcat9/webapps/ROOT.war"



 }



 connection {



  user    = "ubuntu"



  private_key = "${file(local_file.nts4-key.filename)}"



   host = "${aws_instance.web-server.public_ip}"



 }



}



output "pub_ip" {

  value = aws_instance.web-server.public_ip

}
