#!/usr/bin/env bash

echo 'I am going to Initialize the project now'

read -p "Project name: " name;
version="0.0.1"
description=""
entryPoint="server.js"
gitRepo=""
author="Taylor Gagne"
license=""
private=""


/usr/bin/expect <<!
set timeout 1
spawn yarn init
expect "question name:"
send "$name\r"
expect "version:"
send "$version\r"
expect "description:"
send "$description\r"
expect "entry point:"
send "$entryPoint\r"
expect "git repository"
send "$gitRepo\r"
expect "author:"
send "$author\r"
expect "license:"
send "$license\r"
expect "private:"
send "$private\r"
expect eof
!

echo "Finished initializing package file"

echo "creating env file"

cat > .env << EOF
NODE_ENV    = development
SERVER_PORT = 3000
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
    logger.info();

    for (let i = 0; i < numWorkers; i++) {
        cluster.fork();
    }

    cluster.on('online', worker => {
        logger.info('Worker ' + worker.process.pid + ' is online');
    });


    cluster.on('exit', (worker, code, signal) => {
        let timeRef = Date.now();
        logger.info('Worker ' + worker.process.pid + ' died with code: ' + code + ', and signal: ' + signal);
        logger.error();
        logger.info('Starting a new worker');
        logger.info();
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
        logger.info();
    };

    const port = normalizePort(process.env.SERVER_PORT || 4000);

    app.set("port", port);

    const server = http.createServer(app);

    server.on('error', onError);
    server.on('listening', onListening);
    server.listen(port);
}
EOF

mkdir -p "src"

cd src/

echo $PWD

declare -a dirArr=("config" "controllers" "models" "routes" "services" "db")

for i in "${dirArr[@]}"
do
    mkdir "$i"
done

cat > app.js << EOF
'use strict';
import express from 'express';
import morgan from 'morgan';
import bodyParser from 'body-parser';
import logger from './config/logger';

const app = express();

app.use(morgan('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));

app.use('/', (req, res) => {
    res.send('Hello World');
});

export default app;
EOF

cd config/

declare -a fileArr=("config.js" "logger.js")

for i in "${fileArr[@]}"
do
    touch "$i"
done

echo "Finished added config files!"

echo "Adding some config code now"

cat > logger.js <<EOF
'use strict';
import winston from 'winston';
import config from './config';

const logger = winston.createLogger({
    transports: [
        new (winston.transports.Console)(config.LOGGER_CONFIG.CONSOLE),
        new (winston.transports.File)(config.LOGGER_CONFIG.APP_LOG_FILE),
        new (winston.transports.File)(config.LOGGER_CONFIG.ERROR_LOG_FILE),
    ],
});

if (process.env.NODE_ENV !== 'production')
{
    logger.add(new winston.transports.Console({
        format: winston.format.simple(),
    }));
}

export default logger;
EOF

cat > config.js <<EOF
'use strict';
import winston from 'winston';
import path from 'path';

const alignColorsAndTime = winston.format.combine(winston.format.colorize({
    all: true,
}), winston.format.label({
    label: '[LOGGER]',
}), winston.format.timestamp({
    format: 'YY-MM-DD HH:MM:SS',
}), winston.format.printf((info) => ` ${info.label}  ${info.timestamp}  ${info.level} : ${info.message}`));

const appTimeStamp = winston.format.combine(winston.format.timestamp({
    format: 'YY-MM-DD HH:MM:SS',
}), winston.format.printf((info) => `${info.timestamp}  ${info.level} : ${info.message}`));

const errorTimeStamp = winston.format.combine(winston.format.timestamp({
    format: 'YY-MM-DD HH:MM:SS',
}), winston.format.printf((error) => `${error.timestamp}  ${error.level} : ${error.message}`));


const config = {
    LOGGER_CONFIG: {
        APP_LOG_FILE: {
            level           : 'info',
            filename        : path.join('src/logs', 'app.log'),
            handleExceptions: true,
            json            : false,
            maxsize         : 5242880,
            maxFiles        : 5,
            format          : winston.format.combine(appTimeStamp),
        }, ERROR_LOG_FILE: {
            level           : 'error',
            filename        : path.join('src/logs', 'error.log'),
            handleExceptions: true,
            json            : true,
            maxsize         : 5242880,
            maxFiles        : 5,
            colorize        : true,
            format          : winston.format.combine(errorTimeStamp),
        }, CONSOLE: {
            level           : 'debug', handleExceptions: true, json            : false, format          : winston.format.combine(alignColorsAndTime),
        },
    },
};
EOF

#jsonScript= <<EOF
#    "scripts": {
#    "start": "nodemon --exec babel-node server.js"
#    },
#EOF
#
#sleep 10 jq -s add package.json "$jsonScript"

echo "Completed creating project structure..."

echo "Starting to install packages needed..."

yarn add @babel/core @babel/node @babel/preset-env nodemon --dev

yarn add express body-parser morgan dotenv apollo-server-express graphql graphql-tools winston

echo "Done Get to Work :)"