resource "local_file" "status" {
  count    = var.anzahl
  filename = "${path.module}/status-${count.index}.txt"
  content  = "Hallo!"
}
