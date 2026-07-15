variable "filename" {
  description = "Name der Datei, die erstellt wird"
  type        = string
  default     = "output.txt"
}

variable "content" {
  description = "Inhalt der Datei"
  type        = string
  default     = "Hallo aus der Standard-Konfiguration!"
}
