# terratest-playground

To test locally, given you have installed Go already:
* Clone repo

* To configure dependencies, run:

```go mod init "<MODULE_NAME>"```

```go mod tidy```

Where <MODULE_NAME> is the name of your module, typically in the format github.com/<YOUR_USERNAME>/<YOUR_REPO_NAME>.

* To run the tests:

 ```go test -v -timeout 30m```
 
 To test the workflow in github actions, you'll have to add the AWS credentials in Github secrets.
