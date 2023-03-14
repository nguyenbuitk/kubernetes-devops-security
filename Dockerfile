FROM openjdk:8-jdk-alpine
EXPOSE 8080
ARG JAR_FILE=target/*.jar

# to pass OPA scan
RUN addgroup -S pipeline && adduser -S k8s-pipeline -G pipeline
COPY ${JAR_FILE} /home/k8s-pipeline/app.jar

USER k8s-pipeline
ENTRYPOINT ["java","-jar","/app.jar"]
