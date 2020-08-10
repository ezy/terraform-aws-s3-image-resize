resource "local_file" "config" {
  content  = var.config
  filename = "${path.module}/lambda/config.json"
}

data "archive_file" "img_resize_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/build/${md5(local_file.config.content)}.zip"
}
