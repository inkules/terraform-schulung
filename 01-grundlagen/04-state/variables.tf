variable "api_key" {
  description = "Beispiel-Secret, um zu zeigen, dass sensible Werte trotzdem im Klartext im State landen"
  type        = string
  sensitive   = true
  default     = "supergeheimer-api-key-123"
}
