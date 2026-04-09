# Stage: check - kvalita kódu
FROM node:24-alpine AS check
WORKDIR /app
COPY typescript/tester/package*.json ./
RUN npm ci --only=dev
COPY typescript/tester/src/ ./src/
RUN npm run lint && npm run typecheck

# Stage: build - kompilácia testera
FROM node:24-alpine AS build
WORKDIR /app
COPY typescript/tester/package*.json ./
RUN npm ci
COPY typescript/tester/src/ ./src/
RUN npm run build

# Stage: runtime - Python interpret
FROM python:3.14-alpine AS runtime
WORKDIR /app
COPY python/int/src/ ./src/
COPY python/int/requirements.txt ./
RUN pip install -r requirements.txt
ENTRYPOINT ["python3", "src/solint.py"]

# Stage: test - tester
FROM build AS test
WORKDIR /app
COPY --from=runtime /app /python-int
ENTRYPOINT ["node", "dist/tester.js"]
