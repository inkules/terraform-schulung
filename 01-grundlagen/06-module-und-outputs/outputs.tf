output "seite_pfad" {
  description = "Pfad zur generierten HTML-Seite - im Browser öffnen!"
  value       = module.seite.pfad
}

output "seite2_pfad" {
  description = "Pfad zur zweiten, unabhängigen Modul-Instanz"
  value       = module.seite2.pfad
}

output "raetsel_pfad" {
  description = "Pfad zum generierten Tag-1-Rätsel - im Browser öffnen!"
  value       = module.tag1_raetsel.pfad
}
