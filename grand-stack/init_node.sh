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

echo "creating env file"

cat > .env << EOF
NODE_ENV    = development
SERVER_PORT = 3000
EOF

echo "Creating eslint config file"

cat > .eslintrc.json << EOF
{
    "env": {
        "commonjs": true,
        "es6": true,
        "node": true
    },
    "extends": [
        "google"
    ],
    "globals": {
        "Atomics": "readonly",
        "SharedArrayBuffer": "readonly"
    },
    "parserOptions": {
        "ecmaVersion": 2018
    },
    "rules": {
        "no-multi-spaces": 0,
        "no-mixed-spaces-and-tabs": 0,
        "no-tabs": "off",
        "brace-style": ["error", "allman", { "allowSingleLine": true }],
        "strict": 2,
        "indent": ["error", 4, {"VariableDeclarator":  4}],
        "key-spacing": [2, { "align": "colon" }],
        "camelcase": "off",
        "max-len": ["error", { "code": 200 }],
        "consistent-return": "off",
        "new-cap": "off",
        "guard-for-in": "off",
        "arrow-parens": "off",
        "require-jsdoc": ["error", {
            "require": {
                "FunctionDeclaration": true,
                "MethodDefinition": false,
                "ClassDeclaration": false,
                "ArrowFunctionExpression": false,
                "FunctionExpression": false
            }
        }]
    }
}
EOF

echo " Creating babel entry file"

cat > .babelrc << EOF
{
  "presets": [
    "@babel/preset-env"
  ]
}

EOF

echo "env file has been create"

cat > server.js << EOF
'use strict';
import cluster from 'cluster';
import app from './src/app';
import http from 'http';
import logger from './src/config/logger'
import dotenv from 'dotenv'

dotenv.config();

if (cluster.isMaster) {
    const numWorkers = require('os').cpus().length;

    logger.info('Master cluster setting up ' + numWorkers + ' workers...');

    for (let i = 0; i < numWorkers; i++) {
        cluster.fork();
    }

    cluster.on('online', worker => {
        logger.info('Worker ' + worker.process.pid + ' is online');
    });


    cluster.on('exit', (worker, code, signal) => {
        let timeRef = Date.now();
        logger.info('Worker ' + worker.process.pid + ' died with code: ' + code + ', and signal: ' + signal);
        logger.info('Starting a new worker');
        cluster.fork();
    });
} else {
    const normalizePort = val => {
        let port = parseInt(val, 10);

        if (isNaN(port)) {
            // named pipe
            return val;
        }

        if (port >= 0) {
            // port number
            return port;
        }

        return false;
    };

    const onError = error => {
        if (error.syscall !== "listen") {
            throw error;
        }
        const bind = typeof port === "string" ? "pipe " + port : "port " + port;
        switch (error.code) {
            case "EACCES":
                logger.error(bind + " requires elevated privileges");
                process.exit(1);
                break;
            case "EADDRINUSE":
                logger.error(bind + " is already in use");
                process.exit(1);
                break;
            default:
                throw error;
        }
    };

    const onListening = () => {
        const addr = server.address();
        const bind = typeof addr === "string" ? "pipe " + port : "port " + port;
    };

    const port = normalizePort(process.env.SERVER_PORT || 4000);

    app.set("port", port);

    const server = http.createServer(app);

    server.on('error', onError);
    server.on('listening', onListening);
    server.listen(port);
}
EOF

echo "Finished initializing package file"

