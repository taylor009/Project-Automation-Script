#!/usr/bin/env bash
echo 'I am going to Initialize the project now'

read -p "Project name: " name;

cat > package.json << EOF
{
  "name": "${name}",
  "version": "0.0.1",
  "main": "server.js",
  "author": "Taylor Gagne",
  "license": "MIT",
  "scripts": {
    "dev": "nodemon --exec babel-node server.js",
    "test": "cross-env NODE_ENV=development mocha --watch --recursive 'test/**/*.test.js'",
    "coverage": "cross-env NODE_ENV=development nyc --reporter=text yarn test"
  },
  "nyc": {
    "all": true,
    "include": [
      "src/**/*.js"
    ],
    "exclude": [
      "**/*.test.js"
    ],
    "excludeNodeModules": false
  },
  "devDependencies": {

  },
  "dependencies": {

  }
}
EOF

echo "Finished initializing package file"

