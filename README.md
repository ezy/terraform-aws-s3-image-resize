## Introduction

Image resize tool based on AWS Lambda.

- Resize and reduce images with customizable algorithms
- Detects when image is uploaded to S3 and resize it according to settings.
- Can be one click deployed and scaled with terraform

### Credits

Originally forked from https://github.com/maxmode/image-autoresize-terraform

## Usage

### Preconditions

1. Generate Access key and Access token for your AWS User
2. Setup arn:: layers for (graphicsmagick)[https://github.com/rpidanny/gm-lambda-layer] and (image-magick)[https://serverlessrepo.aws.amazon.com/applications/arn:aws:serverlessrepo:us-east-1:145266761615:applications~image-magick-lambda-layer]
3. Install `terraform`

### Include it as a module from github

Create file index.tf with your configuration:

```

provider "aws" {
  version = "~> 1.12"
  // Region "us-west-2" will establish Cloudfront <==> S3 integration faster
  region = "us-west-2"
  access_key = "XXXXXX"
  secret_key = "XXXXXX"
}
provider "archive" {}
provider "local" {}

module "images_gallery" {
  source = "github.com/ezy/image-autoresize-terraform?ref=master"
  image_magick_layers = [
    "arn:aws:lambda:us-west-2:XXXXXX:layer:graphicsmagick:2",
    "arn:aws:lambda:us-west-2:XXXXXX:layer:image-magick:1"
  ]
  search_bucket = "staging.pinn.app"

  config = <<EOF
{
  "bucket": "your_bucket_name",
  "reduce": {
    "directory": "output_dir/gallery",
    "suffix": "_r",
    "quality": "96"
  },
  "resizes": [
    {
      "size": "1500",
      "directory": "output_dir/gallery",
      "suffix": "_lg"
    }, {
      "size": "1200",
      "directory": "output_dir/gallery",
      "suffix": "_md"
    }, {
      "size": "640",
      "directory": "output_dir/gallery",
      "suffix": "_sm"
    }
  ]
}
EOF
}

resource "aws_s3_bucket_notification" "test_website_notification" {
  bucket = "your_bucket_name"

  lambda_function {
    lambda_function_arn = "${module.images_gallery.resize_function}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input_dir/gallery/"
    filter_suffix       = ".jpg"
  }
}

```

### Execute terraform

- Run `terraform init`
- Run `terraform apply`

### How to check?

Upload a picture to folder "input_dir/gallery" in your bucket.
After few seconds resized and reduced images should appear in folder "output_dir/gallery".

## Detailed configuration

### Sample JSON

For **module.config** variable:

```json
{
  "bucket": "your-destination-bucket",
  "backup": {
    "directory": "./original"
  },
  "reduce": {
    "directory": "./reduced",
    "prefix": "reduced-",
    "quality": 90,
    "acl": "public-read",
    "cacheControl": "public, max-age=31536000"
  },
  "resizes": [
    {
      "size": 300,
      "directory": "./resized/small",
      "prefix": "resized-",
      "cacheControl": null
    },
    {
      "size": 450,
      "directory": "./resized/medium",
      "suffix": "_medium"
    },
    {
      "size": "600x600^",
      "gravity": "Center",
      "crop": "600x600",
      "directory": "./resized/cropped-to-square"
    },
    {
      "size": 600,
      "directory": "./resized/600-jpeg",
      "format": "jpg",
      "background": "white"
    },
    {
      "size": 900,
      "directory": "./resized/large",
      "quality": 90
    }
  ]
}
```

### Configuration Parameters

|     name      |     field     |  type   | description                                                                                                                                      |
| :-----------: | :-----------: | :-----: | ------------------------------------------------------------------------------------------------------------------------------------------------ |
|    bucket     |       -       | String  | Destination bucket name at S3 to put processed image. If not supplied, it will use same bucket of event source.                                  |
| jpegOptimizer |       -       | String  | Determine optimiser that should be used `mozjpeg` (default) or `jpegoptim` ( only `JPG` ).                                                       |
|      acl      |       -       | String  | Permission of S3 object. [See AWS ACL documentation](http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html#putObject-property).         |
| cacheControl  |       -       | String  | Cache-Control of S3 object. If not specified, defaults to original image's Cache-Control.                                                        |
| keepExtension |       -       | Boolean | Global setting fo keeping original extension. If `true`, program keeps orignal file extension. otherwise use strict extension eg JPG,jpeg -> jpg |
|    backup     |       -       | Object  | Backup original file setting.                                                                                                                    |
|               |    bucket     | String  | Destination bucket to override. If not supplied, it will use `bucket` setting.                                                                   |
|               |   directory   | String  | Image directory path. Supports relative and absolute paths. Mode details in [DIRECTORY.md](doc/DIRECTORY.md/#directory)                          |
|               |   template    | Object  | Map representing pattern substitution pair. Mode details in [DIRECTORY.md](doc/DIRECTORY.md/#template)                                           |
|               |    prefix     | String  | Prepend filename prefix if supplied.                                                                                                             |
|               |    suffix     | String  | Append filename suffix if supplied.                                                                                                              |
|               |      acl      | String  | Permission of S3 object. [See AWS ACL documentation](http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html#putObject-property).         |
|               | cacheControl  | String  | Cache-Control of S3 object. If not specified, defaults to original image's Cache-Control.                                                        |
|               | keepExtension | Boolean | If `true`, program keeps orignal file extension. otherwise, use strict extension eg JPG,jpeg -> jpg                                              |
|               |     move      | Boolean | If `true`, an original uploaded file will delete from Bucket after completion.                                                                   |
|    reduce     |       -       | Object  | Reduce setting following fields.                                                                                                                 |
|               |    quality    | Number  | Determine reduced image quality ( only `JPG` ).                                                                                                  |
|               | jpegOptimizer | String  | Determine optimiser that should be used `mozjpeg` (default) or `jpegoptim` ( only `JPG` ).                                                       |
|               |    bucket     | String  | Destination bucket to override. If not supplied, it will use `bucket` setting.                                                                   |
|               |   directory   | String  | Image directory path. Supports relative and absolute paths. Mode details in [DIRECTORY.md](doc/DIRECTORY.md/#directory)                          |
|               |   template    | Object  | Map representing pattern substitution pair. Mode details in [DIRECTORY.md](doc/DIRECTORY.md/#template)                                           |
|               |    prefix     | String  | Prepend filename prefix if supplied.                                                                                                             |
|               |    suffix     | String  | Append filename suffix if supplied.                                                                                                              |
|               |      acl      | String  | Permission of S3 object. [See AWS ACL documentation](http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html#putObject-property).         |
|               | cacheControl  | String  | Cache-Control of S3 object. If not specified, defaults to original image's Cache-Control.                                                        |
|               | keepExtension | Boolean | If `true`, program keeps orignal file extension. otherwise, use strict extension eg JPG,jpeg -> jpg                                              |
|    resize     |       -       |  Array  | Resize setting list of following fields.                                                                                                         |
|               |     size      | String  | Image dimensions. [See ImageMagick geometry documentation](http://imagemagick.org/script/command-line-processing.php#geometry).                  |
|               |    format     | String  | Image format override. If not supplied, it will leave the image in original format.                                                              |
|               |     crop      | String  | Dimensions to crop the image. [See ImageMagick crop documentation](http://imagemagick.org/script/command-line-options.php#crop).                 |
|               |    gravity    | String  | Changes how `size` and `crop`. [See ImageMagick gravity documentation](http://imagemagick.org/script/command-line-options.php#gravity).          |
|               |    quality    | Number  | Determine reduced image quality ( forces format `JPG` ).                                                                                         |
|               | jpegOptimizer | String  | Determine optimiser that should be used `mozjpeg` (default) or `jpegoptim` ( only `JPG` ).                                                       |
|               |  orientation  | Boolean | Auto orientation if value is `true`.                                                                                                             |
|               |    bucket     | String  | Destination bucket to override. If not supplied, it will use `bucket` setting.                                                                   |
|               |   directory   | String  | Image directory path. Supports relative and absolute paths. Mode details in [DIRECTORY.md](doc/DIRECTORY.md/#directory)                          |
|               |   template    | Object  | Map representing pattern substitution pair. Mode details in [DIRECTORY.md](doc/DIRECTORY.md/#template)                                           |
|               |    prefix     | String  | Prepend filename prefix if supplied.                                                                                                             |
|               |    suffix     | String  | Append filename suffix if supplied.                                                                                                              |
|               |      acl      | String  | Permission of S3 object. [See AWS ACL documentation](http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html#putObject-property).         |
|               | cacheControl  | String  | Cache-Control of S3 object. If not specified, defaults to original image's Cache-Control.                                                        |
|               | keepExtension | Boolean | If `true`, program keeps orignal file extension. otherwise, use strict extension eg JPG,jpeg -> jpg                                              |
|  optimizers   |       -       | Object  | Definitions for override the each Optimizers command arguments.                                                                                  |
|               |   pngquant    |  Array  | `Pngquant` command arguments. Default is `["--speed=1", "256"]`.                                                                                 |
|               |   jpegoptim   |  Array  | `Jpegoptim` command arguments. Default is `["-s", "--all-progressive"]`.                                                                         |
|               |    mozjpeg    |  Array  | `Mozjpeg` command arguments. Default is `["-optimize", "-progressive"]`.                                                                         |
|               |   gifsicle    |  Array  | `Gifsicle` command arguments. Default is `["--optimize"]`.                                                                                       |

Note that the `optmizers` option will **force** override its command arguments, so if you define these configurations, we don't care any more about how optimizer works.

## Scalability

Need multiple image configurations per project/per bucket?
Just include terraform module multiple times with different names.
And add extra block lambda_function{} in aws_s3_bucket_notification
for every resizer module.

## Credits

Based on:

- https://github.com/ysugimoto/aws-lambda-image
