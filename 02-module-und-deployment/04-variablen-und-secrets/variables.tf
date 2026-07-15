# Unkritischer Wert: sinnvoller Default ist völlig in Ordnung.
variable "app_name" {
  description = "Name der Anwendung, taucht im Dateinamen auf"
  type        = string
  default     = "meine-app"
}

# Secret: bewusst KEIN Default. Muss über TF_VAR_db_password gesetzt werden -
# siehe Abschnitt "Selbst ausprobieren" im zugehörigen Kapitel.
variable "db_password" {
  description = "Beispiel-Secret, das niemals ins Repo darf"
  type        = string
  sensitive   = true
}
