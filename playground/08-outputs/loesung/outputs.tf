output "server_pfad" {
  description = "Pfad der generierten Konfigurationsdatei"
  value       = local_file.server_konfig.filename
}

output "admin_zugang" {
  description = "Admin-Passwort - sensitive, wird in der Konsole ausgeblendet"
  value       = var.admin_passwort
  sensitive   = true
}
