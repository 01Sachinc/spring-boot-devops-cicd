# Build Stage (Optional but standard for multi-stage builds. Since Jenkins compiles JAR via Maven, we use standard JRE packaging for lightweight deployment)
FROM eclipse-temurin:21-jre-alpine

# Metadata describing the image
LABEL maintainer="Senior DevOps Engineer"
LABEL app="spring-boot-devops-cicd"
LABEL version="1.0"

# Set non-root user for enhanced container security
RUN addgroup -S devopsgroup && adduser -S devopsuser -G devopsgroup

# Set the working directory inside the container
WORKDIR /app

# Copy the generated JAR file from target directory into the container
# Wildcard handles versioning transparently
COPY target/spring-boot-devops-cicd-*.jar app.jar

# Change ownership of the application file to the non-root user
RUN chown devopsuser:devopsgroup /app/app.jar

# Switch to the non-root user
USER devopsuser

# Expose the application port mapped in requirements
EXPOSE 8085

# Define default environment variables for execution
ENV JAVA_OPTS="-Xms256m -Xmx512m"

# Command to execute the Spring Boot application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
