FROM alpine
RUN apk add chromium
ADD binary-dist/main-alpine .
ADD .env .
RUN ls	
RUN chmod +x main-alpine
ADD ca.crt .
RUN export NODE_EXTRA_CA_CERTS=ca.crt
