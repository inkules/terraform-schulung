variable "name" {
  description = "Name, der in der Begrüßung verwendet wird"
  type        = string
  default     = "Terraform"
}

variable "fun_facts" {
  description = "Liste von Fakten, die mit ausgegeben werden"
  type        = list(string)
  default = [
    "HCL steht für HashiCorp Configuration Language",
    "Terraform speichert seinen Zustand im State",
  ]
}
