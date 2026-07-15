output "erzeugte_datei" {
  description = "Pfad der erzeugten Konfigurationsdatei"
  value       = local_file.konfiguration.filename
}
