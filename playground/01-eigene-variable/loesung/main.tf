resource "local_file" "notiz" {
  filename = "${path.module}/notiz.txt"
  content  = "Diese Notiz wurde erstellt von ${var.autor}."
}
