resource "aws_iam_instance_profile" "Collector" {
  name = "snowplow-collector-profile"
  role = "${aws_iam_role.Collector.name}"
}

resource "aws_iam_instance_profile" "Enrich" {
  name = "snowplow-enrich-profile"
  role = "${aws_iam_role.Enrich.name}"
}

resource "aws_iam_role" "Collector" {
  name = "snowplow-collector"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "CollectorPolicy" {
  name = "snowplow-collector-policy"
  role = "${aws_iam_role.Collector.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:PutRecord",
                "kinesis:PutRecords"
            ],
            "Resource": [
                "${aws_kinesis_stream.CollectorGood.arn}"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_role" "Enrich" {
  name = "snowplow-enrich"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "EnrichPolicy" {
  name = "snowplow-enrich-policy"
  role = "${aws_iam_role.Enrich.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:ListStreams",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords"
            ],
            "Resource": [
                "${aws_kinesis_stream.CollectorGood.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:*"
            ],
            "Resource": [
                "${aws_dynamodb_table.EnrichInRead.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:PutRecord",
                "kinesis:PutRecords"
            ],
            "Resource": [
                "${aws_kinesis_stream.EnrichGood.arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "SinkFirehose" {
  name = "snowplow-sink-firehose"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}



resource "aws_iam_role_policy" "SinkFirehosePolicy" {
  name = "snowplow-sink-firehose-policy"
  role = "${aws_iam_role.SinkFirehose.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "redshift:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "${aws_s3_bucket.SnowplowSink.arn}"
            ]
        }
    ]
}
EOF
}
