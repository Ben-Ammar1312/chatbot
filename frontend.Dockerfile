FROM node:20-alpine AS build

WORKDIR /app

COPY chatbot_front/package*.json ./
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

COPY chatbot_front/ .
RUN npm run build

FROM nginx:1.27-alpine

COPY deployment/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/chatbotFront/browser/ /usr/share/nginx/html/
