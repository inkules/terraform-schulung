resource "local_file" "konfiguration" {
  filename = "${path.module}/output/${var.projekt_name}-${var.umgebung}.txt"
  content  = "Projekt: ${var.projekt_name}\nUmgebung: ${var.umgebung}"
}
