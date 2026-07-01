By default, the dev environment uses local state.

To use S3:
1. Copy backend-examples/s3-backend.tf.example to environments/dev/backend.tf
2. Adjust bucket/key/region
3. Run terraform init -migrate-state

To use HCP:
1. Copy backend-examples/hcp-backend.tf.example to environments/dev/backend.tf
2. Adjust organization/workspace
3. Run terraform login
4. Run terraform init -migrate-state
