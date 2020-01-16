# Version node lts
FROM node:lts

# Dockerfile manager
LABEL maintainer="KYUNGMIN LIM <ljlm0402@naver.com>"

# Copy Project
COPY . /aws-ecs-depoly

# Update npm
RUN npm install -g npm

# Work to Project
WORKDIR /aws-ecs-depoly

# Install npm
RUN npm install

# Set process port
EXPOSE 3000

# Start process
CMD ["npm", "start"]
