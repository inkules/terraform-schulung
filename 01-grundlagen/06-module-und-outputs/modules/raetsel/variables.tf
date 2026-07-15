variable "titel" {
  description = "Titel des Quiz"
  type        = string
}

variable "farbe" {
  description = "Akzentfarbe (CSS-Farbwert)"
  type        = string
  default     = "#5c3aa5"
}

variable "output_pfad" {
  description = "Pfad der erzeugten HTML-Datei"
  type        = string
}
