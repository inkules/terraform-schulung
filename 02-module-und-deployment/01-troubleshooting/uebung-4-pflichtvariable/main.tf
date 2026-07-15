resource "local_file" "status" {
  filename = "${path.module}/status.txt"
  content  = var.content
}
