# Aufgabe 8: Outputs

**Thema:** Output-Blöcke - ein normaler und ein sensitiver (siehe [Module und Outputs](../../01-grundlagen/06-module-und-outputs/00-module-und-outputs.md) und [Der Terraform State](../../01-grundlagen/04-state/00-state.md))

`main.tf` legt bereits eine Konfigurationsdatei für `var.server_name` an. `outputs.tf` existiert nur als Gerüst mit TODOs - eure Aufgabe: baut zwei Outputs.

**Anforderungen:**

1. `server_pfad` - der Pfad der generierten Datei, also `local_file.server_konfig.filename`.
2. `admin_zugang` - gibt `var.admin_passwort` zurück, markiert als `sensitive = true`. Ein Output-Block kann genau wie eine Variable `sensitive` sein.

## Testen

```bash
terraform init
terraform apply
```

`terraform apply` sollte `admin_zugang = <sensitive>` zeigen, `server_pfad` aber ganz normal.

Zum Ausprobieren - eine echte Terraform-Eigenart, die es wert ist, live gesehen zu werden:

```bash
terraform output                  # admin_zugang steht als <sensitive> da
terraform output admin_zugang     # zeigt den Wert direkt im Klartext!
```

`sensitive` blendet den Wert nur in der **Gesamtübersicht** aus - fragt ihr gezielt genau diesen einen Output ab, bekommt ihr ihn ganz normal zu sehen. Genau dieselbe Lektion wie beim `sensitive`-Flag bei Variablen (Kapitel 04): ein Sichtschutz, kein echter Schutz.

## Aufräumen

```bash
terraform destroy
```

Lösung liegt in [`loesung/`](loesung/), aber erst selbst versuchen!
