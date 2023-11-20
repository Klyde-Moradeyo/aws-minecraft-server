set -e

docker build -t aws_lambda_img lambda/
docker run --name lambda_payload_builder aws_lambda_img
docker cp lambda_payload_builder:/app/lambda_function_payload.zip terraform/
docker stop lambda_payload_builder
docker rm lambda_payload_builder

cd terraform
terraform apply -var "git_branch=main" --auto-approve
cd ..


# docker build -f Dockerfile-2 -t myapp .
# docker run -d -v $(pwd):/app myapp 
# docker exec -it 52fd8df9a9d9637992312d69205426294f763ad2c2aff9b6aa206ad7cbf79324 /bin/bash

