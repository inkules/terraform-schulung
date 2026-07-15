variable "name" {
  description = "Name der Umgebung/App-Instanz"
  type        = string
}

variable "sku" {
  description = "SKU der App"
  type        = string
}

variable "instance_count" {
  description = "Anzahl Instanzen"
  type        = number
  default     = 1
}

variable "output_dir" {
  description = "Ordner, in dem die Konfigurationsdatei erstellt wird"
  type        = string
}
