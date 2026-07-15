# Kaputt: das Zielverzeichnis wird schreibgeschützt (0555 = read+execute,
# kein write) angelegt. terraform validate und terraform plan sehen davon
# nichts - beide fassen die Festplatte gar nicht an. Erst beim "apply", wenn
# Terraform tatsächlich schreiben will, schlägt es fehl.
resource "local_file" "status" {
  filename             = "${path.module}/gesperrt/status.txt"
  content              = "Hallo!"
  directory_permission = "0555"
}
