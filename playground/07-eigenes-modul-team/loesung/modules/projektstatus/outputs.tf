output "pfad" {
  description = "Pfad zur erzeugten Statusdatei"
  value       = local_file.status.filename
}
