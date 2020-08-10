variable "search_bucket" {}
variable "config" {}
variable "image_magick_layers" {
  type = list(string)
}

output "resize_function" {
  value = "${aws_lambda_function.img_resize.arn}"
}
