# TERRAFORM Style Guide

## Google Terraform Formatting Standards

- **Indentation:** Use 2 spaces for indentation. Do not use tabs.

- **Block Separation:** Separate resource, module, variable, and output blocks with a single blank line.

- **Argument Alignment:** Align equal signs for arguments within a block.

- **Quotes:** Use double quotes for all string values.

- **Naming Conventions:** Use `snake_case` for resource names, variables, outputs, and locals.

- **Resource Naming:** Prefix resource names with the resource type (e.g., `instance_web`, `bucket_logs`).

- **Variable Naming:** Use descriptive names, avoid abbreviations.

- **Ordering:** Order blocks as: provider, terraform, locals, variable, data, resource, module, output.

- **Comments:** Use `#` for comments. Place comments above the relevant block or line.

- **Lists and Maps:** For lists and maps, put each item on its own line if there are more than two items.

- **File Structure:** Use separate files for variables (`variables.tf`), outputs (`outputs.tf`), and main resources (`main.tf`).

- **Formatting Tool:** Always run `terraform fmt` before committing code.

**Example:**

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_instance" "instance_web" {
  name         = "web-instance"
  machine_type = "n1-standard-1"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = var.network
    access_config {}
  }
}
```
