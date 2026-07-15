# Was ist Terraform?

Terraform ist ein Open-Source-Infrastructure-as-Code-Softwaretool. Entwickelt von HashiCorp, nimmt es den Usern das inkositente "Klick mir etwas" ab und ermöglicht es ihnen, Infrastruktur in einer deklarativen Konfigurationssprache zu definieren. Mit Terraform können Sie Cloud-Ressourcen wie virtuelle Maschinen, Netzwerke, Datenbanken und mehr erstellen, ändern und versionieren.


## Wie funktioniert Terraform?
Terraform verwendet eine deklarative Sprache namens HashiCorp Configuration Language (HCL), um die gewünschte Infrastruktur zu beschreiben. Anstatt Schritt für Schritt zu definieren, wie die Infrastruktur erstellt werden soll, beschreibt der Benutzer den gewünschten Endzustand. Terraform übernimmt dann die Aufgabe, die notwendigen Schritte zu ermitteln, welche nötig sind um den gweünschten Zustand zu erreichen.
Dies geschieht durch die erstellung eines Plans, welcher die Unterschiede zwischen dem aktuellen Zustand der Infrastruktur und dem gewünschten Zustand aufzeigt. Anschließend kann Terraform diesen Plan ausführen, um die Infrastruktur entsprechend anzupassen.
Dabei nutzt Terraform sogenannte "Provider", welche per API mit den jeweiligen Cloud-Anbietern oder anderen Services kommunizieren. Jeder Provider ist für eine bestimmte Plattform zuständig, wie z.B. AWS, Azure, Google Cloud, Kubernetes und viele mehr.

Terraform speichert den aktuellen Zustand der Infrastruktur in einer State-Datei, welche es ermöglicht Änderungen nachzuverfolgen und sicherzustellen, dass die Infrastruktur konsistent bleibt. Diese State-Datei kann lokal oder remote gespeichert werden, um Teamarbeit und Zusammenarbeit zu erleichtern.

## Vorteile von Terraform
- **Deklarative Konfiguration**: Benutzer definieren den gewünschten Zustand der Infrastruktur, und Terraform kümmert sich um die Umsetzung.
- **Plattformunabhängigkeit**: Terraform unterstützt eine Vielzahl von Cloud-Anbietern und Services, was es ermöglicht, Infrastruktur über verschiedene Plattformen hinweg zu verwalten.
- **Versionierung**: Änderungen an der Infrastruktur können versioniert werden, was eine einfache Rückverfolgbarkeit und Wiederherstellung ermöglicht.
- **Automatisierung**: Terraform ermöglicht die Automatisierung von Infrastrukturänderungen, wodurch menschliche Fehler reduziert und die Effizienz gesteigert werden.
- **Community und Ökosystem**: Terraform hat eine große und aktive Community, die eine Vielzahl von Modulen und Erweiterungen bereitstellt, um die Arbeit mit Terraform zu erleichtern.

## Infrasstructure as Code (IaC)
Infrastructure as Code (IaC) ist ein Ansatz zur Verwaltung und Bereitstellung von Infrastrukturressourcen durch maschinenlesbare Konfigurationsdateien. Anstatt manuell Server, Netzwerke oder andere Ressourcen zu konfigurieren, können Entwickler und Systemadministratoren die Infrastruktur in Codeform definieren. Dies ermöglicht eine konsistente, wiederholbare und versionierbare Bereitstellung von Infrastruktur.

## Selbst ausprobieren

Um den deklarativen Workflow (Plan zeigt Unterschied zum gewünschten Zustand, Apply setzt ihn um) einmal live zu sehen, ohne dafür einen Cloud-Account zu benötigen, liegt in diesem Ordner ein Mini-Beispiel. Es nutzt den `local`-Provider, der nur Dateien auf der eigenen Festplatte anlegt.

```bash
terraform init
terraform plan
terraform apply
```

Danach den Inhalt von `content` in `main.tf` ändern und `terraform plan` erneut ausführen - der Plan zeigt jetzt eine Änderung (`~`) statt einer Neuerstellung an.

