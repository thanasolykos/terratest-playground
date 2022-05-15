package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformFlugelTest1Example(t *testing.T) {
	t.Parallel()

	// Set up expected values to be checked later
	expectedName := "Flugel"
	expectedOwner := "InfraTeam"

	// Set up expected values to be checked later
	expectedTags := map[string]string{
		"Name":  "Flugel",
		"Owner": "InfraTeam",
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "examples/test_terraform_flugel_test1_example",

		// Variables   to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"tag_name":  expectedName,
			"tag_owner": expectedOwner,
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	bucketID := terraform.Output(t, terraformOptions, "bucket_id")
	instanceID := terraform.Output(t, terraformOptions, "instance_id")
	awsRegion := "us-east-2"

	actualS3BucketTags := aws.GetS3BucketTags(t, awsRegion, bucketID)

	actualEC2InstanceTags := aws.GetTagsForEc2Instance(t, awsRegion, instanceID)

	assert.Equal(t, expectedTags, actualS3BucketTags)
	assert.Equal(t, expectedTags, actualEC2InstanceTags)

}
