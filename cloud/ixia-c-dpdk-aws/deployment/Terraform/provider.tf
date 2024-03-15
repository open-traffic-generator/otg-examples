provider "aws" {
	region = var.Region
	max_retries = var.ApiMaxRetries
}