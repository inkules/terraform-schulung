output "config_path" {
  description = "Pfad zur erstellten Konfigurationsdatei"
  value       = local_file.app_config.filename
}
