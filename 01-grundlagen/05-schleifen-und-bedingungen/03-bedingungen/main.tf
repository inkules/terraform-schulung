resource "local_file" "backup" {
  count = var.erstelle_backup ? 1 : 0

  filename = "${path.module}/output/backup.txt"
  content  = "Backup-Datei"
}
