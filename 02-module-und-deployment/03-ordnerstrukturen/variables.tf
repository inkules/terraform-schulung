variable "projekt_name" {
  description = "Name des Projekts, taucht im Dateinamen und Inhalt auf"
  type        = string
  default     = "mein-projekt"
}

variable "umgebung" {
  description = "Umgebung, für die diese Konfiguration gilt"
  type        = string
  default     = "dev"
}
