# Verzögert den Apply künstlich um ein paar Sekunden, damit in einem zweiten
# Terminal genug Zeit bleibt, den State Lock live zu beobachten.
resource "time_sleep" "wait" {
  create_duration = "15s"
}

resource "local_file" "example" {
  filename   = "${path.module}/example.txt"
  content    = "Dieser Inhalt landet im State."
  depends_on = [time_sleep.wait]
}

# var.api_key ist als sensitive markiert. Terraform blendet den Wert deshalb
# in der Konsolenausgabe von plan/apply aus - in der terraform.tfstate-Datei
# steht er trotzdem im Klartext.
resource "local_file" "secret_config" {
  filename = "${path.module}/secret_config.txt"
  content  = "api_key=${var.api_key}"
}

output "api_key" {
  description = "Als sensitive markiert - taucht in 'terraform output' nicht im Klartext auf"
  value       = var.api_key
  sensitive   = true
}
