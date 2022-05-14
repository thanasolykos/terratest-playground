package test

import (
	"crypto/tls"
	"fmt"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformFlugelTest1Example(t *testing.T) {
	t.Parallel()

	//awsRegion := "us-east-2"
	expectedName := "Flugel"
	expectedOwner := "InfraTeam"

	// Set up expected values to be checked later
	//expectedTags := map[string]string{
	//	"Name":  "Flugel",
	//	"Owner": "InfraTeam",
	//}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "examples/test_terraform_flugel_test2_example",

		// Variables   to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"tag_name":  expectedName,
			"tag_owner": expectedOwner,
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	//defer terraform.Destroy(t, terraformOptions)

	//terraform.InitAndApply(t, terraformOptions)

	//bucketID := terraform.Output(t, terraformOptions, "bucket_id")
	//instanceID := terraform.Output(t, terraformOptions, "instance_id")

	//actualS3BucketTags := aws.GetS3BucketTags(t, awsRegion, bucketID)
	//actualEC2InstanceTags := aws.GetTagsForEc2Instance(t, awsRegion, instanceID)
	//assert.Equal(t, expectedTags, actualS3BucketTags)
	//assert.Equal(t, expectedTags, actualEC2InstanceTags)

	// Specify the text the EC2 Instance will return when we make HTTP requests to it.
	instanceText := fmt.Sprintf("{\"Name\" : %s, \"Owner\" : %s}", expectedName, expectedOwner)

	// Run `terraform output` to get the value of an output variable
	instanceURL := terraform.Output(t, terraformOptions, "alb_url")

	// Setup a TLS configuration to submit with the helper, a blank struct is acceptable
	tlsConfig := tls.Config{}

	// It can take a minute or so for the Instance to boot up, so retry a few times
	maxRetries := 30
	timeBetweenRetries := 5 * time.Second

	// Verify that we get back a 200 OK with the expected instanceText
	http_helper.HttpGetWithRetry(t, instanceURL, &tlsConfig, 200, instanceText, maxRetries, timeBetweenRetries)

}
