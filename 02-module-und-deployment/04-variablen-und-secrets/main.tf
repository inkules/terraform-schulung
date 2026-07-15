resource "local_file" "config" {
  filename = "${path.module}/output/${var.app_name}.txt"
  content  = "App: ${var.app_name}\nDB-Passwort: ${var.db_password}"
}
