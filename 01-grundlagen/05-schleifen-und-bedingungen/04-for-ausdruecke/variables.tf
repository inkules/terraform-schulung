variable "umgebungen" {
  description = "Liste von Umgebungen"
  type        = set(string)
  default     = ["dev", "staging", "prod"]
}

variable "pizza_je_umgebung" {
  description = "Beispiel-Map: Pizzabelag je Umgebung"
  type        = map(string)
  default = {
    dev     = "Salami"
    staging = "Peperoni"
    prod    = "Margherita"
  }
}
