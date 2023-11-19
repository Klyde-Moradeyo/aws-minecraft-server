set -e

docker build -t aws_lambda_img lambda/
docker run --name lambda_payload_builder aws_lambda_img
docker cp lambda_payload_builder:/app/lambda_function_payload.zip terraform/
docker stop lambda_payload_builder
docker rm lambda_payload_builder

cd terraform
terraform apply --auto-approve
cd ..