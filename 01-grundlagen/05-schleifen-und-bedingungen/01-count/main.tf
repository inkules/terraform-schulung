resource "local_file" "log" {
  count = var.anzahl_logs

  filename = "${path.module}/output/log-${count.index}.txt"
  content  = "Log-Eintrag Nummer ${count.index}"
}
