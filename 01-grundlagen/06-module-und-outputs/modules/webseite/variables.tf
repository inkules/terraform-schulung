variable "titel" {
  description = "Titel der Seite (erscheint als Überschrift und Browser-Tab-Titel)"
  type        = string
}

variable "tagline" {
  description = "Kurzer Untertitel unter dem Titel"
  type        = string
  default     = ""
}

variable "farbe" {
  description = "Hintergrundfarbe der Seite als CSS-Farbwert"
  type        = string
  default     = "#5c3aa5"
}

variable "links" {
  description = "Liste von Links, die auf der Seite angezeigt werden"
  type = list(object({
    label = string
    url   = string
  }))
  default = []
}

variable "output_dir" {
  description = "Ordner, in dem die HTML-Datei erstellt wird"
  type        = string
}
