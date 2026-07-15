variable "projekt" {
  description = "Name des Projekts"
  type        = string
}

variable "status" {
  description = "Aktueller Status des Projekts"
  type        = string
}

variable "output_dir" {
  description = "Zielordner für die generierte Statusdatei"
  type        = string
}
