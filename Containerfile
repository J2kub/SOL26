FROM node:24-alpine AS build
RUN apk add --no-cache python3 py3-pip python3-dev
WORKDIR /app
COPY typescript/tester/package*.json ./
RUN npm ci
COPY typescript/tester/src ./src
COPY typescript/tester/tsconfig.json ./
RUN npm run build

FROM python:3.14-alpine AS runtime
WORKDIR /int/src
COPY python/int/src ./
COPY python/int/requirements.txt ../
RUN pip install -r ../requirements.txt
ENV PYTHONPATH=/int/src

FROM build AS test
COPY --from=runtime /int /int
COPY sol2xml /sol2xml
ENV SOL2XML=/sol2xml/soltoxml.py
ENV PYTHONPATH=/int/src
RUN pip install --break-system-packages -r /int/requirements.txt
WORKDIR /app
ENTRYPOINT ["node", "dist/tester.js"]
