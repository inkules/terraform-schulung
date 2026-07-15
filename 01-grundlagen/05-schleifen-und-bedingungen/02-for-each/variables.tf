variable "umgebungen" {
  description = "Umgebungen, für die je eine Datei erstellt wird"
  type        = set(string)
  default     = ["dev", "staging", "prod"]
}

variable "pizza_je_umgebung" {
  description = "Beispiel-Map: Pizzabelag je Umgebung. \"prod\" hat absichtlich keinen Eintrag - zeigt den Fallback von lookup()."
  type        = map(string)
  default = {
    dev     = "Salami"
    staging = "Peperoni"
  }
}
