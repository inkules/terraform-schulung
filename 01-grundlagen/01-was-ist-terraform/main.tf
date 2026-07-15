resource "local_file" "hello" {
  filename = "${path.module}/hello.txt"
  content  = "Hi, ich wurde von Terraform erstellt!"
}
