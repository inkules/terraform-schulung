resource "local_file" "debug" {
  count    = var.produktion ? 0 : 1
  filename = "${path.module}/debug.txt"
  content  = "Debug-Modus aktiv"
}
