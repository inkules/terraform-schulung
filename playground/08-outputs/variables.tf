variable "server_name" {
  description = "Name des Servers, für den eine Konfigurationsdatei entsteht"
  type        = string
  default     = "web1"
}

variable "admin_passwort" {
  description = "Admin-Passwort - nur zu Übungszwecken hier als Default, nie in echt so machen"
  type        = string
  default     = "geheim123"
  sensitive   = true
}
