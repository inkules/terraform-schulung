# module.webapp ist wegen for_each eine Map aus Modul-Instanzen (ein Eintrag
# pro Umgebung), kein einzelnes Modul mehr. Zugriff über module.webapp["dev"]
# bzw. hier per for-Ausdruck über alle Instanzen hinweg.
output "config_pfade" {
  description = "Pfad der Konfigurationsdatei je Umgebung"
  value       = { for umgebung, instanz in module.webapp : umgebung => instanz.config_path }
}
