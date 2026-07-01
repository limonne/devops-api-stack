resource "aws_instance" "web" {
  ami           = "ami-05cbf8a8aa4e4b755"
  instance_type = "t3.micro"
  region        = var.region
}
