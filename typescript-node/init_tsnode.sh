#!/usr/bin/env bash

echo 'Initializing project now'

read -p "Project name: " name;

mkdir -p "~/${name}"

cd "${name}"

cat > package.json << EOF
{
  "name": "${name}",
  "version": "0.0.1",
  "main": "server.js",
  "author": "Taylor Gagne",
  "license": "MIT",
  "scripts": {
    "preinstall": "typesync || :",
    "start": "ts-node-dev src/index.ts"
  },
  "devDependencies": {
    "dotenv": "^8.2.0",
    "express": "^4.17.1",
  },
  "dependencies": {
    "@types/express": "^4.17.11",
    "@types/node": "^14.14.33",
    "@types/nodemon": "^1.19.0",
    "nodemon": "^2.0.7",
    "ts-node": "^9.1.1",
    "ts-node-dev": "^1.1.6",
    "typescript": "^4.2.3",
    "typesync": "^0.8.0"
  }
}
EOF

echo "Creating env file"

cat > .env << EOF
NODE_ENV = development
PORT = 3000
EOF

mkdir -p "src"

echo "Finished initializing project!"



