# Kaputt: default ist ein String, aber der Typ ist number.
variable "anzahl" {
  description = "Anzahl der Dateien"
  type        = number
  default     = "drei"
}
