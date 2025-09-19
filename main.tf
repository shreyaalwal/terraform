# main.tf - Archive-based directory transfer
# Create a zip archive of the directory
data "archive_file" "bunty_store" {
  type        = "zip"
  source_dir  = var.local_file_path
  output_path = "${var.local_file_path}.zip"
}

locals {
  connection_details = {
    type        = "ssh"
    host        = var.server_host
    user        = var.server_user
    private_key = file(var.ssh_private_key_path)
  }
}

# Transfer the zip file
resource "null_resource" "transfer_archive" {
  triggers = {
    archive_hash = data.archive_file.bunty_store.output_md5
  }

  connection {
    type        = local.connection_details.type
    host        = local.connection_details.host
    user        = local.connection_details.user
    private_key = local.connection_details.private_key
  }

  provisioner "file" {
    source      = data.archive_file.bunty_store.output_path
    destination = "/tmp/buntystore.zip"
  }

  # Extract and setup files
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -qq && sudo apt-get install -y -qq unzip",
      "cd /tmp && unzip -q -o buntystore.zip",
      "sudo rm -rf /var/www/html/*",
      "sudo cp -r /tmp/* /var/www/html/ 2>/dev/null || true",
      "sudo chown -R www-data:www-data /var/www/html/",
      "sudo chmod -R 755 /var/www/html/",
      "rm -f /tmp/buntystore.zip",
      "sudo systemctl reload apache2 2>/dev/null || sudo systemctl reload nginx 2>/dev/null || true"
    ]
  }
}

# Outputs
output "transfer_status" {
  value = "Directory transfer completed successfully"
  depends_on = [null_resource.transfer_archive]
}

output "archive_hash" {
  value       = data.archive_file.bunty_store.output_md5
  description = "MD5 hash of the transferred archive"
  sensitive   = true
}