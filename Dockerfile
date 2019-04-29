#
# Builder container
#
FROM maven:3.6.0-jdk-8-alpine as builder

WORKDIR /tmp

RUN wget https://raw.githubusercontent.com/soabase/exhibitor/exhibitor-1.7.1/exhibitor-standalone/src/main/resources/buildscripts/standalone/maven/pom.xml
RUN mvn clean generate-sources package

WORKDIR /tmp/target
RUN rm -f original-*.jar && mv ./*.jar app.jar


#
# Runtime container
#
FROM java:openjdk-8-alpine

# Run as user app:app
RUN addgroup -g 2222 app && adduser -D -G app -s /bin/bash -u 2222 app

# Switch to user app
USER app
WORKDIR /app
COPY --from=builder /tmp/target/app.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar","-c","zookeeper","--zkconfigconnect","localhost:2181","--zkconfigzpath","/exhibitor/config"]
