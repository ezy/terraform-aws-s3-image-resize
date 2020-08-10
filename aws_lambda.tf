resource "aws_lambda_function" "img_resize" {
  function_name    = "img_resize_${substr(md5(var.search_bucket), 0, 5)}_${substr(md5(var.config), 0, 5)}_tf"
  role             = aws_iam_role.iam_img_resize_role.arn
  handler          = "index.handler"
  filename         = data.archive_file.img_resize_zip.output_path
  source_code_hash = data.archive_file.img_resize_zip.output_base64sha256
  runtime          = "nodejs12.x"
  timeout          = "60"
  layers           = var.image_magick_layers
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.img_resize.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.search_bucket}"
}
