FROM node:22-alpine
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 4444
CMD ["npm", "start"]
