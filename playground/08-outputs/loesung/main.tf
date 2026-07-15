resource "local_file" "server_konfig" {
  filename = "${path.module}/output/${var.server_name}.txt"
  content  = "Server: ${var.server_name}\nStatus: aktiv"
}
