resource "aws_iam_role" "iam_img_resize_role" {
  name               = "iam_img_resize_${substr(md5(var.search_bucket), 0, 5)}_${substr(md5(var.config), 0, 5)}_tf"
  assume_role_policy = file("${path.module}/policy/lambda_role.json")
}

resource "aws_iam_policy" "iam_img_resize_policy" {
  name   = "iam_img_resize_${substr(md5(var.search_bucket), 0, 5)}_${substr(md5(var.config), 0, 5)}_tf"
  policy = replace(file("${path.module}/policy/lambda_s3_policy.json"), "S3-BUCKET-NAME", "${var.search_bucket}")
}

resource "aws_iam_role_policy_attachment" "iam_img_resize_role-attach" {
  role       = aws_iam_role.iam_img_resize_role.name
  policy_arn = aws_iam_policy.iam_img_resize_policy.arn
}
